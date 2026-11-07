class_name PaperDoll
extends Control

var _silhouette: Texture2D


func _ready() -> void:
	custom_minimum_size = Vector2(350, 320)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_silhouette = load("res://assets/equipment_silhouette.png")


func _draw() -> void:
	var parchment := Color(0.71, 0.56, 0.33, 1.0)
	var parchment_dark := Color(0.52, 0.39, 0.22, 1.0)
	var gold := Color(0.56, 0.42, 0.22, 1.0)
	var gold_hi := Color(0.82, 0.65, 0.36, 1.0)
	var outline := Color(0.25, 0.16, 0.08, 1.0)

	# 羊皮纸底与菱形暗纹
	draw_rect(Rect2(0, 0, 350, 320), parchment)
	for i in range(-320, 352, 24):
		draw_line(Vector2(i, 0), Vector2(i + 320, 320), Color(0.40, 0.29, 0.15, 0.16), 1.0)
		draw_line(Vector2(i, 320), Vector2(i + 320, 0), Color(0.86, 0.72, 0.48, 0.11), 1.0)
	for i in range(12, 350, 48):
		draw_line(Vector2(i, 8), Vector2(i, 312), Color(0.42, 0.30, 0.16, 0.08), 1.0)

	# 边缘与装饰角
	draw_rect(Rect2(0, 0, 350, 320), outline, false, 7.0)
	draw_rect(Rect2(3.5, 3.5, 343, 313), gold, false, 3.0)
	draw_rect(Rect2(8, 8, 334, 304), Color(0.82, 0.66, 0.38, 0.55), false, 1.0)
	for c in [Vector2(8, 8), Vector2(342, 8), Vector2(8, 312), Vector2(342, 312)]:
		draw_circle(c, 5.0, parchment_dark)
		draw_circle(c, 3.2, gold_hi)
		draw_circle(c, 1.4, outline)

	# 人物剪影：使用参考图中提取的人形
	_ellipse(Vector2(175, 276), Vector2(60, 9), Color(0.13, 0.08, 0.04, 0.42))
	_ellipse(Vector2(175, 275), Vector2(46, 6), Color(0.10, 0.06, 0.03, 0.45))
	if _silhouette != null:
		var sh := 230.0
		var sw := sh * float(_silhouette.get_width()) / float(_silhouette.get_height())
		draw_texture_rect(_silhouette, Rect2(Vector2(175.0 - sw * 0.5, 45), Vector2(sw, sh)), false)


func _plate(points: PackedVector2Array, color: Color, edge: Color, width: float = 1.0) -> void:
	draw_colored_polygon(points, color)
	var line := points.duplicate()
	line.append(points[0])
	draw_polyline(line, edge, width, true)


func _limb(a: Vector2, b: Vector2, width: float, fill: Color, rim: Color) -> void:
	draw_line(a, b, rim, width + 3.0, true)
	draw_line(a, b, fill, width, true)


func _ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 28:
		var a := TAU * float(i) / 28.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
