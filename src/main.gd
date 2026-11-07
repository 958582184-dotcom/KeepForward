extends Node2D

var world: World
var hud: HUD
var _shot := ""
var _dragging := false
var _drag_offset := Vector2i.ZERO
var _character_select: CharacterSelect
var _select_layer: CanvasLayer
var _passthrough_timer := 0.0
var _passthrough_points := PackedVector2Array()


func _ready() -> void:
	get_tree().auto_accept_quit = false
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	DisplayServer.window_set_size(Vector2i(960, 540))
	var usable := DisplayServer.screen_get_usable_rect()
	DisplayServer.window_set_position(usable.position + (usable.size - Vector2i(960, 540)) / 2)
	get_viewport().transparent_bg = true
	get_window().theme = UiKit.theme()

	var args := OS.get_cmdline_user_args()
	for a in args:
		if a.begins_with("--shot="):
			_shot = a.substr(7)

	if "--test" in args:
		Game.debug_report()
		get_tree().quit()
		return

	world = World.new()
	add_child(world)
	hud = HUD.new()
	hud.world = world
	add_child(hud)
	world.hud = hud
	hud.window_changed.connect(_update_mouse_passthrough)

	if _shot != "":
		_run_shot()
		return

	if "--auto" in args:
		_run_auto("--boss" in args)
		return

	if "--autofarm" in args:
		_run_autofarm()
		return

	if "--flow" in args:
		_run_flow()
		return

	if "--shoptest" in args:
		_run_shoptest()
		return

	if "--areatest" in args:
		_run_areatest()
		return

	if "--windowtest" in args:
		_run_windowtest()
		return

	if "--passthroughtest" in args:
		_run_passthrough_test()
		return

	if "--infotest" in args:
		_run_infotest()
		return

	if "--monstertest" in args:
		_run_monstertest()
		return

	if "--teambalancetest" in args:
		_run_teambalancetest()
		return

	if "--equiptest" in args:
		_run_equiptest()
		return

	if "--settest" in args:
		_run_settest()
		return

	if "--battletest" in args:
		_run_battletest()
		return

	if "--uitest" in args:
		_run_uitest()
		return

	if "--balancetest" in args:
		_run_balancetest()
		return

	if "--charactertest" in args:
		_run_charactertest()
		return

	if "--bagtest" in args:
		_run_bagtest()
		return

	if Game.loaded:
		world.set_class(Game.class_id)
	else:
		_show_character_select()


func _show_character_select() -> void:
	_select_layer = CanvasLayer.new()
	_select_layer.layer = 20
	add_child(_select_layer)
	_character_select = CharacterSelect.new()
	_select_layer.add_child(_character_select)
	_character_select.character_chosen.connect(_on_character_chosen)


func _on_character_chosen(cid: String) -> void:
	Game.new_game(cid)
	world.set_class(cid)
	if _character_select != null:
		_character_select.queue_free()
		_character_select = null
	if _select_layer != null:
		_select_layer.queue_free()
		_select_layer = null


func _process(delta: float) -> void:
	if _shot != "":
		return
	_passthrough_timer += delta
	if _passthrough_timer < 0.2:
		return
	_passthrough_timer = 0.0
	_update_mouse_passthrough()


func _update_mouse_passthrough() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if _character_select != null and is_instance_valid(_character_select) and _character_select.visible:
		_set_mouse_passthrough(PackedVector2Array())
		return
	if hud == null:
		return
	if hud.has_open_window():
		_set_mouse_passthrough(PackedVector2Array())
		return
	if world != null and world.is_combat_running():
		_set_mouse_passthrough(PackedVector2Array())
		return
	_set_mouse_passthrough(_base_passthrough_polygon())


func _base_passthrough_polygon() -> PackedVector2Array:
	var left := World.HORIZON_RECT.position.x
	var right := World.HORIZON_RECT.position.x + World.HORIZON_RECT.size.x
	var top := World.GROUND_Y
	var bottom := 720.0 if hud._bottom != null and hud._bottom.visible else World.GROUND_Y + World.HORIZON_RECT.size.y
	if Net.in_party:
		return PackedVector2Array([
			Vector2(left, 560.0),
			Vector2(right, 560.0),
			Vector2(right, bottom),
			Vector2(left, bottom),
		])
	var char_left := World.CHAR_X - 35.0
	var char_right := World.CHAR_X + 35.0
	var char_top := top - World.CHAR_SIZE - 26.0
	return PackedVector2Array([
		Vector2(left, top),
		Vector2(char_left, top),
		Vector2(char_left, char_top),
		Vector2(char_right, char_top),
		Vector2(char_right, top),
		Vector2(right, top),
		Vector2(right, bottom),
		Vector2(left, bottom),
	])


func _open_window_rect() -> Rect2:
	if hud == null or hud._current == null or not hud._current.visible:
		return Rect2()
	return hud._current.panel_rect()


func _set_mouse_passthrough(points: PackedVector2Array) -> void:
	if points == _passthrough_points:
		return
	_passthrough_points = points
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var window_size := Vector2(DisplayServer.window_get_size())
	var scaled := PackedVector2Array()
	for p in points:
		scaled.append(Vector2(p.x * window_size.x / viewport_size.x, p.y * window_size.y / viewport_size.y))
	get_window().mouse_passthrough_polygon = scaled
	DisplayServer.window_set_mouse_passthrough(scaled)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = DisplayServer.mouse_get_position() - DisplayServer.window_get_position()
			get_viewport().set_input_as_handled()
		elif _dragging:
			_dragging = false
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and _dragging:
		DisplayServer.window_set_position(DisplayServer.mouse_get_position() - _drag_offset)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_B:
				hud.toggle_window("bag")
			KEY_M:
				hud.toggle_window("dungeon")
			KEY_S:
				hud.toggle_window("shop")
			KEY_I:
				hud.toggle_window("info")
			KEY_T:
				hud.toggle_window("team")
			KEY_F:
				hud.refresh_dungeon()
			KEY_ESCAPE:
				hud.close_current()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Game.save_game()
		get_tree().quit()


func _run_shoptest() -> void:
	Game.debug_seed()
	print("SHOP start free=%d gold=%d stock=%d" % [Game.shop_free_left, Game.gold, Game.shop_stock.size()])
	for i in 6:
		var ok := Game.refresh_shop()
		print("SHOP refresh=%d ok=%s free=%d gold=%d" % [i + 1, str(ok), Game.shop_free_left, Game.gold])
	Game.auto_sell = true
	var before := Game.inventory_count()
	var it := GameItem.create(Game.rng, 10, 2, Game.class_id, "ring", "test")
	Game.receive_drop(it)
	print("SHOP autosell inv %d -> %d gold=%d" % [before, Game.inventory_count(), Game.gold])
	Game.set_auto_mode("repeat")
	print("SHOP mode=%s" % Game.auto_mode)
	get_tree().quit()


func _run_areatest() -> void:
	Game.debug_seed()
	print("AREA start idx=%d name=%s explore=%.0f" % [Game.area_index, String(Game.current_area()["name"]), Game.exploration])
	print("AREA switch1=%s idx=%d name=%s level=%d" % [
		str(Game.set_area(1)), Game.area_index, String(Game.current_area()["name"]), int(Game.dungeons[0]["level"])])
	Game.exploration = 50.0
	Game.save_game()
	Game.load_game()
	print("AREA saved idx=%d ex0=%.0f ex1=%.0f" % [
		Game.area_index, Game.area_exploration[0], Game.area_exploration[1]])
	print("AREA switch2=%s (locked)" % str(Game.set_area(2)))
	get_tree().quit()


func _run_charactertest() -> void:
	for cid in Data.CHARACTER_ORDER:
		Game.new_game(cid)
		var st := Game.compute_stats()
		var ch := Data.character_def(cid)
		print("CHAR %s name=%s talent=%s hp=%d armor=%.0f crit=%.2f haste=%.2f sp=%.0f ls=%.2f pen=%.2f" % [
			cid, ch["name"], ch["title"], int(st["hp_max"]), float(st["armor_total"]),
			float(st["crit_pct"]), float(st["haste_pct"]), float(st["sp"]),
			float(st["lifesteal_pct"]), float(st["pen_pct"])])
	get_tree().quit()


func _run_balancetest() -> void:
	var normal_explore := float(Data.MONSTER_TYPES["normal"]["explore"])
	var elite_explore := float(Data.MONSTER_TYPES["elite"]["explore"])
	var per_run := normal_explore * 3.0 + elite_explore
	print("BALANCE elite_hp=%.2f hero_hp=%.2f boss_hp=%.2f explore_run=%.2f runs=%.1f" % [
		float(Data.DIFFICULTIES["elite"]["hp"]), float(Data.DIFFICULTIES["hero"]["hp"]),
		float(Data.MONSTER_TYPES["boss"]["hp"]), per_run, 100.0 / per_run])
	get_tree().quit()


func _run_uitest() -> void:
	Game.debug_seed()
	hud.toggle_window("bag")
	await get_tree().create_timer(0.2).timeout
	var dolls := hud._bag.find_children("*", "PaperDoll", true, false)
	var x0: float = dolls[0].global_position.x if not dolls.is_empty() else -1.0
	hud._bag._toggle_stats()
	await get_tree().create_timer(0.2).timeout
	dolls = hud._bag.find_children("*", "PaperDoll", true, false)
	var x1: float = dolls[0].global_position.x if not dolls.is_empty() else -1.0
	print("UI bag_left_stable=%s x0=%.1f x1=%.1f" % [str(absf(x0 - x1) < 0.5), x0, x1])

	Game.push_log("UI TEST", Color.WHITE)
	hud.toggle_window("info")
	await get_tree().create_timer(0.2).timeout
	var before := Game.log_history.size()
	hud._info._clear_logs()
	await get_tree().create_timer(0.1).timeout
	print("UI info_clear=%s before=%d after=%d" % [str(Game.log_history.is_empty()), before, Game.log_history.size()])

	hud.toggle_window("shop")
	await get_tree().create_timer(0.2).timeout
	var refresh = hud._shop._footer_left.get_child(0)
	print("UI shop_refresh='%s' gold=%d" % [refresh.text, Game.gold])
	get_tree().quit()


func _run_settest() -> void:
	Game.new_game("warrior")
	Game.level = 16
	var seen := {}
	for i in 80:
		var it := GameItem.create_dungeon_drop(Game.rng, 16, 2, "warrior")
		if it.set_id != "":
			seen[it.set_id] = String(it.set_name)
	print("SETTEST drops=%d" % seen.size())
	for key in ["head", "chest", "hands", "legs", "feet"]:
		Game.equipment[key] = null
	for key in ["head", "chest", "hands"]:
		var it := GameItem.create_set_piece(Game.rng, "lion_wrath", key, 16, 2, "warrior")
		it.req_level = 1
		Game.equipment[key] = it
	var st := Game.compute_stats()
	print("SETTEST lion3 active=%s dps=%.0f crit=%.1f%%" % [
		str(st.get("active_sets", [])), float(st.get("dps", 0)), float(st.get("crit_pct", 0)) * 100.0])
	for key in ["legs", "feet"]:
		var it := GameItem.create_set_piece(Game.rng, "lion_wrath", key, 15, 2, "warrior")
		it.req_level = 1
		Game.equipment[key] = it
	var st2 := Game.compute_stats()
	print("SETTEST split_levels active=%s" % str(st2.get("active_sets", [])))
	for lv in [8, 12, 16, 30]:
		Game.level = lv
		for key in Data.EQUIP_ORDER:
			var it := GameItem.create(Game.rng, lv, 2, "warrior", key, "test")
			it.req_level = 1
			Game.equipment[key] = it
		print("SETTEST cp lv=%d blue=%d" % [lv, Game.combat_power()])
	get_tree().quit()


func _run_battletest() -> void:
	Game.debug_seed()
	world.set_class(Game.class_id)
	print("BATTLE idle_bar=%s char_x=%.0f meet_x=%.0f grass_w=%.0f spawn_x=%.0f" % [
		str(world._player_bar.visible), World.CHAR_X, World.MEET_X,
		World.HORIZON_RECT.size.x, World.MONSTER_SPAWN_X])
	print("BATTLE player_bar_right=%.1f char_right=%.1f" % [
		world._player_bar.position.x + world._player_bar.size.x,
		World.CHAR_X + World.CHAR_SIZE * 0.5])
	world.start_dungeon(Game.dungeons[0])
	var saw_bar := false
	for i in 24:
		await get_tree().create_timer(0.2).timeout
		if world._player_bar.visible:
			saw_bar = true
	print("BATTLE saw_player_bar=%s" % str(saw_bar))
	var guard := 0
	while Game.busy and guard < 100:
		await get_tree().create_timer(0.2).timeout
		guard += 1
	print("BATTLE bar_after_dungeon=%s" % str(world._player_bar.visible))
	get_tree().quit()


func _run_windowtest() -> void:
	Game.new_game("warrior")
	hud.toggle_window("bag")
	hud.toggle_window("info")
	await get_tree().create_timer(0.2).timeout
	print("WINDOW bag=%s info=%s" % [str(hud._bag.visible), str(hud._info.visible)])
	hud.toggle_window("dungeon")
	await get_tree().create_timer(0.2).timeout
	print("WINDOW bag=%s map=%s info=%s" % [str(hud._bag.visible), str(hud._dungeon.visible), str(hud._info.visible)])
	hud.toggle_window("more")
	await get_tree().create_timer(0.2).timeout
	print("WINDOW map=%s more=%s info=%s" % [str(hud._dungeon.visible), str(hud._more.visible), str(hud._info.visible)])
	hud.toggle_window("info")
	await get_tree().create_timer(0.2).timeout
	print("WINDOW more=%s info=%s" % [str(hud._more.visible), str(hud._info.visible)])
	get_tree().quit()


func _run_passthrough_test() -> void:
	Game.new_game("warrior")
	world.set_class("warrior")
	await get_tree().create_timer(0.6).timeout
	_update_mouse_passthrough()
	print("PASSTHROUGH points=%s window=%s" % [str(_passthrough_points.size()), str(DisplayServer.window_get_size())])
	await get_tree().create_timer(4.0).timeout
	get_tree().quit()


func _run_infotest() -> void:
	Game.new_game("warrior")
	world.set_class("warrior")
	await get_tree().create_timer(0.6).timeout
	hud.toggle_window("info")
	await get_tree().create_timer(0.4).timeout
	print("INFOTEST current=%s info=%s pass=%s" % [str(hud._current), str(hud._info.visible), str(_passthrough_points.size())])
	await get_tree().create_timer(4.0).timeout
	get_tree().quit()


func _run_monstertest() -> void:
	Game.new_game("warrior")
	world.set_class("warrior")
	await get_tree().create_timer(0.6).timeout
	world.start_dungeon(Game.dungeons[0])
	await get_tree().create_timer(1.5).timeout
	print("MONSTERTEST busy=%s pass=%s" % [str(world.is_combat_running()), str(_passthrough_points.size())])
	await get_tree().create_timer(5.0).timeout
	get_tree().quit()


func _run_teambalancetest() -> void:
	Game.new_game("warrior")
	for lv in [8, 11]:
		for quality in [1, 4]:
			Game.level = lv
			Game.equipment.clear()
			for key in Data.EQUIP_ORDER:
				Game.equipment[key] = null
			for slot in ["main", "chest", "legs", "feet"]:
				Game.equipment[slot] = GameItem.create(Game.rng, lv, quality, "warrior", slot, "test")
			var p1: Dictionary = Game.profile_snapshot()
			p1["id"] = 1
			p1["position"] = 1
			p1["is_leader"] = true
			var p2: Dictionary = p1.duplicate(true)
			p2["id"] = 2
			p2["position"] = 2
			p2["is_leader"] = false
			var target_level := 17 if lv == 8 else 30
			var d := {"level": target_level, "difficulty": "normal", "kind": "normal",
				"monsters": ["normal", "normal", "normal", "elite"]}
			var result := TeamBattle.build(d, [p1, p2], Game.rng, lv)
			print("TEAMBALANCE lv=%d q=%d dungeon=%d win=%s" % [
				lv, quality, target_level, str(result.get("win", false))])
	get_tree().quit()


func _run_equiptest() -> void:
	for lv in [1, 8, 23, 25]:
		print("EQUIPTEST shop_levels lv=%d levels=%s" % [lv, str(Data.shop_equip_levels(lv))])
	Game.new_game("warrior")
	Game.level = 23
	Game._generate_shop_stock()
	var reqs: Array = []
	var prices: Array = []
	for it in Game.shop_stock:
		reqs.append(it.req_level)
		prices.append(it.shop_price_value())
	print("EQUIPTEST shop23 reqs=%s min_price=%d max_price=%d" % [str(reqs), prices.min(), prices.max()])
	var low := GameItem.create(Game.rng, 20, 0, "warrior", "main", "shop")
	Game.level = 10
	print("EQUIPTEST use_req=%d at_lv10=%s" % [low.req_level, str(Game._can_use_item(low))])
	var drop_reqs: Array = []
	for i in 20:
		var drop := GameItem.create_dungeon_drop(Game.rng, 17, 1, "warrior")
		if not drop_reqs.has(drop.req_level):
			drop_reqs.append(drop.req_level)
	drop_reqs.sort()
	print("EQUIPTEST drop17_reqs=%s" % str(drop_reqs))
	get_tree().quit()


func _run_bagtest() -> void:
	Game.debug_seed()
	var item: GameItem = Game.inventory[0]
	Game.toggle_lock(item)
	var before := Game.inventory_count()
	Game.sell_item(item)
	print("BAG locked=%s sell_blocked=%s" % [str(item.locked), str(Game.inventory_count() == before)])
	Game.dismantle_item(item)
	print("BAG dismantle_blocked=%s" % str(Game.inventory_count() == before))
	Game.toggle_lock(item)
	Game.dismantle_item(item)
	print("BAG dismantled=%s materials=%d" % [str(Game.inventory_count() == before - 1), Game.materials])
	var trinket := GameItem.create(Game.rng, 10, 2, Game.class_id, "trinket", "test")
	Game.receive_drop(trinket)
	print("BAG trinket_equipped=%s" % str(Game.equipment.get("trinket") != null))
	Game.save_game()
	Game.load_game()
	print("BAG load materials=%d trinket=%s" % [Game.materials, str(Game.equipment.get("trinket") != null)])
	get_tree().quit()


func _run_flow() -> void:
	if Game.class_id == "":
		Game.new_game("warrior")
	world.set_class(Game.class_id)
	Game.auto_mode = "off"
	await get_tree().create_timer(0.4).timeout
	print("FLOW class=%s level=%d gold=%d inv=%d equip_main=%s" % [
		Game.class_id, Game.level, Game.gold, Game.inventory_count(),
		"yes" if Game.equipment.get("main") != null else "no"])
	Game.save_game()
	await get_tree().create_timer(0.2).timeout
	var ok := Game.load_game()
	print("FLOW save_load=%s level=%d gold=%d" % [str(ok), Game.level, Game.gold])
	get_tree().quit()


func _run_autofarm() -> void:
	Game.debug_seed()
	Game.auto_mode = "next"
	world.set_class(Game.class_id)
	await get_tree().create_timer(0.2).timeout
	world.resume_auto(0.1)
	await get_tree().create_timer(30.0).timeout
	print("AUTOFARM busy=%s lv=%d gold=%d inv=%d explore=%.1f mode=%s" % [
		str(Game.busy), Game.level, Game.gold, Game.inventory_count(), Game.exploration, Game.auto_mode])
	get_tree().quit()


func _run_auto(boss: bool) -> void:
	Game.debug_seed()
	world.set_class(Game.class_id)
	await get_tree().create_timer(0.2).timeout
	var d: Dictionary = Game.make_boss_dungeon() if boss else Game.dungeons[0]
	print("AUTO_START ", Data.dungeon_title(d), " ", d["difficulty"])
	world.start_dungeon(d)
	await get_tree().create_timer(18.0).timeout
	print("AUTO_RESULT busy=%s lv=%d gold=%d inv=%d explore=%.1f clears=%d" % [
		str(Game.busy), Game.level, Game.gold, Game.inventory_count(), Game.exploration, Game.area_clears])
	get_tree().quit()


# ---------- 截图 / 调试 ----------

func _run_shot() -> void:
	if _shot == "class" or _shot == "firstrun":
		Game.class_id = ""
		Game.loaded = false
		Game.new_game("warrior")
		world.set_class("warrior")
		await get_tree().create_timer(0.4).timeout
	elif _shot == "select":
		Game.class_id = ""
		Game.loaded = false
		_show_character_select()
		await get_tree().create_timer(0.4).timeout
	elif _shot == "team":
		Game.new_game("warrior")
		world.set_class("warrior")
		await get_tree().create_timer(0.3).timeout
		if not Net.create_room("测试队伍", ""):
			Net.in_party = true
			Net.is_host = true
			Net.local_id = 1
			Net.leader_id = 1
			Net.room_name = "测试队伍"
			var p: Dictionary = Game.profile_snapshot()
			p["id"] = 1
			p["position"] = 1
			p["is_leader"] = true
			Net.members = [p]
			Net.party_changed.emit()
		hud.toggle_window("team")
		await get_tree().create_timer(0.4).timeout
	elif _shot == "main":
		Game.new_game("warrior")
		world.set_class("warrior")
		await get_tree().create_timer(0.4).timeout
	elif _shot == "inspect":
		Game.new_game("warrior")
		world.set_class("warrior")
		await get_tree().create_timer(0.3).timeout
		Net.in_party = true
		Net.is_host = true
		Net.local_id = 1
		Net.leader_id = 1
		Net.room_name = "测试队伍"
		var p: Dictionary = Game.profile_snapshot()
		p["id"] = 1
		p["position"] = 1
		p["is_leader"] = true
		Net.members = [p]
		Net.party_changed.emit()
		hud.toggle_window("team")
		await get_tree().create_timer(0.4).timeout
		hud._team._show_equipment(Net.members[0])
		await get_tree().create_timer(0.4).timeout
	else:
		Game.debug_seed()
		Game.auto_mode = "next"
		world.set_class(Game.class_id)
		await get_tree().create_timer(0.25).timeout
		match _shot:
			"bag":
				hud.toggle_window("bag")
			"bagcollapsed":
				hud.toggle_window("bag")
				await get_tree().create_timer(0.25).timeout
				hud._bag._toggle_stats()
			"tooltip":
				hud.toggle_window("bag")
				await get_tree().create_timer(0.25).timeout
				for it in Game.inventory:
					if it != null:
						hud._bag._tip.show_item(it, Game.compare_item(it), Game.class_id, "")
						hud._bag._tip.position = Vector2(470, 190)
						break
			"map":
				hud.toggle_window("dungeon")
			"shop":
				hud.toggle_window("shop")
			"more":
				hud.toggle_window("more")
			"stats":
				hud.toggle_window("stats")
			"info":
				if not Game.dungeons.is_empty():
					world.start_dungeon(Game.dungeons[0])
				await get_tree().create_timer(1.8).timeout
				hud.toggle_window("info")
			"bossmap":
				Game.exploration = 100.0
				Game.exploration_changed.emit()
				hud.toggle_window("dungeon")
			"encounter":
				if not Game.dungeons.is_empty():
					world.start_dungeon(Game.dungeons[0])
			"party":
				var p1: Dictionary = Game.profile_snapshot()
				p1["id"] = 1
				p1["position"] = 1
				p1["is_leader"] = true
				var p2: Dictionary = Game.profile_snapshot()
				p2["id"] = 2
				p2["character_id"] = "sera"
				p2["name"] = "塞拉"
				p2["position"] = 2
				Net.in_party = true
				Net.local_id = 1
				Net.is_host = true
				Net.members = [p1, p2]
				world.set_party_members(Net.members)
				world._player_bar.visible = true
				world._player_bar.value = world._player_bar.max_value * 0.8
				world._shield_bar.visible = true
				world._shield_bar.value = world._shield_bar.max_value * 0.45
			"bossencounter":
				Game.exploration = 100.0
				world.start_dungeon(Game.make_boss_dungeon())
	await get_tree().create_timer(3.4 if _shot == "firstrun" else 1.15).timeout
	await RenderingServer.frame_post_draw
	var dir := "res://shots"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var img := get_viewport().get_texture().get_image()
	if img != null:
		var path := "%s/%s.png" % [dir, _shot]
		img.save_png(path)
		print("SHOT_OK ", ProjectSettings.globalize_path(path))
	else:
		print("SHOT_FAIL no image")
	get_tree().quit()
