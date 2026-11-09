class_name BackpackWindow
extends BaseWindow

const EQ_CELL := 50
const EQ_BIG_CELL := 50
const INV_CELL := 42
const EQ_POS := {
	"head": Vector2(150, 50),
	"chest": Vector2(150, 110),
	"legs": Vector2(150, 170),
	"feet": Vector2(150, 235),
	"hands": Vector2(85, 150),
	"main": Vector2(82, 82),
	"off": Vector2(222, 92),
	"neck": Vector2(285, 20),
	"ring1": Vector2(285, 75),
	"trinket": Vector2(285, 130),
	"rune1": Vector2(8, 150),
	"rune2": Vector2(8, 205),
	"rune3": Vector2(8, 260),
}

var _tip: ItemTooltip
var _menu: PopupMenu
var _menu_item: GameItem
var _stats_open := true
var _sell_menu: PanelContainer
var _dismantle_menu: PanelContainer
var _menu_overlay: ColorRect
var _sell_btn: Button
var _dismantle_btn: Button
var _sell_auto_off: CheckBox
var _sell_auto_on: CheckBox
var _dismantle_auto_off: CheckBox
var _dismantle_auto_on: CheckBox
var _sell_quality_checks: Array = []
var _dismantle_quality_checks: Array = []
var _sell_below_check: CheckBox
var _dismantle_below_check: CheckBox
var _set_expanded: Dictionary = {}
var _stats_scroll: ScrollContainer


func _init() -> void:
	title = "背包"
	window_size = Vector2(760, 570)


func _after_build() -> void:
	_tip = ItemTooltip.new()
	add_child(_tip)
	_menu = PopupMenu.new()
	_menu.id_pressed.connect(_on_menu_id)
	add_child(_menu)
	_build_action_menus()
	closed.connect(_close_action_menus)


func _build_action_menus() -> void:
	_menu_overlay = ColorRect.new()
	_menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu_overlay.color = Color(0, 0, 0, 0)
	_menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu_overlay.z_index = 80
	_menu_overlay.visible = false
	_menu_overlay.gui_input.connect(_on_menu_overlay_input)
	add_child(_menu_overlay)
	_sell_menu = _make_action_menu(true)
	_dismantle_menu = _make_action_menu(false)
	_sync_action_menus()


func _make_action_menu(is_sell: bool) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.stylebox(Color(0.035, 0.045, 0.060, 0.98), UiKit.COL_GOLD_DIM, 2, 8))
	p.z_index = 100
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.visible = false
	add_child(p)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	p.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	margin.add_child(v)
	v.add_child(UiKit.label("自动出售" if is_sell else "自动分解", 11, UiKit.COL_GOLD))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 1)
	v.add_child(grid)
	var group := ButtonGroup.new()
	group.allow_unpress = false
	var off := CheckBox.new()
	off.text = "关闭"
	off.button_group = group
	off.add_theme_color_override("font_color", UiKit.COL_MUTED)
	grid.add_child(off)
	var on := CheckBox.new()
	on.text = "开启"
	on.button_group = group
	on.add_theme_color_override("font_color", UiKit.COL_GREEN)
	grid.add_child(on)
	if is_sell:
		_sell_auto_off = off
		_sell_auto_on = on
	else:
		_dismantle_auto_off = off
		_dismantle_auto_on = on
	off.toggled.connect(func(pressed: bool):
		if pressed:
			if is_sell:
				Game.set_auto_sell(false)
			else:
				Game.set_auto_dismantle(false)
			_sync_action_menus())
	on.toggled.connect(func(pressed: bool):
		if pressed:
			if is_sell:
				Game.set_auto_sell(true)
			else:
				Game.set_auto_dismantle(true)
			_sync_action_menus())
	var checks: Array = []
	for q in 5:
		var quality := q
		var cb := CheckBox.new()
		cb.text = String(Data.QUALITIES[quality]["name"])
		cb.add_theme_color_override("font_color", Data.quality_color(quality))
		cb.add_theme_color_override("font_pressed_color", Data.quality_color(quality))
		cb.toggled.connect(func(enabled: bool):
			if is_sell:
				Game.set_sell_quality(quality, enabled)
			else:
				Game.set_dismantle_quality(quality, enabled))
		grid.add_child(cb)
		checks.append(cb)
	if is_sell:
		_sell_quality_checks = checks
	else:
		_dismantle_quality_checks = checks
	var blank := Control.new()
	blank.custom_minimum_size = Vector2(0, 22)
	grid.add_child(blank)
	var below := CheckBox.new()
	below.text = "低于当前装备等级"
	below.add_theme_color_override("font_color", UiKit.COL_MUTED)
	if is_sell:
		_sell_below_check = below
	else:
		_dismantle_below_check = below
	below.toggled.connect(func(enabled: bool):
		if is_sell:
			Game.set_sell_below(enabled)
		else:
			Game.set_dismantle_below(enabled))
	v.add_child(below)
	var action := UiKit.button("出售" if is_sell else "分解", 11)
	action.custom_minimum_size = Vector2(0, 26)
	action.pressed.connect(func():
		if is_sell:
			Game.sell_selected_unlocked()
		else:
			Game.dismantle_selected_unlocked()
		_close_action_menus())
	v.add_child(action)
	return p


func _sync_action_menus() -> void:
	if _sell_auto_off == null or _dismantle_auto_off == null:
		return
	_sell_auto_off.set_pressed_no_signal(not Game.auto_sell)
	_sell_auto_on.set_pressed_no_signal(Game.auto_sell)
	_dismantle_auto_off.set_pressed_no_signal(not Game.auto_dismantle)
	_dismantle_auto_on.set_pressed_no_signal(Game.auto_dismantle)
	for q in _sell_quality_checks.size():
		_sell_quality_checks[q].set_pressed_no_signal(Game.sell_qualities.has(q))
	for q in _dismantle_quality_checks.size():
		_dismantle_quality_checks[q].set_pressed_no_signal(Game.dismantle_qualities.has(q))
	_sell_below_check.set_pressed_no_signal(Game.sell_below_equipped)
	_dismantle_below_check.set_pressed_no_signal(Game.dismantle_below_equipped)


func _open_sell_menu() -> void:
	if _sell_menu.visible:
		_close_action_menus()
		return
	_open_action_menu(_sell_menu, _sell_btn)


func _open_dismantle_menu() -> void:
	if _dismantle_menu.visible:
		_close_action_menus()
		return
	_open_action_menu(_dismantle_menu, _dismantle_btn)


func _open_action_menu(menu: PanelContainer, button: Button) -> void:
	_close_action_menus()
	_sync_action_menus()
	_menu_overlay.visible = true
	menu.visible = true
	var needed := menu.get_combined_minimum_size()
	menu.size = needed
	var origin := button.get_global_rect().position - get_global_rect().position
	var max_x := maxf(8.0, size.x - needed.x - 8.0)
	var pos := Vector2(clampf(origin.x, 8.0, max_x), maxf(8.0, origin.y - needed.y - 6.0))
	menu.position = pos.round()


func _close_action_menus() -> void:
	if _sell_menu != null:
		_sell_menu.visible = false
	if _dismantle_menu != null:
		_dismantle_menu.visible = false
	if _menu_overlay != null:
		_menu_overlay.visible = false


func _on_menu_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_close_action_menus()
		get_viewport().set_input_as_handled()


func _refresh_body(box: VBoxContainer) -> void:
	var stats := Game.compute_stats()
	var stats_scroll_y := _stats_scroll.scroll_vertical if _stats_scroll != null else 0
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	for c in _footer_left.get_children():
		_footer_left.remove_child(c)
		c.queue_free()
	if _tip != null:
		_tip.hide_tip()
	if _menu != null:
		_menu.hide()

	_footer_left.add_child(UiKit.label("金币 %s" % UiKit.num(Game.gold), 12, UiKit.COL_GOLD))
	_footer_left.add_child(UiKit.label("材料 %d" % Game.materials, 12, Color("#8fd3c7")))
	_footer_left.add_child(UiKit.spacer())
	_sell_btn = UiKit.button("⚙ 出售", 10)
	_sell_btn.custom_minimum_size = Vector2(72, 24)
	_sell_btn.tooltip_text = "自动出售设置与手动出售"
	_sell_btn.pressed.connect(_open_sell_menu)
	_footer_left.add_child(_sell_btn)
	_dismantle_btn = UiKit.button("⚙ 分解", 10)
	_dismantle_btn.custom_minimum_size = Vector2(72, 24)
	_dismantle_btn.tooltip_text = "自动分解设置与手动分解"
	_dismantle_btn.pressed.connect(_open_dismantle_menu)
	_footer_left.add_child(_dismantle_btn)

	var title_row := HBoxContainer.new()
	title_row.add_child(UiKit.label("背包", 16, UiKit.COL_GOLD))
	title_row.add_child(UiKit.spacer())
	box.add_child(title_row)

	var main := HBoxContainer.new()
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 12)
	box.add_child(main)

	# 左：装备 + 背包
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(370, 0)
	left.add_theme_constant_override("separation", 6)
	main.add_child(left)

	var doll := PaperDoll.new()
	doll.custom_minimum_size = Vector2(370, 320)
	left.add_child(doll)
	var equip_lv := UiKit.label("装备等级 %d" % int(stats.get("ilvl", 1)), 12, Color("#3d2a17"))
	equip_lv.position = Vector2(6, 4)
	doll.add_child(equip_lv)
	var toggle := UiKit.button("◀" if _stats_open else "▶", 12)
	toggle.position = Vector2(304, 286)
	toggle.custom_minimum_size = Vector2(32, 26)
	toggle.size = Vector2(32, 26)
	toggle.clip_contents = false
	toggle.tooltip_text = "收起属性" if _stats_open else "展开属性"
	toggle.add_theme_color_override("font_color", UiKit.COL_GOLD)
	toggle.add_theme_stylebox_override("normal", UiKit.stylebox(Color(0.10, 0.12, 0.16, 0.9), Color(0.30, 0.26, 0.20), 1, 2))
	toggle.add_theme_stylebox_override("hover", UiKit.stylebox(Color(0.16, 0.14, 0.11, 0.95), UiKit.COL_GOLD, 1, 2))
	toggle.pressed.connect(_toggle_stats)
	var toggle_frame := PanelContainer.new()
	toggle_frame.position = Vector2(302, 284)
	toggle_frame.custom_minimum_size = Vector2(36, 30)
	toggle_frame.size = Vector2(36, 30)
	toggle_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toggle_frame.add_theme_stylebox_override("panel",
		UiKit.stylebox(Color(0, 0, 0, 0), Color(0.30, 0.26, 0.20), 2, 0))
	doll.add_child(toggle_frame)
	doll.add_child(toggle)
	for key in Data.EQUIP_ORDER:
		var cell := EQ_BIG_CELL if key == "main" or key == "off" else EQ_CELL
		var slot := ItemSlot.new(cell, key)
		slot.position = EQ_POS.get(key, Vector2.ZERO)
		slot.set_item(Game.equipment.get(key))
		slot.clicked.connect(_on_equip_clicked)
		slot.hovered.connect(_on_slot_hovered)
		slot.unhovered.connect(_on_slot_unhovered)
		slot.dropped.connect(_on_item_dropped)
		doll.add_child(slot)
		slot.set_paper(true)

	var inv_head := HBoxContainer.new()
	inv_head.custom_minimum_size = Vector2(370, 22)
	inv_head.add_theme_constant_override("separation", 5)
	inv_head.add_child(UiKit.label("背包", 12, UiKit.COL_GOLD))
	inv_head.add_child(UiKit.label("%d/%d" % [Game.inventory_count(), Data.INVENTORY_SIZE], 10, UiKit.COL_MUTED))
	inv_head.add_child(UiKit.spacer())
	var auto_eq := UiKit.button("自动替换：%s" % ("开" if Game.auto_equip else "关"), 9)
	auto_eq.custom_minimum_size = Vector2(92, 20)
	auto_eq.add_theme_color_override("font_color", UiKit.COL_GREEN if Game.auto_equip else UiKit.COL_MUTED)
	auto_eq.pressed.connect(_toggle_auto_equip)
	inv_head.add_child(auto_eq)
	var sort_btn := UiKit.button("整理", 10)
	sort_btn.custom_minimum_size = Vector2(34, 20)
	sort_btn.pressed.connect(func(): Game.sort_inventory())
	inv_head.add_child(sort_btn)
	left.add_child(inv_head)

	var inv_scroll := ScrollContainer.new()
	inv_scroll.custom_minimum_size = Vector2(370, 134)
	inv_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inv_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	left.add_child(inv_scroll)

	var inv_grid := GridContainer.new()
	inv_grid.columns = 7
	inv_grid.add_theme_constant_override("h_separation", 4)
	inv_grid.add_theme_constant_override("v_separation", 4)
	var inv_center := CenterContainer.new()
	inv_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inv_scroll.add_child(inv_center)
	inv_center.add_child(inv_grid)
	for i in Data.INVENTORY_SIZE:
		var slot := ItemSlot.new(INV_CELL, "")
		slot.inv_index = i
		slot.set_item(Game.inventory[i] if i < Game.inventory.size() else null)
		slot.clicked.connect(_on_inv_clicked)
		slot.hovered.connect(_on_slot_hovered)
		slot.unhovered.connect(_on_slot_unhovered)
		slot.dropped.connect(_on_item_dropped)
		inv_grid.add_child(slot)

	if not _stats_open:
		_stats_scroll = null
		return

	# 右：人物 + 属性
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(340, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)

	var cls: Dictionary = Data.class_def(Game.class_id)
	var ch: Dictionary = Data.character_def(Game.class_id)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	var portrait := PanelContainer.new()
	portrait.custom_minimum_size = Vector2(60, 60)
	portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	portrait.add_theme_stylebox_override("panel", UiKit.stylebox(UiKit.COL_PANEL_2, UiKit.COL_BORDER, 1, 3))
	var avatar := TextureRect.new()
	var avatar_path := String(ch.get("portrait", ch["sprite"]))
	var sheet := load(avatar_path) as Texture2D
	if sheet != null:
		avatar.texture = sheet
	avatar.custom_minimum_size = Vector2(54, 54)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	avatar.modulate = Color(String(ch.get("tint", "#ffffff")))
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_child(avatar)
	header.add_child(portrait)

	var info := VBoxContainer.new()
	info.custom_minimum_size = Vector2(240, 60)
	info.add_theme_constant_override("separation", 4)
	var char_head := HBoxContainer.new()
	var name_pad := Control.new()
	name_pad.custom_minimum_size = Vector2(3, 0)
	name_pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	char_head.add_child(name_pad)
	char_head.add_child(UiKit.label(Data.character_name(Game.class_id), 18, Color(String(ch["color"]))))
	var level_label := UiKit.label("Lv.%d" % Game.level, 12, UiKit.COL_MUTED)
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	level_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	char_head.add_child(level_label)
	var power_gap := Control.new()
	power_gap.custom_minimum_size = Vector2(40, 0)
	char_head.add_child(power_gap)
	var power_label := UiKit.label("战力 %s" % UiKit.num(Game.combat_power()), 11, UiKit.COL_GOLD)
	power_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	power_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	char_head.add_child(power_label)
	char_head.add_child(UiKit.spacer())
	info.add_child(char_head)
	var exp_bar := UiKit.progress(Game.exp, Game.exp_to_next(), 6, UiKit.COL_TEAL)
	exp_bar.custom_minimum_size = Vector2(240, 6)
	exp_bar.size = Vector2(240, 6)
	exp_bar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	info.add_child(exp_bar)
	header.add_child(info)
	right.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(scroll)
	_stats_scroll = scroll

	var rv := VBoxContainer.new()
	rv.custom_minimum_size = Vector2(320, 0)
	rv.add_theme_constant_override("separation", 3)
	scroll.add_child(rv)

	var prim_grid := GridContainer.new()
	prim_grid.columns = 4
	prim_grid.add_theme_constant_override("h_separation", 10)
	prim_grid.add_theme_constant_override("v_separation", 1)
	rv.add_child(prim_grid)
	for key in ["strength", "agility", "intellect", "stamina"]:
		prim_grid.add_child(UiKit.label("%s %d" % [Data.PRIMARY_NAMES[key], int(stats.get(key, 0))], 12, UiKit.stat_color(key)))

	rv.add_child(UiKit.hsep())
	rv.add_child(UiKit.label("战斗属性", 12, UiKit.COL_GOLD))
	var rows := [
		["每秒伤害", UiKit.num(int(stats["dps"])), UiKit.COL_GOLD],
		["生命上限", UiKit.num(int(stats["hp_max"])), UiKit.COL_GREEN],
		["护甲", UiKit.num(int(stats["armor_total"])), UiKit.COL_TEXT],
		["攻击强度", UiKit.num(int(stats["ap"])) if float(stats["ap"]) > 0.0 else "—", UiKit.COL_TEXT],
		["法术强度", UiKit.num(int(stats["sp"])) if float(stats["sp"]) > 0.0 else "—", UiKit.COL_TEXT],
		["暴击", UiKit.pct(stats["crit_pct"]), UiKit.COL_TEXT],
		["暴击伤害", "%d%%" % int(round(float(stats["crit_dmg_pct"]) * 100.0)), UiKit.COL_TEXT],
		["急速", UiKit.pct(stats["haste_pct"]), UiKit.COL_TEXT],
		["命中", UiKit.pct(stats["hit_pct"]), UiKit.COL_TEXT],
		["闪避", UiKit.pct(stats["dodge_pct"]), UiKit.COL_TEXT],
		["招架", UiKit.pct(stats["parry_pct"]), UiKit.COL_TEXT],
		["格挡", UiKit.pct(stats["block_pct"]), UiKit.COL_TEXT],
		["全能", UiKit.pct(stats["vers_pct"]), UiKit.COL_TEXT],
		["吸血", UiKit.pct(stats["lifesteal_pct"]), UiKit.COL_TEXT],
		["生命回复", UiKit.num(int(stats["hp_regen"])), UiKit.COL_GREEN],
		["额外攻击", UiKit.pct(stats["extra_attack_pct"]), UiKit.COL_TEAL],
		["穿透", UiKit.pct(stats["pen_pct"]), UiKit.COL_TEXT],
		["有效生命", UiKit.num(int(stats["ehp"])), UiKit.COL_MUTED],
	]
	var pair_grid := GridContainer.new()
	pair_grid.columns = 1
	pair_grid.add_theme_constant_override("h_separation", 0)
	pair_grid.add_theme_constant_override("v_separation", 1)
	rv.add_child(pair_grid)
	for row in rows:
		var row_h := _stat_row(row[0], row[1], row[2])
		if row[0] == "有效生命":
			row_h.tooltip_text = "按生命上限、护甲减伤、闪避、招架和格挡综合折算的承伤能力，不是直接血量"
		pair_grid.add_child(row_h)

	var active_sets: Array = stats.get("active_sets", [])
	if not active_sets.is_empty():
		rv.add_child(UiKit.hsep())
		rv.add_child(UiKit.label("套装效果", 12, UiKit.COL_GOLD))
		for entry in active_sets:
			var set_id := String(entry.get("id", ""))
			var set_level := int(entry.get("level", 0))
			var sd := Data.set_def(set_id)
			var count := int(entry.get("count", 0))
			var max_count := int(entry.get("max", 0))
			var map_key := "%s|%d" % [set_id, set_level]
			var expand_key := map_key
			var expanded := bool(_set_expanded.get(map_key, false))
			var head := HBoxContainer.new()
			head.add_theme_constant_override("separation", 6)
			head.add_child(UiKit.label("%s套装（%d/%d）" % [
				String(entry.get("name", "")), count, max_count],
				11, UiKit.COL_GREEN if count >= 2 else UiKit.COL_MUTED))
			head.add_child(UiKit.spacer())
			var expand := UiKit.button("▼" if expanded else "▶", 9)
			expand.custom_minimum_size = Vector2(20, 20)
			expand.tooltip_text = "点此按钮可以展开详情"
			expand.pressed.connect(func():
				_set_expanded[expand_key] = not bool(_set_expanded.get(expand_key, false))
				refresh())
			head.add_child(expand)
			rv.add_child(head)
			if expanded:
				var bonuses: Dictionary = sd.get("bonuses", {})
				var thresholds: Array = bonuses.keys()
				thresholds.sort()
				for threshold in thresholds:
					var active := count >= int(threshold)
					var line := UiKit.label("%d件效果 %s" % [int(threshold), Data.set_bonus_text(bonuses[threshold])],
						10, UiKit.COL_GREEN if active else UiKit.COL_MUTED)
					line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					rv.add_child(line)
				var pieces: Dictionary = sd.get("pieces", {})
				for slot in ["head", "chest", "hands", "legs", "feet", "neck", "ring", "trinket"]:
					if not pieces.has(slot):
						continue
					var equipped := Game.is_set_piece_equipped(set_id, set_level, slot)
					var piece_line := UiKit.label(String(pieces[slot]), 10,
						UiKit.COL_GREEN if equipped else UiKit.COL_MUTED)
					piece_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					rv.add_child(piece_line)

	if stats_scroll_y > 0:
		scroll.set_deferred("scroll_vertical", stats_scroll_y)

	if _stats_open:
		main.add_child(right)
	else:
		right.free()


func _stat_row(name_text: String, value_text: String, color: Color) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.custom_minimum_size = Vector2(320, 0)
	h.mouse_filter = Control.MOUSE_FILTER_STOP
	var name_label := UiKit.label(name_text, 11, UiKit.COL_MUTED)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(name_label)
	h.add_child(UiKit.spacer())
	var v := UiKit.label(value_text, 12, color)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(v)
	return h


func _toggle_stats() -> void:
	_stats_open = not _stats_open
	resize_keep_origin(Vector2(760, 570) if _stats_open else Vector2(410, 570), true, true)
	refresh()


func _toggle_auto_equip() -> void:
	Game.set_auto_equip(not Game.auto_equip)
	refresh()


func _toggle_auto_sell() -> void:
	Game.set_auto_sell(not Game.auto_sell)
	refresh()


func _on_equip_clicked(slot: ItemSlot, item: GameItem, _button: int) -> void:
	if item == null:
		return
	Game.unequip(slot.slot_id)


func _on_inv_clicked(_slot: ItemSlot, item: GameItem, button: int) -> void:
	if item == null:
		return
	if button == MOUSE_BUTTON_RIGHT:
		_open_item_menu(item)
		return
	Game.equip_item(item)


func _on_item_dropped(source: ItemSlot, target: ItemSlot) -> void:
	if source == null or target == null or source.item == null:
		return
	if source.inv_index >= 0 and target.inv_index >= 0:
		Game.move_inventory(source.inv_index, target.inv_index)
	elif source.inv_index >= 0 and target.slot_id != "":
		Game.equip_at(source.item, source.inv_index, target.slot_id)
	elif source.slot_id != "" and target.inv_index >= 0:
		Game.unequip_to(source.slot_id, target.inv_index)
	elif source.slot_id != "" and target.slot_id != "":
		Game.swap_equipment_slots(source.slot_id, target.slot_id)
	refresh()


func _open_item_menu(item: GameItem) -> void:
	_menu_item = item
	_menu.clear()
	_menu.add_item("装备", 0)
	_menu.add_item("出售  +%d 金币" % item.sell_value(), 1)
	_menu.set_item_disabled(1, item.locked)
	_menu.add_item("解锁" if item.locked else "锁定", 2)
	_menu.add_item("分解  +%d 材料" % maxi(1, int(round(item.sell_value() * 0.5))), 3)
	_menu.set_item_disabled(3, item.locked)
	_menu.reset_size()
	var gp := get_global_mouse_position()
	_menu.popup(Rect2i(Vector2i(gp), Vector2i(1, 1)))


func _on_menu_id(id: int) -> void:
	var item := _menu_item
	if item == null:
		return
	match id:
		0:
			Game.equip_item(item)
		1:
			Game.sell_item(item)
		2:
			Game.toggle_lock(item)
		3:
			Game.dismantle_item(item)
	refresh()


func _on_slot_hovered(slot: ItemSlot, item: GameItem) -> void:
	if item == null or _tip == null:
		if _tip != null:
			_tip.hide_tip()
		return
	if slot.slot_id != "":
		_tip.show_item(item, null, Game.class_id, "", false)
	else:
		_tip.show_item(item, Game.compare_item(item), Game.class_id, "")


func _on_slot_unhovered(_slot: ItemSlot) -> void:
	if _tip != null:
		_tip.hide_tip()
