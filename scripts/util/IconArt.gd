class_name IconArt
extends RefCounted

## 24x24 vocabulary icons. Each object is drawn on its own layer, outlined,
## then set on a shared plate so the whole set reads as one family.

const S := 24

const SKIN := Color("d9a074")
const SKIN_DK := Color("a8744c")
const HAIR_DK := Color("2c1c1e")
const WHITE := Color("f4ece0")
const WOOD := Color("a8743c")
const WOOD_DK := Color("744a28")
const IRON := Color("5a5a6a")
const STEEL := Color("c4ccd8")
const GOLD := Color("f0c262")
const RED := Color("d2504a")
const GREEN := Color("5ea04a")
const WATER := Color("7ab8d8")


static func render(word_id: String, highlighted: bool) -> Image:
	var layer := Px.canvas(S, S)
	_draw(layer, word_id)
	Px.outline(layer)
	var out := Px.canvas(S, S)
	_plate(out, word_id, highlighted)
	Px.blit(out, layer, Vector2i.ZERO)
	return out


static func _plate(img: Image, word_id: String, hl: bool) -> void:
	var top := Color("4a3446")
	var bot := Color("2a1c2c")
	match word_id:
		"w14", "w30":
			top = Color("2c2450")
			bot = Color("1a1232")
		"w11", "w29", "w02":
			top = Color("3a4a3a")
			bot = Color("20301f")
		"w07", "w21", "w13":
			top = Color("2e4658")
			bot = Color("1a2a3a")
	var border := Color("e8b860") if hl else Color("6a4a44")
	var edge := Color("fff0b8") if hl else Color("3a2828")
	for y in range(S):
		var c := top.lerp(bot, float(y) / float(S - 1))
		for x in range(S):
			var corner := (x == 0 or x == S - 1) and (y == 0 or y == S - 1)
			if corner:
				continue
			var on_edge := x == 0 or y == 0 or x == S - 1 or y == S - 1
			if on_edge:
				img.set_pixel(x, y, border)
			elif x == 1 or y == 1 or x == S - 2 or y == S - 2:
				img.set_pixel(x, y, edge if hl else c.darkened(0.25))
			else:
				var cc := c
				if hl:
					cc = c.lightened(0.1)
				img.set_pixel(x, y, cc)
	# soft floor shadow under the object
	Px.ellipse(img, 12, 20, 7, 1, Color(0, 0, 0, 0.28))


static func _draw(l: Image, id: String) -> void:
	match id:
		"w01": # pelataran: wooden terrace deck with rail
			Px.rect(l, 2, 12, 20, 8, WOOD)
			for i in range(3):
				Px.rect(l, 2, 12 + i * 3, 20, 1, WOOD_DK)
			for x in [6, 11, 17]:
				Px.rect(l, x, 12, 1, 8, Px.shade(WOOD, 0.15))
			Px.rect(l, 2, 12, 20, 1, Px.light(WOOD, 0.2))
			Px.rect(l, 3, 5, 2, 8, WOOD_DK)
			Px.rect(l, 19, 5, 2, 8, WOOD_DK)
			Px.rect(l, 3, 5, 18, 2, WOOD)
			Px.rect(l, 3, 5, 18, 1, Px.light(WOOD, 0.2))
			Px.rect(l, 11, 6, 2, 6, WOOD_DK)
		"w02": # basasimpun: tidy folded stack
			Px.box(l, 4, 15, 16, 4, Color("7fc08a"))
			Px.box(l, 5, 11, 14, 4, Color("e8b8c8"))
			Px.box(l, 6, 7, 12, 4, Color("86b4e0"))
			Px.rect(l, 7, 8, 4, 1, WHITE)
			Px.px(l, 18, 4, GOLD)
			Px.px(l, 17, 3, GOLD)
			Px.px(l, 19, 3, GOLD)
			Px.px(l, 18, 2, GOLD)
		"w03": # rinjing: wok
			Px.rect(l, 1, 11, 4, 2, WOOD_DK)
			Px.rect(l, 19, 11, 4, 2, WOOD_DK)
			Px.ball(l, 12, 12, 9, 6, IRON)
			Px.rect(l, 3, 7, 18, 5, Color(0, 0, 0, 0))
			Px.ellipse(l, 12, 10, 8, 2, Color("2a2a34"))
			Px.ellipse(l, 12, 10, 6, 1, Color("d89a3a"))
			Px.px(l, 9, 10, Color("f8d070"))
			Px.px(l, 14, 10, Color("f8d070"))
			Px.tri(l, 8, 19, 10, 15, 12, 19, Color("f08a2a"))
			Px.tri(l, 12, 19, 14, 15, 16, 19, Color("f0b84a"))
		"w04": # maharu: pot being stirred
			Px.box(l, 5, 11, 14, 9, Color("8a6a52"))
			Px.rect(l, 4, 10, 16, 2, Color("6a4e3c"))
			Px.rect(l, 6, 12, 12, 1, Color("e0a850"))
			Px.rect(l, 6, 14, 3, 5, Color("a88468"))
			Px.thick(l, 10.0, 11.0, 17.0, 3.0, 1.0, Color("c89a58"))
			Px.px(l, 17, 3, Color("e8c07a"))
			Px.px(l, 8, 6, Color(1, 1, 1, 0.6))
			Px.px(l, 7, 4, Color(1, 1, 1, 0.5))
			Px.px(l, 9, 3, Color(1, 1, 1, 0.4))
		"w05": # panai: cobek
			Px.ball(l, 12, 14, 9, 5, Color("8a8a96"))
			Px.ellipse(l, 12, 13, 6, 3, Color("5e5e6a"))
			Px.px(l, 10, 13, RED)
			Px.px(l, 12, 14, GREEN)
			Px.px(l, 14, 12, RED)
			Px.px(l, 13, 13, Color("e8d890"))
		"w06": # mamirik: pestle on mortar
			Px.ball(l, 11, 16, 8, 4, Color("8a8a96"))
			Px.ellipse(l, 11, 15, 5, 2, Color("5e5e6a"))
			Px.thick(l, 9.0, 14.0, 18.0, 4.0, 2.0, Color("8a6a52"))
			Px.thick(l, 9.5, 13.5, 17.5, 3.5, 0.7, Color("c8a47e"))
			Px.px(l, 8, 14, RED)
			Px.px(l, 11, 15, RED)
			Px.px(l, 13, 15, GREEN)
		"w07": # cirat: teapot
			Px.ball(l, 11, 13, 7, 6, Color("7aaac0"))
			Px.rect(l, 8, 6, 6, 2, Color("5e8aa0"))
			Px.px(l, 11, 5, GOLD)
			Px.thick(l, 17.0, 11.0, 21.0, 8.0, 1.2, Color("5e8aa0"))
			Px.thick(l, 4.0, 10.0, 3.0, 15.0, 1.2, Color("5e8aa0"))
			Px.rect(l, 8, 13, 7, 1, GOLD)
			Px.px(l, 21, 4, Color(1, 1, 1, 0.6))
			Px.px(l, 20, 2, Color(1, 1, 1, 0.5))
		"w08": # ulas tilam: sheet over mattress
			Px.box(l, 2, 12, 20, 7, Color("f2d0dc"))
			Px.box(l, 3, 8, 8, 5, WHITE)
			Px.tri(l, 12, 12, 21, 12, 14, 17, Color("e08aa8"))
			Px.rect(l, 2, 19, 2, 2, WOOD_DK)
			Px.rect(l, 20, 19, 2, 2, WOOD_DK)
			Px.px(l, 6, 10, Color("e8b8c8"))
		"w09": # tapih: patterned sarong
			Px.box(l, 6, 3, 12, 17, Color("b8548a"))
			Px.rect(l, 6, 8, 12, 2, GOLD)
			Px.rect(l, 6, 15, 12, 2, GOLD)
			for x in range(8, 17, 3):
				Px.px(l, x, 12, Color("f8e0f0"))
				Px.px(l, x + 1, 11, Color("f8e0f0"))
			Px.rect(l, 17, 3, 1, 17, Px.light(Color("b8548a"), 0.15))
		"w10": # nukar: coins
			Px.ball(l, 8, 16, 5, 3, GOLD)
			Px.ball(l, 8, 13, 5, 3, GOLD)
			Px.ball(l, 8, 10, 5, 3, Px.light(GOLD, 0.1))
			Px.rect(l, 6, 10, 4, 1, Px.shade(GOLD, 0.25))
			Px.ball(l, 17, 14, 4, 4, Px.light(GOLD, 0.05))
			Px.rect(l, 16, 12, 2, 5, Px.shade(GOLD, 0.25))
			Px.px(l, 19, 11, WHITE)
		"w11": # sabat: grass
			var gs := [[5, 20, 4, 5], [8, 20, 8, 3], [11, 20, 11, 2], [14, 20, 14, 6], [17, 20, 18, 4], [20, 20, 19, 9]]
			for g in gs:
				Px.thick(l, float(g[0]), float(g[1]), float(g[2]), float(g[3]), 1.0, Color("7cc050"))
			Px.thick(l, 11.0, 20.0, 11.0, 2.0, 0.6, Color("b0e070"))
			Px.rect(l, 3, 19, 18, 2, Color("6a4a30"))
		"w12": # lading: knife
			Px.thick(l, 4.0, 18.0, 15.0, 5.0, 2.0, STEEL)
			Px.thick(l, 5.0, 17.0, 14.0, 5.0, 0.6, WHITE)
			Px.thick(l, 15.0, 5.0, 19.0, 2.0, 1.4, WOOD_DK)
			Px.thick(l, 16.0, 5.0, 20.0, 2.0, 0.5, WOOD)
			Px.px(l, 13, 8, GOLD)
		"w13": # haruan: snakehead fish
			Px.ball(l, 11, 12, 9, 4, Color("4a6a58"))
			Px.rect(l, 3, 13, 16, 2, Color("b0b890"))
			Px.tri(l, 18, 12, 22, 8, 22, 16, Color("3a5a4a"))
			Px.rect(l, 6, 7, 10, 2, Color("3a5a4a"))
			Px.px(l, 5, 11, WHITE)
			Px.px(l, 5, 12, Color("1a1020"))
			for x in range(8, 17, 3):
				Px.px(l, x, 11, Color("2a4a3a"))
		"w14": # kadap: dark with moon and stars
			Px.ball(l, 16, 8, 4, 4, Color("f4eab0"))
			Px.ellipse(l, 18, 7, 3, 3, Color("2c2450"))
			for p in [[5, 5], [9, 10], [4, 14], [12, 6], [8, 17], [19, 16]]:
				Px.px(l, p[0], p[1], Color("fff0b8"))
			Px.px(l, 5, 4, Color("fff0b8"))
			Px.px(l, 5, 6, Color("fff0b8"))
			Px.px(l, 4, 5, Color("fff0b8"))
			Px.px(l, 6, 5, Color("fff0b8"))
		"w15": # kai: grandfather
			Px.ball(l, 12, 17, 7, 4, Color("5a6a8a"))
			Px.ball(l, 12, 10, 6, 7, SKIN)
			Px.rect(l, 7, 3, 10, 3, HAIR_DK)
			Px.rect(l, 6, 4, 12, 1, Color("1a1020"))
			Px.rect(l, 8, 13, 8, 4, WHITE)
			Px.px(l, 9, 9, HAIR_DK)
			Px.px(l, 14, 9, HAIR_DK)
			Px.rect(l, 8, 8, 3, 1, WHITE)
			Px.rect(l, 13, 8, 3, 1, WHITE)
		"w16": # acil: aunt with scarf and basket
			Px.ball(l, 10, 17, 6, 4, Color("d0708a"))
			Px.ball(l, 10, 10, 6, 7, SKIN)
			Px.ball(l, 10, 7, 7, 5, Color("e8a0b0"))
			Px.rect(l, 7, 9, 6, 3, SKIN)
			Px.px(l, 8, 10, HAIR_DK)
			Px.px(l, 12, 10, HAIR_DK)
			Px.box(l, 15, 15, 7, 5, WOOD)
			Px.rect(l, 16, 12, 1, 3, WOOD_DK)
			Px.rect(l, 20, 12, 1, 3, WOOD_DK)
			Px.rect(l, 16, 12, 5, 1, WOOD_DK)
			Px.px(l, 17, 14, RED)
			Px.px(l, 19, 14, GOLD)
		"w17": # bahari: old pocket clock, sepia
			Px.ball(l, 12, 13, 8, 8, Color("c8a468"))
			Px.ellipse(l, 12, 13, 6, 6, Color("f0e0b8"))
			Px.rect(l, 11, 3, 3, 2, GOLD)
			Px.rect(l, 12, 9, 1, 5, Color("5a3a28"))
			Px.rect(l, 12, 13, 4, 1, Color("5a3a28"))
			for p in [[12, 8], [12, 18], [7, 13], [17, 13]]:
				Px.px(l, p[0], p[1], WOOD_DK)
		"w18": # karindangan: longing heart
			Px.ball(l, 8, 9, 4, 4, Color("e0607e"))
			Px.ball(l, 15, 9, 4, 4, Color("e0607e"))
			Px.tri(l, 4, 11, 19, 11, 12, 20, Color("d0486c"))
			Px.rect(l, 5, 10, 14, 2, Color("d0486c"))
			Px.px(l, 7, 7, Color("ffc0d0"))
			Px.px(l, 8, 6, Color("ffc0d0"))
			Px.px(l, 20, 3, GOLD)
			Px.px(l, 21, 4, GOLD)
			Px.px(l, 19, 4, GOLD)
			Px.px(l, 20, 5, GOLD)
		"w19": # mahadang: waiting on a bench
			Px.rect(l, 3, 14, 18, 2, WOOD)
			Px.rect(l, 3, 14, 18, 1, Px.light(WOOD, 0.2))
			Px.rect(l, 4, 16, 2, 4, WOOD_DK)
			Px.rect(l, 18, 16, 2, 4, WOOD_DK)
			Px.rect(l, 3, 7, 2, 7, WOOD_DK)
			Px.ball(l, 12, 5, 3, 3, SKIN)
			Px.rect(l, 10, 3, 5, 2, HAIR_DK)
			Px.box(l, 9, 8, 7, 6, Color("5a8a6a"))
			Px.px(l, 19, 10, Color("fff0b8"))
			Px.px(l, 21, 10, Color("fff0b8"))
			Px.px(l, 20, 10, Color("fff0b8"))
		"w20": # himung: smiling sun
			Px.ball(l, 12, 12, 7, 7, GOLD)
			for a in range(0, 360, 45):
				var r := deg_to_rad(float(a))
				Px.px(l, 12 + int(round(cos(r) * 10.0)), 12 + int(round(sin(r) * 10.0)), Color("ffd88a"))
			Px.px(l, 9, 10, Color("5a3020"))
			Px.px(l, 15, 10, Color("5a3020"))
			Px.rect(l, 9, 14, 7, 1, Color("5a3020"))
			Px.px(l, 8, 13, Color("5a3020"))
			Px.px(l, 16, 13, Color("5a3020"))
			Px.px(l, 8, 12, Color("f08a6a"))
			Px.px(l, 17, 12, Color("f08a6a"))
		"w21": # gadur: basin
			Px.ball(l, 12, 14, 9, 5, Color("7a98b8"))
			Px.ellipse(l, 12, 11, 9, 3, Color("a8c4dc"))
			Px.ellipse(l, 12, 11, 7, 2, WATER)
			Px.px(l, 9, 11, WHITE)
			Px.px(l, 14, 10, WHITE)
			Px.ball(l, 16, 5, 1, 1, Color("d8f0f8"))
			Px.ball(l, 8, 6, 2, 2, Color("d8f0f8"))
		"w22": # hawas: eye
			Px.ellipse(l, 12, 12, 10, 6, WHITE)
			Px.ellipse(l, 12, 12, 10, 1, WHITE)
			Px.ball(l, 12, 12, 4, 4, Color("8a5a3a"))
			Px.ellipse(l, 12, 12, 2, 2, Color("1a1020"))
			Px.px(l, 13, 10, WHITE)
			Px.rect(l, 3, 9, 3, 1, HAIR_DK)
			Px.rect(l, 18, 9, 3, 1, HAIR_DK)
			Px.rect(l, 6, 7, 12, 1, HAIR_DK)
		"w23": # warik: monkey
			Px.ball(l, 5, 12, 3, 3, Color("8a5a3a"))
			Px.ball(l, 19, 12, 3, 3, Color("8a5a3a"))
			Px.ball(l, 12, 12, 8, 8, Color("8a5a3a"))
			Px.ellipse(l, 12, 14, 5, 4, Color("e8c49a"))
			Px.ellipse(l, 9, 10, 2, 2, Color("e8c49a"))
			Px.ellipse(l, 15, 10, 2, 2, Color("e8c49a"))
			Px.px(l, 9, 10, HAIR_DK)
			Px.px(l, 15, 10, HAIR_DK)
			Px.px(l, 11, 13, SKIN_DK)
			Px.px(l, 13, 13, SKIN_DK)
			Px.rect(l, 10, 16, 5, 1, Color("6a3a2a"))
		"w24": # julak: uncle
			Px.ball(l, 12, 18, 7, 4, Color("9a6a40"))
			Px.ball(l, 12, 10, 6, 7, Color("c68e62"))
			Px.rect(l, 7, 4, 10, 3, Color("2a3a6a"))
			Px.rect(l, 8, 3, 8, 1, Color("2a3a6a"))
			Px.px(l, 9, 10, HAIR_DK)
			Px.px(l, 14, 10, HAIR_DK)
			Px.rect(l, 8, 13, 8, 1, HAIR_DK)
			Px.rect(l, 10, 15, 4, 1, SKIN_DK)
			Px.rect(l, 16, 17, 5, 2, GOLD)
		"w25": # dingsanak: siblings
			Px.ball(l, 7, 18, 4, 3, Color("5e9a6a"))
			Px.ball(l, 17, 18, 4, 3, Color("c0825a"))
			Px.ball(l, 7, 11, 4, 5, SKIN)
			Px.ball(l, 17, 11, 4, 5, Color("d0906a"))
			Px.rect(l, 4, 6, 7, 2, HAIR_DK)
			Px.rect(l, 14, 6, 7, 2, HAIR_DK)
			for x in [6, 8, 16, 18]:
				Px.px(l, x, 11, HAIR_DK)
			Px.rect(l, 10, 17, 4, 2, SKIN)
		"w26": # uyuh: tired face
			Px.ball(l, 11, 13, 8, 8, SKIN)
			Px.rect(l, 7, 11, 3, 1, HAIR_DK)
			Px.rect(l, 12, 11, 3, 1, HAIR_DK)
			Px.rect(l, 7, 13, 3, 1, SKIN_DK)
			Px.rect(l, 12, 13, 3, 1, SKIN_DK)
			Px.rect(l, 9, 17, 4, 1, Color("7a3a3a"))
			Px.px(l, 8, 17, SKIN_DK)
			Px.px(l, 13, 17, SKIN_DK)
			Px.ball(l, 20, 7, 1, 2, WATER)
			Px.ball(l, 21, 13, 1, 2, WATER)
			Px.px(l, 20, 5, WHITE)
		"w27": # padaringan: rice bin
			Px.ball(l, 12, 14, 8, 7, Color("b8884a"))
			Px.rect(l, 6, 4, 12, 3, Color("8a5a30"))
			Px.rect(l, 6, 4, 12, 1, Color("c89a58"))
			Px.rect(l, 5, 7, 14, 1, WOOD_DK)
			for i in range(3):
				Px.rect(l, 6, 11 + i * 3, 12, 1, Px.shade(Color("b8884a"), 0.2))
			Px.px(l, 9, 3, WHITE)
			Px.px(l, 12, 2, WHITE)
			Px.px(l, 15, 3, WHITE)
		"w28": # atung: affectionate call
			Px.ball(l, 11, 14, 7, 6, Color("e0a070"))
			Px.ball(l, 11, 11, 7, 7, Color("e8b088"))
			Px.rect(l, 5, 5, 12, 3, HAIR_DK)
			Px.rect(l, 5, 6, 2, 4, HAIR_DK)
			Px.rect(l, 16, 6, 2, 4, HAIR_DK)
			Px.px(l, 9, 11, HAIR_DK)
			Px.px(l, 13, 11, HAIR_DK)
			Px.rect(l, 9, 15, 5, 1, Color("c0504a"))
			Px.px(l, 8, 14, Color("f0907a"))
			Px.px(l, 14, 14, Color("f0907a"))
			Px.ball(l, 19, 6, 2, 2, Color("e0607e"))
			Px.tri(l, 17, 7, 21, 7, 19, 10, Color("d0486c"))
		"w29": # ambun: dew on a leaf
			Px.thick(l, 3.0, 17.0, 20.0, 8.0, 3.2, Color("4c9444"))
			Px.thick(l, 3.0, 16.0, 20.0, 7.0, 0.7, Color("a0d878"))
			Px.ball(l, 9, 13, 2, 2, Color("cfeef8"))
			Px.ball(l, 14, 11, 2, 2, Color("cfeef8"))
			Px.px(l, 15, 10, WHITE)
			Px.px(l, 10, 12, WHITE)
			Px.ball(l, 12, 19, 1, 2, Color("cfeef8"))
		"w30": # salau: dusk haze
			Px.ellipse(l, 12, 14, 5, 5, Color("f0a050"))
			Px.rect(l, 2, 14, 20, 8, Color(0, 0, 0, 0))
			for i in range(5):
				var c := Color("8a5a8a").lerp(Color("c88aa0"), float(i) / 4.0)
				c.a = 0.95
				Px.rect(l, 3 + (i % 2) * 2, 12 + i * 2, 18 - (i % 2) * 4, 1, c)
			Px.rect(l, 2, 20, 20, 2, Color("3a2848"))
			Px.px(l, 5, 6, Color("f4e8c0"))
			Px.px(l, 18, 5, Color("f4e8c0"))
		_:
			Px.ball(l, 12, 12, 6, 6, Color("aaaaaa"))
