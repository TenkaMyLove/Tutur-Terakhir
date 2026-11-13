class_name NenekArt
extends RefCounted

## Nenek Wati, seated on a woven mat. 128x160, drawn for 1:1 display.
## Head hair line sits at y>=38 so the icon row above never covers her face.

const W := 128
const H := 160


static func render(state: String, fr: int) -> Image:
	var skin := Color("c98f5f")
	var kebaya := Color("ecddc6")
	var tapih := Color("7c2f4a")
	var gold := Color("e2b462")
	var selen := Color("c8524a")
	match state:
		"happy", "correct":
			skin = Color("d29a68")
			selen = Color("dc6c5c")
		"tired":
			skin = Color("b98558")
			kebaya = Color("d9c9b1")
			tapih = Color("63283f")
			selen = Color("96453f")
		"talk":
			selen = Color("d25e52")
	var b := 0 if (fr % 4) < 2 else 1
	var sag := 3 if state == "tired" else 0
	var img := Px.canvas(W, H)
	_mat(img)
	_lap(img, tapih, gold)
	_torso(img, kebaya, selen, gold, b + sag)
	_head(img, skin, state, fr, b + sag)
	_arms(img, skin, kebaya, state, fr, b + sag)
	Px.rim(img, Color("ffc27a"), 0.38)
	Px.outline(img)
	var out := Px.canvas(W, H)
	Px.ellipse(out, 64, 150, 58, 7, Color(0.06, 0.02, 0.1, 0.34))
	Px.ellipse(out, 64, 149, 50, 5, Color(0.06, 0.02, 0.1, 0.22))
	Px.blit(out, img, Vector2i.ZERO)
	return out


# ------------------------------------------------------------------ mat
static func _mat(img: Image) -> void:
	var edge := Color("6a3426")
	var a := Color("c99a58")
	var bb := Color("a97a40")
	var red := Color("9a4a34")
	Px.ellipse(img, 64, 142, 54, 10, edge)
	for y in range(130, 156):
		for x in range(8, 121):
			var dx := float(x - 64) / 51.5
			var dy := float(y - 142) / 7.8
			if dx * dx + dy * dy > 1.0:
				continue
			var weave := (int(x / 3) + int(y / 2)) % 2
			var c := a if weave == 0 else bb
			if y % 5 == 0:
				c = Px.shade(c, 0.12)
			if absi(x - 64) % 22 < 2:
				c = red
			if dx * 0.5 - dy * 0.6 > 0.45:
				c = Px.light(c, 0.08)
			Px.px(img, x, y, c)
	# fringe tassels on both ends
	for i in 4:
		Px.px(img, 9 - 1, 139 + i * 2, Color("e8d0a0"))
		Px.px(img, 119 + 1, 139 + i * 2, Color("e8d0a0"))


# ------------------------------------------------------------------ lap
static func _lap(img: Image, tapih: Color, gold: Color) -> void:
	var dk := Px.shade(tapih, 0.22)
	var lt := Px.light(tapih, 0.14)
	for y in range(100, 150):
		for x in range(18, 111):
			var dx := float(x - 64) / 45.0
			var dy := float(y - 126) / 24.0
			if dx * dx + dy * dy > 1.0:
				continue
			var v := dx * 0.5 - dy * 0.55
			var c := tapih
			if v > 0.5:
				c = lt
			elif v < -0.45:
				c = dk
			Px.px(img, x, y, c)
	# folds
	for k in [-26, -12, 6, 24]:
		var k3 := int(float(k) / 3.0)
		Px.line(img, 64 + k3, 112, 64 + k, 144, dk)
		Px.line(img, 65 + k3, 113, 65 + k, 143, Px.shade(tapih, 0.1))
	# sasirangan wave band + dot rows
	for x in range(22, 107):
		var yy := 130 + int(round(sin(float(x) * 0.42) * 1.6))
		var dx2 := float(x - 64) / 45.0
		if absf(dx2) < 0.96:
			Px.px(img, x, yy, gold)
			if x % 6 == 0:
				Px.px(img, x, yy + 3, Px.shade(gold, 0.15))
				Px.px(img, x + 1, yy - 3, Px.light(gold, 0.1))
	for x in range(26, 104, 8):
		Px.px(img, x, 138, Px.shade(gold, 0.2))
		Px.px(img, x + 4, 122, Px.shade(gold, 0.25))


# ------------------------------------------------------------------ torso
static func _torso(img: Image, kebaya: Color, selen: Color, gold: Color, b: int) -> void:
	var dk := Px.shade(kebaya, 0.16)
	var lt := Px.light(kebaya, 0.08)
	var top := 76 + b
	for y in range(top, 116):
		var u := float(y - top) / float(116 - top)
		var half := int(round(lerpf(23.0, 19.0, u) + sin(u * PI) * 2.0))
		for x in range(64 - half, 64 + half + 1):
			var c := kebaya
			if x < 64 - half + 4:
				c = dk
			elif x > 64 + half - 4:
				c = lt
			Px.px(img, x, y, c)
	# rounded shoulders
	Px.ellipse(img, 44, top + 3, 6, 4, kebaya)
	Px.ellipse(img, 84, top + 3, 6, 4, lt)
	# front seam, trim, buttons
	Px.rect(img, 64, top + 4, 1, 40, dk)
	Px.rect(img, 62, top + 2, 1, 22, Px.light(kebaya, 0.12))
	for i in 4:
		Px.px(img, 66, top + 12 + i * 8, gold)
	# lace motif on hem
	for x in range(44, 85, 3):
		Px.px(img, x, 112, dk)
	# selendang diagonal across chest
	Px.thick(img, 46.0, top + 2.0, 82.0, 108.0, 4.2, Px.shade(selen, 0.1))
	Px.thick(img, 46.0, top + 1.0, 82.0, 107.0, 3.2, selen)
	Px.thick(img, 47.0, top - 1.0, 83.0, 105.0, 0.9, Px.light(selen, 0.25))
	Px.line(img, 46, top + 5, 82, 112, gold)
	Px.rect(img, 79, 108, 9, 10, selen)
	Px.rect(img, 79, 108, 2, 10, Px.shade(selen, 0.15))
	Px.rect(img, 79, 117, 9, 1, gold)
	# neck
	Px.rect(img, 58, top - 9, 12, 11, Color("b07c52"))


# ------------------------------------------------------------------ head
static func _head(img: Image, skin: Color, state: String, fr: int, b: int) -> void:
	var hair := Color("c6c1bd")
	var hair_w := Color("eeeae4")
	var hair_d := Color("6b6470")
	var skin_dk := Px.shade(skin, 0.16)
	var skin_lt := Px.light(skin, 0.1)
	var cy := 54 + b
	# back hair mass and bun
	Px.ellipse(img, 64, cy - 6, 18, 18, hair_d)
	Px.ball(img, 83, cy - 14, 8, 7, hair_w)
	for i in 4:
		Px.line(img, 78 + i, cy - 19 + i, 88, cy - 12 + i, hair)
	Px.thick(img, 76.0, cy - 8.0, 90.0, cy - 18.0, 0.7, Color("e8c060"))
	Px.px(img, 90, cy - 18, Color("fff0b0"))
	# ears and earrings
	Px.ball(img, 49, cy + 1, 2, 4, skin_dk)
	Px.ball(img, 79, cy + 1, 2, 4, skin)
	Px.px(img, 49, cy + 6, Color("e8c060"))
	Px.px(img, 79, cy + 6, Color("e8c060"))
	# face
	Px.ball(img, 64, cy, 14, 17, skin)
	# chin / jaw shade
	for x in range(54, 75):
		Px.px(img, x, cy + 16, skin_dk)
	# hair cap with centre parting
	for y in range(cy - 19, cy + 3):
		for x in range(48, 81):
			var dx := float(x - 64) / 15.5
			var dy := float(y - (cy - 3)) / 18.5
			if dx * dx + dy * dy > 1.0:
				continue
			var hairline := cy - 9 + int(absf(float(x - 64)) * 0.34)
			if x == 64 or x == 63:
				hairline += 2
			if y < hairline:
				var c := hair
				if (x * 3 + y) % 7 == 0:
					c = hair_w
				elif (x + y * 2) % 9 == 0:
					c = hair_d
				Px.px(img, x, y, c)
	# sideburn hair hugging the cheek
	for y in range(cy - 9, cy + 6):
		var inset := int(maxf(0.0, float(y - (cy - 9))) * 0.1)
		for k in range(2):
			Px.px(img, 51 + k + inset, y, hair)
			Px.px(img, 77 - k - inset, y, hair)
	# brows
	var by := cy - 7
	var brow := Color("8a8490")
	if state == "tired":
		by += 1
	Px.rect(img, 55, by, 5, 1, brow)
	Px.rect(img, 68, by, 5, 1, brow)
	# eyes
	var blink := (fr == 5) or (state == "tired" and fr % 4 == 3)
	var ey := cy - 3
	var closed_smile := state == "happy" or state == "correct"
	var eyec := Color("2b1a1c")
	var sclera := Color("f3e6d4")
	for ex in [56, 69]:
		if closed_smile:
			Px.px(img, ex, ey + 1, eyec)
			Px.px(img, ex + 1, ey, eyec)
			Px.px(img, ex + 2, ey, eyec)
			Px.px(img, ex + 3, ey + 1, eyec)
		elif blink:
			Px.rect(img, ex, ey + 1, 4, 1, eyec)
		else:
			Px.rect(img, ex, ey, 4, 2, sclera)
			Px.rect(img, ex + 1, ey, 2, 2, eyec)
			Px.px(img, ex + 1, ey, Color("f8f0e4"))
			Px.rect(img, ex, ey - 1, 4, 1, skin_dk)
			if state == "tired":
				Px.rect(img, ex, ey - 1, 4, 2, skin_dk)
		# crow's feet and eye bags
		var side := -1 if ex < 64 else 1
		var ox: int = ex - 1 if side < 0 else ex + 4
		Px.px(img, ox, ey, skin_dk)
		Px.px(img, ox + side, ey + 1, skin_dk)
		Px.rect(img, ex, ey + 3, 4, 1, skin_dk)
	if state == "tired":
		Px.rect(img, 56, ey + 4, 4, 1, Px.shade(skin, 0.3))
		Px.rect(img, 69, ey + 4, 4, 1, Px.shade(skin, 0.3))
	# forehead wrinkles
	Px.rect(img, 57, cy - 11, 6, 1, skin_dk)
	Px.rect(img, 66, cy - 11, 5, 1, skin_dk)
	Px.rect(img, 60, cy - 13, 8, 1, skin_dk)
	# nose
	Px.rect(img, 64, cy - 1, 1, 6, skin_dk)
	Px.px(img, 63, cy + 5, skin_dk)
	Px.px(img, 65, cy + 5, skin_dk)
	Px.px(img, 66, cy + 1, skin_lt)
	Px.px(img, 66, cy + 2, skin_lt)
	# nasolabial lines
	Px.line(img, 59, cy + 5, 57, cy + 10, skin_dk)
	Px.line(img, 70, cy + 5, 72, cy + 10, skin_dk)
	# cheeks
	if closed_smile:
		Px.ellipse(img, 55, cy + 6, 3, 2, Color(0.95, 0.45, 0.4, 0.45))
		Px.ellipse(img, 73, cy + 6, 3, 2, Color(0.95, 0.45, 0.4, 0.45))
	# mouth (sirih-stained lips)
	var lip := Color("8e3a3e")
	var lip_dk := Color("5e2228")
	var my := cy + 10
	match state:
		"happy", "correct":
			Px.rect(img, 59, my, 10, 1, lip)
			Px.rect(img, 60, my + 1, 8, 2, lip_dk)
			Px.rect(img, 61, my + 1, 6, 1, Color("f2e8dc"))
			Px.px(img, 58, my - 1, lip)
			Px.px(img, 69, my - 1, lip)
		"tired":
			Px.rect(img, 61, my + 1, 6, 1, lip)
			Px.px(img, 60, my + 2, skin_dk)
			Px.px(img, 67, my + 2, skin_dk)
		"talk":
			var open := 2 if fr % 2 == 0 else 1
			Px.rect(img, 61, my, 6, open + 1, lip_dk)
			Px.rect(img, 60, my - 1 + open, 8, 1, lip)
			if open == 1:
				Px.rect(img, 60, my, 8, 1, lip)
		_:
			Px.rect(img, 60, my + 1, 8, 1, lip)
			Px.px(img, 59, my, lip)
			Px.px(img, 68, my, lip)
	Px.rect(img, 61, my + 3, 6, 1, skin_dk)
	if state == "tired":
		# sweat drop on temple
		Px.ball(img, 77, cy - 6, 1, 2, Color("9ad0e8"))
		Px.px(img, 77, cy - 8, Color("d8f0f8"))


# ------------------------------------------------------------------ arms
static func _arm(img: Image, s: Vector2, e: Vector2, w: Vector2, sleeve: Color) -> void:
	var dk := Px.shade(sleeve, 0.2)
	var lt := Px.light(sleeve, 0.1)
	Px.thick(img, s.x, s.y, e.x, e.y, 5.2, dk)
	Px.thick(img, e.x, e.y, w.x, w.y, 4.4, dk)
	Px.thick(img, s.x + 1, s.y - 1, e.x + 1, e.y - 1, 3.4, sleeve)
	Px.thick(img, e.x + 1, e.y - 1, w.x + 1, w.y - 1, 2.8, sleeve)
	Px.thick(img, s.x + 2, s.y - 2, e.x + 2, e.y - 2, 0.9, lt)
	# cuff
	Px.ball(img, int(w.x), int(w.y), 4, 3, Px.light(sleeve, 0.04))


static func _hand(img: Image, p: Vector2, skin: Color, finger: Vector2 = Vector2.ZERO) -> void:
	Px.ball(img, int(p.x), int(p.y), 4, 3, skin)
	if finger != Vector2.ZERO:
		Px.thick(img, p.x, p.y, finger.x, finger.y, 1.4, skin)
		Px.px(img, int(finger.x), int(finger.y), Px.light(skin, 0.2))
	Px.px(img, int(p.x) + 1, int(p.y) - 1, Px.light(skin, 0.18))


static func _arms(img: Image, skin: Color, kebaya: Color, state: String, fr: int, b: int) -> void:
	var sl := Vector2(46, 82 + b)
	var sr := Vector2(82, 82 + b)
	match state:
		"point_left":
			_arm(img, sr, Vector2(92, 100), Vector2(74, 114), kebaya)
			_hand(img, Vector2(70, 114), skin)
			_arm(img, sl, Vector2(28, 86 + b), Vector2(14, 90 + b), kebaya)
			_hand(img, Vector2(10, 91 + b), skin, Vector2(2, 92 + b))
		"point_right":
			_arm(img, sl, Vector2(36, 100), Vector2(54, 114), kebaya)
			_hand(img, Vector2(58, 114), skin)
			_arm(img, sr, Vector2(100, 86 + b), Vector2(114, 90 + b), kebaya)
			_hand(img, Vector2(118, 91 + b), skin, Vector2(126, 92 + b))
		"point_down":
			_arm(img, sl, Vector2(36, 100), Vector2(54, 114), kebaya)
			_hand(img, Vector2(58, 114), skin)
			_arm(img, sr, Vector2(98, 96), Vector2(104, 124), kebaya)
			_hand(img, Vector2(104, 128), skin, Vector2(104, 138))
		"act":
			var ang := float(fr % 8) * PI / 4.0
			var tip := Vector2(64.0 + cos(ang) * 6.0, 139.0 + sin(ang) * 2.0)
			# bowl in front of the lap
			Px.ellipse(img, 64, 142, 17, 6, Color("5a3426"))
			Px.ellipse(img, 64, 140, 15, 5, Color("8a5a3a"))
			Px.ellipse(img, 64, 140, 12, 3, Color("d88a3a"))
			Px.ellipse(img, 66, 139, 6, 1, Color("f2b45a"))
			var wr := Vector2(80.0 + sin(ang) * 1.5, 112.0)
			_arm(img, sr, Vector2(94, 98), wr, kebaya)
			Px.thick(img, wr.x, wr.y, tip.x, tip.y, 1.2, Color("b8864a"))
			Px.px(img, int(tip.x), int(tip.y), Color("e8c080"))
			_hand(img, wr, skin)
			_arm(img, sl, Vector2(34, 102), Vector2(48, 128), kebaya)
			_hand(img, Vector2(50, 133), skin)
		"happy":
			var bob := 0 if fr % 2 == 0 else 1
			_arm(img, sl, Vector2(38, 98), Vector2(58, 94 - bob), kebaya)
			_arm(img, sr, Vector2(90, 98), Vector2(70, 94 - bob), kebaya)
			_hand(img, Vector2(62, 91 - bob), skin)
			_hand(img, Vector2(67, 91 - bob), skin)
		"correct":
			_arm(img, sl, Vector2(36, 100), Vector2(54, 114), kebaya)
			_hand(img, Vector2(58, 114), skin)
			var bob2 := 0 if fr % 2 == 0 else 2
			_arm(img, sr, Vector2(98, 92), Vector2(100, 76 - bob2), kebaya)
			_hand(img, Vector2(100, 71 - bob2), skin, Vector2(100, 62 - bob2))
		"tired":
			_arm(img, sl, Vector2(34, 104), Vector2(40, 124), kebaya)
			_hand(img, Vector2(42, 128), skin)
			if fr % 4 >= 2:
				_arm(img, sr, Vector2(92, 96), Vector2(74, 80 + b), kebaya)
				_hand(img, Vector2(70, 76 + b), skin)
			else:
				_arm(img, sr, Vector2(94, 104), Vector2(86, 124), kebaya)
				_hand(img, Vector2(84, 128), skin)
		"talk":
			var bob3 := 0 if fr % 2 == 0 else 3
			_arm(img, sl, Vector2(36, 100), Vector2(54, 114), kebaya)
			_hand(img, Vector2(58, 114), skin)
			_arm(img, sr, Vector2(98, 94), Vector2(98, 80 - bob3), kebaya)
			_hand(img, Vector2(98, 75 - bob3), skin, Vector2(100, 67 - bob3))
		_:
			# idle: hands folded in the lap
			_arm(img, sl, Vector2(36, 100), Vector2(56, 116), kebaya)
			_arm(img, sr, Vector2(92, 100), Vector2(72, 116), kebaya)
			_hand(img, Vector2(60, 118), skin)
			_hand(img, Vector2(68, 118), Px.shade(skin, 0.05))
