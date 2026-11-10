class_name ItemTooltip
extends PanelContainer

var _box: VBoxContainer
var _built := false


func _ready() -> void:
	_build()


func _build() -> void:
	_built = true
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 200
	add_theme_stylebox_override("panel", UiKit.stylebox(Color(0.031, 0.040, 0.055, 1.0), UiKit.COL_GOLD_DIM, 2, 12))
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 3)
	add_child(_box)


func _clear() -> void:
	for c in _box.get_children():
		_box.remove_child(c)
		c.queue_free()


func show_item(item: GameItem, compare: GameItem, class_id: String, hint: String = "", show_compare: bool = true,
		set_count: int = -1) -> void:
	if not _built:
		_build()
	if item == null:
		hide_tip()
		return
	_clear()
	visible = true
	if show_compare:
		var compare_row := HBoxContainer.new()
		compare_row.add_theme_constant_override("separation", 14)
		var left := VBoxContainer.new()
		left.custom_minimum_size = Vector2(292, 0)
		var left_spacer := Control.new()
		left_spacer.custom_minimum_size = Vector2(0, 16)
		left.add_child(left_spacer)
		_add_item_block(left, item, class_id)
		_add_set_block(left, item, set_count)
		compare_row.add_child(left)
		var right := VBoxContainer.new()
		right.custom_minimum_size = Vector2(292, 0)
		right.add_child(UiKit.label("当前装备", 12, UiKit.COL_MUTED))
		if compare != null:
			_add_item_block(right, compare, class_id)
			_add_set_block(right, compare, -1)
		else:
			right.add_child(UiKit.label("该部位未穿戴", 11, UiKit.COL_DIM))
		compare_row.add_child(right)
		_box.add_child(compare_row)
	else:
		_add_item_block(_box, item, class_id)
		_add_set_block(_box, item, set_count)

	if hint != "":
		_box.add_child(UiKit.label(hint, 10, UiKit.COL_DIM))
	_layout(show_compare)


func _add_item_block(parent: VBoxContainer, item: GameItem, class_id: String) -> void:
	if item.quality == 5 and item.uniq != "":
		parent.add_child(UiKit.label("首领掉落 · 神器", 10, Color("#ff8a80")))
	parent.add_child(UiKit.label(item.item_name, 16, item.quality_color()))
	parent.add_child(UiKit.label("评分 %d  ·  %s  ·  %s" % [Game.item_power(item, class_id), item.slot_name(),
		item.quality_name()], 11, UiKit.COL_MUTED))
	var can_use := Game.level >= item.req_level
	parent.add_child(UiKit.label("穿戴等级 %d%s" % [item.req_level, "" if can_use else "（角色等级不足）"],
		11, UiKit.COL_MUTED if can_use else UiKit.COL_RED))
	parent.add_child(UiKit.hsep())
	for key in ["strength", "agility", "intellect", "stamina"]:
		if item.stats.has(key):
			parent.add_child(UiKit.label(Data.fmt_primary(key, float(item.stats[key])), 12, UiKit.stat_color(key)))
	if item.stats.has("armor"):
		parent.add_child(UiKit.label("护甲 +%d" % int(item.stats["armor"]), 12, UiKit.COL_TEXT))
	if item.weapon_max > 0.0:
		parent.add_child(UiKit.label("伤害 %d - %d" % [int(item.weapon_min), int(item.weapon_max)], 12, UiKit.COL_TEXT))
	for key in Data.AFFIX_KEYS:
		if item.stats.has(key):
			parent.add_child(UiKit.label(Data.fmt_affix(key, float(item.stats[key])), 12, UiKit.COL_TEAL))
	if item.quality == 5 and item.uniq != "":
		var ad := Data.artifact_def(item.uniq)
		parent.add_child(UiKit.hsep())
		var effect_label := UiKit.label("%s：%s" % [String(ad.get("effect", "神器")), String(ad.get("desc", ""))],
			11, UiKit.COL_GOLD)
		effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		effect_label.custom_minimum_size = Vector2(285, 0)
		parent.add_child(effect_label)
	parent.add_child(UiKit.label("售价 %d 金币" % item.sell_value(), 10, UiKit.COL_GOLD))


func _add_set_block(parent: VBoxContainer, item: GameItem, set_count: int) -> void:
	if item == null or item.set_id == "":
		return
	var sd := Data.set_def(item.set_id)
	if sd.is_empty():
		return
	var count := Game.set_piece_count(item.set_id, item.set_level) if set_count < 0 else set_count
	var max_count := int(sd.get("max", 0))
	parent.add_child(UiKit.hsep())
	parent.add_child(UiKit.label("套装：%s（%d/%d）" % [
		item.set_name, count, max_count], 11, UiKit.COL_GOLD))
	var bonuses: Dictionary = sd.get("bonuses", {})
	var thresholds: Array = bonuses.keys()
	thresholds.sort()
	for threshold in thresholds:
		var active := count >= int(threshold)
		var line := UiKit.label("%d 件：%s" % [int(threshold), Data.set_bonus_text(bonuses[threshold])],
			10, UiKit.COL_GREEN if active else UiKit.COL_DIM)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(285, 0)
		parent.add_child(line)


func _layout(wide: bool) -> void:
	var need := _box.get_combined_minimum_size()
	var w := 620.0 if wide else 330.0
	var vp := get_viewport_rect().size
	var h := minf(maxf(need.y + 24.0, 56.0), vp.y - 16.0)
	size = Vector2(w, h)
	var mouse := get_viewport().get_mouse_position()
	var pos := mouse + Vector2(18, 16)
	if pos.x + w > vp.x - 8.0:
		pos.x = mouse.x - w - 18.0
	if pos.y + h > vp.y - 8.0:
		pos.y = vp.y - h - 8.0
	pos.x = maxf(8.0, pos.x)
	pos.y = maxf(8.0, pos.y)
	position = pos.round()


func hide_tip() -> void:
	visible = false
