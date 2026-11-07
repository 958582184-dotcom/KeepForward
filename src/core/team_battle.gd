class_name TeamBattle
extends RefCounted

const MAX_ROUNDS := 200


static func build(dungeon: Dictionary, members: Array, rng: RandomNumberGenerator, leader_level: int) -> Dictionary:
	var profiles: Array = []
	for m in members:
		profiles.append(m.duplicate(true))
	profiles.sort_custom(func(a, b): return int(a.get("position", 1)) < int(b.get("position", 1)))
	for i in profiles.size():
		profiles[i]["position"] = i + 1

	var n := profiles.size()
	var party_level := 0
	for p in profiles:
		party_level += int(p.get("level", 1))
	party_level = int(round(float(party_level) / maxf(1.0, float(n))))
	var combatants := {}
	var order: Array = []
	for p in profiles:
		var id := int(p.get("id", 0))
		var st: Dictionary = p.get("stats", {})
		var c := {
			"id": id,
			"profile": p,
			"hp_max": maxf(1.0, float(st.get("hp_max", 1.0))),
			"hp": maxf(1.0, float(st.get("hp_max", 1.0))),
			"shield": 0.0,
			"alive": true,
			"attack_count": 0,
		}
		combatants[str(id)] = c
		order.append(str(id))

	var monsters: Array = []
	var win := true
	for type_id in dungeon.get("monsters", []):
		if not _has_alive(combatants):
			win = false
			break
		var mon_level := int(dungeon.get("level", 1))
		var diff := String(dungeon.get("difficulty", "normal"))
		var gap_mult := Data.level_gap_multipliers(party_level, mon_level)
		var total_hp := Data.monster_hp(String(type_id), mon_level, diff) * float(n) \
			* Data.TEAM_ENEMY_HP_SCALE * gap_mult.x
		var mon_dmg := Data.monster_damage(String(type_id), mon_level, diff) * float(n) \
			* Data.TEAM_ENEMY_ATTACK_SCALE * gap_mult.y
		var mon_armor := Data.monster_armor(mon_level)
		for c in combatants.values():
			c["shield"] = 0.0
		var enemy_hp := total_hp
		var turns: Array = []
		var rounds := 0
		while enemy_hp > 0.0 and _has_alive(combatants) and rounds < MAX_ROUNDS:
			rounds += 1
			for id in order:
				var c: Dictionary = combatants[id]
				if not bool(c["alive"]):
					continue
				var p: Dictionary = c["profile"]
				var st: Dictionary = p.get("stats", {})
				c["attack_count"] = int(c["attack_count"]) + 1
				var eff_armor := mon_armor * (1.0 - float(st.get("pen_pct", 0.0)))
				var armor_mit := clampf(eff_armor / (eff_armor + 90.0 + 12.0 * mon_level), 0.0, 0.75)
				var player_hit := maxf(1.0, float(st.get("dps", 1.0)) * float(st.get("interval", 1.0))
					* (1.0 - armor_mit))
				var dmg := maxi(1, int(round(player_hit * rng.randf_range(0.90, 1.10))))
				var note := ""
				var school := String(p.get("school", ""))
				if school == "swift" and int(c["attack_count"]) % 3 == 0:
					var extra := maxi(1, int(round(float(dmg) * 0.6)))
					dmg += extra
					note = "疾风额外伤害 +%d" % extra
				elif school == "arcane":
					var chance := 0.03 + 0.003 * float(p.get("weapon_ilvl", 1)) \
						+ 0.012 * float(p.get("weapon_quality", 0)) \
						+ float(st.get("extra_attack_pct", 0.0))
					if rng.randf() < clampf(chance, 0.0, 0.50):
						var echo := maxi(1, int(round(player_hit * rng.randf_range(0.90, 1.10))))
						dmg += echo
						note = "奥术回响 +%d" % echo
				dmg = mini(dmg, int(ceil(enemy_hp)))
				enemy_hp = maxf(0.0, enemy_hp - float(dmg))
				c["hp"] = minf(float(c["hp_max"]),
					float(c["hp"]) + float(dmg) * float(st.get("lifesteal_pct", 0.0)) + float(st.get("hp_regen", 0.0)))
				var shield_target := _front(combatants, order)
				if school == "moon" and shield_target != "":
					var front: Dictionary = combatants[shield_target]
					var gained := float(dmg) * 0.06
					front["shield"] = minf(float(front["hp_max"]) * 0.20, float(front["shield"]) + gained)
				var shield_id := 0
				var shield_value := 0
				if school == "moon" and shield_target != "":
					shield_id = int(combatants[shield_target]["id"])
					shield_value = int(ceil(float(combatants[shield_target]["shield"])))
				turns.append({
					"kind": "player", "actor_id": int(c["id"]), "actor_name": String(p.get("name", "")),
					"dmg": dmg, "enemy_hp": int(ceil(enemy_hp)),
					"actor_hp": int(ceil(float(c["hp"]))), "actor_shield": int(ceil(float(c["shield"]))),
					"shield_id": shield_id, "shield_value": shield_value, "note": note,
				})
				if enemy_hp <= 0.0:
					break
			if enemy_hp <= 0.0:
				break
			var target_id := _front(combatants, order)
			if target_id == "":
				break
			var target: Dictionary = combatants[target_id]
			var tst: Dictionary = target["profile"].get("stats", {})
			var armor: float = float(tst.get("armor_total", 0.0))
			var pmit := clampf(armor / (armor + 90.0 + 12.0 * mon_level), 0.0, 0.75)
			var avoid := (1.0 - pmit) * (1.0 - float(tst.get("dodge_pct", 0.0))) \
				* (1.0 - float(tst.get("parry_pct", 0.0))) * (1.0 - float(tst.get("block_pct", 0.0)))
			var mdmg := maxi(1, int(round(mon_dmg * avoid * rng.randf_range(0.90, 1.10))))
			var absorbed := mini(mdmg, int(floor(float(target["shield"]))))
			target["shield"] = float(target["shield"]) - float(absorbed)
			target["hp"] = maxf(0.0, float(target["hp"]) - float(mdmg - absorbed))
			if float(target["hp"]) <= 0.0:
				target["alive"] = false
			turns.append({
				"kind": "monster", "target_id": int(target["id"]),
				"dmg": mdmg, "absorbed": absorbed, "enemy_hp": int(ceil(enemy_hp)),
				"target_hp": int(ceil(float(target["hp"]))), "target_shield": int(ceil(float(target["shield"]))),
			})
		var mon_win := enemy_hp <= 0.0 and _has_alive(combatants)
		monsters.append({
			"type": String(type_id), "level": mon_level, "difficulty": diff,
			"hp_total": int(ceil(total_hp)), "turns": turns, "win": mon_win,
		})
		if not mon_win:
			win = false
			break

	if not _has_alive(combatants):
		win = false
	var rewards := _build_rewards(dungeon, profiles, rng, win)
	return {
		"dungeon": dungeon.duplicate(true),
		"members": profiles,
		"leader_id": _leader_id(profiles),
		"monsters": monsters,
		"win": win,
		"rewards": rewards,
	}


static func _has_alive(combatants: Dictionary) -> bool:
	for c in combatants.values():
		if bool(c["alive"]):
			return true
	return false


static func _front(combatants: Dictionary, order: Array) -> String:
	for id in order:
		if bool(combatants[id]["alive"]):
			return String(id)
	return ""


static func _leader_id(profiles: Array) -> int:
	for p in profiles:
		if bool(p.get("is_leader", false)):
			return int(p.get("id", 0))
	return int(profiles[0].get("id", 0)) if not profiles.is_empty() else 0


static func _build_rewards(dungeon: Dictionary, profiles: Array, rng: RandomNumberGenerator, win: bool) -> Dictionary:
	var rewards := {}
	if not win:
		return rewards
	var mon_list: Array = dungeon.get("monsters", [])
	var mon_level := int(dungeon.get("level", 1))
	var diff := String(dungeon.get("difficulty", "normal"))
	var is_boss := String(dungeon.get("kind", "normal")) == "boss"
	for p in profiles:
		var id := int(p.get("id", 0))
		var plevel := int(p.get("level", 1))
		var gold := 0
		var exp_gain := 0
		var kills := 0
		var bosses := 0
		for type_id in mon_list:
			var t := String(type_id)
			var e := int(round(float(Data.exp_reward(t, mon_level, diff)) * 0.5))
			if mon_level < plevel:
				e = int(round(float(e) * 0.3))
			var g := int(round(Data.gold_reward(t, mon_level, diff) * rng.randf_range(0.85, 1.2)))
			if t == "boss":
				e += 100
				g += 150
				bosses += 1
			kills += 1
			gold += g
			exp_gain += e
		var items: Array = []
		var count := Data.weighted_pick(rng, Data.DUNGEON_DROP_COUNT_WEIGHTS)
		var shift := Data.dungeon_quality_shift(mon_level, plevel, diff)
		for i in count:
			var q := Data.roll_quality(rng, Data.DUNGEON_QUALITY_WEIGHTS, shift)
			var drop := GameItem.create_dungeon_drop(rng, mon_level, q, String(p.get("character_id", "warrior")))
			items.append(drop.to_dict())
		var explore := 0.0
		if bool(p.get("is_leader", false)) and not is_boss:
			explore = float(Data.EXPLORE_CLEAR_GAIN.get(diff, 1.0))
		rewards[str(id)] = {
			"gold": gold,
			"exp": exp_gain,
			"items": items,
			"explore": explore,
			"metrics": {"kills": kills, "bosses": bosses, "items": items.size(), "dungeons": 1},
		}
	return rewards
