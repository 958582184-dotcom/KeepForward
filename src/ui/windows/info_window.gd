class_name InfoWindow
extends BaseWindow

var _scroll: ScrollContainer
var _refresh_queued := false
var _filter := "battle"
var _tab_buttons: Dictionary = {}


func _init() -> void:
	title = "信息"
	window_size = Vector2(260, 240)


func _after_build() -> void:
	Game.log_added.connect(_on_log_added)
	for key in ["battle", "summary"]:
		var b := UiKit.button("战斗" if key == "battle" else "综合", 9)
		b.custom_minimum_size = Vector2(40, 24)
		b.pressed.connect(_set_filter.bind(key))
		_footer_left.add_child(b)
		_tab_buttons[key] = b
	var clear_btn := UiKit.button("清除", 10)
	clear_btn.custom_minimum_size = Vector2(46, 24)
	clear_btn.add_theme_color_override("font_color", UiKit.COL_MUTED)
	clear_btn.pressed.connect(_clear_logs)
	_footer_left.add_child(clear_btn)
	_update_tabs()


func _set_filter(key: String) -> void:
	if _filter == key:
		return
	_filter = key
	_update_tabs()
	refresh()


func _update_tabs() -> void:
	for key in _tab_buttons:
		var b: Button = _tab_buttons[key]
		b.add_theme_color_override("font_color", UiKit.COL_GOLD if key == _filter else UiKit.COL_MUTED)


func _on_log_added(_text: String, _color: Color, kind: String) -> void:
	if not visible or _refresh_queued or kind != _filter:
		return
	_refresh_queued = true
	await get_tree().create_timer(0.18).timeout
	_refresh_queued = false
	if visible:
		refresh()


func _refresh_body(box: VBoxContainer) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_scroll)

	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 6)
	rv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(rv)

	var shown := 0
	for entry in Game.log_history:
		if String(entry.get("kind", "system")) != _filter:
			continue
		var l := UiKit.label(String(entry["text"]), 11, entry["color"])
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rv.add_child(l)
		shown += 1
	if shown == 0:
		var empty := "暂无伤害、掉落或经验记录。" if _filter == "battle" else "暂无副本、升级或装备记录。"
		rv.add_child(UiKit.label(empty, 11, UiKit.COL_DIM))
	_scroll_to_bottom()


func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	if _scroll != null:
		_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)


func _clear_logs() -> void:
	Game.clear_logs()
	refresh()
