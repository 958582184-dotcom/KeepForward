extends Node

signal party_changed
signal rooms_changed
signal notice(text, color)
signal team_battle(result)

var is_host := false
var in_party := false
var local_id := 0
var leader_id := 1
var room_name := ""
var members: Array = []
var rooms: Array = []
var team_dungeon: Dictionary = {}

var _password := ""
var _pending_password := ""
var _pending_join := false
var _peer: ENetMultiplayerPeer
var _discovery_listener: PacketPeerUDP
var _discovery_sender: PacketPeerUDP
var _discovery_t := 0.0
var _room_last: Dictionary = {}
var _profile_dirty := false
var _profile_t := 0.0


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Game.stats_changed.connect(_on_local_changed)
	Game.equipment_changed.connect(_on_local_changed)
	_start_discovery_listener()
	set_process(true)


func _process(delta: float) -> void:
	_discovery_t += delta
	_profile_t += delta
	if in_party and _profile_t >= 1.0:
		_profile_t = 0.0
		if _profile_dirty:
			_profile_dirty = false
			_push_profile()
	if not in_party and _discovery_listener != null:
		_poll_discovery()
		_expire_rooms()
	if is_host and in_party and _discovery_t >= 1.5:
		_discovery_t = 0.0
		_broadcast_room()


# ---------- 房间 ----------

func create_room(name: String, password: String = "") -> bool:
	if in_party:
		leave_party()
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(Data.TEAM_PORT, 64)
	if err != OK:
		notice.emit("创建房间失败：端口 %d 被占用" % Data.TEAM_PORT, Color("#ff7b6e"))
		return false
	_peer = peer
	multiplayer.multiplayer_peer = peer
	is_host = true
	in_party = true
	local_id = 1
	leader_id = 1
	room_name = name.strip_edges() if name.strip_edges() != "" else "队长"
	_password = password
	team_dungeon = {}
	members.clear()
	var p: Dictionary = Game.profile_snapshot()
	p["id"] = 1
	p["position"] = 1
	p["is_leader"] = true
	members.append(p)
	_stop_discovery_listener()
	_start_discovery_sender()
	party_changed.emit()
	var local_ip := _local_ipv4()
	var ip_note := ("，本机 IP %s" % local_ip) if local_ip != "" else ""
	notice.emit("房间已创建：%s（端口 %d%s）" % [room_name, Data.TEAM_PORT, ip_note], Color("#63c76a"))
	return true


func join_room(ip: String, password: String = "") -> bool:
	if ip.strip_edges() == "":
		notice.emit("请输入房主 IP", Color("#ff7b6e"))
		return false
	if in_party:
		leave_party()
	_pending_password = password
	_pending_join = true
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip.strip_edges(), Data.TEAM_PORT)
	if err != OK:
		notice.emit("加入失败：%s" % err, Color("#ff7b6e"))
		return false
	_peer = peer
	multiplayer.multiplayer_peer = peer
	_stop_discovery_listener()
	notice.emit("正在连接 %s:%d …" % [ip.strip_edges(), Data.TEAM_PORT], Color("#c8d2df"))
	return true


func leave_party() -> void:
	if not in_party:
		return
	if is_host:
		rpc("rpc_disband", "房主已解散队伍")
	else:
		rpc_id(1, "rpc_request_leave")
	_close_network()
	notice.emit("已离开队伍", Color("#c8d2df"))


func _close_network() -> void:
	var was_host := is_host
	is_host = false
	in_party = false
	leader_id = 0
	members.clear()
	team_dungeon = {}
	_password = ""
	_pending_join = false
	if _peer != null:
		_peer.close()
		_peer = null
	multiplayer.multiplayer_peer = null
	_stop_discovery_sender()
	_start_discovery_listener()
	if was_host:
		room_name = ""
	party_changed.emit()


func disbanded(reason: String) -> void:
	if not in_party:
		return
	_close_network()
	notice.emit(reason, Color("#ff7b6e"))


func is_leader() -> bool:
	return is_host and in_party


func local_member() -> Dictionary:
	for m in members:
		if int(m.get("id", 0)) == local_id:
			return m
	return {}


func member_by_id(id: int) -> Dictionary:
	for m in members:
		if int(m.get("id", 0)) == id:
			return m
	return {}


func request_position(peer_id: int, pos: int) -> void:
	if not in_party or Game.busy:
		return
	if is_host:
		_apply_position(peer_id, pos)
	else:
		rpc_id(1, "rpc_request_position", peer_id, pos)


func host_start_team(d: Dictionary) -> void:
	if not is_host or not in_party or Game.busy:
		return
	if d.is_empty():
		notice.emit("请先选择副本", Color("#ff7b6e"))
		return
	team_dungeon = d.duplicate(true)
	Game.current_dungeon = d
	var result: Dictionary = TeamBattle.build(d, members, Game.rng, Game.level)
	rpc("rpc_team_start", result)
	team_battle.emit(result)


func on_team_battle_finished(win: bool) -> void:
	if not is_host or not in_party:
		return
	if not win:
		return
	if Game.auto_mode == "off":
		return
	await get_tree().create_timer(1.2 / maxf(0.25, Game.speed_mult)).timeout
	if not is_host or not in_party or Game.auto_mode == "off":
		return
	var d: Dictionary = Game.pick_auto_dungeon()
	if d.is_empty():
		return
	host_start_team(d)


# ---------- 位置 / 资料 ----------

func _apply_position(peer_id: int, pos: int) -> void:
	if members.is_empty():
		return
	var idx := -1
	for i in members.size():
		if int(members[i].get("id", 0)) == peer_id:
			idx = i
			break
	if idx < 0:
		return
	var m: Dictionary = members[idx]
	members.remove_at(idx)
	pos = clampi(pos, 1, members.size() + 1)
	members.insert(pos - 1, m)
	for i in members.size():
		members[i]["position"] = i + 1
	_broadcast_party()


func _on_local_changed() -> void:
	_profile_dirty = true


func _push_profile() -> void:
	if not in_party:
		return
	if is_host:
		_update_member(local_id, Game.profile_snapshot())
		_broadcast_party()
	else:
		rpc_id(1, "rpc_profile_update", Game.profile_snapshot())


func _update_member(id: int, profile: Dictionary) -> void:
	for i in members.size():
		if int(members[i].get("id", 0)) == id:
			var old: Dictionary = members[i]
			profile["id"] = id
			profile["position"] = int(old.get("position", i + 1))
			profile["is_leader"] = bool(old.get("is_leader", false))
			members[i] = profile
			return


func _broadcast_party() -> void:
	members.sort_custom(func(a, b): return int(a.get("position", 1)) < int(b.get("position", 1)))
	party_changed.emit()
	if is_host:
		rpc("rpc_party_state", members, room_name, leader_id)


func _sync_party_state(remote_members: Array, name: String, lead: int) -> void:
	members = remote_members
	room_name = name
	leader_id = lead
	party_changed.emit()


# ---------- RPC ----------

@rpc("any_peer", "call_remote", "reliable")
func rpc_request_join(password: String, profile: Dictionary) -> void:
	if not is_host:
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0:
		return
	if _password != "" and password != _password:
		rpc_id(sender, "rpc_join_result", false, "密码错误", [], room_name, leader_id)
		return
	profile["id"] = sender
	profile["position"] = members.size() + 1
	profile["is_leader"] = false
	members.append(profile)
	rpc_id(sender, "rpc_join_result", true, "", members, room_name, leader_id)
	_broadcast_party()
	notice.emit("%s 加入了队伍" % String(profile.get("name", "玩家")), Color("#63c76a"))


@rpc("authority", "call_remote", "reliable")
func rpc_join_result(ok: bool, reason: String, remote_members: Array, name: String, lead: int) -> void:
	if not ok:
		notice.emit("加入失败：%s" % reason, Color("#ff7b6e"))
		_close_network()
		return
	_pending_join = false
	in_party = true
	is_host = false
	local_id = multiplayer.get_unique_id()
	leader_id = lead
	members = remote_members
	room_name = name
	_stop_discovery_listener()
	party_changed.emit()
	notice.emit("已加入队伍：%s" % name, Color("#63c76a"))


@rpc("authority", "call_remote", "reliable")
func rpc_party_state(remote_members: Array, name: String, lead: int) -> void:
	_sync_party_state(remote_members, name, lead)


@rpc("authority", "call_remote", "reliable")
func rpc_disband(reason: String) -> void:
	disbanded(reason)


@rpc("any_peer", "call_remote", "reliable")
func rpc_request_leave() -> void:
	if not is_host:
		return
	var sender := multiplayer.get_remote_sender_id()
	for i in members.size():
		if int(members[i].get("id", 0)) == sender:
			var nm := String(members[i].get("name", "玩家"))
			members.remove_at(i)
			for j in members.size():
				members[j]["position"] = j + 1
			_broadcast_party()
			notice.emit("%s 离开了队伍" % nm, Color("#c8d2df"))
			return


@rpc("any_peer", "call_remote", "reliable")
func rpc_request_position(peer_id: int, pos: int) -> void:
	if is_host:
		_apply_position(peer_id, pos)


@rpc("any_peer", "call_remote", "reliable")
func rpc_profile_update(profile: Dictionary) -> void:
	if not is_host:
		return
	_update_member(multiplayer.get_remote_sender_id(), profile)
	_broadcast_party()


@rpc("authority", "call_remote", "reliable")
func rpc_team_start(result: Dictionary) -> void:
	team_dungeon = result.get("dungeon", {}).duplicate(true)
	Game.current_dungeon = team_dungeon
	team_battle.emit(result)


# ---------- 连接信号 ----------

func _on_connected_to_server() -> void:
	if not _pending_join:
		return
	if multiplayer.multiplayer_peer == null:
		return
	rpc_id(1, "rpc_request_join", _pending_password, Game.profile_snapshot())


func _on_connection_failed() -> void:
	_pending_join = false
	_close_network()
	notice.emit("连接失败，请检查 IP、防火墙和端口", Color("#ff7b6e"))


func _on_server_disconnected() -> void:
	if in_party and not is_host:
		disbanded("房主已断开，队伍解散")


func _on_peer_disconnected(id: int) -> void:
	if not is_host:
		return
	for i in members.size():
		if int(members[i].get("id", 0)) == id:
			var nm := String(members[i].get("name", "玩家"))
			members.remove_at(i)
			for j in members.size():
				members[j]["position"] = j + 1
			_broadcast_party()
			notice.emit("%s 掉线，已离开队伍" % nm, Color("#ff7b6e"))
			return


# ---------- 局域网发现 ----------

func _start_discovery_listener() -> void:
	if _discovery_listener != null:
		return
	var udp := PacketPeerUDP.new()
	var err := udp.bind(Data.TEAM_DISCOVERY_PORT, "0.0.0.0")
	if err != OK:
		return
	_discovery_listener = udp


func _stop_discovery_listener() -> void:
	if _discovery_listener != null:
		_discovery_listener.close()
		_discovery_listener = null
	rooms.clear()
	rooms_changed.emit()


func _start_discovery_sender() -> void:
	if _discovery_sender != null:
		return
	var udp := PacketPeerUDP.new()
	udp.set_broadcast_enabled(true)
	var err := udp.bind(0, "0.0.0.0")
	if err != OK:
		return
	udp.set_dest_address("255.255.255.255", Data.TEAM_DISCOVERY_PORT)
	_discovery_sender = udp


func _stop_discovery_sender() -> void:
	if _discovery_sender != null:
		_discovery_sender.close()
		_discovery_sender = null


func _broadcast_room() -> void:
	if _discovery_sender == null or not is_host:
		return
	var info := {
		"name": room_name,
		"players": members.size(),
		"has_password": _password != "",
		"version": Data.VERSION,
	}
	var packet := JSON.stringify(info).to_utf8_buffer()
	var targets := ["255.255.255.255"]
	for addr in IP.get_local_addresses():
		if not _is_ipv4(addr) or addr == "127.0.0.1" or addr.begins_with("169.254."):
			continue
		var parts := addr.split(".")
		var subnet := "%s.%s.%s.255" % [parts[0], parts[1], parts[2]]
		if not targets.has(subnet):
			targets.append(subnet)
	for target in targets:
		_discovery_sender.set_dest_address(target, Data.TEAM_DISCOVERY_PORT)
		_discovery_sender.put_packet(packet)


func _is_ipv4(addr: String) -> bool:
	var parts := addr.split(".")
	if parts.size() != 4:
		return false
	for p in parts:
		if not p.is_valid_int():
			return false
	return true


func _local_ipv4() -> String:
	for addr in IP.get_local_addresses():
		if _is_ipv4(addr) and addr != "127.0.0.1" and not addr.begins_with("169.254."):
			if addr.begins_with("192.168.") or addr.begins_with("10.") or addr.begins_with("172."):
				return addr
	return ""


func _poll_discovery() -> void:
	if _discovery_listener == null:
		return
	while _discovery_listener.get_available_packet_count() > 0:
		var data := _discovery_listener.get_packet()
		var ip := _discovery_listener.get_packet_ip()
		var obj: Variant = JSON.parse_string(data.get_string_from_utf8())
		if typeof(obj) != TYPE_DICTIONARY:
			continue
		var info: Dictionary = obj
		var key := "%s:%d" % [ip, Data.TEAM_PORT]
		info["ip"] = ip
		info["port"] = Data.TEAM_PORT
		info["key"] = key
		info["last_seen"] = Time.get_ticks_msec()
		var found := false
		for i in rooms.size():
			if String(rooms[i].get("key", "")) == key:
				rooms[i] = info
				found = true
				break
		if not found:
			rooms.append(info)
		rooms_changed.emit()


func _expire_rooms() -> void:
	if rooms.is_empty():
		return
	var now := Time.get_ticks_msec()
	var changed := false
	for i in range(rooms.size() - 1, -1, -1):
		if now - int(rooms[i].get("last_seen", 0)) > 5000:
			rooms.remove_at(i)
			changed = true
	if changed:
		rooms_changed.emit()


func refresh_rooms() -> void:
	rooms_changed.emit()
