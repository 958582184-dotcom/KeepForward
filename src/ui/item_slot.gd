class_name ItemSlot
extends Control

signal clicked(slot: ItemSlot, item: GameItem, button_index: int)
signal hovered(slot: ItemSlot, item: GameItem)
signal unhovered(slot: ItemSlot)
signal dropped(source: ItemSlot, target: ItemSlot)

var item: GameItem = null
var slot_id := ""
var inv_index := -1
var cell := 44
var paper := false
var _hover := false
var _built := false
var _drag_started := false

var _icon: TextureRect
var _ilvl: Label
var _empty: Label
var _lock: Label


func _init(size_px: int = 44, sid: String = "") -> void:
	cell = size_px
	slot_id = sid
	custom_minimum_size = Vector2(cell, cell)
	size = Vector2(cell, cell)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE


func _ready() -> void:
	if not _built:
		_build()
	_refresh()


func _build() -> void:
	_built = true
	_icon = TextureRect.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_icon)

	_empty = UiKit.label("", 13, UiKit.COL_DIM)
	_empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_empty)

	_ilvl = UiKit.label("", 11, UiKit.COL_MUTED)
	_ilvl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ilvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_ilvl)

	_lock = UiKit.label("锁", 10, UiKit.COL_GOLD)
	_lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock.visible = false
	add_child(_lock)

	resized.connect(_layout)
	_layout()


func _layout() -> void:
	if _icon == null:
		return
	var s := float(cell) * 0.72
	_icon.size = Vector2(s, s)
	_icon.position = ((size - Vector2(s, s)) * 0.5).round()
	_ilvl.size = Vector2(26, 14)
	_ilvl.position = Vector2(size.x - 27, size.y - 15)
	_lock.position = Vector2(3, 1)


func set_item(new_item: GameItem) -> void:
	item = new_item
	if _built:
		_refresh()


func set_paper(enabled: bool) -> void:
	paper = enabled
	if _built:
		var empty_col := Color("#c6a46b")
		if slot_id == "off":
			empty_col = Color("#9cc8ea")
		elif slot_id == "hands":
			empty_col = Color("#d3a36a")
		_empty.add_theme_color_override("font_color", empty_col)
		_ilvl.add_theme_color_override("font_color", Color("#d8bc86") if paper else UiKit.COL_MUTED)
		_lock.add_theme_color_override("font_color", Color("#f0c976") if paper else UiKit.COL_GOLD)
		queue_redraw()


func _refresh() -> void:
	if _icon == null:
		return
	_icon.texture = UiKit.icon_for_item(item)
	_icon.visible = item != null
	_ilvl.text = str(item.ilvl) if item != null else ""
	_ilvl.visible = item != null
	_lock.visible = item != null and item.locked
	_empty.visible = item == null
	_empty.text = Data.slot_short(slot_id) if slot_id != "" else ""
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if item != null else Control.CURSOR_ARROW
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var bg := Color(0.063, 0.078, 0.106, 0.96)
	if paper:
		bg = Color(0.175, 0.125, 0.080, 0.96)
	if item != null:
		bg = bg.lerp(item.quality_color(), 0.13)
	if _hover:
		bg = bg.lerp(Color(1, 1, 1), 0.07)
	draw_rect(r, bg)
	var border := Color(0.176, 0.212, 0.263)
	if paper:
		border = Color(0.58, 0.43, 0.24)
		if slot_id == "off":
			border = Color(0.38, 0.56, 0.74)
		elif slot_id == "hands":
			border = Color(0.64, 0.45, 0.27)
	if item != null:
		border = item.quality_color()
	draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), border, false, 2.0)
	if paper:
		draw_rect(Rect2(Vector2(4, 4), size - Vector2(8, 8)), Color(0.78, 0.60, 0.34, 0.22), false, 1.0)
		var accent := Color(0.78, 0.60, 0.34, 0.55)
		if slot_id == "off":
			accent = Color(0.35, 0.62, 0.88, 0.9)
		elif slot_id == "main":
			accent = Color(0.86, 0.68, 0.34, 0.9)
		elif slot_id == "hands":
			accent = Color(0.72, 0.47, 0.26, 0.9)
		draw_colored_polygon(PackedVector2Array([
			Vector2(size.x - 12, 1), Vector2(size.x - 1, 1), Vector2(size.x - 1, 12),
		]), accent)
		draw_circle(Vector2(5, 5), 1.5, Color(0.82, 0.64, 0.36, 0.55))
		draw_circle(Vector2(size.x - 5, 5), 1.5, Color(0.82, 0.64, 0.36, 0.55))
		draw_circle(Vector2(5, size.y - 5), 1.5, Color(0.82, 0.64, 0.36, 0.55))
		draw_circle(Vector2(size.x - 5, size.y - 5), 1.5, Color(0.82, 0.64, 0.36, 0.55))
	if item != null:
		draw_rect(Rect2(3, 3, size.x - 6, 2), border)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if _drag_started:
				_drag_started = false
			else:
				clicked.emit(self, item, event.button_index)
			accept_event()


func _get_drag_data(_pos: Vector2) -> Variant:
	if item == null or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return null
	_drag_started = true
	var preview := PanelContainer.new()
	preview.add_theme_stylebox_override("panel", UiKit.stylebox(Color(0.04, 0.05, 0.065, 0.98), item.quality_color(), 1, 4))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	preview.add_child(row)
	var icon := TextureRect.new()
	icon.texture = UiKit.icon_for_item(item)
	icon.custom_minimum_size = Vector2(28, 28)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(icon)
	row.add_child(UiKit.label(item.item_name, 11, item.quality_color()))
	set_drag_preview(preview)
	return {"source": self, "item": item}


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("source"):
		return false
	var src: ItemSlot = data["source"]
	if src == null or src == self or src.item == null:
		return false
	if slot_id != "":
		return Game.can_equip_to(src.item, slot_id)
	return true


func _drop_data(_pos: Vector2, data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY or not data.has("source"):
		return
	var src: ItemSlot = data["source"]
	if src == null:
		return
	_drag_started = false
	dropped.emit(src, self)


func _notification(what: int) -> void:
	if not _built:
		return
	if what == NOTIFICATION_MOUSE_ENTER:
		_hover = true
		queue_redraw()
		hovered.emit(self, item)
	elif what == NOTIFICATION_MOUSE_EXIT:
		_hover = false
		queue_redraw()
		unhovered.emit(self)
	elif what == NOTIFICATION_DRAG_END:
		_drag_started = false
