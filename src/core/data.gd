class_name Data
extends RefCounted

const TITLE := "KeepForward"
const VERSION := "0.79.0"
const SAVE_PATH := "user://ember_walker_save.json"
const INVENTORY_SIZE := 100
const MAX_LEVEL := 60

const TEAM_PORT := 45872
const TEAM_DISCOVERY_PORT := 45871
const TEAM_ENEMY_ATTACK_SCALE := 0.45
const TEAM_ENEMY_HP_SCALE := 1.35

const CLASS_ORDER := ["warrior", "mage", "archer"]
const CHARACTER_ORDER := ["warrior", "mage", "archer", "warden", "oracle", "ranger"]

const CHARACTERS := {
	"warrior": {
		"name": "罗兰", "title": "铁壁", "tag": "重装 · 坚韧",
		"color": "#e0a24a", "archetype": "warrior",
		"sprite": "res://assets/characters/roland_walk.png",
		"portrait": "res://assets/characters/roland_face.png",
		"tint": "#ffffff", "frame_w": 16, "frame_h": 16,
		"desc": "以生命和护甲硬抗伤害，适合稳扎稳打的长时间战斗。",
		"bonus_text": "生命上限 +15%\n护甲 +10%",
		"hp_pct": 0.15, "armor_pct": 0.10,
	},
	"mage": {
		"name": "梅林", "title": "奥术", "tag": "秘法 · 爆发",
		"color": "#ffad66", "archetype": "mage",
		"sprite": "res://assets/characters/merlin_walk.png",
		"portrait": "res://assets/characters/merlin_face.png",
		"tint": "#ffffff", "frame_w": 16, "frame_h": 16,
		"desc": "把智力转化为纯粹的法术强度，并用少量暴击放大爆发。",
		"bonus_text": "法术强度 +15%\n暴击 +5%",
		"power_pct": 0.15, "crit": 0.05,
	},
	"archer": {
		"name": "艾拉", "title": "疾风", "tag": "游侠 · 迅捷",
		"color": "#79d17c", "archetype": "archer",
		"sprite": "res://assets/characters/ella_walk.png",
		"portrait": "res://assets/characters/ella_face.png",
		"tint": "#ffffff", "frame_w": 16, "frame_h": 16,
		"desc": "靠高频攻击和暴击滚雪球，持续输出能力最强。",
		"bonus_text": "暴击 +8%\n急速 +8%",
		"crit": 0.08, "haste": 0.08,
	},
	"warden": {
		"name": "布伦", "title": "狂战", "tag": "重装 · 狂战",
		"color": "#ff7b5e", "archetype": "warrior",
		"sprite": "res://assets/characters/wren_walk.png",
		"portrait": "res://assets/characters/wren_face.png",
		"tint": "#ffffff", "frame_w": 16, "frame_h": 16,
		"desc": "放弃部分防守换取更凶的进攻，用力量与速度压过敌人。",
		"bonus_text": "攻击强度 +10%\n急速 +3%",
		"power_pct": 0.10, "haste": 0.03,
	},
	"oracle": {
		"name": "塞拉", "title": "月辉", "tag": "秘法 · 月辉",
		"color": "#d18cff", "archetype": "mage",
		"sprite": "res://assets/characters/sera_walk.png",
		"portrait": "res://assets/characters/sera_face.png",
		"tint": "#ffffff", "frame_w": 16, "frame_h": 16,
		"desc": "用月光维持生命，把造成的伤害转成自己的续航。",
		"bonus_text": "吸血 +6%\n生命上限 +5%",
		"lifesteal": 0.06, "hp_pct": 0.05,
	},
	"ranger": {
		"name": "凯", "title": "破甲", "tag": "游侠 · 破甲",
		"color": "#5ec8d8", "archetype": "archer",
		"sprite": "res://assets/characters/kai_walk.png",
		"portrait": "res://assets/characters/kai_face.png",
		"tint": "#ffffff", "frame_w": 16, "frame_h": 16,
		"desc": "专注射穿护甲，面对高防御目标时伤害更稳定。",
		"bonus_text": "护甲穿透 +10%",
		"pen": 0.10,
	},
}

const CLASSES := {
	"warrior": {
		"name": "战士",
		"role": "板甲 / 重甲 · 力量",
		"desc": "力量与耐力。高护甲、高生命，用最朴素的方式碾过敌阵。",
		"sprite": "res://assets/characters/roland_walk.png",
		"color": "#e0a24a",
		"main": "strength",
		"attack_type": "physical",
		"armor_types": ["plate", "heavy"],
		"weapon_types": ["sword", "mace"],
		"offhand_type": "shield",
		"attack_interval": 2.2,
		"base_hp": 70,
		"base": {"strength": 13, "agility": 4, "intellect": 2, "stamina": 13},
		"growth": {"strength": 2.7, "agility": 0.35, "intellect": 0.30, "stamina": 1.9},
	},
	"mage": {
		"name": "法师",
		"role": "布甲 / 轻甲 · 智力",
		"desc": "智力与奥术。脆皮，但法术强度与穿透让伤害曲线陡得吓人。",
		"sprite": "res://assets/characters/merlin_walk.png",
		"color": "#6fa8ff",
		"main": "intellect",
		"attack_type": "magic",
		"armor_types": ["cloth", "light"],
		"weapon_types": ["wand", "codex"],
		"offhand_type": "tome",
		"attack_interval": 2.4,
		"base_hp": 50,
		"base": {"strength": 3, "agility": 5, "intellect": 14, "stamina": 8},
		"growth": {"strength": 0.30, "agility": 0.40, "intellect": 2.9, "stamina": 1.4},
	},
	"archer": {
		"name": "弓箭手",
		"role": "皮甲 / 锁甲 · 敏捷",
		"desc": "敏捷与猎弓。攻速快、暴击高、闪避好，靠持续输出滚雪球。",
		"sprite": "res://assets/characters/ella_walk.png",
		"color": "#79d17c",
		"main": "agility",
		"attack_type": "physical",
		"armor_types": ["leather", "mail"],
		"weapon_types": ["shortbow", "longbow"],
		"offhand_type": "quiver",
		"attack_interval": 1.7,
		"base_hp": 60,
		"base": {"strength": 4, "agility": 14, "intellect": 3, "stamina": 9},
		"growth": {"strength": 0.35, "agility": 2.9, "intellect": 0.35, "stamina": 1.5},
	},
}

const ARMOR_NAMES := {"plate": "板甲", "heavy": "重甲", "cloth": "布甲", "light": "轻甲", "leather": "皮甲", "mail": "锁甲"}
const ARMOR_SLOT_NAMES := {"head": "头盔", "chest": "胸甲", "hands": "护手", "legs": "护腿", "feet": "战靴"}
const WEAPON_NAMES := {"sword": "长剑", "axe": "战斧", "mace": "战锤", "staff": "法杖", "wand": "魔杖",
	"codex": "法典", "bow": "长弓", "shortbow": "短弓", "longbow": "长弓"}
const OFFHAND_NAMES := {"shield": "盾牌", "tome": "魔典", "quiver": "箭袋"}

const SLOT_INFO := {
	"head": {"name": "头盔", "short": "头盔", "kind": "armor"},
	"chest": {"name": "胸甲", "short": "胸甲", "kind": "armor"},
	"hands": {"name": "手套", "short": "手套", "kind": "armor"},
	"legs": {"name": "腿甲", "short": "腿甲", "kind": "armor"},
	"feet": {"name": "鞋子", "short": "鞋子", "kind": "armor"},
	"main": {"name": "主武器", "short": "主武器", "kind": "weapon"},
	"off": {"name": "副武器", "short": "副武器", "kind": "offhand"},
	"neck": {"name": "项链", "short": "项链", "kind": "jewel"},
	"trinket": {"name": "饰品", "short": "饰品", "kind": "jewel"},
	"ring": {"name": "戒指", "short": "戒指", "kind": "jewel"},
	"rune": {"name": "符文", "short": "符文", "kind": "rune"},
	"ring1": {"name": "戒指", "short": "戒指", "kind": "jewel"},
	"rune1": {"name": "符文", "short": "符文", "kind": "rune"},
	"rune2": {"name": "符文", "short": "符文", "kind": "rune"},
	"rune3": {"name": "符文", "short": "符文", "kind": "rune"},
}

const EQUIP_ORDER := ["head", "neck", "chest", "main", "off", "hands", "legs",
	"ring1", "trinket", "feet", "rune1", "rune2", "rune3"]

const QUALITIES := [
	{"name": "普通", "color": "#b9c2d0", "mult": 1.00, "affixes": 1},
	{"name": "优秀", "color": "#4fe06a", "mult": 1.06, "affixes": 2},
	{"name": "精良", "color": "#4aa3ff", "mult": 1.14, "affixes": 3},
	{"name": "史诗", "color": "#b96bff", "mult": 1.26, "affixes": 4},
	{"name": "传说", "color": "#ff9f43", "mult": 1.42, "affixes": 5},
]

const QUALITY_PREFIX := ["磨损的", "坚固的", "精工的", "史诗的", "传世的"]

const SETS := {
	"throne_oath": {"name": "王座之誓", "cls": "warrior", "track": "armor", "armor_type": "plate", "max": 5,
		"pieces": {"head": "不眠王冠", "chest": "王座壁垒", "hands": "誓约之握", "legs": "不退之膝", "feet": "最后岗哨"},
		"bonuses": {3: {"armor_pct": 0.08, "parry_pct": 0.02}, 5: {"hp_pct": 0.08, "armor_pct": 0.10}}},
	"ashen_veteran": {"name": "灰烬老兵", "cls": "warrior", "track": "armor", "armor_type": "plate", "max": 2,
		"pieces": {"chest": "灰烬胸甲", "legs": "余烬护腿"},
		"bonuses": {2: {"hp_pct": 0.06, "armor_pct": 0.05}}},
	"traitor_shell": {"name": "背叛者之壳", "cls": "warrior", "track": "armor", "armor_type": "plate", "max": 3,
		"pieces": {"head": "叛徒的沉默", "hands": "伪誓之手", "feet": "逃亡者之靴"},
		"bonuses": {3: {"dodge_pct": 0.03, "armor_pct": 0.06}}},
	"lion_wrath": {"name": "雄狮之怒", "cls": "warrior", "track": "armor", "armor_type": "heavy", "max": 5,
		"pieces": {"head": "狮鬃战盔", "chest": "怒吼胸甲", "hands": "裂爪护手", "legs": "猎王护腿", "feet": "追猎战靴"},
		"bonuses": {3: {"dmg_pct": 0.05, "crit_pct": 0.03}, 5: {"dmg_pct": 0.07, "haste_pct": 0.04}}},
	"broken_fang": {"name": "断牙", "cls": "warrior", "track": "armor", "armor_type": "heavy", "max": 2,
		"pieces": {"chest": "断牙胸甲", "hands": "残牙护手"},
		"bonuses": {2: {"crit_pct": 0.03, "haste_pct": 0.03}}},
	"butcher_feast": {"name": "屠夫之宴", "cls": "warrior", "track": "armor", "armor_type": "heavy", "max": 3,
		"pieces": {"head": "屠夫面具", "legs": "血宴护腿", "feet": "筵席之靴"},
		"bonuses": {3: {"dmg_pct": 0.05, "pen_pct": 0.03}}},
	"forgemaster": {"name": "铸火者的杰作", "cls": "warrior", "track": "jewel", "max": 3,
		"pieces": {"neck": "熔金之链", "ring": "不灭炉心", "trinket": "大师的签名"},
		"bonuses": {2: {"crit_pct": 0.02}, 3: {"dmg_pct": 0.04, "crit_dmg_pct": 0.10}}},
	"serpent_kiss": {"name": "毒蛇之吻", "cls": "warrior", "track": "jewel", "max": 2,
		"pieces": {"neck": "毒牙项链", "ring": "蛇眼戒指"},
		"bonuses": {2: {"haste_pct": 0.03, "pen_pct": 0.02}}},
	"nightwatcher": {"name": "守夜人的灯", "cls": "warrior", "track": "jewel", "max": 3,
		"pieces": {"neck": "长明灯", "ring": "守夜人之眼", "trinket": "不灭灯芯"},
		"bonuses": {2: {"hp_pct": 0.04}, 3: {"armor_pct": 0.06, "hp_pct": 0.04}}},
	"graveward": {"name": "墓碑之护", "cls": "warrior", "track": "jewel", "max": 2,
		"pieces": {"neck": "墓碑护符", "ring": "安息之戒"},
		"bonuses": {2: {"hp_pct": 0.04, "armor_pct": 0.04}}},

	"starlit_echo": {"name": "星穹回响", "cls": "mage", "track": "armor", "armor_type": "cloth", "max": 5,
		"pieces": {"head": "观星者之冠", "chest": "星图法袍", "hands": "执笔之手", "legs": "夜航长裤", "feet": "无声步履"},
		"bonuses": {3: {"dmg_pct": 0.05, "crit_pct": 0.03}, 5: {"dmg_pct": 0.07, "haste_pct": 0.04}}},
	"bookburner": {"name": "焚书者", "cls": "mage", "track": "armor", "armor_type": "cloth", "max": 2,
		"pieces": {"chest": "焚书残袍", "legs": "焦页护腿"},
		"bonuses": {2: {"dmg_pct": 0.04, "crit_pct": 0.02}}},
	"shattered_mirror": {"name": "碎镜", "cls": "mage", "track": "armor", "armor_type": "cloth", "max": 3,
		"pieces": {"head": "碎镜面罩", "hands": "棱光手甲", "feet": "折影长靴"},
		"bonuses": {3: {"crit_pct": 0.03, "pen_pct": 0.03}}},
	"eclipse_veil": {"name": "月蚀之纱", "cls": "mage", "track": "armor", "armor_type": "light", "max": 5,
		"pieces": {"head": "月蚀冠冕", "chest": "暗纱长袍", "hands": "银线护手", "legs": "夜潮长裤", "feet": "露行长靴"},
		"bonuses": {3: {"hp_pct": 0.05, "lifesteal_pct": 0.02}, 5: {"hp_pct": 0.06, "armor_pct": 0.06, "lifesteal_pct": 0.02}}},
	"silver_dew": {"name": "银露", "cls": "mage", "track": "armor", "armor_type": "light", "max": 2,
		"pieces": {"chest": "露凝轻甲", "hands": "露滴护手"},
		"bonuses": {2: {"hp_pct": 0.04, "haste_pct": 0.03}}},
	"vigil_keeper": {"name": "守灵人", "cls": "mage", "track": "armor", "armor_type": "light", "max": 3,
		"pieces": {"head": "守灵面纱", "legs": "灯下长裤", "feet": "长明步履"},
		"bonuses": {3: {"lifesteal_pct": 0.02, "hp_pct": 0.04}}},
	"pact_stars": {"name": "群星之契", "cls": "mage", "track": "jewel", "max": 3,
		"pieces": {"neck": "星尘之链", "ring": "轨道之环", "trinket": "星核"},
		"bonuses": {2: {"crit_pct": 0.02}, 3: {"dmg_pct": 0.04, "crit_dmg_pct": 0.10}}},
	"ashen_dust": {"name": "飞灰", "cls": "mage", "track": "jewel", "max": 2,
		"pieces": {"neck": "飞灰坠", "ring": "余温之环"},
		"bonuses": {2: {"haste_pct": 0.03, "pen_pct": 0.02}}},
	"sunken_bell": {"name": "沉钟", "cls": "mage", "track": "jewel", "max": 3,
		"pieces": {"neck": "沉钟之链", "ring": "钟舌之环", "trinket": "静海钟"},
		"bonuses": {2: {"hp_pct": 0.04}, 3: {"armor_pct": 0.05, "hp_pct": 0.04}}},
	"mist": {"name": "薄雾", "cls": "mage", "track": "jewel", "max": 2,
		"pieces": {"neck": "薄雾坠", "ring": "雾隐之环"},
		"bonuses": {2: {"dodge_pct": 0.03, "armor_pct": 0.04}}},

	"windscar": {"name": "风痕", "cls": "archer", "track": "armor", "armor_type": "leather", "max": 5,
		"pieces": {"head": "风痕兜帽", "chest": "疾行皮甲", "hands": "引弦护手", "legs": "踏风护腿", "feet": "追影皮靴"},
		"bonuses": {3: {"haste_pct": 0.04, "crit_pct": 0.03}, 5: {"haste_pct": 0.05, "dmg_pct": 0.06}}},
	"featherlight": {"name": "轻羽", "cls": "archer", "track": "armor", "armor_type": "leather", "max": 2,
		"pieces": {"chest": "轻羽胸甲", "legs": "绒羽护腿"},
		"bonuses": {2: {"haste_pct": 0.03, "dodge_pct": 0.02}}},
	"shadowpass": {"name": "掠影", "cls": "archer", "track": "armor", "armor_type": "leather", "max": 3,
		"pieces": {"head": "掠影头巾", "hands": "影缝护手", "feet": "过隙之靴"},
		"bonuses": {3: {"haste_pct": 0.04, "crit_pct": 0.02}}},
	"eyrie": {"name": "鹰巢", "cls": "archer", "track": "armor", "armor_type": "mail", "max": 5,
		"pieces": {"head": "鹰巢兜帽", "chest": "鹰眼锁甲", "hands": "扣弦护手", "legs": "俯冲护腿", "feet": "山脊战靴"},
		"bonuses": {3: {"crit_pct": 0.03, "crit_dmg_pct": 0.08}, 5: {"dmg_pct": 0.07, "crit_pct": 0.03}}},
	"huntsman": {"name": "猎户", "cls": "archer", "track": "armor", "armor_type": "mail", "max": 2,
		"pieces": {"chest": "猎户锁甲", "hands": "准星护手"},
		"bonuses": {2: {"crit_pct": 0.02, "pen_pct": 0.03}}},
	"bone_whistle": {"name": "骨哨", "cls": "archer", "track": "armor", "armor_type": "mail", "max": 3,
		"pieces": {"head": "骨哨面罩", "legs": "白鹿护腿", "feet": "静步战靴"},
		"bonuses": {3: {"pen_pct": 0.03, "dmg_pct": 0.04}}},
	"hundred_paces": {"name": "百步", "cls": "archer", "track": "jewel", "max": 3,
		"pieces": {"neck": "百步之链", "ring": "准星之环", "trinket": "弦鸣"},
		"bonuses": {2: {"crit_pct": 0.02}, 3: {"crit_dmg_pct": 0.10, "pen_pct": 0.02}}},
	"flying_shaft": {"name": "飞矢", "cls": "archer", "track": "jewel", "max": 2,
		"pieces": {"neck": "飞矢坠", "ring": "箭羽之戒"},
		"bonuses": {2: {"haste_pct": 0.03, "pen_pct": 0.02}}},
	"windward": {"name": "风障", "cls": "archer", "track": "jewel", "max": 3,
		"pieces": {"neck": "风障之链", "ring": "逆风之环", "trinket": "风眼"},
		"bonuses": {2: {"dodge_pct": 0.02}, 3: {"hp_pct": 0.04, "armor_pct": 0.04}}},
	"moss_stone": {"name": "苔石", "cls": "archer", "track": "jewel", "max": 2,
		"pieces": {"neck": "苔石坠", "ring": "石心之戒"},
		"bonuses": {2: {"hp_pct": 0.04, "armor_pct": 0.04}}},
}

const AFFIX_KIND := {
	"crit": {"name": "暴击", "title": "锐利", "div": 8.0, "percent": true},
	"haste": {"name": "急速", "title": "疾风", "div": 10.0, "percent": true},
	"hit": {"name": "命中", "title": "猎手", "div": 10.0, "percent": true},
	"dodge": {"name": "闪避", "title": "灵巧", "div": 16.0, "percent": true},
	"parry": {"name": "招架", "title": "铁壁", "div": 16.0, "percent": true},
	"block": {"name": "格挡", "title": "壁垒", "div": 16.0, "percent": true},
	"vers": {"name": "全能", "title": "均衡", "div": 12.0, "percent": true},
	"lifesteal": {"name": "吸血", "title": "汲血", "div": 15.0, "percent": true},
	"pen": {"name": "穿透", "title": "破甲", "div": 10.0, "percent": true},
	"crit_dmg": {"name": "暴击伤害", "title": "致命", "div": 10.0, "percent": true},
	"attack_power": {"name": "攻击强度", "title": "蛮力", "div": 1.0, "percent": false},
	"spell_power": {"name": "法术强度", "title": "奥术", "div": 1.0, "percent": false},
	"hp": {"name": "生命", "title": "坚韧", "div": 1.0, "percent": false},
	"hp_regen": {"name": "生命回复", "title": "复苏", "div": 1.0, "percent": false},
	"extra_attack": {"name": "额外攻击", "title": "回响", "div": 1.0, "percent": true},
}

const AFFIX_BASE := {
	"crit": 2.0, "haste": 2.0, "hit": 1.5, "dodge": 2.0, "parry": 2.0, "block": 2.0,
	"vers": 1.5, "lifesteal": 1.2, "pen": 1.5, "crit_dmg": 3.0,
	"attack_power": 4.0, "spell_power": 4.0, "hp": 10.0, "hp_regen": 1.5,
	"extra_attack": 1.0,
}
const AFFIX_SCALE := {
	"crit": 0.80, "haste": 0.85, "hit": 0.60, "dodge": 0.65, "parry": 0.65, "block": 0.65,
	"vers": 0.55, "lifesteal": 0.45, "pen": 0.60, "crit_dmg": 1.00,
	"attack_power": 1.20, "spell_power": 1.20, "hp": 5.00, "hp_regen": 0.45,
	"extra_attack": 0.10,
}

const AFFIX_WEIGHTS := {
	"warrior": {"crit": 14, "haste": 9, "hit": 8, "dodge": 2, "parry": 8, "block": 8,
		"vers": 8, "lifesteal": 6, "pen": 7, "crit_dmg": 8, "attack_power": 12,
		"spell_power": 0, "hp": 10, "hp_regen": 6},
	"mage": {"crit": 13, "haste": 12, "hit": 8, "dodge": 3, "parry": 2, "block": 0,
		"vers": 8, "lifesteal": 5, "pen": 9, "crit_dmg": 8, "attack_power": 0,
		"spell_power": 13, "hp": 8, "hp_regen": 5, "extra_attack": 4},
	"archer": {"crit": 15, "haste": 13, "hit": 8, "dodge": 8, "parry": 3, "block": 0,
		"vers": 8, "lifesteal": 7, "pen": 7, "crit_dmg": 8, "attack_power": 12,
		"spell_power": 0, "hp": 8, "hp_regen": 5},
}

const AFFIX_KEYS := ["crit", "haste", "hit", "dodge", "parry", "block", "vers",
	"lifesteal", "pen", "crit_dmg", "attack_power", "spell_power", "hp", "hp_regen",
	"extra_attack"]

const AFFIX_TIERS := {
	"crit": "S", "haste": "S", "crit_dmg": "S", "pen": "S", "lifesteal": "S", "extra_attack": "S",
	"hit": "A", "dodge": "A", "parry": "A", "block": "A", "vers": "A",
	"attack_power": "A", "spell_power": "A",
	"hp": "B", "hp_regen": "B",
}
const AFFIX_TIER_WEIGHT := {"S": 0.65, "A": 1.0, "B": 1.25}
const AFFIX_TIER_VALUE := {"S": 0.80, "A": 1.0, "B": 1.15}

const STYLE_AFFIX_POOL := {
	"knight": ["parry", "block", "hp"],
	"berserker": ["attack_power", "crit_dmg", "pen"],
	"arcane": ["spell_power", "crit", "crit_dmg"],
	"moon": ["hp", "lifesteal", "hp_regen"],
	"swift": ["crit", "haste", "hit"],
	"hunt": ["crit", "crit_dmg", "pen"],
	"jewel_attack": ["crit", "haste", "pen"],
	"jewel_defense": ["dodge", "parry", "hp"],
}

const PRIMARY_NAMES := {"strength": "力量", "agility": "敏捷", "intellect": "智力", "stamina": "耐力"}

const WEAPON_STYLE := {
	"sword": "knight", "mace": "berserker", "axe": "berserker",
	"wand": "arcane", "codex": "moon", "staff": "arcane", "bow": "swift",
	"shortbow": "swift", "longbow": "hunt",
	"shield": "knight", "tome": "arcane", "quiver": "swift",
}
const ARMOR_STYLE_BY_TYPE := {
	"plate": "knight", "heavy": "berserker",
	"cloth": "arcane", "light": "moon",
	"leather": "swift", "mail": "hunt",
}
const LEGACY_STYLE_MAP := {
	"guard": "knight", "assault": "berserker", "ward": "moon",
	"ranger": "swift", "scout": "hunt",
}
const JEWEL_STYLES := ["jewel_attack", "jewel_defense"]
const STYLE_INFO := {
	"knight": {"name": "骑士", "desc": "偏防御：护甲 / 招架 / 格挡 / 生命"},
	"berserker": {"name": "狂战士", "desc": "偏攻击：攻击强度 / 暴击伤害 / 穿透"},
	"arcane": {"name": "奥术", "desc": "纯输出：法术强度 / 暴击 / 暴伤，有概率额外攻击一次"},
	"moon": {"name": "月辉", "desc": "半生存：法术伤害转护盾，生命 / 吸血 / 回复"},
	"swift": {"name": "疾风", "desc": "高攻速：急速 / 暴击，每 3 次攻击造成额外伤害"},
	"hunt": {"name": "猎杀", "desc": "高攻击：暴击 / 暴伤 / 穿透，不依赖攻击次数"},
	"jewel_attack": {"name": "锐利", "desc": "攻击向饰品：攻击属性 / 暴击 / 急速"},
	"jewel_defense": {"name": "守护", "desc": "防御向饰品：耐力 / 护甲 / 闪避"},
	"rune": {"name": "战斗符文", "desc": "只提供战斗属性，不提供主属性"},
}
const RUNE_STATS := ["crit", "haste", "hit", "dodge", "parry", "block",
	"vers", "lifesteal", "pen", "crit_dmg", "hp_regen"]
const RUNE_AFFIX_KEYS := ["crit", "haste", "hit", "dodge", "parry", "block",
	"vers", "lifesteal", "pen", "crit_dmg", "hp_regen", "extra_attack"]

const DIFF_ORDER := ["normal", "elite", "hero"]
const DIFFICULTIES := {
	"normal": {"name": "普通", "color": "#c8d2df", "hp": 1.00, "dmg": 1.00, "reward": 1.0, "quality_shift": 0},
	"elite": {"name": "精英", "color": "#f0c060", "hp": 3.45, "dmg": 3.60, "reward": 1.6, "quality_shift": 1},
	"hero": {"name": "英雄", "color": "#ff6b5e", "hp": 4.50, "dmg": 4.80, "reward": 2.4, "quality_shift": 2},
}

const MONSTER_TYPES := {
	"normal": {"name": "小怪", "hp": 1.0, "dmg": 1.0, "exp": 1.0, "gold": 1.0,
		"explore": 0.75, "drop_chance": 0.25, "quality": [55, 30, 12, 3, 0]},
	"elite": {"name": "精英", "hp": 1.9, "dmg": 1.35, "exp": 3.2, "gold": 4.0,
		"explore": 2.5, "drop_chance": 1.0, "quality": [0, 40, 40, 18, 2]},
	"boss": {"name": "区域首领", "hp": 19.0, "dmg": 4.5, "exp": 14.0, "gold": 25.0,
		"explore": 0.0, "drop_chance": 1.0, "quality": [0, 0, 18, 55, 27]},
}

const AREAS := [
	{"name": "灰烬平原", "min_level": 1, "max_level": 10, "color": "#c8a05a",
		"desc": "被余烬覆盖的旧战场，低阶怪物的猎场"},
	{"name": "霜风冰原", "min_level": 11, "max_level": 20, "color": "#7fc8e8",
		"desc": "风雪中的冻土，精英与首领盘踞"},
	{"name": "熔岩裂谷", "min_level": 21, "max_level": 30, "color": "#ff7b52",
		"desc": "地火撕裂的深谷，只有最硬的装备能走下去"},
]
const CONTENT_MAX_LEVEL := 30
const EXPLORE_CLEAR_GAIN := {"normal": 1.0, "elite": 2.0, "hero": 4.0}

const SHOP_STOCK_SIZE := 8
const SHOP_LEVEL_RANGE := 10
const SHOP_FREE_PER_HOUR := 5
const SHOP_PAID_COST := 100
const SHOP_QUALITY_WEIGHTS := [58, 30, 9.5, 2.0, 0.5]
const QUALITY_PRICE_MULT := [1.0, 2.2, 5.0, 12.0, 28.0]

# 副本掉落：0-2 件，稀有度整体压低紫色及以上
const DUNGEON_DROP_COUNT_WEIGHTS := [30, 50, 20]
const DUNGEON_QUALITY_WEIGHTS := [52, 32, 12, 3.5, 0.5]
const DROP_CATEGORY_WEIGHTS := [70, 22, 8]
const DROP_EQUIP_SLOTS := ["head", "chest", "hands", "legs", "feet", "main", "off"]
const DROP_EQUIP_WEIGHTS := [9, 9, 9, 9, 9, 13, 8]
const DROP_JEWEL_SLOTS := ["neck", "trinket", "ring"]
const DROP_JEWEL_WEIGHTS := [7, 6, 9]


static func area_def(index: int) -> Dictionary:
	return AREAS[clampi(index, 0, AREAS.size() - 1)]


static func area_unlocked(index: int, player_level: int) -> bool:
	if index < 0 or index >= AREAS.size():
		return false
	if index == 0:
		return true
	return player_level >= int(AREAS[index]["min_level"])


static func class_def(class_id: String) -> Dictionary:
	if CLASSES.has(class_id):
		return CLASSES[class_id]
	var arch := String(character_def(class_id).get("archetype", "warrior"))
	return CLASSES.get(arch, CLASSES["warrior"])


static func character_def(class_id: String) -> Dictionary:
	return CHARACTERS.get(class_id, CHARACTERS["warrior"])


static func character_name(class_id: String) -> String:
	return String(character_def(class_id)["name"])


static func quality_color(q: int) -> Color:
	return Color(QUALITIES[clampi(q, 0, 4)]["color"])


static func set_def(set_id: String) -> Dictionary:
	return SETS.get(set_id, {})


static func set_candidates(class_id: String, slot: String) -> Array:
	var cls := String(character_def(class_id).get("archetype", class_id))
	var kind := String(SLOT_INFO.get(slot, {}).get("kind", ""))
	var track := ""
	if kind == "armor":
		track = "armor"
	elif kind == "jewel":
		track = "jewel"
	if track == "":
		return []
	var out: Array = []
	for set_id in SETS:
		var d: Dictionary = SETS[set_id]
		if String(d.get("cls", "")) != cls or String(d.get("track", "")) != track:
			continue
		if (d.get("pieces", {}) as Dictionary).has(slot):
			out.append(set_id)
	return out


static func set_bonus_text(bonus: Dictionary) -> String:
	var parts: Array = []
	var labels := {
		"hp_pct": "生命", "armor_pct": "护甲", "dmg_pct": "伤害",
		"crit_pct": "暴击", "haste_pct": "急速", "pen_pct": "穿透",
		"lifesteal_pct": "吸血", "dodge_pct": "闪避", "parry_pct": "招架",
		"block_pct": "格挡", "crit_dmg_pct": "暴击伤害",
	}
	for key in labels:
		if bonus.has(key):
			parts.append("%s +%.0f%%" % [labels[key], float(bonus[key]) * 100.0])
	return " · ".join(parts)


static func quality_name(q: int) -> String:
	return QUALITIES[clampi(q, 0, 4)]["name"]


static func difficulty_color(diff: String) -> Color:
	return Color(DIFFICULTIES.get(diff, DIFFICULTIES["normal"])["color"])


static func slot_label(slot: String) -> String:
	return SLOT_INFO.get(slot, {}).get("name", slot)


static func slot_short(slot: String) -> String:
	return SLOT_INFO.get(slot, {}).get("short", "?")


static func base_slot(slot: String) -> String:
	if slot.begins_with("ring"):
		return "ring"
	if slot.begins_with("rune"):
		return "rune"
	return slot


static func affix_percent(key: String, value: float) -> float:
	var div: float = AFFIX_KIND.get(key, {}).get("div", 1.0)
	return value / div


static func fmt_affix(key: String, value: float) -> String:
	var info: Dictionary = AFFIX_KIND.get(key, {})
	var nm: String = info.get("name", key)
	if info.get("percent", false):
		return "%s +%.1f%%" % [nm, value / float(info.get("div", 1.0))]
	return "%s +%d" % [nm, int(round(value))]


static func fmt_primary(key: String, value: float) -> String:
	return "%s +%d" % [PRIMARY_NAMES.get(key, key), int(round(value))]


static func exp_to_next(level: int) -> int:
	var base := 70.0 * pow(float(level), 1.45)
	if level <= 5:
		base *= 0.85
	return int(round(base))


static func dungeon_level_range(player_level: int, area: Dictionary) -> Vector2i:
	var amin := int(area["min_level"])
	var amax := int(area["max_level"])
	var hi: int = mini(amax, player_level + 4)
	var lo: int = maxi(amin, player_level - 4)
	if lo > hi:
		lo = hi
	if hi < amin:
		hi = amin
	if lo > amax:
		lo = amax
	return Vector2i(lo, hi)


static func enemy_level_exponent(level: int) -> float:
	var tier := maxi(0, int(level / 5.0))
	return pow(1.025, float(maxi(0, level - 1))) * (1.0 + 0.08 * float(tier))


static func enemy_early_factor(level: int) -> float:
	match level:
		1:
			return 0.85
		2:
			return 0.90
		3:
			return 0.95
		_:
			return 1.0


static func monster_hp(type_id: String, level: int, diff: String) -> float:
	var t: Dictionary = MONSTER_TYPES[type_id]
	var d: Dictionary = DIFFICULTIES[diff]
	return (38.0 + 22.0 * level) * 1.8 * float(t["hp"]) * float(d["hp"]) * enemy_level_exponent(level) * enemy_early_factor(level)


static func monster_damage(type_id: String, level: int, diff: String) -> float:
	var t: Dictionary = MONSTER_TYPES[type_id]
	var d: Dictionary = DIFFICULTIES[diff]
	return (3.0 + 1.65 * level) * 5.0 * float(t["dmg"]) * float(d["dmg"]) * enemy_level_exponent(level) * enemy_early_factor(level)


static func monster_armor(level: int) -> float:
	return (8.0 + 3.5 * level) * enemy_level_exponent(level) * enemy_early_factor(level)


static func exp_reward(type_id: String, level: int, diff: String) -> int:
	var t: Dictionary = MONSTER_TYPES[type_id]
	var d: Dictionary = DIFFICULTIES[diff]
	return int(round((7.0 + 4.2 * level) * float(t["exp"]) * float(d["reward"])))


static func gold_reward(type_id: String, level: int, diff: String) -> int:
	var t: Dictionary = MONSTER_TYPES[type_id]
	var d: Dictionary = DIFFICULTIES[diff]
	return int(round((2.0 + 1.3 * level) * float(t["gold"]) * float(d["reward"])))


static func weighted_pick(rng: RandomNumberGenerator, weights: Array) -> int:
	var total := 0.0
	for w in weights:
		total += float(w)
	if total <= 0.0:
		return 0
	var r := rng.randf() * total
	for i in weights.size():
		r -= float(weights[i])
		if r <= 0.0:
			return i
	return weights.size() - 1


static func roll_quality(rng: RandomNumberGenerator, weights: Array, shift: int) -> int:
	var q := weighted_pick(rng, weights)
	return clampi(q + shift, 0, 4)


static func level_gap_multipliers(party_level: int, mon_level: int) -> Vector2:
	var gap := maxi(0, mon_level - party_level)
	var tier := int(gap / 5.0)
	var hp_mult := 1.0 + 0.12 * float(gap) + 0.55 * float(tier)
	var dmg_mult := 1.0 + 0.10 * float(gap) + 0.45 * float(tier)
	return Vector2(hp_mult, dmg_mult)


static func equip_tier_floor(level: int) -> int:
	if level <= 1:
		return 1
	return maxi(1, int(level / 5.0) * 5)


static func normalize_equip_tier(level: int) -> int:
	return equip_tier_floor(level)


static func shop_equip_levels(player_level: int) -> Array[int]:
	var base := equip_tier_floor(player_level)
	var lo := base
	if player_level >= 5 and player_level % 5 == 0:
		lo = maxi(1, base - 5)
	var hi := base + 10
	var levels: Array[int] = []
	if lo <= 1:
		levels.append(1)
	var t := maxi(5, int(ceil(float(lo) / 5.0)) * 5)
	while t <= hi:
		levels.append(t)
		t += 5
	if levels.is_empty():
		levels.append(base)
	return levels


static func dungeon_quality_shift(mon_level: int, player_level: int, diff: String) -> int:
	var d: Dictionary = DIFFICULTIES.get(diff, DIFFICULTIES["normal"])
	var level_bonus := mini(2, int(mon_level / 10.0))
	var gap_bonus := 1 if mon_level - player_level >= 5 else 0
	return clampi(int(d.get("quality_shift", 0)) + level_bonus + gap_bonus, 0, 4)


static func monster_display_name(type_id: String, level: int) -> String:
	var base: String = MONSTER_TYPES[type_id]["name"]
	return "Lv.%d %s" % [level, base]


static func dungeon_title(d: Dictionary) -> String:
	return "%s Lv.%d" % [String(d.get("zone", "山谷")), int(d.get("level", 1))]


static func recommended_combat_power(d: Dictionary, reference_level: int = 0) -> int:
	var lv := int(d.get("level", 1))
	var base := 70.0 * float(lv) + 40.0
	var mult := 1.0
	match String(d.get("difficulty", "normal")):
		"elite":
			mult = 1.18
		"hero":
			mult = 1.32
	if String(d.get("kind", "normal")) == "boss":
		mult = maxf(mult, 1.30)
	if reference_level > 0:
		mult *= 1.0 + 0.12 * float(maxi(0, lv - reference_level))
	return int(round(base * mult / 10.0)) * 10


static func boss_title(level: int) -> String:
	return "区域首领 Lv.%d" % level
