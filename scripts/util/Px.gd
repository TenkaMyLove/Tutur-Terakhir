class_name Px
extends RefCounted

## Low-level pixel drawing helpers shared by PixelArt, NenekArt and IconArt.
## Light source convention: warm sunset light from the upper right.

const CLEAR := Color(0, 0, 0, 0)
const OUTLINE := Color(0.13, 0.08, 0.12, 1.0)

const _BAYER := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]


static func canvas(w: int, h: int) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(CLEAR)
	return img


static func tex(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)


static func hex(s: String) -> Color:
	return Color(s)


static func bayer(x: int, y: int) -> float:
	return (float(_BAYER[(y & 3) * 4 + (x & 3)]) + 0.5) / 16.0


## Hue-shifted shadow: darker and slightly purple.
static func shade(c: Color, amt: float = 0.2) -> Color:
	var d := c.darkened(amt)
	var o := d.lerp(Color(0.28, 0.16, 0.36, c.a), 0.16)
	o.a = c.a
	return o


## Hue-shifted highlight: lighter and slightly golden.
static func light(c: Color, amt: float = 0.18) -> Color:
	var l := c.lightened(amt)
	var o := l.lerp(Color(1.0, 0.85, 0.6, c.a), 0.14)
	o.a = c.a
	return o


static func px(img: Image, x: int, y: int, c: Color) -> void:
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return
	if c.a <= 0.001:
		return
	if c.a >= 0.99:
		img.set_pixel(x, y, c)
	else:
		var base := img.get_pixel(x, y)
		var o := base.lerp(c, c.a)
		o.a = maxf(base.a, c.a)
		img.set_pixel(x, y, o)


static func rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	var r := Rect2i(0, 0, img.get_width(), img.get_height()).intersection(Rect2i(x, y, w, h))
	if r.size.x <= 0 or r.size.y <= 0:
		return
	if c.a >= 0.99:
		img.fill_rect(r, c)
		return
	for yy in range(r.position.y, r.position.y + r.size.y):
		for xx in range(r.position.x, r.position.x + r.size.x):
			px(img, xx, yy, c)


static func ellipse(img: Image, cx: int, cy: int, rx: int, ry: int, c: Color) -> void:
	var fx := float(maxi(1, rx)) + 0.35
	var fy := float(maxi(1, ry)) + 0.35
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			var dx := float(x - cx) / fx
			var dy := float(y - cy) / fy
			if dx * dx + dy * dy <= 1.0:
				px(img, x, y, c)


## Cel-shaded ellipse, lit from the upper right.
static func ball(img: Image, cx: int, cy: int, rx: int, ry: int, base: Color) -> void:
	var lt := light(base)
	var dk := shade(base)
	var fx := float(maxi(1, rx)) + 0.35
	var fy := float(maxi(1, ry)) + 0.35
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			var dx := float(x - cx) / fx
			var dy := float(y - cy) / fy
			if dx * dx + dy * dy > 1.0:
				continue
			var v := dx * 0.55 - dy * 0.7
			var c := base
			if v > 0.52:
				c = lt
			elif v < -0.42:
				c = dk
			px(img, x, y, c)


## Box with a lit right/top edge and shaded left/bottom edge.
static func box(img: Image, x: int, y: int, w: int, h: int, base: Color) -> void:
	rect(img, x, y, w, h, base)
	if w >= 3:
		rect(img, x, y, 1, h, shade(base, 0.12))
		rect(img, x + w - 1, y, 1, h, light(base, 0.1))
	if h >= 3:
		rect(img, x, y, w, 1, light(base, 0.08))
		rect(img, x, y + h - 1, w, 1, shade(base, 0.14))


static func line(img: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	var x := x0
	var y := y0
	for _i in range(512):
		px(img, x, y, c)
		if x == x1 and y == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy


## Line with round brush of radius r.
static func thick(img: Image, x0: float, y0: float, x1: float, y1: float, r: float, c: Color) -> void:
	var steps := int(maxf(absf(x1 - x0), absf(y1 - y0))) + 1
	var ri := int(ceil(r))
	for i in range(steps + 1):
		var t := float(i) / float(maxi(1, steps))
		var cx := lerpf(x0, x1, t)
		var cy := lerpf(y0, y1, t)
		for yy in range(int(cy) - ri, int(cy) + ri + 1):
			for xx in range(int(cx) - ri, int(cx) + ri + 1):
				var dx := float(xx) - cx
				var dy := float(yy) - cy
				if dx * dx + dy * dy <= r * r + 0.3:
					px(img, xx, yy, c)


static func tri(img: Image, ax: int, ay: int, bx: int, by: int, cx: int, cy: int, c: Color) -> void:
	var minx := mini(ax, mini(bx, cx))
	var maxx := maxi(ax, maxi(bx, cx))
	var miny := mini(ay, mini(by, cy))
	var maxy := maxi(ay, maxi(by, cy))
	var den := float((by - cy) * (ax - cx) + (cx - bx) * (ay - cy))
	if absf(den) < 0.001:
		return
	for y in range(miny, maxy + 1):
		for x in range(minx, maxx + 1):
			var a := float((by - cy) * (x - cx) + (cx - bx) * (y - cy)) / den
			var b := float((cy - ay) * (x - cx) + (ax - cx) * (y - cy)) / den
			var g := 1.0 - a - b
			if a >= -0.02 and b >= -0.02 and g >= -0.02:
				px(img, x, y, c)


## Soft radial glow using ordered dithering (stays pixel-art crisp).
static func glow(img: Image, cx: int, cy: int, r: int, c: Color, strength: float = 1.0, ysquash: float = 1.0) -> void:
	if strength <= 0.01:
		return
	var ry := int(float(r) * ysquash)
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - r, cx + r + 1):
			var dx := float(x - cx) / float(r)
			var dy := float(y - cy) / (float(r) * ysquash)
			var d := sqrt(dx * dx + dy * dy)
			if d >= 1.0:
				continue
			var s := pow(1.0 - d, 1.8) * strength * c.a
			var v := s * 4.0
			var base := floorf(v)
			var frac := v - base
			var a := (base + (1.0 if frac > bayer(x, y) else 0.0)) / 4.0
			if a > 0.0:
				px(img, x, y, Color(c.r, c.g, c.b, minf(a, 0.95)))


## Fills a 1px dark outline around the opaque silhouette (4-neighbour).
static func outline(img: Image, c: Color = OUTLINE) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var src := img.get_data()
	var dst := src.duplicate()
	var r := int(c.r * 255.0)
	var g := int(c.g * 255.0)
	var b := int(c.b * 255.0)
	var a := int(c.a * 255.0)
	for y in range(h):
		for x in range(w):
			var i := (y * w + x) * 4
			if src[i + 3] > 20:
				continue
			var hit := false
			if x > 0 and src[i - 4 + 3] > 200:
				hit = true
			elif x < w - 1 and src[i + 4 + 3] > 200:
				hit = true
			elif y > 0 and src[i - w * 4 + 3] > 200:
				hit = true
			elif y < h - 1 and src[i + w * 4 + 3] > 200:
				hit = true
			if hit:
				dst[i] = r
				dst[i + 1] = g
				dst[i + 2] = b
				dst[i + 3] = a
	img.set_data(w, h, false, Image.FORMAT_RGBA8, dst)


## Warm rim light on right-hand silhouette edges (call before outline()).
static func rim(img: Image, c: Color, amt: float = 0.5) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var src := img.get_data()
	var dst := src.duplicate()
	var cr := c.r * 255.0
	var cg := c.g * 255.0
	var cb := c.b * 255.0
	for y in range(h):
		for x in range(w - 1):
			var i := (y * w + x) * 4
			if src[i + 3] > 200 and src[i + 4 + 3] < 20:
				dst[i] = int(lerpf(float(src[i]), cr, amt))
				dst[i + 1] = int(lerpf(float(src[i + 1]), cg, amt))
				dst[i + 2] = int(lerpf(float(src[i + 2]), cb, amt))
	img.set_data(w, h, false, Image.FORMAT_RGBA8, dst)


## Pseudo random in [0,1) from an integer seed.
static func rnd(i: int) -> float:
	return fposmod(sin(float(i) * 12.9898 + 4.1414) * 43758.5453, 1.0)


## Copies `src` onto `dst` (alpha blended) at pos.
static func blit(dst: Image, src: Image, pos: Vector2i) -> void:
	dst.blend_rect(src, Rect2i(0, 0, src.get_width(), src.get_height()), pos)


## Vertical gradient of discrete bands with dithered transitions.
## stops: Array of [position 0..1, Color]. Fills rows y0..y1-1 across width.
static func sky_bands(img: Image, y0: int, y1: int, stops: Array, bands: int) -> void:
	var w := img.get_width()
	var span := maxi(1, y1 - y0)
	for y in range(y0, y1):
		var u := float(y - y0) / float(span)
		var v := u * float(bands)
		var bi := floori(v)
		var frac := v - float(bi)
		var ca := _stops_at(stops, (float(bi) + 0.5) / float(bands))
		if frac > 0.62 and bi < bands - 1:
			var cb := _stops_at(stops, (float(bi) + 1.5) / float(bands))
			var k := (frac - 0.62) / 0.38
			for x in range(w):
				var pick := cb if k > bayer(x, y) else ca
				img.set_pixel(x, y, pick)
		else:
			img.fill_rect(Rect2i(0, y, w, 1), ca)


static func _stops_at(stops: Array, u: float) -> Color:
	u = clampf(u, 0.0, 1.0)
	for i in range(stops.size() - 1):
		var a: Array = stops[i]
		var b: Array = stops[i + 1]
		if u <= float(b[0]):
			var k := (u - float(a[0])) / maxf(0.0001, float(b[0]) - float(a[0]))
			return (a[1] as Color).lerp(b[1] as Color, clampf(k, 0.0, 1.0))
	return (stops[stops.size() - 1] as Array)[1]


## Three-keyframe colour (afternoon -> dusk -> night).
static func kf(t: float, c0: String, c1: String, c2: String) -> Color:
	if t < 0.5:
		return Color(c0).lerp(Color(c1), t * 2.0)
	return Color(c1).lerp(Color(c2), (t - 0.5) * 2.0)
