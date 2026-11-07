class_name HUD
extends CanvasLayer

var world: Node

var _bottom: PanelContainer
var _status_label: Label
var _collapse_btn: Button
var _team_badge: PanelContainer
var _team_badge_label: Label
var _buttons: Dictionary = {}
var _button_icons: Dictionary = {}
var _windows: Dictionary = {}
var _current: BaseWindow = null
var _manual_started := false

var _bag: BackpackWindow
var _dungeon: MapWindow
var _shop: ShopWindow
var _info: InfoWindow
var _more: MoreWindow
var _stats: StatsWindow
var _team: TeamWindow
var _team_result: Dictionary = {}


func _ready() -> void:
	layer = 5
	_build_bottom()
	_build_windows()
	_connect_game()
	update_badges()
	update_status_line()
	add_log("挂机刷装备 · 点图标查看背包 / 副本 / 商店 / 信息")


func _build_bottom() -> void:
	_bottom = PanelContainer.new()
	add_child(_bottom)
	_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom.offset_left = 390
	_bottom.offset_right = -390
	_bottom.offset_top = -56
	_bottom.offset_bottom = 0
	var sb := UiKit.stylebox(Color(0.024, 0.031, 0.043, 0.94), UiKit.COL_BORDER_DIM, 1, 4)
	sb.border_width_top = 1
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	_bottom.add_theme_stylebox_override("panel", sb)

	var h := HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_BEGIN
	h.add_theme_constant_override("separation", 4)
	_bottom.add_child(h)
	var defs := [
		["bag", "bag_2x", "背包（B）", "bag"],
		["dungeon", "map_2x", "副本（M）", "dungeon"],
		["shop", "shop_2x", "商店（S）", "shop"],
		["team", "team_32", "组队（T）", "team"],
		["stats", "chart_32", "统计", "stats"],
		["info", "info_32", "信息（I）", "info"],
		["more", "dots_2x", "设置", "more"],
	]
	for d in defs:
		var key := String(d[0])
		var action := String(d[3])
		var btn := UiKit.button("", 14)
		btn.custom_minimum_size = Vector2(40, 40)
		btn.tooltip_text = String(d[2])
		btn.pressed.connect(toggle_window.bind(action))
		h.add_child(btn)
		var center := CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(center)
		var icon := TextureRect.new()
		icon.texture = UiKit.icon(String(d[1]))
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		center.add_child(icon)
		if key == "team":
			_team_badge = PanelContainer.new()
			_team_badge.add_theme_stylebox_override("panel",
				UiKit.stylebox(Color(0.035, 0.043, 0.063, 0.98), UiKit.COL_GOLD, 1, 0))
			_team_badge.custom_minimum_size = Vector2(16, 14)
			_team_badge.size = Vector2(16, 14)
			_team_badge.position = Vector2(23, 25)
			_team_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_team_badge.visible = false
			_team_badge_label = UiKit.label("", 8, UiKit.COL_GOLD)
			_team_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_team_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			_team_badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_team_badge.add_child(_team_badge_label)
			btn.add_child(_team_badge)
		_buttons[key] = btn
		_button_icons[key] = icon

	_status_label = UiKit.label("", 12, UiKit.COL_MUTED)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.clip_text = true
	_status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(_status_label)

	_collapse_btn = UiKit.button("▾", 10)
	_collapse_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_collapse_btn.offset_left = 406
	_collapse_btn.offset_right = 430
	_collapse_btn.offset_top = -72
	_collapse_btn.offset_bottom = -56
	_collapse_btn.custom_minimum_size = Vector2(24, 16)
	_collapse_btn.tooltip_text = "收起底部按钮"
	_collapse_btn.add_theme_color_override("font_color", UiKit.COL_GOLD)
	_collapse_btn.add_theme_stylebox_override("normal",
		UiKit.stylebox(Color(0.035, 0.043, 0.063, 0.92), UiKit.COL_BORDER_DIM, 1, 1))
	_collapse_btn.add_theme_stylebox_override("hover",
		UiKit.stylebox(Color(0.10, 0.12, 0.16, 0.98), UiKit.COL_GOLD, 1, 1))
	_collapse_btn.pressed.connect(_toggle_bottom)
	add_child(_collapse_btn)


func _build_windows() -> void:
	_bag = BackpackWindow.new()
	add_child(_bag)
	_bag.closed.connect(_on_window_closed.bind("bag"))

	_dungeon = MapWindow.new()
	add_child(_dungeon)
	_dungeon.closed.connect(_on_window_closed.bind("dungeon"))
	_dungeon.enter_dungeon.connect(_start_dungeon)
	_dungeon.boss_requested.connect(_start_boss)

	_shop = ShopWindow.new()
	add_child(_shop)
	_shop.closed.connect(_on_window_closed.bind("shop"))

	_info = InfoWindow.new()
	add_child(_info)
	_info.closed.connect(_on_window_closed.bind("info"))

	_more = MoreWindow.new()
	add_child(_more)
	_more.closed.connect(_on_window_closed.bind("more"))

	_stats = StatsWindow.new()
	add_child(_stats)
	_stats.closed.connect(_on_window_closed.bind("stats"))

	_team = TeamWindow.new()
	add_child(_team)
	_team.closed.connect(_on_window_closed.bind("team"))

	_windows = {"bag": _bag, "dungeon": _dungeon, "shop": _shop, "info": _info, "more": _more,
		"stats": _stats, "team": _team}


func _connect_game() -> void:
	Game.stats_changed.connect(_on_state_changed)
	Game.inventory_changed.connect(_on_state_changed)
	Game.equipment_changed.connect(_on_state_changed)
	Game.gold_changed.connect(_on_state_changed)
	Game.exploration_changed.connect(_on_state_changed)
	Game.dungeons_changed.connect(_on_dungeons_changed)
	Game.area_changed.connect(_on_area_changed)
	Game.shop_changed.connect(_on_shop_changed)
	Game.metrics_changed.connect(_on_state_changed)
	Game.auto_mode_changed.connect(func(_m): update_badges())
	Game.toast.connect(add_log)
	Game.busy_changed.connect(_on_busy_changed)
	Net.notice.connect(add_log)
	Net.party_changed.connect(_on_party_changed)
	Net.team_battle.connect(_on_team_battle)
	if world != null and world.has_signal("team_battle_finished"):
		world.team_battle_finished.connect(_on_team_battle_finished)


func add_log(text: String, color: Color = Color("#c8d2df")) -> void:
	Game.push_log(text, color)


func set_stage(_text: String) -> void:
	pass


func clear_stage() -> void:
	pass


func update_badges() -> void:
	var dungeon_icon: TextureRect = _button_icons.get("dungeon")
	var dungeon_btn: Button = _buttons.get("dungeon")
	if dungeon_icon != null:
		dungeon_icon.modulate = UiKit.COL_RED if Game.boss_ready() else Color.WHITE
	if dungeon_btn != null:
		dungeon_btn.tooltip_text = "副本（首领待战）" if Game.boss_ready() else "副本（M）"
	var bag_icon: TextureRect = _button_icons.get("bag")
	var bag_btn: Button = _buttons.get("bag")
	var full := Game.inventory_count() >= Data.INVENTORY_SIZE and not Game.auto_sell
	if bag_icon != null:
		bag_icon.modulate = UiKit.COL_RED if full else Color.WHITE
	if bag_btn != null:
		bag_btn.tooltip_text = "背包（已满）" if full else "背包（B）"
	if _team_badge != null:
		_team_badge.visible = Net.in_party
		if _team_badge_label != null:
			_team_badge_label.text = str(maxi(1, Net.members.size()))
	var team_btn: Button = _buttons.get("team")
	if team_btn != null:
		team_btn.tooltip_text = "组队（T） · %d 人" % Net.members.size() if Net.in_party else "组队（T）"


func _toggle_bottom() -> void:
	if _bottom == null:
		return
	_bottom.visible = not _bottom.visible
	if _collapse_btn != null:
		_collapse_btn.text = "▴" if not _bottom.visible else "▾"
		_collapse_btn.tooltip_text = "展开底部按钮" if not _bottom.visible else "收起底部按钮"


func update_status_line() -> void:
	if _status_label == null:
		return
	var text := "Lv.%d" % Game.level
	if Game.current_dungeon.is_empty():
		text += " · 未选择副本"
	elif String(Game.current_dungeon.get("kind", "normal")) == "boss":
		text += " · 首领 Lv.%d" % int(Game.current_dungeon.get("level", 1))
	else:
		text += " · %s" % Data.dungeon_title(Game.current_dungeon)
		var diff := String(Game.current_dungeon.get("difficulty", "normal"))
		if diff != "normal":
			text += " %s" % String(Data.DIFFICULTIES[diff]["name"])
	_status_label.text = text
	_status_label.add_theme_color_override("font_color",
		UiKit.COL_RED if Game.boss_ready() else UiKit.COL_MUTED)


func _on_state_changed() -> void:
	update_badges()
	update_status_line()
	if _bag != null and _bag.visible:
		_bag.refresh()
	if _shop != null and _shop.visible:
		_shop.refresh()
	if _info != null and _info.visible:
		_info.refresh()
	if _stats != null and _stats.visible:
		_stats.refresh()


func _on_dungeons_changed() -> void:
	update_status_line()
	if _dungeon != null and _dungeon.visible:
		_dungeon.refresh()


func _on_area_changed(_index: int) -> void:
	update_status_line()
	if _dungeon != null and _dungeon.visible:
		_dungeon.refresh()
	update_badges()


func _on_shop_changed() -> void:
	if _shop != null and _shop.visible:
		_shop.refresh()


func _on_busy_changed(_value: bool) -> void:
	update_status_line()
	if _dungeon != null and _dungeon.visible:
		_dungeon.refresh()


func toggle_window(name: String) -> void:
	if Game.class_id == "":
		return
	var w: BaseWindow = _windows.get(name)
	if w == null:
		return
	if name == "info" or name == "stats":
		if w.visible:
			w.close()
		else:
			w.open()
			w.refresh()
		return
	if w.visible:
		w.close()
		return
	for key in ["bag", "dungeon", "more", "team"]:
		if key == name:
			continue
		var other: BaseWindow = _windows.get(key)
		if other != null and other.visible:
			other.close()
	_current = w
	w.open()


func close_current() -> void:
	if _current != null and _current.visible:
		_current.close()
	elif _shop != null and _shop.visible:
		_shop.close()
	elif _info != null and _info.visible:
		_info.close()


func has_open_window() -> bool:
	for key in _windows:
		var w: BaseWindow = _windows[key]
		if w != null and w.visible:
			return true
	return false

func refresh_dungeon() -> void:
	if _dungeon != null and _dungeon.visible:
		Game.refresh_dungeons()


func _on_window_closed(_name: String) -> void:
	if has_open_window():
		return
	_current = null
	if not _manual_started:
		return
	if world != null and Game.auto_mode != "off":
		world.resume_auto(0.8)


func _start_dungeon(d: Dictionary) -> void:
	_manual_started = true
	_close_all_now()
	if Net.in_party:
		if Net.is_leader():
			Net.host_start_team(d)
		else:
			add_log("只有队长可以选择副本并开始", UiKit.COL_RED)
		return
	if world != null:
		world.start_dungeon(d)


func _start_boss() -> void:
	_manual_started = true
	_close_all_now()
	if Net.in_party:
		if Net.is_leader():
			Net.host_start_team(Game.make_boss_dungeon())
		else:
			add_log("只有队长可以选择副本并开始", UiKit.COL_RED)
		return
	if world != null:
		world.start_dungeon(Game.make_boss_dungeon())


func _close_all_now() -> void:
	for key in ["bag", "dungeon", "shop", "more", "stats", "team"]:
		var w: BaseWindow = _windows.get(key)
		if w != null:
			w.visible = false
	_current = null


func _on_party_changed() -> void:
	if world != null:
		world.set_party_members(Net.members)
	update_badges()
	update_status_line()
	if _team != null and _team.visible:
		_team.refresh()


func _on_team_battle(result: Dictionary) -> void:
	_team_result = result
	_close_all_now()
	if world != null:
		world.start_team_battle(result)


func _on_team_battle_finished(win: bool) -> void:
	var reward: Dictionary = {}
	var rewards: Dictionary = _team_result.get("rewards", {})
	reward = rewards.get(str(Net.local_id), {})
	if not reward.is_empty():
		Game.apply_team_reward(reward)
		var lines: Array = []
		for d in reward.get("items", []):
			if d is Dictionary:
				lines.append(String(d.get("name", "装备")))
		if not lines.is_empty():
			add_log("个人掉落：%s" % "、".join(lines), UiKit.COL_GREEN)
	if world != null:
		world.set_party_members(Net.members)
	Net.on_team_battle_finished(win)
