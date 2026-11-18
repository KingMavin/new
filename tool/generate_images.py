"""Generates the still backdrop art for Immortal Path into assets/images/.

Pure standard library (zlib + struct). Rerun with:  python3 tool/generate_images.py
Every image is procedurally painted - original, license-free, and swappable.
"""
import math
import os
import random
import struct
import zlib

W, H = 640, 360
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'images')


class Canvas(object):
    def __init__(self, seed=1):
        self.px = [[(0.0, 0.0, 0.0)] * W for _ in range(H)]
        self.rng = random.Random(seed)

    def clamp(self, v):
        return max(0.0, min(1.0, v))

    def blend(self, x, y, color, alpha):
        if 0 <= x < W and 0 <= y < H:
            r, g, b = self.px[y][x]
            dr, dg, db = color
            self.px[y][x] = (
                self.clamp(r * (1 - alpha) + dr * alpha),
                self.clamp(g * (1 - alpha) + dg * alpha),
                self.clamp(b * (1 - alpha) + db * alpha),
            )

    def gradient(self, stops):
        for y in range(H):
            t = y / (H - 1)
            for i in range(len(stops) - 1):
                p0, c0 = stops[i]
                p1, c1 = stops[i + 1]
                if p0 <= t <= p1:
                    f = (t - p0) / max(1e-6, (p1 - p0))
                    c = tuple(c0[k] + (c1[k] - c0[k]) * f for k in range(3))
                    break
            row = self.px[y]
            for x in range(W):
                row[x] = c

    def disc_glow(self, cx, cy, r, color, core_alpha=1.0, spread=3.0):
        for y in range(max(0, int(cy - r * spread)), min(H, int(cy + r * spread))):
            for x in range(max(0, int(cx - r * spread)), min(W, int(cx + r * spread))):
                d = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
                if d <= r:
                    a = core_alpha
                else:
                    f = 1.0 - (d - r) / (r * (spread - 1.0))
                    a = core_alpha * max(0.0, f) ** 2
                if a > 0.01:
                    self.blend(x, y, color, a * 0.55 if d > r else a)

    def stars(self, n, color=(1, 1, 1), ymax=0.7, size_max=1):
        for _ in range(n):
            x = self.rng.randrange(W)
            y = self.rng.randrange(int(H * ymax))
            s = self.rng.randint(1, size_max)
            a = 0.3 + self.rng.random() * 0.7
            for dy in range(s):
                for dx in range(s):
                    self.blend(x + dx, y + dy, color, a)

    def add(self, other, alpha=1.0):
        for y in range(H):
            row = self.px[y]
            orow = other.px[y]
            for x in range(W):
                c = orow[x]
                if c != (0.0, 0.0, 0.0):
                    self.blend(x, y, c, alpha)

    def ridge(self, base_y, amplitude, color, roughness=0.55, points=24, seed_extra=0):
        rng = random.Random(int(base_y * 7 + amplitude * 13 + seed_extra))
        ys = [base_y + rng.uniform(-amplitude, amplitude)]
        step = W / points
        vals = [rng.uniform(-1, 1) for _ in range(points + 1)]
        # midpoint displacement smoothing
        for level in range(3):
            nxt = []
            for i in range(len(vals) - 1):
                nxt.append(vals[i])
                nxt.append((vals[i] + vals[i + 1]) / 2 + rng.uniform(-1, 1) * 0.35 * roughness * amplitude / (level + 1))
            nxt.append(vals[-1])
            vals = nxt
        coords = [(i / (len(vals) - 1) * W, base_y + v) for i, v in enumerate(vals)]
        self.fill_polygon(coords, color)

    def fill_polygon(self, coords, color, alpha=1.0):
        ys = [p[1] for p in coords]
        y0, y1 = int(min(ys)), int(max(ys))
        n = len(coords)
        for y in range(y0, min(H, y1 + 1)):
            xs = []
            for i in range(n):
                x0, yy0 = coords[i]
                x1, yy1 = coords[(i + 1) % n]
                if (yy0 <= y < yy1) or (yy1 <= y < yy0):
                    t = (y - yy0) / (yy1 - yy0)
                    xs.append(x0 + t * (x1 - x0))
            xs.sort()
            for i in range(0, len(xs) - 1, 2):
                a, b = int(xs[i]), int(xs[i + 1])
                for x in range(max(0, a), min(W, b + 1)):
                    self.blend(x, y, color, alpha)

    def mist_band(self, cy, height, alpha=0.2, color=(0.92, 0.95, 0.97)):
        for y in range(max(0, cy - height), min(H, cy + height)):
            f = 1.0 - abs(y - cy) / height
            a = alpha * f * f
            row = self.px[y]
            for x in range(W):
                w = 0.75 + 0.25 * math.sin(x * 0.012 + y * 0.05)
                self.blend(x, y, color, a * w)

    def line(self, x0, y0, x1, y1, color, width=1, alpha=1.0):
        steps = int(max(abs(x1 - x0), abs(y1 - y0))) * 2 + 1
        for i in range(steps + 1):
            t = i / steps
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            for dy in range(width):
                for dx in range(width):
                    self.blend(int(x) + dx, int(y) + dy, color, alpha)

    def rect(self, x0, y0, x1, y1, color, alpha=1.0):
        for y in range(max(0, int(y0)), min(H, int(y1))):
            for x in range(max(0, int(x0)), min(W, int(x1))):
                self.blend(x, y, color, alpha)

    def triangle(self, p0, p1, p2, color, alpha=1.0):
        self.fill_polygon([p0, p1, p2], color, alpha)

    def particles(self, n, x_range, y_range, color, size=2, alpha=0.7, rise=False):
        for _ in range(n):
            x = self.rng.uniform(*x_range)
            y = self.rng.uniform(*y_range)
            s = self.rng.randint(1, size)
            a = self.rng.uniform(0.3, 1.0) * alpha
            for dy in range(s):
                for dx in range(s):
                    self.blend(int(x) + dx, int(y) + dy, color, a)


# ---- silhouette vocabulary -------------------------------------------------

def pagoda(c, cx, base_y, scale, color):
    tiers = 4
    h = 26 * scale
    for t in range(tiers):
        w = (34 - t * 6) * scale / 2 + 6 * scale
        y = base_y - t * h
        c.triangle((cx - w, y), (cx + w, y), (cx, y - h), color)
        c.rect(cx - w * 0.8, y, cx + w * 0.8, y + 6 * scale, color)
    c.rect(cx - 2 * scale, base_y, cx + 2 * scale, base_y + 8 * scale, color)


def gate(c, cx, base_y, scale, color, glow=None):
    w = 26 * scale
    h = 54 * scale
    c.rect(cx - w, base_y - h, cx - w + 6 * scale, base_y, color)
    c.rect(cx + w - 6 * scale, base_y - h, cx + w, base_y, color)
    c.rect(cx - w - 10 * scale, base_y - h, cx + w + 10 * scale, base_y - h + 7 * scale, color)
    c.rect(cx - w - 5 * scale, base_y - h * 0.72, cx + w + 5 * scale, base_y - h * 0.72 + 5 * scale, color)
    if glow:
        c.rect(cx - w * 0.55, base_y - h * 0.65, cx + w * 0.55, base_y, glow, 0.5)


def bamboos(c, x0, x1, base_y, n, color, tall=True):
    for i in range(n):
        x = x0 + (x1 - x0) * (i + c.rng.uniform(-0.3, 0.3)) / max(1, n - 1)
        x = max(0, min(W - 1, x))
        h = c.rng.uniform(90, 160) if tall else c.rng.uniform(40, 80)
        c.line(x, base_y, x, base_y - h, color, 2)
        seg = h / c.rng.uniform(4, 6)
        y = base_y
        while y > base_y - h:
            ny = y - seg
            c.line(x, y, x, ny, color, 2)
            y = ny
        leaves = c.rng.randint(2, 4)
        for _ in range(leaves):
            lx = x + c.rng.uniform(-14, 14)
            ly = base_y - h + c.rng.uniform(0, 18)
            c.line(x, base_y - h + c.rng.uniform(0, 20), lx, ly, color, 1)


def tree(c, x, base_y, scale, color):
    c.line(x, base_y, x, base_y - 18 * scale, color, 2)
    for angle in range(0, 360, 45):
        r = 10 * scale
        cx = x + math.cos(math.radians(angle)) * r * 0.8
        cy = base_y - 20 * scale + math.sin(math.radians(angle)) * r * 0.5
        for yy in range(int(cy - 6), int(cy + 6)):
            for xx in range(int(cx - 8), int(cx + 8)):
                if (xx - cx) ** 2 / 64 + (yy - cy) ** 2 / 36 <= 1:
                    c.blend(xx, yy, color, 0.9)


def figure(c, cx, base_y, scale, color, pose='stand'):
    h = 20 * scale
    c.rect(cx - 3 * scale, base_y - h, cx + 3 * scale, base_y, color)
    c.rect(cx - 2 * scale, base_y - h - 5 * scale, cx + 2 * scale, base_y - h, color)
    if pose == 'hood':
        c.triangle((cx - 4 * scale, base_y - h), (cx + 4 * scale, base_y - h), (cx, base_y - h - 8 * scale), color)


def spears(c, xs, base_y, color, lean=0.3):
    for x in xs:
        c.line(x, base_y, x + lean * 14, base_y - c.rng.uniform(26, 40), color, 1)
        tipx = x + lean * 14
        c.triangle((tipx - 1, base_y - 40), (tipx + 3, base_y - 40), (tipx + 1, base_y - 47), color)


def planted_swords(c, base_y, n, color):
    for _ in range(n):
        x = c.rng.uniform(20, W - 20)
        h = c.rng.uniform(18, 42)
        tilt = c.rng.uniform(-0.35, 0.35)
        x2 = x + tilt * h
        c.line(x, base_y, x2, base_y - h, color, 2)
        c.triangle((x2 - 2.5, base_y - h), (x2 + 2.5, base_y - h), (x2 + tilt * 3, base_y - h - 8), color)


def rock_spikes(c, base_y, n, color, big=True):
    for _ in range(n):
        x = c.rng.uniform(10, W - 10)
        h = c.rng.uniform(30, 70) if big else c.rng.uniform(10, 26)
        w = h * c.rng.uniform(0.25, 0.5)
        c.triangle((x - w, base_y), (x + w, base_y), (x, base_y - h), color)


def ruins_wall(c, base_y, color):
    gap = (0.02, 0.02, 0.03)
    x = 30
    while x < W - 40:
        seg = c.rng.uniform(40, 100)
        h = c.rng.uniform(28, 60)
        c.rect(x, base_y - h, min(W, x + seg), base_y, color)
        for _ in range(int(seg / 24)):
            gx = x + c.rng.uniform(2, seg - 4)
            c.rect(gx, base_y - c.rng.uniform(4, h), gx + c.rng.uniform(3, 8), base_y, gap)
        x += seg + c.rng.uniform(4, 22)


def lightning(c, x0, y0, x1, y1, color, width=2):
    pts = [(x0, y0)]
    n = 8
    for i in range(1, n):
        t = i / n
        x = x0 + (x1 - x0) * t + c.rng.uniform(-18, 18) * (1 - abs(t - 0.5) * 2)
        y = y0 + (y1 - y0) * t
        pts.append((x, y))
    pts.append((x1, y1))
    for i in range(n):
        c.line(pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1], color, width)
        if c.rng.random() < 0.4:
            bx, by = pts[i]
            c.line(bx, by, bx + c.rng.uniform(-40, 40), by + c.rng.uniform(10, 30), color, 1)


def pool(c, cx, cy, rx, ry, color, glow=None):
    for y in range(int(cy - ry), int(cy + ry)):
        for x in range(int(cx - rx), int(cx + rx)):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1:
                f = 0.6 + 0.4 * math.sin(x * 0.05 + y * 0.2)
                c.blend(x, y, tuple(v * f for v in color), 0.8)
    if glow:
        c.disc_glow(cx, cy, rx * 0.5, glow, 0.5, 2.5)


def banners(c, xs, top_y, color):
    for x in xs:
        c.line(x, top_y, x, top_y + 46, color, 2)
        c.triangle((x + 1, top_y), (x + 1, top_y + 34), (x + 14, top_y + 28), color, 0.9)


def rib_arcs(c, cx, base_y, n, color):
    for i in range(n):
        r = 40 + i * 22
        x0 = cx - r
        x1 = cx + r
        h = r * 0.8
        for t in range(int(r * 2)):
            tt = t / (r * 2)
            x = x0 + (x1 - x0) * tt
            y = base_y - h * math.sin(math.pi * tt)
            c.line(x, y, x + 1, y + 1, color, 2)


def furnace(c, cx, base_y, scale, color, glow):
    r = 20 * scale
    for y in range(int(base_y - r * 2), int(base_y)):
        for x in range(int(cx - r), int(cx + r)):
            dx, dy = (x - cx) / r, (base_y - y - r * 0.9) / (r * 1.8)
            if dx * dx + dy * dy <= 1:
                c.blend(x, y, color, 0.95)
    c.rect(cx - r * 0.6, base_y - 2, cx + r * 0.6, base_y + 4 * scale, color)
    glow_col = glow
    for i in range(3):
        c.rect(cx - r * (0.5 - i * 0.1), base_y - 6 - i * 10, cx + r * (0.5 - i * 0.1), base_y - 2 - i * 10, glow_col, 0.5 - i * 0.12)


def cave_arch(c, cx, base_y, r, color, rim):
    for y in range(int(base_y - r), int(base_y)):
        for x in range(int(cx - r), int(cx + r)):
            d = math.sqrt((x - cx) ** 2 + ((base_y - y) / 1.4) ** 2)
            if d <= r:
                c.blend(x, y, color, 0.98)
    for a in range(0, 181, 2):
        x = cx + math.cos(math.radians(180 + a)) * r
        y = base_y - math.sin(math.radians(a)) * r * 1.1
        c.line(x, y, x + 2, y + 1, rim, 2, 0.7)


# ---- scenes ----------------------------------------------------------------

def finish(c, path):
    data = bytearray()
    for y in range(H):
        data.append(0)
        row = c.px[y]
        for x in range(W):
            r, g, b = row[x]
            data.append(int(r * 255 + 0.5))
            data.append(int(g * 255 + 0.5))
            data.append(int(b * 255 + 0.5))
    compressed = zlib.compress(bytes(data), 6)
    def chunk(tag, payload):
        return (struct.pack('>I', len(payload)) + tag + payload +
                struct.pack('>I', zlib.crc32(tag + payload) & 0xffffffff))
    ihdr = struct.pack('>IIBBBBB', W, H, 8, 2, 0, 0, 0)
    png = (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) +
           chunk(b'IDAT', compressed) + chunk(b'IEND', b''))
    with open(os.path.join(OUT, path), 'wb') as f:
        f.write(png)


def sky(c, top, mid, bottom, horizon=0.62):
    c.gradient([(0.0, top), (horizon, mid), (1.0, bottom)])

C_BLACK = (0.02, 0.02, 0.05)
C_DARK = (0.06, 0.07, 0.10)

def ridge_dark(c, base, amp, tint=(0.07, 0.09, 0.13), seed=1):
    c.ridge(base, amp, tint, seed_extra=seed)

def vignette(c, strength=0.35):
    for y in range(H):
        for x in range(W):
            dx = (x - W / 2) / (W / 2)
            dy = (y - H / 2) / (H / 2)
            f = 1 - strength * (dx * dx + dy * dy)
            r, g, b = c.px[y][x]
            c.px[y][x] = (r * f, g * f, b * f)


SCENES = {}

def scene(name, seed):
    def wrap(fn):
        SCENES[name] = (fn, seed)
        return fn
    return wrap

@scene('screen_home', 11)
def s(c):
    sky(c, (0.03, 0.04, 0.10), (0.10, 0.09, 0.22), (0.02, 0.02, 0.06), 0.7)
    c.stars(90, (0.9, 0.9, 1.0), 0.8)
    ridge_dark(c, 320, 50, (0.05, 0.06, 0.10), 2)
    cave_arch(c, 320, 350, 120, (0.015, 0.02, 0.04), (0.45, 0.55, 0.9))
    c.disc_glow(320, 250, 26, (0.55, 0.75, 1.0), 0.9, 3.5)
    figure(c, 320, 285, 1.3, (0.02, 0.02, 0.05))
    c.particles(40, (180, 460), (170, 300), (0.5, 0.7, 1.0), 1, 0.8)
    c.mist_band(320, 40, 0.10, (0.4, 0.5, 0.8))
    vignette(c)

@scene('screen_world', 12)
def s(c):
    sky(c, (0.45, 0.62, 0.72), (0.70, 0.78, 0.80), (0.86, 0.88, 0.84))
    ridge_dark(c, 190, 60, (0.28, 0.38, 0.44), 5)
    ridge_dark(c, 240, 55, (0.18, 0.26, 0.32), 6)
    c.mist_band(230, 30, 0.35)
    ridge_dark(c, 300, 45, (0.10, 0.16, 0.20), 7)
    pagoda(c, 470, 262, 1.6, (0.07, 0.11, 0.15))
    c.mist_band(300, 25, 0.25)
    ridge_dark(c, 355, 18, (0.05, 0.09, 0.12), 8)
    vignette(c, 0.25)

@scene('screen_alchemy', 13)
def s(c):
    sky(c, (0.10, 0.04, 0.16), (0.22, 0.10, 0.30), (0.05, 0.02, 0.09), 0.75)
    c.stars(60, (1.0, 0.9, 1.0), 0.5)
    ridge_dark(c, 330, 30, (0.05, 0.03, 0.09), 9)
    furnace(c, 320, 330, 1.7, (0.13, 0.07, 0.14), (1.0, 0.55, 0.15))
    c.disc_glow(320, 300, 30, (1.0, 0.6, 0.2), 0.5, 2.5)
    c.particles(50, (240, 400), (140, 330), (1.0, 0.55, 0.15), 2, 0.8)
    vignette(c)

@scene('screen_sect', 14)
def s(c):
    sky(c, (0.80, 0.55, 0.35), (0.92, 0.78, 0.55), (0.60, 0.48, 0.42))
    c.disc_glow(140, 170, 30, (1.0, 0.92, 0.75), 0.7, 3)
    ridge_dark(c, 200, 55, (0.30, 0.24, 0.30), 10)
    c.mist_band(240, 26, 0.4, (1.0, 0.92, 0.85))
    ridge_dark(c, 290, 40, (0.18, 0.14, 0.18), 11)
    pagoda(c, 200, 290, 1.8, (0.09, 0.07, 0.10))
    pagoda(c, 430, 296, 1.3, (0.09, 0.07, 0.10))
    gate(c, 560, 350, 1.1, (0.08, 0.06, 0.09))
    ridge_dark(c, 360, 12, (0.06, 0.05, 0.08), 12)
    vignette(c, 0.25)

@scene('screen_dao', 15)
def s(c):
    sky(c, (0.02, 0.02, 0.09), (0.08, 0.06, 0.22), (0.16, 0.10, 0.28))
    for _ in range(130):
        c.stars(1, (0.85 + 0.15 * c.rng.random(),) * 3, 1.0, 2)
    c.disc_glow(500, 90, 34, (0.95, 0.93, 1.0), 1.0, 3.2)
    c.stars(25, (0.8, 0.85, 1.0), 0.95, 2)
    ridge_dark(c, 345, 22, (0.03, 0.03, 0.07), 13)
    vignette(c)

@scene('screen_tribulation', 16)
def s(c):
    sky(c, (0.10, 0.11, 0.16), (0.20, 0.22, 0.30), (0.08, 0.09, 0.13), 0.8)
    c.mist_band(90, 60, 0.25, (0.35, 0.38, 0.5))
    c.mist_band(130, 40, 0.2, (0.3, 0.32, 0.45))
    ridge_dark(c, 300, 55, (0.06, 0.07, 0.10), 14)
    ridge_dark(c, 355, 20, (0.03, 0.04, 0.06), 15)
    lightning(c, 110, 40, 150, 250, (1.0, 0.97, 0.85), 2)
    lightning(c, 480, 60, 430, 240, (0.85, 0.9, 1.0), 2)
    c.particles(20, (0, W), (300, 350), (0.7, 0.75, 0.9), 1, 0.4)
    vignette(c)

@scene('screen_store', 17)
def s(c):
    sky(c, (0.16, 0.09, 0.05), (0.34, 0.20, 0.09), (0.08, 0.05, 0.03), 0.7)
    c.disc_glow(320, 200, 60, (1.0, 0.75, 0.3), 0.35, 3.5)
    pagoda(c, 320, 300, 2.4, (0.10, 0.06, 0.04))
    banners(c, [180, 225, 415, 460], 210, (0.12, 0.07, 0.05))
    ridge_dark(c, 340, 16, (0.05, 0.03, 0.02), 16)
    c.particles(30, (100, 540), (160, 320), (1.0, 0.75, 0.3), 1, 0.6)
    vignette(c)

@scene('screen_settings', 18)
def s(c):
    sky(c, (0.10, 0.16, 0.14), (0.22, 0.32, 0.24), (0.06, 0.10, 0.08), 0.75)
    bamboos(c, 20, 180, 360, 9, (0.04, 0.09, 0.07))
    bamboos(c, 460, 630, 360, 8, (0.05, 0.10, 0.08))
    c.disc_glow(120, 110, 22, (0.9, 0.95, 0.9), 0.6, 3)
    ridge_dark(c, 330, 20, (0.06, 0.12, 0.09), 17)
    c.mist_band(330, 30, 0.25, (0.85, 0.95, 0.85))
    vignette(c, 0.25)

@scene('screen_encounter', 19)
def s(c):
    sky(c, (0.13, 0.14, 0.18), (0.24, 0.25, 0.30), (0.10, 0.10, 0.13), 0.66)
    ridge_dark(c, 220, 45, (0.13, 0.14, 0.17), 18)
    c.mist_band(250, 28, 0.3, (0.65, 0.68, 0.75))
    ridge_dark(c, 320, 30, (0.06, 0.06, 0.08), 19)
    spears(c, [60, 120, 170, 500, 560, 610], 350, (0.04, 0.04, 0.05))
    banners(c, [280, 360], 240, (0.05, 0.05, 0.06))
    c.mist_band(320, 20, 0.18)
    vignette(c)

@scene('event_ancient_tomb', 20)
def s(c):
    sky(c, (0.05, 0.05, 0.09), (0.12, 0.10, 0.15), (0.03, 0.03, 0.05), 0.75)
    ridge_dark(c, 280, 60, (0.08, 0.07, 0.10), 20)
    cave_arch(c, 320, 340, 80, (0.02, 0.02, 0.03), (0.7, 0.5, 0.2))
    c.disc_glow(280, 320, 8, (1.0, 0.7, 0.25), 1.0, 3)
    c.disc_glow(360, 320, 8, (1.0, 0.7, 0.25), 1.0, 3)
    ridge_dark(c, 355, 10, (0.02, 0.02, 0.03), 21)
    vignette(c)

@scene('event_spirit_spring', 21)
def s(c):
    sky(c, (0.10, 0.20, 0.26), (0.20, 0.38, 0.40), (0.06, 0.12, 0.14), 0.6)
    bamboos(c, 10, 130, 360, 7, (0.03, 0.10, 0.09))
    bamboos(c, 510, 630, 360, 7, (0.03, 0.10, 0.09))
    pool(c, 320, 320, 130, 34, (0.15, 0.45, 0.50), (0.5, 1.0, 0.9))
    c.disc_glow(320, 320, 20, (0.4, 1.0, 0.85), 0.5, 3)
    c.particles(30, (200, 440), (240, 320), (0.5, 1.0, 0.85), 1, 0.7)
    vignette(c, 0.3)

@scene('event_wandering_merchant', 22)
def s(c):
    sky(c, (0.30, 0.16, 0.10), (0.55, 0.32, 0.16), (0.16, 0.10, 0.08), 0.7)
    ridge_dark(c, 300, 40, (0.12, 0.08, 0.07), 22)
    c.line(0, 340, W, 350, (0.07, 0.05, 0.04), 6)
    c.rect(200, 300, 330, 334, (0.03, 0.02, 0.02))
    c.triangle((200, 300), (330, 300), (265, 262), (0.05, 0.03, 0.03))
    c.disc_glow(430, 260, 10, (1.0, 0.8, 0.4), 1.0, 3)
    c.line(430, 268, 430, 350, (0.04, 0.03, 0.02), 2)
    figure(c, 470, 336, 1.6, (0.03, 0.02, 0.02))
    vignette(c)

@scene('event_beggar_sage', 23)
def s(c):
    sky(c, (0.35, 0.25, 0.20), (0.60, 0.45, 0.30), (0.22, 0.16, 0.12), 0.7)
    ridge_dark(c, 310, 35, (0.16, 0.12, 0.10), 23)
    tree(c, 150, 330, 1.8, (0.07, 0.05, 0.04))
    figure(c, 320, 340, 1.7, (0.04, 0.03, 0.03))
    c.line(360, 330, 380, 350, (0.05, 0.04, 0.03), 2)
    c.mist_band(320, 22, 0.2, (0.9, 0.85, 0.75))
    vignette(c)

@scene('event_bandit_ambush', 24)
def s(c):
    sky(c, (0.35, 0.10, 0.08), (0.60, 0.22, 0.10), (0.14, 0.05, 0.04), 0.6)
    ridge_dark(c, 200, 70, (0.12, 0.06, 0.05), 24)
    ridge_dark(c, 300, 45, (0.07, 0.04, 0.03), 25)
    spears(c, [80, 130, 180, 230, 420, 470, 520], 350, (0.03, 0.02, 0.02), 0.25)
    figure(c, 300, 340, 1.5, (0.03, 0.02, 0.02))
    c.mist_band(330, 20, 0.15, (0.8, 0.5, 0.4))
    vignette(c)

@scene('event_fallen_cultivator', 26)
def s(c):
    sky(c, (0.18, 0.19, 0.21), (0.30, 0.31, 0.34), (0.10, 0.11, 0.12), 0.7)
    ridge_dark(c, 300, 30, (0.08, 0.09, 0.10), 26)
    for _ in range(70):
        x = c.rng.randrange(W)
        y0 = c.rng.randrange(200)
        c.line(x, y0, x - 3, y0 + 14, (0.55, 0.6, 0.7), 1, 0.5)
    c.line(320, 340, 310, 290, (0.05, 0.05, 0.06), 3)
    c.triangle((306, 290), (314, 290), (310, 276), (0.06, 0.06, 0.07))
    c.rect(250, 336, 400, 344, (0.04, 0.04, 0.05))
    vignette(c, 0.3)

@scene('event_wild_garden', 27)
def s(c):
    sky(c, (0.55, 0.68, 0.55), (0.75, 0.82, 0.65), (0.35, 0.45, 0.32))
    ridge_dark(c, 260, 30, (0.20, 0.30, 0.20), 27)
    ridge_dark(c, 340, 16, (0.10, 0.18, 0.12), 28)
    for _ in range(160):
        x = c.rng.randrange(W)
        y = c.rng.randrange(250, 355)
        c.line(x, y, x, y - c.rng.randint(4, 9), (0.05, 0.14, 0.07), 1)
        c.disc_glow(x, y - 8, 1.5, (0.9, 0.8, 0.3), 0.7, 1.8)
    c.stars(0)
    vignette(c, 0.2)

@scene('event_dragon_bones', 28)
def s(c):
    sky(c, (0.30, 0.20, 0.16), (0.55, 0.38, 0.26), (0.18, 0.12, 0.10), 0.7)
    rib_arcs(c, 320, 345, 5, (0.10, 0.08, 0.07))
    ridge_dark(c, 350, 12, (0.07, 0.05, 0.04), 29)
    c.particles(18, (0, W), (250, 340), (0.8, 0.7, 0.5), 1, 0.3)
    c.mist_band(330, 20, 0.2, (0.9, 0.8, 0.65))
    vignette(c)

@scene('event_lost_child', 29)
def s(c):
    sky(c, (0.04, 0.05, 0.10), (0.10, 0.11, 0.18), (0.02, 0.03, 0.05), 0.7)
    c.stars(70, (0.9, 0.9, 1.0), 0.5)
    ridge_dark(c, 280, 30, (0.05, 0.06, 0.09), 30)
    for hx, s_ in ((90, 1.1), (200, 1.4), (440, 1.6), (560, 1.2), (330, 1.0)):
        c.rect(hx - 22 * s_, 330 - 26 * s_, hx + 22 * s_, 340, (0.03, 0.03, 0.05))
        c.triangle((hx - 26 * s_, 304), (hx + 26 * s_, 304), (hx, 330 - 34 * s_), (0.03, 0.03, 0.05))
        c.disc_glow(hx, 322, 3.5, (1.0, 0.75, 0.35), 0.9, 2.6)
    figure(c, 320, 346, 0.9, (0.02, 0.02, 0.03))
    vignette(c)

@scene('event_secret_auction', 30)
def s(c):
    sky(c, (0.14, 0.06, 0.06), (0.30, 0.14, 0.10), (0.08, 0.04, 0.04), 0.75)
    for i, x in enumerate(range(120, 520, 80)):
        c.line(x, 120 - (i % 2) * 14, x, 190, (0.10, 0.05, 0.04), 2)
        c.disc_glow(x, 118 - (i % 2) * 14, 6, (1.0, 0.72, 0.25), 0.9, 3)
    c.rect(220, 260, 420, 320, (0.09, 0.05, 0.05))
    c.rect(236, 276, 404, 300, (0.14, 0.09, 0.06))
    c.disc_glow(320, 285, 14, (1.0, 0.8, 0.35), 0.6, 3)
    vignette(c)

@scene('event_thunder_cave', 31)
def s(c):
    sky(c, (0.08, 0.09, 0.14), (0.16, 0.17, 0.25), (0.05, 0.05, 0.09), 0.8)
    ridge_dark(c, 290, 70, (0.06, 0.07, 0.10), 31)
    cave_arch(c, 320, 350, 90, (0.02, 0.02, 0.04), (0.4, 0.45, 0.7))
    lightning(c, 70, 30, 120, 220, (1.0, 0.98, 0.9), 2)
    lightning(c, 540, 50, 500, 210, (0.8, 0.85, 1.0), 2)
    c.particles(24, (230, 410), (260, 345), (0.5, 0.6, 1.0), 1, 0.6)
    vignette(c)

@scene('event_old_monk', 32)
def s(c):
    sky(c, (0.55, 0.45, 0.40), (0.80, 0.68, 0.55), (0.40, 0.32, 0.28), 0.65)
    c.disc_glow(180, 140, 26, (1.0, 0.92, 0.78), 0.8, 3)
    ridge_dark(c, 240, 50, (0.28, 0.22, 0.22), 32)
    c.mist_band(270, 26, 0.35, (1.0, 0.94, 0.85))
    pagoda(c, 500, 280, 1.2, (0.14, 0.10, 0.10))
    ridge_dark(c, 340, 16, (0.10, 0.08, 0.08), 33)
    figure(c, 200, 344, 1.4, (0.07, 0.05, 0.05))
    vignette(c, 0.25)

@scene('event_the_beggar', 33)
def s(c):
    sky(c, (0.05, 0.06, 0.12), (0.12, 0.13, 0.22), (0.03, 0.04, 0.07), 0.75)
    c.disc_glow(470, 100, 28, (0.9, 0.92, 1.0), 0.9, 3.2)
    ridge_dark(c, 300, 30, (0.05, 0.06, 0.09), 34)
    gate(c, 200, 350, 0.9, (0.03, 0.03, 0.05))
    c.rect(150, 344, 250, 356, (0.02, 0.02, 0.04))
    figure(c, 380, 344, 1.2, (0.02, 0.02, 0.03))
    c.mist_band(330, 24, 0.2, (0.5, 0.55, 0.75))
    vignette(c)

@scene('event_faceless_messenger', 34)
def s(c):
    sky(c, (0.10, 0.10, 0.14), (0.20, 0.20, 0.26), (0.07, 0.07, 0.10), 0.8)
    c.disc_glow(320, 140, 44, (0.85, 0.88, 0.95), 0.25, 3.5)
    c.mist_band(300, 50, 0.3, (0.55, 0.57, 0.65))
    figure(c, 320, 348, 2.6, (0.02, 0.02, 0.03), 'hood')
    c.line(320, 348, 320, 240, (0.02, 0.02, 0.03), 6)
    c.mist_band(340, 16, 0.25)
    vignette(c)

@scene('loc_bamboo_forest', 40)
def s(c):
    sky(c, (0.25, 0.35, 0.28), (0.45, 0.58, 0.38), (0.12, 0.22, 0.14))
    for band_x in range(0, W, 6):
        c.line(band_x, 0, band_x + 3, 40, (0.85, 1.0, 0.8), 1, 0.12)
    bamboos(c, -10, 200, 360, 12, (0.03, 0.11, 0.06))
    bamboos(c, 190, 400, 360, 10, (0.04, 0.13, 0.07))
    bamboos(c, 390, 650, 360, 12, (0.02, 0.09, 0.05))
    c.mist_band(300, 40, 0.2, (0.9, 1.0, 0.9))
    vignette(c, 0.3)

@scene('loc_misty_mountains', 41)
def s(c):
    sky(c, (0.40, 0.54, 0.62), (0.66, 0.74, 0.76), (0.55, 0.62, 0.66))
    ridge_dark(c, 170, 70, (0.25, 0.34, 0.40), 41)
    c.mist_band(220, 40, 0.5, (0.92, 0.95, 0.97))
    ridge_dark(c, 260, 55, (0.16, 0.24, 0.29), 42)
    c.mist_band(300, 34, 0.42, (0.90, 0.93, 0.96))
    ridge_dark(c, 340, 34, (0.08, 0.14, 0.18), 43)
    vignette(c, 0.2)

@scene('loc_lotus_lake', 42)
def s(c):
    sky(c, (0.15, 0.16, 0.28), (0.30, 0.26, 0.38), (0.10, 0.10, 0.18), 0.6)
    c.disc_glow(180, 130, 30, (0.95, 0.93, 1.0), 0.9, 3)
    ridge_dark(c, 250, 25, (0.08, 0.08, 0.14), 44)
    pool(c, 320, 300, 320, 80, (0.10, 0.14, 0.24))
    c.mist_band(280, 16, 0.15, (0.8, 0.8, 0.95))
    for _ in range(26):
        x = c.rng.uniform(40, 600)
        y = c.rng.uniform(250, 345)
        c.disc_glow(x, y, 3, (0.95, 0.7, 0.8), 0.85, 2.2)
        c.blend(int(x), int(y), (0.9, 0.45, 0.6), 1.0)
    vignette(c)

@scene('loc_ember_valley', 43)
def s(c):
    sky(c, (0.12, 0.04, 0.04), (0.30, 0.10, 0.06), (0.05, 0.02, 0.02), 0.7)
    ridge_dark(c, 200, 60, (0.10, 0.05, 0.05), 45)
    ridge_dark(c, 300, 40, (0.06, 0.03, 0.03), 46)
    c.disc_glow(320, 320, 60, (1.0, 0.4, 0.1), 0.5, 3)
    c.rect(180, 330, 460, 344, (0.35, 0.08, 0.02))
    c.rect(230, 336, 410, 344, (1.0, 0.55, 0.1))
    c.particles(60, (200, 440), (120, 330), (1.0, 0.5, 0.12), 2, 0.9)
    vignette(c)

@scene('loc_serpent_peak', 44)
def s(c):
    sky(c, (0.16, 0.18, 0.22), (0.30, 0.32, 0.38), (0.10, 0.11, 0.15), 0.75)
    c.triangle((160, 360), (330, 360), (250, 40), (0.05, 0.06, 0.09))
    c.triangle((330, 360), (480, 360), (430, 130), (0.07, 0.08, 0.12))
    c.mist_band(220, 30, 0.3, (0.6, 0.65, 0.75))
    ridge_dark(c, 340, 25, (0.04, 0.04, 0.07), 47)
    lightning(c, 500, 40, 460, 200, (0.9, 0.92, 1.0), 1)
    vignette(c)

@scene('loc_beast_wasteland', 45)
def s(c):
    sky(c, (0.35, 0.33, 0.30), (0.60, 0.55, 0.46), (0.24, 0.22, 0.19), 0.65)
    c.disc_glow(530, 150, 22, (0.95, 0.9, 0.75), 0.7, 3)
    rock_spikes(c, 340, 16, (0.08, 0.07, 0.06))
    ridge_dark(c, 320, 20, (0.16, 0.14, 0.12), 48)
    c.mist_band(330, 18, 0.2, (0.85, 0.8, 0.7))
    vignette(c, 0.25)

@scene('loc_sword_tomb', 46)
def s(c):
    sky(c, (0.13, 0.14, 0.19), (0.26, 0.27, 0.33), (0.08, 0.08, 0.12), 0.7)
    ridge_dark(c, 290, 30, (0.09, 0.09, 0.13), 49)
    planted_swords(c, 348, 26, (0.10, 0.11, 0.15))
    c.rect(0, 344, W, 360, (0.04, 0.04, 0.06))
    c.mist_band(320, 22, 0.18, (0.6, 0.65, 0.8))
    vignette(c)

@scene('loc_hells_gorge', 47)
def s(c):
    sky(c, (0.15, 0.05, 0.04), (0.35, 0.12, 0.08), (0.08, 0.03, 0.03), 0.6)
    c.rect(0, 200, 180, 360, (0.10, 0.04, 0.04))
    c.rect(460, 180, 640, 360, (0.10, 0.04, 0.04))
    ridge_dark(c, 200, 40, (0.12, 0.05, 0.05), 50)
    c.rect(190, 330, 450, 344, (0.5, 0.1, 0.03))
    c.rect(240, 336, 400, 344, (1.0, 0.45, 0.08))
    c.particles(35, (200, 440), (250, 335), (1.0, 0.5, 0.1), 2, 0.7)
    c.mist_band(310, 22, 0.2, (0.7, 0.3, 0.2))
    vignette(c)

@scene('loc_heavenly_gate', 48)
def s(c):
    sky(c, (0.35, 0.32, 0.28), (0.75, 0.70, 0.60), (0.95, 0.90, 0.80))
    c.disc_glow(320, 170, 60, (1.0, 0.97, 0.85), 0.6, 3.5)
    ridge_dark(c, 260, 55, (0.30, 0.26, 0.24), 51)
    c.mist_band(290, 30, 0.4, (1.0, 0.98, 0.92))
    ridge_dark(c, 350, 20, (0.16, 0.14, 0.13), 52)
    gate(c, 320, 350, 1.5, (0.12, 0.10, 0.10), (1.0, 0.95, 0.8))
    vignette(c, 0.2)

@scene('loc_verdant_palace', 49)
def s(c):
    sky(c, (0.20, 0.34, 0.24), (0.42, 0.58, 0.36), (0.10, 0.20, 0.13), 0.65)
    pagoda(c, 320, 300, 2.6, (0.05, 0.14, 0.09))
    banners(c, [170, 230, 410, 470], 220, (0.07, 0.16, 0.10))
    c.mist_band(300, 24, 0.25, (0.85, 1.0, 0.9))
    ridge_dark(c, 350, 14, (0.03, 0.09, 0.05), 53)
    c.disc_glow(320, 240, 40, (0.5, 1.0, 0.7), 0.25, 3)
    vignette(c, 0.25)

@scene('loc_ash_sanctum', 50)
def s(c):
    sky(c, (0.10, 0.04, 0.05), (0.25, 0.09, 0.10), (0.06, 0.02, 0.03), 0.7)
    c.disc_glow(320, 180, 46, (1.0, 0.3, 0.2), 0.3, 3.5)
    for i in range(3):
        w = 150 - i * 34
        c.rect(320 - w, 300 - i * 44, 320 + w, 300 - (i - 1) * 44 if i else 300, (0.07, 0.04, 0.05))
    c.rect(320 - 40, 168, 320 + 40, 212, (0.09, 0.05, 0.06))
    c.rect(150, 300, 490, 312, (0.09, 0.05, 0.06))
    c.rect(120, 312, 520, 326, (0.11, 0.06, 0.07))
    c.particles(25, (150, 490), (200, 320), (1.0, 0.4, 0.2), 1, 0.5)
    vignette(c)

@scene('loc_moonveil_glade', 51)
def s(c):
    sky(c, (0.12, 0.10, 0.24), (0.30, 0.24, 0.42), (0.16, 0.12, 0.28), 0.55)
    c.disc_glow(160, 120, 26, (0.92, 0.95, 1.0), 1.0, 3)
    c.disc_glow(430, 170, 18, (0.85, 0.88, 1.0), 0.8, 2.5)
    tree(c, 100, 330, 1.6, (0.06, 0.05, 0.12))
    tree(c, 540, 340, 1.9, (0.06, 0.05, 0.12))
    c.mist_band(320, 30, 0.25, (0.75, 0.75, 0.95))
    pool(c, 320, 340, 140, 20, (0.20, 0.18, 0.35), (0.7, 0.7, 1.0))
    vignette(c)

@scene('loc_fallen_zhao', 52)
def s(c):
    sky(c, (0.35, 0.28, 0.20), (0.60, 0.50, 0.35), (0.22, 0.18, 0.13), 0.7)
    ruins_wall(c, 340, (0.10, 0.09, 0.08))
    ridge_dark(c, 280, 25, (0.20, 0.17, 0.13), 54)
    planted_swords(c, 350, 5, (0.08, 0.07, 0.06))
    c.mist_band(320, 20, 0.2, (0.9, 0.85, 0.7))
    vignette(c, 0.25)

@scene('loc_bone_pits', 53)
def s(c):
    sky(c, (0.40, 0.40, 0.38), (0.66, 0.64, 0.58), (0.30, 0.29, 0.26), 0.7)
    rock_spikes(c, 345, 20, (0.62, 0.60, 0.55), False)
    rock_spikes(c, 350, 8, (0.35, 0.33, 0.3))
    ridge_dark(c, 330, 14, (0.22, 0.21, 0.19), 55)
    c.mist_band(325, 16, 0.2, (0.9, 0.88, 0.8))
    vignette(c, 0.2)

@scene('loc_sword_vault', 54)
def s(c):
    sky(c, (0.05, 0.07, 0.12), (0.10, 0.15, 0.24), (0.03, 0.05, 0.09), 0.9)
    c.rect(0, 250, W, 360, (0.03, 0.04, 0.07))
    for x in range(80, W - 40, 90):
        c.rect(x, 180, x + 10, 340, (0.05, 0.06, 0.10))
        for _ in range(3):
            sx = x + 12 + c.rng.uniform(0, 60)
            c.line(sx, 330, sx + c.rng.uniform(-6, 6), 230 - c.rng.uniform(0, 40), (0.55, 0.65, 0.95), 2)
            c.disc_glow(sx, 235, 2, (0.6, 0.7, 1.0), 0.9, 2.4)
    c.disc_glow(320, 120, 50, (0.5, 0.65, 1.0), 0.2, 3.5)
    c.stars(25, (0.7, 0.8, 1.0), 0.4)
    vignette(c)

@scene('loc_fallen_yan', 55)
def s(c):
    sky(c, (0.28, 0.34, 0.26), (0.52, 0.58, 0.42), (0.16, 0.22, 0.15), 0.7)
    ruins_wall(c, 330, (0.10, 0.11, 0.09))
    tree(c, 120, 340, 1.5, (0.06, 0.10, 0.06))
    tree(c, 520, 345, 1.8, (0.06, 0.10, 0.06))
    for _ in range(40):
        x = c.rng.randrange(W)
        y = c.rng.randrange(220, 350)
        c.line(x, y, x + c.rng.uniform(-6, 6), y - c.rng.randint(6, 16), (0.05, 0.13, 0.06), 1, 0.8)
    c.mist_band(300, 24, 0.2)
    vignette(c, 0.25)

@scene('loc_void_rift', 56)
def s(c):
    sky(c, (0.03, 0.02, 0.07), (0.09, 0.05, 0.16), (0.02, 0.01, 0.05), 0.9)
    for _ in range(90):
        c.stars(1, (0.7, 0.6, 1.0), 1.0)
    ridge_dark(c, 330, 18, (0.04, 0.03, 0.08), 56)
    for i in range(4):
        x = 240 + i * 40
        lightning(c, 320 + 40 * (i - 2) * 0.2, 0, x + c.rng.uniform(-15, 15), 250 + i * 18, (0.7, 0.4, 1.0), 1)
    c.disc_glow(320, 120, 40, (0.55, 0.35, 0.9), 0.3, 3.5)
    c.particles(30, (200, 440), (100, 300), (0.65, 0.45, 1.0), 1, 0.7)
    vignette(c)

@scene('story_human', 60)
def s(c):
    sky(c, (0.45, 0.35, 0.22), (0.80, 0.60, 0.35), (0.35, 0.28, 0.20), 0.6)
    c.disc_glow(150, 150, 28, (1.0, 0.9, 0.7), 0.7, 3)
    pagoda(c, 250, 300, 2.0, (0.16, 0.10, 0.06))
    pagoda(c, 420, 302, 1.5, (0.13, 0.09, 0.06))
    banners(c, [120, 180, 500, 560], 230, (0.12, 0.08, 0.05))
    c.mist_band(290, 24, 0.3, (1.0, 0.9, 0.75))
    ridge_dark(c, 350, 14, (0.08, 0.06, 0.04), 60)
    vignette(c, 0.2)

@scene('story_demon', 61)
def s(c):
    sky(c, (0.10, 0.03, 0.05), (0.28, 0.07, 0.10), (0.06, 0.01, 0.03), 0.7)
    c.disc_glow(320, 120, 40, (1.0, 0.25, 0.25), 0.8, 3.2)
    for i in range(2):
        w = 120 - i * 30
        c.rect(320 - w, 330 - i * 50, 320 + w, 330 - max(0, (i - 1) * 50), (0.08, 0.03, 0.04))
    spears(c, [100, 150, 200, 440, 490, 540], 350, (0.05, 0.02, 0.03))
    c.particles(25, (200, 440), (180, 330), (1.0, 0.3, 0.2), 1, 0.6)
    ridge_dark(c, 352, 10, (0.04, 0.02, 0.03), 61)
    vignette(c)

@scene('story_demi', 62)
def s(c):
    sky(c, (0.10, 0.12, 0.18), (0.22, 0.28, 0.30), (0.07, 0.10, 0.09), 0.6)
    c.disc_glow(480, 110, 24, (0.9, 0.95, 1.0), 0.7, 3)
    bamboos(c, 20, 250, 360, 9, (0.04, 0.10, 0.08))
    bamboos(c, 430, 650, 360, 9, (0.03, 0.09, 0.07))
    c.mist_band(310, 30, 0.25, (0.8, 0.9, 0.9))
    figure(c, 320, 348, 1.4, (0.03, 0.05, 0.05))
    vignette(c, 0.25)


def main():
    if not os.path.isdir(OUT):
        os.makedirs(OUT)
    for name, (fn, seed) in sorted(SCENES.items()):
        canvas = Canvas(seed)
        fn(canvas)
        finish(canvas, name + '.png')
        print('painted', name)
    print(len(SCENES), 'images ->', os.path.abspath(OUT))


if __name__ == '__main__':
    main()
