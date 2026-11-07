class_name PaperDoll
extends Control


func _ready() -> void:
	custom_minimum_size = Vector2(350, 320)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var fill := Color(0.135, 0.165, 0.220, 0.97)
	var fill_hi := Color(0.175, 0.210, 0.275, 0.98)
	var deep := Color(0.055, 0.070, 0.100, 0.96)
	var rim := Color(0.42, 0.48, 0.58, 0.85)
	var rim_hi := Color(0.62, 0.70, 0.82, 0.9)
	var gold := Color(0.78, 0.64, 0.36, 0.8)
	var gold_hi := Color(0.95, 0.78, 0.42, 0.92)
	var shadow := Color(0.015, 0.020, 0.030, 0.55)

	# 光晕与地面
	draw_circle(Vector2(165, 166), 132.0, Color(0.10, 0.13, 0.18, 0.55))
	draw_circle(Vector2(165, 166), 110.0, Color(0.13, 0.16, 0.22, 0.38))
	_ring(Vector2(165, 166), Vector2(92, 92), Color(0.36, 0.45, 0.58, 0.18), 1.0)
	_ellipse(Vector2(165, 302), Vector2(78, 12), shadow)
	_ring(Vector2(165, 302), Vector2(78, 12), Color(0.42, 0.48, 0.58, 0.25), 1.0)

	# 腿与护膝
	_limb(Vector2(151, 192), Vector2(147, 254), 16.0, fill, rim)
	_limb(Vector2(179, 192), Vector2(183, 254), 16.0, fill, rim)
	_limb(Vector2(147, 250), Vector2(145, 286), 14.0, fill, rim)
	_limb(Vector2(183, 250), Vector2(185, 286), 14.0, fill, rim)
	for x in [149.0, 181.0]:
		draw_circle(Vector2(x, 222), 9.0, rim)
		draw_circle(Vector2(x, 222), 6.5, fill_hi)
		draw_circle(Vector2(x - 1.5, 220), 2.0, gold_hi)
	draw_line(Vector2(150, 256), Vector2(148, 282), Color(0.32, 0.39, 0.48, 0.7), 2.0)
	draw_line(Vector2(180, 256), Vector2(182, 282), Color(0.32, 0.39, 0.48, 0.7), 2.0)

	# 靴子
	for x in [138.0, 192.0]:
		_ellipse(Vector2(x, 290), Vector2(23, 9), rim)
		_ellipse(Vector2(x, 289), Vector2(19, 7), fill_hi)
		draw_line(Vector2(x - 15, 293), Vector2(x - 6, 293), gold, 2.0)
		draw_arc(Vector2(x, 289), 17.0, PI * 1.05, PI * 1.55, 16, Color(0.72, 0.80, 0.90, 0.5), 1.0, true)

	# 手臂
	_limb(Vector2(131, 92), Vector2(104, 142), 15.0, fill, rim)
	_limb(Vector2(104, 142), Vector2(78, 177), 13.0, fill, rim)
	_limb(Vector2(199, 92), Vector2(226, 142), 15.0, fill, rim)
	_limb(Vector2(226, 142), Vector2(252, 177), 13.0, fill, rim)

	# 护腕
	_limb(Vector2(101, 151), Vector2(84, 171), 10.0, fill_hi, rim_hi)
	_limb(Vector2(229, 151), Vector2(246, 171), 10.0, fill_hi, rim_hi)
	draw_circle(Vector2(83, 174), 8.5, rim)
	draw_circle(Vector2(83, 174), 6.5, fill_hi)
	draw_circle(Vector2(247, 174), 8.5, rim)
	draw_circle(Vector2(247, 174), 6.5, fill_hi)
	draw_circle(Vector2(82, 173), 1.8, gold_hi)
	draw_circle(Vector2(246, 173), 1.8, gold_hi)

	# 肩甲
	for c in [Vector2(130, 86), Vector2(200, 86)]:
		_ellipse(c, Vector2(23, 16), rim)
		_ellipse(c + Vector2(0, -1), Vector2(20, 12.5), fill_hi)
		draw_arc(c + Vector2(0, -1), 18.0, PI * 1.05, PI * 1.55, 18,
			Color(0.72, 0.80, 0.90, 0.55), 1.5, true)
		draw_line(c + Vector2(-17, 7), c + Vector2(-8, 10), gold, 2.0)

	# 躯干
	var torso := PackedVector2Array([
		Vector2(128, 76), Vector2(202, 76), Vector2(196, 108),
		Vector2(190, 168), Vector2(140, 168), Vector2(134, 108),
	])
	_plate(torso, fill, rim, 2.0)
	var chest := PackedVector2Array([
		Vector2(145, 84), Vector2(185, 84), Vector2(181, 120),
		Vector2(176, 158), Vector2(154, 158), Vector2(149, 120),
	])
	_plate(chest, fill_hi, Color(0.34, 0.40, 0.50, 0.8), 1.0)
	draw_line(Vector2(165, 88), Vector2(165, 154), Color(0.30, 0.36, 0.45, 0.75), 1.0)
	draw_line(Vector2(143, 100), Vector2(158, 96), Color(0.58, 0.66, 0.78, 0.35), 1.0)
	draw_line(Vector2(187, 100), Vector2(172, 96), Color(0.58, 0.66, 0.78, 0.35), 1.0)
	draw_line(Vector2(149, 122), Vector2(181, 122), Color(0.28, 0.34, 0.43, 0.7), 1.0)
	draw_line(Vector2(152, 136), Vector2(178, 136), Color(0.28, 0.34, 0.43, 0.55), 1.0)
	draw_line(Vector2(134, 108), Vector2(196, 108), Color(0.55, 0.60, 0.68, 0.55), 1.0)
	draw_line(Vector2(134, 108), Vector2(128, 76), Color(0.68, 0.75, 0.85, 0.45), 1.0)
	draw_line(Vector2(196, 108), Vector2(202, 76), Color(0.28, 0.33, 0.42, 0.8), 1.0)

	# 胸徽
	draw_circle(Vector2(165, 104), 6.0, deep)
	draw_circle(Vector2(165, 104), 4.2, gold)
	draw_circle(Vector2(165, 104), 1.6, gold_hi)

	# 腰带与骨盆
	draw_line(Vector2(141, 171), Vector2(189, 171), deep, 5.0)
	draw_line(Vector2(141, 171), Vector2(189, 171), gold, 2.0)
	var buckle := PackedVector2Array([
		Vector2(165, 166), Vector2(172, 171), Vector2(165, 176), Vector2(158, 171),
	])
	_plate(buckle, gold, gold_hi, 1.0)
	var pelvis := PackedVector2Array([
		Vector2(140, 166), Vector2(190, 166), Vector2(184, 198), Vector2(146, 198),
	])
	_plate(pelvis, fill, rim, 1.5)
	draw_line(Vector2(146, 180), Vector2(157, 191), Color(0.32, 0.38, 0.47, 0.8), 1.0)
	draw_line(Vector2(184, 180), Vector2(173, 191), Color(0.32, 0.38, 0.47, 0.8), 1.0)
	draw_circle(Vector2(149, 187), 2.2, gold)
	draw_circle(Vector2(181, 187), 2.2, gold)
	draw_line(Vector2(146, 198), Vector2(150, 252), Color(0.26, 0.31, 0.38, 0.55), 1.0)
	draw_line(Vector2(184, 198), Vector2(180, 252), Color(0.26, 0.31, 0.38, 0.55), 1.0)

	# 颈与头盔
	draw_rect(Rect2(156, 48, 18, 24), fill)
	draw_rect(Rect2(156, 48, 18, 24), rim, false, 2.0)
	_ellipse(Vector2(165, 53), Vector2(13, 5), Color(0.22, 0.28, 0.36, 0.9))
	draw_circle(Vector2(165, 28), 25.0, rim)
	draw_circle(Vector2(165, 28), 22.0, fill_hi)
	draw_arc(Vector2(165, 28), 19.0, PI * 1.05, PI * 1.55, 22,
		Color(0.72, 0.80, 0.90, 0.55), 2.0, true)
	draw_line(Vector2(165, 6), Vector2(165, 13), gold, 2.0)
	var visor := PackedVector2Array([
		Vector2(149, 24), Vector2(181, 24), Vector2(181, 31), Vector2(171, 31),
		Vector2(171, 43), Vector2(159, 43), Vector2(159, 31), Vector2(149, 31),
	])
	_plate(visor, Color(0.025, 0.032, 0.045, 0.96), Color(0.20, 0.25, 0.33, 0.8), 1.0)
	draw_line(Vector2(151, 23), Vector2(179, 23), gold, 1.0)

	# 边线与金色细节
	draw_line(Vector2(154, 72), Vector2(176, 72), gold, 1.5)
	draw_line(Vector2(132, 82), Vector2(150, 82), gold, 1.0)
	draw_line(Vector2(180, 82), Vector2(198, 82), gold, 1.0)
	draw_line(Vector2(141, 171), Vector2(189, 171), Color(0.55, 0.44, 0.24, 0.7), 1.0)
	draw_rect(Rect2(0.5, 0.5, 349, 319), Color(0.24, 0.29, 0.37, 0.55), false, 1.0)


func _plate(points: PackedVector2Array, color: Color, edge: Color, width: float = 1.0) -> void:
	draw_colored_polygon(points, color)
	var line := points.duplicate()
	line.append(points[0])
	draw_polyline(line, edge, width, true)


func _ring(center: Vector2, radii: Vector2, color: Color, width: float = 1.0) -> void:
	var pts := PackedVector2Array()
	for i in 36:
		var a := TAU * float(i) / 36.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	pts.append(pts[0])
	draw_polyline(pts, color, width, true)


func _limb(a: Vector2, b: Vector2, width: float, fill: Color, rim: Color) -> void:
	draw_line(a, b, rim, width + 3.0, true)
	draw_line(a, b, fill, width, true)


func _ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 28:
		var a := TAU * float(i) / 28.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
