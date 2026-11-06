class_name TeamWindow
extends BaseWindow

var _tip: ItemTooltip
var _inspect: PanelContainer
var _room_input: LineEdit
var _create_pass: LineEdit
var _manual_ip: LineEdit
var _join_pass: LineEdit


func _init() -> void:
	title = "组队"
	window_size = Vector2(620, 470)


func _after_build() -> void:
	_tip = ItemTooltip.new()
	_tip.z_index = 100
	add_child(_tip)
	Net.party_changed.connect(_on_net_changed)
	Net.rooms_changed.connect(_on_net_changed)


func _on_net_changed() -> void:
	if visible:
		refresh()


func _refresh_body(box: VBoxContainer) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	for c in _footer_left.get_children():
		_footer_left.remove_child(c)
		c.queue_free()
	if _tip != null:
		_tip.hide_tip()
	_hide_inspect()
	if Net.in_party:
		_build_party(box)
	else:
		_build_lobby(box)


func _build_lobby(box: VBoxContainer) -> void:
	var head := HBoxContainer.new()
	head.add_child(UiKit.label("局域网组队", 16, UiKit.COL_GOLD))
	head.add_child(UiKit.spacer())
	head.add_child(UiKit.label("端口 %d" % Data.TEAM_PORT, 11, UiKit.COL_MUTED))
	box.add_child(head)
	box.add_child(UiKit.hsep())

	var create := UiKit.panel(UiKit.COL_PANEL_2, UiKit.COL_BORDER_DIM, 1, 10)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 6)
	create.add_child(cv)
	cv.add_child(UiKit.label("创建队伍", 13, UiKit.COL_TEXT))
	_room_input = _line_edit("房间名", "")
	cv.add_child(_room_input)
	_create_pass = _line_edit("可选密码", "")
	cv.add_child(_create_pass)
	var create_btn := UiKit.button("创建房间并成为队长", 12)
	create_btn.pressed.connect(_on_create)
	cv.add_child(create_btn)
	box.add_child(create)

	box.add_child(UiKit.label("加入队伍", 13, UiKit.COL_TEXT))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 118)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 4)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	if Net.rooms.is_empty():
		list.add_child(UiKit.label("搜索中… 也可以手动输入房主 IP", 11, UiKit.COL_MUTED))
	else:
		for room in Net.rooms:
			list.add_child(_room_row(room))
	_manual_ip = _line_edit("手动 IP，例如 192.168.1.23", "")
	box.add_child(_manual_ip)
	_join_pass = _line_edit("密码（可选）", "")
	box.add_child(_join_pass)
	var join_btn := UiKit.button("加入", 12)
	join_btn.pressed.connect(_on_join_manual)
	box.add_child(join_btn)


func _build_party(box: VBoxContainer) -> void:
	var head := HBoxContainer.new()
	head.add_child(UiKit.label("队伍：%s" % Net.room_name, 16, UiKit.COL_GOLD))
	head.add_child(UiKit.spacer())
	head.add_child(UiKit.label("%d 人" % Net.members.size(), 11, UiKit.COL_MUTED))
	box.add_child(head)
	box.add_child(UiKit.hsep())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 190)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 5)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var sorted_members: Array = Net.members.duplicate()
	sorted_members.sort_custom(func(a, b): return int(a.get("position", 1)) < int(b.get("position", 1)))
	for m in sorted_members:
		list.add_child(_member_row(m))
	_build_position_bar(box, sorted_members)

	var leave := UiKit.button("离开队伍", 11)
	leave.add_theme_color_override("font_color", UiKit.COL_MUTED)
	leave.pressed.connect(func(): Net.leave_party())
	_footer_left.add_child(leave)


func _build_position_bar(box: VBoxContainer, sorted_members: Array) -> void:
	box.add_child(UiKit.hsep())
	var bar := UiKit.panel(UiKit.COL_PANEL_2, UiKit.COL_BORDER_DIM, 1, 6)
	box.add_child(bar)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	bar.add_child(v)
	var head := HBoxContainer.new()
	head.add_child(UiKit.label("站位", 11, UiKit.COL_MUTED))
	head.add_child(UiKit.label("后排", 9, UiKit.COL_DIM))
	head.add_child(UiKit.spacer())
	head.add_child(UiKit.label("前排", 9, UiKit.COL_DIM))
	v.add_child(head)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(0, 80)
	v.add_child(scroll)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 4)
	scroll.add_child(row)
	row.add_child(UiKit.spacer())
	for i in range(sorted_members.size() - 1, -1, -1):
		var av := PartyAvatar.new()
		av.setup(sorted_members[i])
		av.dropped.connect(_on_avatar_dropped)
		row.add_child(av)
	if sorted_members.is_empty():
		row.add_child(UiKit.label("暂无成员", 10, UiKit.COL_MUTED))


func _on_avatar_dropped(from_id: int, target_id: int) -> void:
	if Game.busy:
		return
	var target: Dictionary = Net.member_by_id(target_id)
	if target.is_empty():
		return
	Net.request_position(from_id, int(target.get("position", 1)))


func _member_row(m: Dictionary) -> PanelContainer:
	var is_leader := bool(m.get("is_leader", false))
	var col := UiKit.COL_GOLD if is_leader else UiKit.COL_BORDER_DIM
	var p := UiKit.panel(UiKit.COL_PANEL_2, col, 1, 8)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	p.add_child(row)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 0)
	info.add_child(UiKit.label("%s%s" % [String(m.get("name", "玩家")), " · 队长" if is_leader else ""], 13,
		UiKit.COL_GOLD if is_leader else UiKit.COL_TEXT))
	var stats: Dictionary = m.get("stats", {})
	info.add_child(UiKit.label("Lv.%d  HP %d  输出 %.0f" % [
		int(m.get("level", 1)), int(stats.get("hp_max", 1)), float(stats.get("dps", 0.0))],
		10, UiKit.COL_MUTED))
	row.add_child(info)
	var equip := UiKit.button("装备", 10)
	equip.pressed.connect(func(): _show_equipment(m))
	row.add_child(equip)
	return p


func _show_equipment(m: Dictionary) -> void:
	_hide_inspect()
	_inspect = UiKit.panel(UiKit.COL_PANEL, UiKit.COL_GOLD_DIM, 2, 12)
	_inspect.z_index = 50
	_inspect.position = Vector2(130, 85)
	_inspect.size = Vector2(360, 300)
	add_child(_inspect)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	_inspect.add_child(v)
	var head := HBoxContainer.new()
	head.add_child(UiKit.label("%s 的装备" % String(m.get("name", "玩家")), 14, UiKit.COL_GOLD))
	head.add_child(UiKit.spacer())
	var close := UiKit.button("×", 12)
	close.custom_minimum_size = Vector2(26, 24)
	close.pressed.connect(_hide_inspect)
	head.add_child(close)
	v.add_child(head)
	v.add_child(UiKit.hsep())
	var eq: Dictionary = m.get("equipment", {})
	var shown := 0
	for key in Data.EQUIP_ORDER:
		if eq.get(key) == null:
			continue
		var d: Dictionary = eq[key]
		var item := GameItem.from_dict(d)
		var b := UiKit.button("%s · %s" % [Data.SLOT_INFO.get(key, {}).get("name", key), item.item_name], 10)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_color_override("font_color", item.quality_color())
		var item_copy := item
		b.pressed.connect(func():
			_tip.show_item(item_copy, null, String(m.get("class_id", "warrior")), "", false)
			_tip.position = _inspect.position + Vector2(20, 30))
		b.mouse_entered.connect(func():
			_tip.show_item(item_copy, null, String(m.get("class_id", "warrior")), "", false)
			_tip.position = _inspect.position + Vector2(20, 30))
		b.mouse_exited.connect(func(): _tip.hide_tip())
		v.add_child(b)
		shown += 1
	if shown == 0:
		v.add_child(UiKit.label("没有装备", 11, UiKit.COL_MUTED))


func _hide_inspect() -> void:
	if _inspect != null:
		_inspect.queue_free()
		_inspect = null
	if _tip != null:
		_tip.hide_tip()


func _room_row(room: Dictionary) -> PanelContainer:
	var p := UiKit.panel(UiKit.COL_PANEL_2, UiKit.COL_BORDER_DIM, 1, 7)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	p.add_child(row)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UiKit.label(String(room.get("name", "队伍")), 12))
	var lock := " · 有密码" if bool(room.get("has_password", false)) else ""
	info.add_child(UiKit.label("%s · %d 人%s" % [String(room.get("ip", "")), int(room.get("players", 1)), lock],
		10, UiKit.COL_MUTED))
	row.add_child(info)
	var join := UiKit.button("加入", 10)
	join.pressed.connect(func(): _on_join(String(room.get("ip", ""))))
	row.add_child(join)
	return p


func _line_edit(placeholder: String, text: String) -> LineEdit:
	var e := LineEdit.new()
	e.placeholder_text = placeholder
	e.text = text
	e.custom_minimum_size = Vector2(0, 28)
	e.add_theme_font_override("font", UiKit.font())
	e.add_theme_font_size_override("font_size", 14)
	return e


func _on_create() -> void:
	Net.create_room(_room_input.text if _room_input != null else "", _create_pass.text if _create_pass != null else "")
	refresh()


func _on_join_manual() -> void:
	var ip := _manual_ip.text.strip_edges() if _manual_ip != null else ""
	if ip == "" and not Net.rooms.is_empty():
		ip = String(Net.rooms[0].get("ip", ""))
	_on_join(ip)


func _on_join(ip: String) -> void:
	if ip.strip_edges() == "":
		Net.notice.emit("请输入房主 IP", Color("#ff7b6e"))
		return
	Net.join_room(ip, _join_pass.text if _join_pass != null else "")
	refresh()
