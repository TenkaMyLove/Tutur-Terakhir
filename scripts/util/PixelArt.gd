class_name PixelArt
extends RefCounted

## Procedural warm dusk pixel art for Tutur Terakhir (GL Compatibility / Web).


static func solid(size: Vector2i, color: Color) -> ImageTexture:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


static func rect_bordered(size: Vector2i, fill: Color, border: Color, border_w: int = 1) -> ImageTexture:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(border)
	var inner := Rect2i(border_w, border_w, max(1, size.x - border_w * 2), max(1, size.y - border_w * 2))
	img.fill_rect(inner, fill)
	return ImageTexture.create_from_image(img)


static func _px(img: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return
	if color.a <= 0.001:
		return
	if color.a >= 0.99:
		img.set_pixel(x, y, color)
	else:
		var base := img.get_pixel(x, y)
		img.set_pixel(x, y, base.lerp(color, color.a))


static func _fill_rect(img: Image, rect: Rect2i, color: Color) -> void:
	var r := Rect2i(0, 0, img.get_width(), img.get_height()).intersection(rect)
	if r.size.x <= 0 or r.size.y <= 0:
		return
	if color.a >= 0.99:
		img.fill_rect(r, color)
		return
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			_px(img, x, y, color)


static func _fill_ellipse(img: Image, cx: int, cy: int, rx: int, ry: int, color: Color) -> void:
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			var dx := float(x - cx) / float(maxi(1, rx))
			var dy := float(y - cy) / float(maxi(1, ry))
			if dx * dx + dy * dy <= 1.0:
				_px(img, x, y, color)


static func nenek_frame(state: String, frame: int = 0) -> ImageTexture:
	var body := Color("d4a07a")
	var dress := Color("9a3a3a")
	var hair := Color("2c1c18")
	var kain := Color("c45a4a")
	var accent := Color("f0c27a")
	match state:
		"happy", "correct":
			dress = Color("b84848")
			accent = Color("ffe29a")
		"tired":
			body = Color("b88870")
			dress = Color("6e3030")
		"talk":
			accent = Color("ffd27a")
		"point_left", "point_right", "point_down", "act":
			accent = Color("e8b86a")
	var img := Image.create(72, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# Ground shadow
	_fill_ellipse(img, 36, 90, 18, 4, Color(0, 0, 0, 0.28))
	# Mat under Nenek
	_fill_rect(img, Rect2i(10, 78, 52, 8), Color("8a5a30"))
	_fill_rect(img, Rect2i(12, 80, 48, 2), Color("a07040"))
	# Skirt / tapih layers
	_fill_rect(img, Rect2i(18, 48, 36, 32), dress)
	_fill_rect(img, Rect2i(16, 52, 40, 6), kain.darkened(0.1))
	_fill_rect(img, Rect2i(20, 62, 32, 3), accent.darkened(0.25))
	# Torso kebaya
	_fill_rect(img, Rect2i(22, 34, 28, 18), body.lightened(0.05))
	_fill_rect(img, Rect2i(24, 36, 24, 4), kain)
	# Head
	_fill_ellipse(img, 36, 22, 12, 13, body.lightened(0.1))
	# Hair bun + fringe
	_fill_ellipse(img, 36, 12, 10, 8, hair)
	_fill_rect(img, Rect2i(24, 14, 24, 6), hair)
	# Eyes
	var blink := frame % 10 == 9
	if blink:
		_fill_rect(img, Rect2i(30, 22, 4, 1), Color("2a1a18"))
		_fill_rect(img, Rect2i(40, 22, 4, 1), Color("2a1a18"))
	else:
		_fill_rect(img, Rect2i(30, 20, 4, 3), Color("2a1a18"))
		_fill_rect(img, Rect2i(40, 20, 4, 3), Color("2a1a18"))
		_px(img, 31, 21, Color("f5e6d0"))
		_px(img, 41, 21, Color("f5e6d0"))
	# Mouth
	match state:
		"happy":
			_fill_rect(img, Rect2i(33, 28, 8, 2), Color("8a4040"))
			_px(img, 32, 27, Color("8a4040"))
			_px(img, 41, 27, Color("8a4040"))
		"tired":
			_fill_rect(img, Rect2i(34, 28, 6, 1), Color("8a4040"))
		"talk":
			_fill_rect(img, Rect2i(34, 27, 6, 3 if frame % 2 == 0 else 1), Color("8a4040"))
		_:
			_fill_rect(img, Rect2i(34, 28, 6, 1), Color("8a4040"))
	# Arms / gesture
	match state:
		"point_left":
			_fill_rect(img, Rect2i(2, 40, 22, 5), body)
			_fill_rect(img, Rect2i(1, 38, 5, 5), accent)
		"point_right":
			_fill_rect(img, Rect2i(48, 40, 22, 5), body)
			_fill_rect(img, Rect2i(66, 38, 5, 5), accent)
		"point_down":
			_fill_rect(img, Rect2i(50, 46, 5, 22), body)
			_fill_rect(img, Rect2i(48, 66, 8, 5), accent)
		"act":
			var bob := 2 if frame % 2 == 0 else 0
			_fill_rect(img, Rect2i(8, 42 - bob, 14, 5), body)
			_fill_rect(img, Rect2i(50, 42 + bob, 14, 5), body)
		"correct":
			_fill_rect(img, Rect2i(10, 36, 10, 5), body)
			_fill_rect(img, Rect2i(52, 36, 10, 5), body)
		_:
			_fill_rect(img, Rect2i(12, 42, 10, 5), body)
			_fill_rect(img, Rect2i(50, 42, 10, 5), body)
	# Shawl
	_fill_rect(img, Rect2i(20, 36, 32, 5), accent.darkened(0.12))
	_fill_rect(img, Rect2i(22, 38, 28, 2), accent.lightened(0.1))
	return ImageTexture.create_from_image(img)


static func icon_for_word(word_id: String, highlighted: bool = false) -> ImageTexture:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var border := Color("fff2c8") if highlighted else Color("3a2418")
	var bg := Color("2a1c14")
	_fill_rect(img, Rect2i(0, 0, 24, 24), border)
	_fill_rect(img, Rect2i(2, 2, 20, 20), bg)
	match word_id:
		"w01": # pelataran — planks
			_fill_rect(img, Rect2i(4, 8, 16, 10), Color("c4a574"))
			_fill_rect(img, Rect2i(4, 10, 16, 1), Color("8a6a40"))
			_fill_rect(img, Rect2i(4, 14, 16, 1), Color("8a6a40"))
		"w02": # basasimpun — tidy stack
			_fill_rect(img, Rect2i(5, 14, 14, 4), Color("8fbc8f"))
			_fill_rect(img, Rect2i(7, 10, 10, 4), Color("6a9a6a"))
			_fill_rect(img, Rect2i(9, 6, 6, 4), Color("a0d0a0"))
		"w03": # rinjing — wok
			_fill_ellipse(img, 12, 13, 8, 5, Color("3a3a3a"))
			_fill_rect(img, Rect2i(4, 12, 16, 3), Color("2a2a2a"))
		"w04": # maharu — stirring
			_fill_ellipse(img, 12, 14, 7, 4, Color("4a4a4a"))
			_fill_rect(img, Rect2i(11, 5, 2, 10), Color("c4a060"))
		"w05": # panai — cobek
			_fill_ellipse(img, 12, 14, 8, 5, Color("7a7a7a"))
			_fill_ellipse(img, 12, 13, 5, 3, Color("5a5a5a"))
		"w06": # mamirik
			_fill_ellipse(img, 12, 15, 7, 4, Color("8a8a8a"))
			_fill_rect(img, Rect2i(10, 6, 4, 10), Color("6a5a4a"))
		"w07": # cirat — teapot
			_fill_rect(img, Rect2i(7, 8, 10, 10), Color("6a9aaa"))
			_fill_rect(img, Rect2i(16, 10, 5, 3), Color("5a8a9a"))
			_fill_rect(img, Rect2i(9, 5, 6, 3), Color("7ab0c0"))
		"w08": # ulas tilam
			_fill_rect(img, Rect2i(4, 8, 16, 10), Color("e8c8d8"))
			_fill_rect(img, Rect2i(6, 10, 4, 2), Color("d080a0"))
			_fill_rect(img, Rect2i(14, 14, 4, 2), Color("d080a0"))
		"w09": # tapih
			_fill_rect(img, Rect2i(8, 5, 8, 14), Color("b85c8a"))
			_fill_rect(img, Rect2i(8, 9, 8, 2), Color("f0c070"))
		"w10": # nukar — coins/hand
			_fill_ellipse(img, 9, 12, 4, 4, Color("d4b060"))
			_fill_ellipse(img, 15, 12, 4, 4, Color("c4a050"))
		"w11": # sabat — grass
			_fill_rect(img, Rect2i(6, 14, 2, 6), Color("6a8a4a"))
			_fill_rect(img, Rect2i(10, 10, 2, 10), Color("7aaa4a"))
			_fill_rect(img, Rect2i(14, 12, 2, 8), Color("5a7a3a"))
			_fill_rect(img, Rect2i(17, 9, 2, 11), Color("8aba5a"))
		"w12": # lading — knife
			_fill_rect(img, Rect2i(5, 11, 12, 3), Color("c0c8d0"))
			_fill_rect(img, Rect2i(16, 10, 4, 5), Color("8a5a30"))
		"w13": # haruan — fish
			_fill_ellipse(img, 12, 12, 8, 4, Color("5a7aaa"))
			_fill_rect(img, Rect2i(18, 10, 3, 5), Color("4a6a9a"))
			_px(img, 7, 11, Color("e8e8e8"))
		"w14": # kadap — dark sky
			_fill_rect(img, Rect2i(4, 4, 16, 16), Color("2a2040"))
			_px(img, 8, 8, Color("f0e8a0"))
			_px(img, 14, 12, Color("f0e8a0"))
		"w15": # kai
			_fill_ellipse(img, 12, 9, 5, 5, Color("c4a080"))
			_fill_rect(img, Rect2i(8, 14, 8, 6), Color("5a4a3a"))
			_fill_rect(img, Rect2i(9, 6, 6, 2), Color("e8e0d0"))
		"w16": # acil
			_fill_ellipse(img, 12, 9, 5, 5, Color("d4a090"))
			_fill_rect(img, Rect2i(8, 14, 8, 6), Color("c08090"))
			_fill_rect(img, Rect2i(8, 6, 8, 3), Color("3a2a28"))
		"w17": # bahari — old clock/sun
			_fill_ellipse(img, 12, 12, 7, 7, Color("b09060"))
			_fill_rect(img, Rect2i(11, 7, 2, 6), Color("5a4030"))
			_fill_rect(img, Rect2i(11, 11, 5, 2), Color("5a4030"))
		"w18": # karindangan — heart
			_fill_rect(img, Rect2i(8, 10, 3, 3), Color("c06080"))
			_fill_rect(img, Rect2i(13, 10, 3, 3), Color("c06080"))
			_fill_rect(img, Rect2i(9, 13, 6, 4), Color("a04868"))
		"w19": # mahadang — waiting seat
			_fill_rect(img, Rect2i(6, 14, 12, 4), Color("8a6a40"))
			_fill_rect(img, Rect2i(7, 8, 3, 6), Color("7a5a30"))
			_fill_rect(img, Rect2i(14, 8, 3, 6), Color("7a5a30"))
		"w20": # himung — smile sun
			_fill_ellipse(img, 12, 12, 7, 7, Color("f0c060"))
			_fill_rect(img, Rect2i(9, 10, 2, 2), Color("5a3a20"))
			_fill_rect(img, Rect2i(13, 10, 2, 2), Color("5a3a20"))
			_fill_rect(img, Rect2i(9, 15, 6, 2), Color("5a3a20"))
		_:
			_fill_rect(img, Rect2i(7, 7, 10, 10), Color("aaaaaa"))
	if highlighted:
		_fill_rect(img, Rect2i(0, 0, 24, 1), Color("ffe8a3"))
		_fill_rect(img, Rect2i(0, 23, 24, 1), Color("ffe8a3"))
		_fill_rect(img, Rect2i(0, 0, 1, 24), Color("ffe8a3"))
		_fill_rect(img, Rect2i(23, 0, 1, 24), Color("ffe8a3"))
	return ImageTexture.create_from_image(img)


static func dusk_sky(size: Vector2i, t: float) -> ImageTexture:
	t = clampf(t, 0.0, 1.0)
	var top := Color("ff7a3a").lerp(Color("1a1035"), t)
	var mid := Color("ffb040").lerp(Color("352060"), t)
	var bot := Color("e06838").lerp(Color("140c22"), t)
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	for y in size.y:
		var u := float(y) / float(maxi(1, size.y - 1))
		var c: Color
		if u < 0.4:
			c = top.lerp(mid, u / 0.4)
		else:
			c = mid.lerp(bot, (u - 0.4) / 0.6)
		for x in size.x:
			var haze := 0.03 * sin(x * 0.05 + y * 0.02)
			img.set_pixel(x, y, c.lightened(haze))
	# Sun / moon
	var sun_c := Color(1.0, 0.9, 0.45, 0.9).lerp(Color(0.85, 0.85, 1.0, 0.7), t)
	_fill_ellipse(img, int(size.x * 0.78), int(size.y * 0.22), 14, 14, sun_c)
	_fill_ellipse(img, int(size.x * 0.78), int(size.y * 0.22), 8, 8, sun_c.lightened(0.2))
	# Distant palms
	_draw_palm(img, 18, int(size.y * 0.58), 0.5, t)
	_draw_palm(img, size.x - 28, int(size.y * 0.52), 0.65, t)
	# Neighbor house (dapur sebelah) — left, slightly behind
	_draw_stilt_house(
		img,
		Rect2i(int(size.x * 0.02), int(size.y * 0.42), int(size.x * 0.28), int(size.y * 0.32)),
		t,
		true
	)
	# Nenek's house — main porch focus
	var hx := int(size.x * 0.30)
	var hy := int(size.y * 0.36)
	var hw := int(size.x * 0.52)
	var hh := int(size.y * 0.38)
	_draw_stilt_house(img, Rect2i(hx, hy, hw, hh), t, false)
	# Ground
	_fill_rect(img, Rect2i(0, int(size.y * 0.78), size.x, int(size.y * 0.22)), Color("5a3a22").lerp(Color("1a1010"), t))
	_fill_rect(img, Rect2i(0, int(size.y * 0.76), size.x, 4), Color("4a6a30").lerp(Color("1a2018"), t))
	# Stars when dark
	if t > 0.55:
		for i in 12:
			var sx := int(fposmod(i * 47.3, size.x - 4))
			var sy := int(8 + fposmod(i * 19.1, size.y * 0.28))
			_px(img, sx, sy, Color(1, 1, 0.9, 0.4 + t * 0.4))
	return ImageTexture.create_from_image(img)


static func approach_sky(size: Vector2i) -> ImageTexture:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var top := Color("ff6e2e")
	var mid := Color("ff9a3a")
	var low := Color("f0a050")
	var horizon := Color("d87848")
	for y in size.y:
		var u := float(y) / float(maxi(1, size.y - 1))
		var c: Color
		if u < 0.35:
			c = top.lerp(mid, u / 0.35)
		elif u < 0.55:
			c = mid.lerp(low, (u - 0.35) / 0.2)
		else:
			c = low.lerp(horizon, (u - 0.55) / 0.45)
		for x in size.x:
			var band := 0.025 * sin(x * 0.03 + y * 0.05)
			img.set_pixel(x, y, c.lightened(band))
	# Sun
	_fill_ellipse(img, int(size.x * 0.35), 48, 22, 20, Color(1.0, 0.92, 0.5, 0.95))
	_fill_ellipse(img, int(size.x * 0.35), 48, 12, 11, Color(1.0, 0.98, 0.75, 0.9))
	# Soft clouds
	for i in 5:
		var cx := int(80 + i * 200 + (i % 2) * 40)
		var cy := 28 + (i % 3) * 10
		_fill_ellipse(img, cx, cy, 28, 8, Color(1, 0.9, 0.8, 0.22))
		_fill_ellipse(img, cx + 16, cy + 2, 20, 7, Color(1, 0.88, 0.75, 0.18))
	# Far treeline / kampung silhouettes
	for x in range(0, size.x, 5):
		var h := 12 + int(abs(sin(x * 0.07)) * 18) + (x % 11)
		_fill_rect(img, Rect2i(x, size.y - 78 - h, 5, h), Color("243e24"))
	# River strip
	var ry := int(size.y * 0.68)
	for y in range(ry, ry + 14):
		for x in size.x:
			var ripple := 0.08 * sin(x * 0.12 + y)
			img.set_pixel(x, y, Color("3a6a7a").lightened(ripple))
	# Near bank grass
	_fill_rect(img, Rect2i(0, ry + 14, size.x, size.y - (ry + 14)), Color("4a6a2e"))
	# Dirt path (center band)
	var path_y := int(size.y * 0.78)
	_fill_rect(img, Rect2i(0, path_y, size.x, size.y - path_y), Color("7a5530"))
	for x in range(0, size.x, 8):
		_fill_rect(img, Rect2i(x, path_y + 4 + (x % 3), 5, 1), Color("8a6638"))
		_fill_rect(img, Rect2i(x + 3, path_y + 12 + (x % 2), 4, 1), Color("6a4528"))
	# Path edge grass tufts
	for x in range(0, size.x, 14):
		_fill_rect(img, Rect2i(x, path_y - 4, 2, 5), Color("5a8a3a"))
		_fill_rect(img, Rect2i(x + 6, path_y - 6, 2, 7), Color("4a7a30"))
	# Scattered palms along path
	_draw_palm(img, 160, path_y - 8, 0.9, 0.1)
	_draw_palm(img, 520, path_y - 6, 1.05, 0.1)
	_draw_palm(img, 780, path_y - 10, 0.85, 0.1)
	_draw_palm(img, 980, path_y - 8, 0.95, 0.1)
	return ImageTexture.create_from_image(img)


static func _draw_stilt_house(img: Image, rect: Rect2i, t: float, is_neighbor: bool) -> void:
	var wood := Color("5a3826").lerp(Color("1a1014"), t)
	var roof := Color("3a2218").lerp(Color("100c10"), t)
	if is_neighbor:
		wood = Color("4a3020").lerp(Color("141014"), t)
		roof = Color("2e1c14").lerp(Color("0c0a0c"), t)
	var hx := rect.position.x
	var hy := rect.position.y
	var hw := rect.size.x
	var hh := rect.size.y
	# Stilts
	_fill_rect(img, Rect2i(hx + 6, hy + hh - 4, 3, 18), wood.darkened(0.1))
	_fill_rect(img, Rect2i(hx + hw - 10, hy + hh - 4, 3, 18), wood.darkened(0.1))
	_fill_rect(img, Rect2i(hx + hw / 2 - 1, hy + hh - 4, 3, 18), wood.darkened(0.1))
	# Deck
	_fill_rect(img, Rect2i(hx - 6, hy + hh - 8, hw + 14, 8), wood.lightened(0.06))
	for i in maxi(3, hw / 14):
		_fill_rect(img, Rect2i(hx - 4 + i * 12, hy + hh - 7, 10, 1), wood.darkened(0.15))
	# Walls
	_fill_rect(img, Rect2i(hx, hy + 8, hw, hh - 16), wood)
	# Roof slabs
	_fill_rect(img, Rect2i(hx - 8, hy + 2, hw + 16, 8), roof)
	_fill_rect(img, Rect2i(hx - 2, hy - 4, hw + 4, 8), roof.lightened(0.05))
	# Door + windows
	_fill_rect(img, Rect2i(hx + hw / 2 - 6, hy + 22, 12, int(hh * 0.35)), Color("2a1810").lerp(Color("0a080c"), t))
	_fill_rect(img, Rect2i(hx + 8, hy + 18, 10, 8), Color("6a90a0").lerp(Color("203040"), t))
	_fill_rect(img, Rect2i(hx + hw - 20, hy + 18, 10, 8), Color("6a90a0").lerp(Color("203040"), t))
	# Railing
	for i in maxi(4, hw / 12):
		_fill_rect(img, Rect2i(hx - 2 + i * 10, hy + hh - 20, 2, 12), Color("7a5a30").lerp(Color("2a2018"), t))
	_fill_rect(img, Rect2i(hx - 2, hy + hh - 20, hw + 8, 2), Color("8a6a38").lerp(Color("2a2018"), t))
	var glow_a := 0.2 + t * 0.55
	if is_neighbor:
		# Dapur: warm cooking glow + thin smoke so "dapur sebelah" reads clearly
		_fill_ellipse(img, hx + hw - 14, hy + 28, 9, 7, Color(1.0, 0.55, 0.2, 0.25 + glow_a * 0.35))
		_fill_rect(img, Rect2i(hx + hw - 18, hy + 24, 8, 6), Color(1.0, 0.45, 0.15, 0.55 + glow_a * 0.3))
		for i in 4:
			_fill_ellipse(img, hx + hw - 12 + (i % 2), hy + 8 - i * 5, 3 + i / 2, 2, Color(0.75, 0.75, 0.78, 0.28 - i * 0.04))
	else:
		_fill_ellipse(img, hx + hw - 16, hy + 16, 9, 7, Color(1.0, 0.85, 0.4, glow_a * 0.45))
		_fill_rect(img, Rect2i(hx + hw - 18, hy + 12, 5, 9), Color(1.0, 0.8, 0.35, glow_a))


static func _draw_palm(img: Image, base_x: int, base_y: int, scale: float, dusk_t: float) -> void:
	var trunk := Color("6a4228").lerp(Color("2a1814"), dusk_t)
	var leaf := Color("2f7a38").lerp(Color("1a3a20"), dusk_t)
	var th := int(42 * scale)
	var tw := maxi(2, int(4 * scale))
	_fill_rect(img, Rect2i(base_x - tw / 2, base_y - th, tw, th), trunk)
	var top := Vector2i(base_x, base_y - th)
	for a in [-50, -20, 20, 50, -70, 70]:
		var rad := deg_to_rad(float(a) - 90.0)
		for s in range(0, int(22 * scale)):
			var px := top.x + int(cos(rad) * s)
			var py := top.y + int(sin(rad) * s * 0.55)
			_fill_rect(img, Rect2i(px, py, 2, 2), leaf.lightened(0.05 * (s % 3)))


static func tree_sprite() -> ImageTexture:
	var img := Image.create(64, 112, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_fill_ellipse(img, 32, 104, 16, 4, Color(0, 0, 0, 0.3))
	# Trunk
	_fill_rect(img, Rect2i(28, 48, 8, 56), Color("6a4228"))
	_fill_rect(img, Rect2i(30, 48, 2, 56), Color("8a5a38"))
	# Climbable marks
	for i in 5:
		_fill_rect(img, Rect2i(26, 56 + i * 10, 3, 2), Color("5a3820"))
		_fill_rect(img, Rect2i(35, 60 + i * 10, 3, 2), Color("5a3820"))
	# Canopy layers
	_fill_ellipse(img, 32, 36, 26, 22, Color("1f5e28"))
	_fill_ellipse(img, 22, 28, 14, 12, Color("2a7a34"))
	_fill_ellipse(img, 42, 26, 14, 12, Color("2f8a3a"))
	_fill_ellipse(img, 32, 18, 16, 12, Color("3a9a42"))
	_fill_ellipse(img, 32, 30, 10, 8, Color("4aaa50"))
	return ImageTexture.create_from_image(img)


static func person_sprite(kind: String, frame: int = 0) -> ImageTexture:
	var img := Image.create(28, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_fill_ellipse(img, 14, 45, 8, 2, Color(0, 0, 0, 0.25))
	var skin := Color("d4a07a")
	var shirt := Color("3a6a8a")
	var pants := Color("2a2a3a")
	var hair := Color("2a1a18")
	match kind:
		"kid":
			shirt = Color("e06050")
			pants = Color("3a5a8a")
			hair = Color("3a2418")
		"mother":
			shirt = Color("a04070")
			pants = Color("6a2848")
			hair = Color("1a1010")
			skin = Color("c49070")
		"player":
			shirt = Color("3a7a5a")
			pants = Color("2a4030")
			hair = Color("2a2018")
			skin = Color("c48860")
	var bob := 1 if frame % 2 == 0 else 0
	if kind == "kid":
		_fill_ellipse(img, 14, 10 + bob, 6, 6, skin)
		_fill_rect(img, Rect2i(9, 6 + bob, 10, 5), hair)
		_fill_rect(img, Rect2i(8, 16 + bob, 12, 12), shirt)
		_fill_rect(img, Rect2i(4, 14 + bob, 5, 4), skin)
		_fill_rect(img, Rect2i(19, 14 + bob, 5, 4), skin)
		_fill_rect(img, Rect2i(9, 28 + bob, 4, 12), pants)
		_fill_rect(img, Rect2i(15, 28 + bob, 4, 10), pants)
		_px(img, 12, 10 + bob, Color("2a1a18"))
		_px(img, 16, 10 + bob, Color("2a1a18"))
	elif kind == "mother":
		# Watching upward toward tree
		_fill_ellipse(img, 14, 10, 6, 7, skin)
		_fill_ellipse(img, 14, 7, 7, 5, hair)
		_fill_rect(img, Rect2i(8, 6, 12, 4), hair)
		_fill_rect(img, Rect2i(7, 17, 14, 16), shirt)
		_fill_rect(img, Rect2i(9, 33, 10, 12), pants)
		_fill_rect(img, Rect2i(3, 20, 5, 4), skin) # raised hand concern
		_fill_rect(img, Rect2i(2, 18, 3, 3), Color("e8c0a0"))
		_px(img, 12, 10, Color("2a1a18"))
		_px(img, 16, 10, Color("2a1a18"))
		_fill_rect(img, Rect2i(12, 14, 5, 1), Color("8a4040"))
	else:
		_fill_ellipse(img, 14, 10, 6, 6, skin)
		_fill_rect(img, Rect2i(9, 6, 10, 5), hair)
		_fill_rect(img, Rect2i(8, 16, 12, 14), shirt)
		_fill_rect(img, Rect2i(5, 20, 4, 4), skin)
		_fill_rect(img, Rect2i(19, 20, 4, 4), skin)
		_fill_rect(img, Rect2i(9, 30, 4, 14), pants)
		_fill_rect(img, Rect2i(15, 30 + bob, 4, 14 - bob), pants)
		_fill_rect(img, Rect2i(8, 44, 5, 2), Color("3a2a20"))
		_fill_rect(img, Rect2i(15, 44 - bob, 5, 2), Color("3a2a20"))
		_px(img, 12, 10, Color("2a1a18"))
		_px(img, 16, 10, Color("2a1a18"))
	return ImageTexture.create_from_image(img)


static func house_far() -> ImageTexture:
	var img := Image.create(128, 110, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_fill_ellipse(img, 64, 102, 40, 5, Color(0, 0, 0, 0.28))
	var wood := Color("6a422c")
	var dark := Color("3a2418")
	# Stilts
	_fill_rect(img, Rect2i(28, 78, 5, 24), dark)
	_fill_rect(img, Rect2i(60, 78, 5, 24), dark)
	_fill_rect(img, Rect2i(95, 78, 5, 24), dark)
	# Deck
	_fill_rect(img, Rect2i(18, 72, 92, 10), wood.lightened(0.08))
	for i in 7:
		_fill_rect(img, Rect2i(20 + i * 12, 74, 10, 1), wood.darkened(0.2))
	# Stairs
	_fill_rect(img, Rect2i(52, 82, 24, 4), wood)
	_fill_rect(img, Rect2i(56, 86, 16, 4), wood.darkened(0.1))
	_fill_rect(img, Rect2i(60, 90, 8, 4), wood.darkened(0.15))
	# Walls
	_fill_rect(img, Rect2i(24, 34, 80, 40), wood)
	_fill_rect(img, Rect2i(28, 38, 72, 2), wood.lightened(0.1))
	# Roof
	_fill_rect(img, Rect2i(14, 26, 100, 12), dark)
	_fill_rect(img, Rect2i(22, 18, 84, 12), dark.lightened(0.08))
	_fill_rect(img, Rect2i(34, 12, 60, 10), Color("2a1810"))
	# Door / windows
	_fill_rect(img, Rect2i(56, 48, 16, 24), Color("2a1810"))
	_fill_rect(img, Rect2i(32, 44, 12, 10), Color("7aa0b0"))
	_fill_rect(img, Rect2i(84, 44, 12, 10), Color("7aa0b0"))
	# Railing
	for i in 9:
		_fill_rect(img, Rect2i(22 + i * 10, 62, 2, 12), Color("8a6238"))
	_fill_rect(img, Rect2i(22, 62, 86, 2), Color("9a7240"))
	# Lamp glow
	_fill_ellipse(img, 92, 42, 10, 8, Color(1.0, 0.85, 0.4, 0.35))
	_fill_rect(img, Rect2i(90, 38, 5, 8), Color(1.0, 0.82, 0.35, 0.85))
	# Coconut near house
	_draw_palm(img, 12, 95, 0.55, 0.15)
	_draw_palm(img, 116, 95, 0.5, 0.15)
	return ImageTexture.create_from_image(img)


static func house_neighbor() -> ImageTexture:
	## Smaller tetangga house with dapur glow + smoke.
	var img := Image.create(96, 90, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_fill_ellipse(img, 48, 84, 28, 4, Color(0, 0, 0, 0.25))
	var wood := Color("5a3a28")
	var dark := Color("2e1c14")
	_fill_rect(img, Rect2i(18, 66, 4, 18), dark)
	_fill_rect(img, Rect2i(44, 66, 4, 18), dark)
	_fill_rect(img, Rect2i(72, 66, 4, 18), dark)
	_fill_rect(img, Rect2i(12, 60, 72, 8), wood.lightened(0.05))
	_fill_rect(img, Rect2i(16, 30, 64, 32), wood)
	_fill_rect(img, Rect2i(8, 22, 80, 10), dark)
	_fill_rect(img, Rect2i(16, 16, 64, 10), dark.lightened(0.08))
	_fill_rect(img, Rect2i(40, 42, 12, 18), Color("2a1810"))
	_fill_rect(img, Rect2i(22, 38, 10, 8), Color("6a90a0"))
	# Dapur window glow
	_fill_ellipse(img, 70, 44, 8, 6, Color(1.0, 0.55, 0.2, 0.4))
	_fill_rect(img, Rect2i(64, 40, 10, 8), Color(1.0, 0.5, 0.18, 0.75))
	# Smoke
	_fill_ellipse(img, 72, 28, 4, 3, Color(0.8, 0.8, 0.82, 0.35))
	_fill_ellipse(img, 74, 20, 5, 3, Color(0.8, 0.8, 0.82, 0.25))
	_fill_ellipse(img, 70, 12, 6, 3, Color(0.8, 0.8, 0.82, 0.15))
	return ImageTexture.create_from_image(img)


static func fence_post() -> ImageTexture:
	var img := Image.create(8, 28, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_fill_rect(img, Rect2i(2, 0, 4, 28), Color("6a4a28"))
	_fill_rect(img, Rect2i(0, 8, 8, 2), Color("7a5a30"))
	_fill_rect(img, Rect2i(0, 16, 8, 2), Color("7a5a30"))
	return ImageTexture.create_from_image(img)
