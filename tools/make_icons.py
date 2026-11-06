"""生成 16x16 像素图标（装备槽、货币、按钮）。"""
import os
from PIL import Image, ImageDraw

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "icons")
os.makedirs(OUT_DIR, exist_ok=True)

OUT = (22, 20, 28, 255)
STEEL = (186, 196, 210, 255)
STEEL_D = (118, 128, 146, 255)
STEEL_L = (224, 230, 238, 255)
LEATHER = (150, 96, 58, 255)
LEATHER_D = (98, 62, 40, 255)
LEATHER_L = (188, 128, 80, 255)
GOLD = (231, 184, 74, 255)
GOLD_D = (164, 120, 40, 255)
WOOD = (124, 78, 46, 255)
RED = (204, 72, 72, 255)
RED_L = (236, 112, 103, 255)
BLUE = (82, 150, 222, 255)
BLUE_L = (150, 204, 250, 255)
GREEN = (92, 182, 104, 255)
PURPLE = (168, 98, 214, 255)
WHITE = (242, 240, 230, 255)
PARCH = (226, 202, 154, 255)
PARCH_D = (176, 148, 100, 255)


def canvas():
    im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def save(im, name):
    im.save(os.path.join(OUT_DIR, name + ".png"))


def poly(d, pts, fill, outline=OUT, width=1):
    d.polygon(pts, fill=outline)
    if width:
        d.line(pts + [pts[0]], fill=outline, width=width)
    # 向内缩放的填充由调用方再画一层


def helmet():
    im, d = canvas()
    outer = [(2, 5), (4, 2), (11, 2), (13, 5), (13, 10), (11, 13), (4, 13), (2, 10)]
    d.polygon(outer, fill=OUT)
    inner = [(3, 5), (5, 3), (10, 3), (12, 5), (12, 9), (10, 12), (5, 12), (3, 9)]
    d.polygon(inner, fill=STEEL)
    d.rectangle([3, 5, 12, 6], fill=STEEL_L)
    d.rectangle([4, 7, 11, 8], fill=OUT)          # 观察缝
    d.rectangle([6, 7, 9, 11], fill=OUT)          # T 形面甲
    d.rectangle([4, 10, 11, 11], fill=STEEL_D)
    d.rectangle([5, 4, 8, 4], fill=WHITE)
    save(im, "helmet")


def chest():
    im, d = canvas()
    outer = [(2, 4), (5, 3), (10, 3), (13, 4), (14, 7), (12, 14), (3, 14), (1, 7)]
    d.polygon(outer, fill=OUT)
    inner = [(3, 5), (5, 4), (10, 4), (12, 5), (12, 7), (11, 13), (4, 13), (3, 7)]
    d.polygon(inner, fill=STEEL)
    d.rectangle([4, 5, 11, 5], fill=STEEL_L)
    d.rectangle([4, 10, 11, 11], fill=LEATHER_D)  # 腰带
    d.rectangle([7, 10, 8, 11], fill=GOLD)
    d.rectangle([2, 5, 3, 7], fill=STEEL_D)
    d.rectangle([12, 5, 13, 7], fill=STEEL_D)
    d.rectangle([6, 3, 9, 4], fill=OUT)           # 领口
    save(im, "chest")


def gloves():
    im, d = canvas()
    d.rectangle([4, 3, 11, 11], fill=OUT)
    d.rectangle([5, 4, 10, 10], fill=LEATHER)
    d.polygon([(3, 6), (5, 6), (5, 11), (2, 11), (2, 8)], fill=OUT)
    d.polygon([(3, 7), (4, 7), (4, 10), (3, 10)], fill=LEATHER_L)
    d.rectangle([3, 11, 12, 14], fill=OUT)
    d.rectangle([4, 11, 11, 13], fill=LEATHER_D)
    d.rectangle([6, 5, 9, 5], fill=LEATHER_L)
    d.rectangle([6, 8, 9, 8], fill=LEATHER_D)
    save(im, "gloves")


def legs():
    im, d = canvas()
    d.rectangle([3, 2, 12, 13], fill=OUT)
    d.rectangle([4, 3, 11, 12], fill=LEATHER)
    d.rectangle([7, 6, 8, 12], fill=OUT)          # 裤缝
    d.rectangle([4, 3, 11, 4], fill=LEATHER_D)    # 腰带
    d.rectangle([7, 3, 8, 4], fill=GOLD)
    d.rectangle([4, 11, 6, 12], fill=LEATHER_D)
    d.rectangle([9, 11, 11, 12], fill=LEATHER_D)
    save(im, "legs")


def boots():
    im, d = canvas()
    d.polygon([(2, 4), (6, 4), (6, 9), (7, 9), (7, 13), (1, 13)], fill=OUT)
    d.polygon([(3, 5), (5, 5), (5, 9), (6, 10), (6, 12), (2, 12)], fill=LEATHER)
    d.polygon([(9, 4), (13, 4), (14, 12), (14, 13), (8, 13), (8, 9), (9, 9)], fill=OUT)
    d.polygon([(10, 5), (12, 5), (13, 11), (13, 12), (9, 12), (9, 10), (10, 10)], fill=LEATHER)
    d.rectangle([1, 13, 7, 14], fill=LEATHER_D)
    d.rectangle([8, 13, 14, 14], fill=LEATHER_D)
    save(im, "boots")


def sword():
    im, d = canvas()
    d.rectangle([6, 0, 9, 10], fill=OUT)
    d.rectangle([7, 1, 8, 9], fill=STEEL)
    d.polygon([(7, 0), (8, 0), (8, 1), (7, 1)], fill=STEEL_L)
    d.rectangle([4, 9, 11, 11], fill=OUT)
    d.rectangle([3, 10, 4, 11], fill=GOLD)
    d.rectangle([11, 10, 12, 11], fill=GOLD)
    d.rectangle([5, 10, 10, 10], fill=GOLD_D)
    d.rectangle([7, 11, 8, 14], fill=LEATHER_D)
    d.rectangle([6, 14, 9, 15], fill=GOLD)
    d.rectangle([7, 2, 7, 8], fill=STEEL_L)
    save(im, "sword")


def axe():
    im, d = canvas()
    d.rectangle([7, 2, 9, 15], fill=OUT)
    d.rectangle([8, 3, 8, 14], fill=WOOD)
    d.polygon([(9, 2), (14, 4), (14, 9), (9, 10)], fill=OUT)
    d.polygon([(10, 3), (13, 4), (13, 8), (10, 9)], fill=STEEL)
    d.polygon([(10, 3), (13, 4), (11, 5)], fill=STEEL_L)
    d.rectangle([6, 11, 9, 12], fill=LEATHER_D)
    save(im, "axe")


def mace():
    im, d = canvas()
    d.rectangle([7, 6, 9, 15], fill=OUT)
    d.rectangle([8, 7, 8, 14], fill=WOOD)
    d.ellipse([3, 1, 12, 10], fill=OUT)
    d.ellipse([4, 2, 11, 9], fill=STEEL_D)
    d.ellipse([5, 3, 10, 8], fill=STEEL)
    d.rectangle([7, 0, 8, 1], fill=STEEL_L)
    d.rectangle([2, 3, 3, 4], fill=STEEL_L)
    d.rectangle([12, 3, 13, 4], fill=STEEL_L)
    save(im, "mace")


def staff():
    im, d = canvas()
    d.rectangle([7, 4, 9, 15], fill=OUT)
    d.rectangle([8, 5, 8, 14], fill=WOOD)
    d.ellipse([4, 0, 12, 8], fill=OUT)
    d.ellipse([5, 1, 11, 7], fill=BLUE)
    d.ellipse([6, 2, 9, 5], fill=BLUE_L)
    d.rectangle([7, 1, 8, 1], fill=WHITE)
    save(im, "staff")


def wand():
    im, d = canvas()
    d.line([(4, 14), (9, 7)], fill=OUT, width=3)
    d.line([(5, 13), (9, 7)], fill=WOOD, width=1)
    d.polygon([(10, 1), (13, 5), (10, 9), (7, 5)], fill=OUT)
    d.polygon([(10, 2), (12, 5), (10, 8), (8, 5)], fill=GOLD)
    d.rectangle([9, 4, 10, 6], fill=WHITE)
    save(im, "wand")


def bow():
    im, d = canvas()
    d.arc([0, 0, 12, 15], start=300, end=60, fill=OUT, width=3)
    d.arc([1, 1, 11, 14], start=300, end=60, fill=WOOD, width=1)
    d.line([(10, 2), (10, 13)], fill=WHITE, width=1)
    d.line([(10, 7), (14, 7)], fill=OUT, width=2)
    d.line([(11, 6), (13, 6)], fill=STEEL, width=1)
    d.polygon([(13, 5), (15, 7), (13, 9), (12, 7)], fill=STEEL_L)
    save(im, "bow")


def shield():
    im, d = canvas()
    outer = [(2, 2), (13, 2), (13, 6), (11, 11), (7, 14), (4, 11), (2, 6)]
    d.polygon(outer, fill=OUT)
    inner = [(3, 3), (12, 3), (12, 6), (10, 10), (7, 12), (5, 10), (3, 6)]
    d.polygon(inner, fill=STEEL)
    d.rectangle([7, 3, 8, 11], fill=GOLD_D)
    d.rectangle([4, 6, 11, 7], fill=GOLD_D)
    d.rectangle([3, 3, 12, 4], fill=STEEL_L)
    save(im, "shield")


def tome():
    im, d = canvas()
    d.rectangle([2, 3, 13, 13], fill=OUT)
    d.rectangle([3, 4, 12, 12], fill=PURPLE)
    d.rectangle([3, 4, 12, 5], fill=(120, 70, 160, 255))
    d.rectangle([5, 6, 11, 11], fill=PARCH)
    d.rectangle([6, 7, 10, 7], fill=PARCH_D)
    d.rectangle([6, 9, 10, 9], fill=PARCH_D)
    d.rectangle([2, 3, 3, 13], fill=GOLD_D)
    save(im, "tome")


def quiver():
    im, d = canvas()
    d.rectangle([5, 4, 10, 14], fill=OUT)
    d.rectangle([6, 5, 9, 13], fill=LEATHER)
    d.rectangle([6, 8, 9, 9], fill=LEATHER_D)
    for x in (6, 8, 10):
        d.line([(x, 5), (x, 1)], fill=WOOD, width=1)
        d.polygon([(x - 1, 1), (x, 0), (x + 1, 1)], fill=STEEL_L)
    save(im, "quiver")


def necklace():
    im, d = canvas()
    d.arc([3, 2, 12, 11], start=200, end=340, fill=GOLD, width=1)
    d.arc([4, 3, 11, 10], start=200, end=340, fill=GOLD_D, width=1)
    d.polygon([(8, 8), (11, 11), (8, 15), (5, 11)], fill=OUT)
    d.polygon([(8, 9), (10, 11), (8, 14), (6, 11)], fill=BLUE)
    d.rectangle([7, 10, 8, 11], fill=BLUE_L)
    save(im, "necklace")


def ring():
    im, d = canvas()
    d.ellipse([3, 5, 12, 14], outline=OUT, width=3)
    d.ellipse([4, 6, 11, 13], outline=GOLD, width=2)
    d.rectangle([7, 2, 8, 5], fill=OUT)
    d.rectangle([6, 1, 9, 4], fill=OUT)
    d.rectangle([7, 2, 8, 3], fill=BLUE)
    d.rectangle([8, 2, 8, 2], fill=BLUE_L)
    save(im, "ring")


def rune():
    im, d = canvas()
    d.polygon([(8, 0), (15, 8), (8, 15), (1, 8)], fill=OUT)
    d.polygon([(8, 2), (13, 8), (8, 13), (3, 8)], fill=STEEL_D)
    d.polygon([(8, 4), (11, 8), (8, 11), (5, 8)], fill=WHITE)
    d.line([(8, 5), (8, 10)], fill=STEEL_D)
    d.line([(6, 7), (8, 5)], fill=STEEL_D)
    d.line([(10, 7), (8, 5)], fill=STEEL_D)
    save(im, "rune")


def coin():
    im, d = canvas()
    d.ellipse([2, 2, 13, 13], fill=OUT)
    d.ellipse([3, 3, 12, 12], fill=GOLD_D)
    d.ellipse([4, 4, 11, 11], fill=GOLD)
    d.rectangle([7, 5, 8, 10], fill=GOLD_D)
    d.rectangle([6, 6, 9, 7], fill=GOLD_D)
    d.rectangle([6, 9, 9, 10], fill=GOLD_D)
    d.rectangle([5, 5, 6, 5], fill=WHITE)
    save(im, "coin")


def map_icon():
    im, d = canvas()
    d.rectangle([1, 3, 14, 13], fill=OUT)
    d.rectangle([2, 4, 13, 12], fill=PARCH)
    d.line([(5, 4), (5, 12)], fill=PARCH_D)
    d.line([(10, 4), (10, 12)], fill=PARCH_D)
    d.line([(8, 6), (12, 11)], fill=RED, width=2)
    d.line([(12, 6), (8, 11)], fill=RED, width=2)
    save(im, "map")


def shop_icon():
    im, d = canvas()
    d.rectangle([2, 2, 13, 5], fill=RED)
    d.rectangle([2, 2, 3, 5], fill=WHITE)
    d.rectangle([6, 2, 7, 5], fill=WHITE)
    d.rectangle([10, 2, 11, 5], fill=WHITE)
    d.rectangle([2, 2, 13, 2], fill=RED_L)
    d.rectangle([2, 5, 13, 13], fill=OUT)
    d.rectangle([3, 6, 12, 12], fill=LEATHER_D)
    d.rectangle([4, 8, 11, 9], fill=LEATHER)
    d.ellipse([6, 9, 9, 12], fill=GOLD)
    save(im, "shop")


def close_icon():
    im, d = canvas()
    d.line([(4, 4), (11, 11)], fill=OUT, width=4)
    d.line([(11, 4), (4, 11)], fill=OUT, width=4)
    d.line([(5, 5), (10, 10)], fill=STEEL_L, width=2)
    d.line([(10, 5), (5, 10)], fill=STEEL_L, width=2)
    save(im, "close")


def dots_icon():
    im, d = canvas()
    for x in (3, 7, 11):
        d.rectangle([x, 6, x + 1, 9], fill=STEEL_L)
    save(im, "dots")


def plus_icon():
    im, d = canvas()
    d.rectangle([7, 3, 8, 12], fill=STEEL_L)
    d.rectangle([3, 7, 12, 8], fill=STEEL_L)
    save(im, "plus")


ops = [helmet, chest, gloves, legs, boots, sword, axe, mace, staff, wand, bow,
       shield, tome, quiver, necklace, ring, rune, coin, map_icon, shop_icon,
       close_icon, dots_icon, plus_icon]
for op in ops:
    op()

# 预览拼图
names = ["helmet", "chest", "gloves", "legs", "boots", "sword", "axe", "mace",
         "staff", "wand", "bow", "shield", "tome", "quiver", "necklace", "ring",
         "rune", "coin", "map", "shop", "close", "dots", "plus"]
sheet = Image.new("RGBA", (6 * 20, 4 * 20 + 40), (60, 64, 72, 255))
for i, n in enumerate(names):
    im = Image.open(os.path.join(OUT_DIR, n + ".png"))
    x = (i % 6) * 20 + 2
    y = (i // 6) * 20 + 2
    sheet.alpha_composite(im, (x, y))
sheet.resize((sheet.width * 5, sheet.height * 5), Image.Resampling.NEAREST).save(
    os.path.join(os.path.dirname(__file__), "icons_preview.png"))
print("icons:", len(names))
