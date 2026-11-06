class_name PartyAvatar
extends PanelContainer

signal dropped(from_id: int, target_id: int)

var member: Dictionary = {}
var _portrait: TextureRect
var _preview: PanelContainer


func setup(m: Dictionary) -> void:
	member = m
	custom_minimum_size = Vector2(62, 76)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var border := UiKit.COL_GOLD if int(m.get("position", 1)) == 1 else UiKit.COL_BORDER_DIM
	add_theme_stylebox_override("panel", UiKit.stylebox(UiKit.COL_PANEL_2, border, 1, 3))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(0, 42)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(center)
	_portrait = TextureRect.new()
	var portrait_path := String(m.get("portrait", ""))
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		_portrait.texture = load(portrait_path)
	_portrait.custom_minimum_size = Vector2(38, 38)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_portrait)
	var name_label := UiKit.label(String(m.get("name", "玩家")), 9,
		UiKit.COL_GOLD if int(m.get("position", 1)) == 1 else UiKit.COL_TEXT)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(name_label)
	var pos := UiKit.label("%d" % int(m.get("position", 1)), 9, UiKit.COL_MUTED)
	pos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(pos)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if Game.busy or not Net.in_party:
		return null
	_preview = PanelContainer.new()
	_preview.add_theme_stylebox_override("panel", UiKit.stylebox(UiKit.COL_PANEL, UiKit.COL_GOLD, 1, 4))
	_preview.custom_minimum_size = Vector2(54, 54)
	var pv := VBoxContainer.new()
	_preview.add_child(pv)
	var icon := TextureRect.new()
	icon.texture = _portrait.texture
	icon.custom_minimum_size = Vector2(38, 38)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pv.add_child(icon)
	var l := UiKit.label(String(member.get("name", "玩家")), 9, UiKit.COL_GOLD)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(l)
	set_drag_preview(_preview)
	return {"source": self, "from_id": int(member.get("id", 0))}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if Game.busy or not Net.in_party:
		return false
	if not (data is Dictionary):
		return false
	if not data.has("source") or data["source"] == self:
		return false
	return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not (data is Dictionary):
		return
	dropped.emit(int(data.get("from_id", 0)), int(member.get("id", 0)))
