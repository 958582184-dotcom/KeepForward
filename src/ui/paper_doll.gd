class_name PaperDoll
extends Control


func _ready() -> void:
	custom_minimum_size = Vector2(350, 320)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var parchment := Color(0.71, 0.56, 0.33, 1.0)
	var parchment_dark := Color(0.52, 0.39, 0.22, 1.0)
	var gold := Color(0.56, 0.42, 0.22, 1.0)
	var gold_hi := Color(0.82, 0.65, 0.36, 1.0)
	var outline := Color(0.25, 0.16, 0.08, 1.0)
	var sil := Color(0.27, 0.20, 0.14, 1.0)
	var sil_dark := Color(0.18, 0.12, 0.08, 1.0)

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

	# 人物剪影：缩小居中，避开上/下槽位
	draw_set_transform(Vector2(63, 59), 0.0, Vector2(0.68, 0.68))
	_ellipse(Vector2(165, 302), Vector2(62, 9), Color(0.13, 0.08, 0.04, 0.48))
	_ellipse(Vector2(165, 300), Vector2(48, 6), Color(0.10, 0.06, 0.03, 0.5))
	# 腿
	_limb(Vector2(151, 192), Vector2(147, 254), 16.0, sil, sil_dark)
	_limb(Vector2(179, 192), Vector2(183, 254), 16.0, sil, sil_dark)
	_limb(Vector2(147, 250), Vector2(145, 286), 14.0, sil, sil_dark)
	_limb(Vector2(183, 250), Vector2(185, 286), 14.0, sil, sil_dark)
	_ellipse(Vector2(138, 290), Vector2(23, 9), sil_dark)
	_ellipse(Vector2(138, 288), Vector2(19, 7), sil)
	_ellipse(Vector2(192, 290), Vector2(23, 9), sil_dark)
	_ellipse(Vector2(192, 288), Vector2(19, 7), sil)
	# 手臂
	_limb(Vector2(131, 92), Vector2(104, 142), 15.0, sil, sil_dark)
	_limb(Vector2(104, 142), Vector2(78, 177), 13.0, sil, sil_dark)
	_limb(Vector2(199, 92), Vector2(226, 142), 15.0, sil, sil_dark)
	_limb(Vector2(226, 142), Vector2(252, 177), 13.0, sil, sil_dark)
	draw_circle(Vector2(75, 181), 10.0, sil_dark)
	draw_circle(Vector2(75, 181), 7.5, sil)
	draw_circle(Vector2(255, 181), 10.0, sil_dark)
	draw_circle(Vector2(255, 181), 7.5, sil)
	# 躯干与骨盆
	var torso := PackedVector2Array([
		Vector2(128, 76), Vector2(202, 76), Vector2(196, 108),
		Vector2(190, 168), Vector2(140, 168), Vector2(134, 108),
	])
	_plate(torso, sil, sil_dark, 1.5)
	var pelvis := PackedVector2Array([
		Vector2(140, 166), Vector2(190, 166), Vector2(184, 198), Vector2(146, 198),
	])
	_plate(pelvis, sil, sil_dark, 1.5)
	# 颈与头
	draw_rect(Rect2(156, 48, 18, 24), sil)
	draw_rect(Rect2(156, 48, 18, 24), sil_dark, false, 2.0)
	draw_circle(Vector2(165, 28), 25.0, sil_dark)
	draw_circle(Vector2(165, 28), 22.0, sil)
	# 头部剪影轮廓，轻微发梢
	draw_colored_polygon(PackedVector2Array([
		Vector2(153, 10), Vector2(160, 1), Vector2(165, 8), Vector2(171, 0),
		Vector2(177, 9), Vector2(184, 7), Vector2(180, 19), Vector2(151, 19),
	]), sil)
	draw_line(Vector2(151, 174), Vector2(189, 174), Color(0.15, 0.10, 0.06, 0.9), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
