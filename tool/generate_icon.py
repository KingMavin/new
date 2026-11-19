"""Generates the Immortal Path app icon into assets/icon/.

Pure standard library (zlib + struct). Rerun with:  python3 tool/generate_icon.py
Outputs:
  app_icon.png            1024x1024 full-bleed launcher/source icon
  app_icon_foreground.png 1024x1024 adaptive-icon foreground (transparent edges)
  store_icon.png          512x512 store-listing icon
All are procedurally painted - original, license-free, swappable.
"""
import math
import os
import random
import struct
import zlib

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'icon')


class Canvas(object):
    def __init__(self, size, seed=7, alpha=False):
        self.S = size
        self.alpha = alpha
        self.px = [[(0.0, 0.0, 0.0, 0.0 if alpha else 1.0)] * size
                   for _ in range(size)]
        self.rng = random.Random(seed)

    def clamp(self, v):
        return max(0.0, min(1.0, v))

    def blend(self, x, y, color, alpha):
        if 0 <= x < self.S and 0 <= y < self.S:
            r, g, b, a = self.px[y][x]
            dr = color[0]
            dg = color[1]
            db = color[2]
            da = color[3] if len(color) > 3 else 1.0
            na = a + (da - a) * alpha
            if na <= 1e-6:
                self.px[y][x] = (0.0, 0.0, 0.0, 0.0)
                return
            fr = alpha * da / max(1e-6, na)
            self.px[y][x] = (
                self.clamp(r + (dr - r) * fr),
                self.clamp(g + (dg - g) * fr),
                self.clamp(b + (db - b) * fr),
                self.clamp(na),
            )

    def gradient(self, stops):
        S = self.S
        for y in range(S):
            t = y / (S - 1)
            c = stops[-1][1]
            for i in range(len(stops) - 1):
                p0, c0 = stops[i]
                p1, c1 = stops[i + 1]
                if p0 <= t <= p1:
                    f = (t - p0) / max(1e-6, (p1 - p0))
                    c = tuple(c0[k] + (c1[k] - c0[k]) * f for k in range(3))
                    break
            row = self.px[y]
            for x in range(S):
                r, g, b, a = row[x]
                row[x] = (c[0], c[1], c[2], a)

    def disc_glow(self, cx, cy, r, color, core_alpha=1.0, spread=3.0):
        S = self.S
        for y in range(max(0, int(cy - r * spread)), min(S, int(cy + r * spread))):
            for x in range(max(0, int(cx - r * spread)), min(S, int(cx + r * spread))):
                d = math.hypot(x - cx, y - cy) / max(1e-6, r)
                if d > spread:
                    continue
                if d <= 1.0:
                    a = core_alpha
                else:
                    a = core_alpha * max(0.0, 1.0 - (d - 1.0) / (spread - 1.0)) ** 2
                if a > 0:
                    self.blend(x, y, color, a)

    def stars(self, n, ymax=0.5, color=(1, 1, 1), size_max=2):
        S = self.S
        for _ in range(n):
            x = int(self.rng.random() * S)
            y = int(self.rng.random() * ymax * S)
            s = 0.5 + self.rng.random() * size_max
            b = 0.35 + self.rng.random() * 0.65
            self.disc_glow(x, y, s, color, core_alpha=b, spread=2.0)

    def ridge(self, base_y, amplitude, color, roughness=0.55, points=48,
              seed_extra=0):
        S = self.S
        rng = random.Random(11 + seed_extra)
        n = points
        ys = []
        for i in range(n + 1):
            x = i / n
            h = 0.0
            for (freq, mag) in ((1.0, 1.0), (2.0, 0.5), (4.0, 0.25),
                                (8.0, roughness)):
                h += mag * abs(math.sin((freq * x + rng.random() * 0.08)
                                        * math.pi * 0.5 + freq * 0.7))
            ys.append(h)
        peak = max(ys)
        ys = [v / peak for v in ys]
        coords = []
        for i in range(n + 1):
            x = i / n * S
            y = base_y * S - ys[i] * amplitude * S
            coords.append((x, y))
        poly = [(0, S), (0, coords[0][1])] + coords + [(S, S)]
        self.fill_polygon(poly, color)

    def fill_polygon(self, coords, color):
        S = self.S
        y0 = max(0, int(min(p[1] for p in coords)))
        y1 = min(S - 1, int(max(p[1] for p in coords)))
        for y in range(y0, y1 + 1):
            xs = []
            for i in range(len(coords)):
                xa, ya = coords[i]
                xb, yb = coords[(i + 1) % len(coords)]
                if (ya <= y < yb) or (yb <= y < ya):
                    xs.append(xa + (y - ya) / (yb - ya) * (xb - xa))
            xs.sort()
            for j in range(0, len(xs) - 1, 2):
                for x in range(max(0, int(xs[j] - 0.5)),
                               min(S, int(xs[j + 1] + 1.5))):
                    self.blend(x, y, color, 1.0)

    def rect(self, x0, y0, x1, y1, color, alpha=1.0):
        S = self.S
        for y in range(max(0, int(y0)), min(S, int(y1))):
            for x in range(max(0, int(x0)), min(S, int(x1))):
                self.blend(x, y, color, alpha)

    def triangle(self, p0, p1, p2, color, alpha=1.0):
        self.fill_polygon([p0, p1, p2], color)



def pagoda(c, cx, base_y, unit, color):
    """Tiered pagoda: wide flat eaves, narrow bodies, a finial on top.
    unit = one eave-halfwidth at the ground tier, in pixels."""
    tiers = 4
    y = base_y
    for t in range(tiers):
        w = unit * (1.0 - t * 0.16)
        body_h = unit * 0.10
        roof_h = unit * 0.22
        c.rect(cx - w * 0.62, y - body_h, cx + w * 0.62, y, color)
        y -= body_h
        c.fill_polygon(
            [(cx - w * 1.25, y), (cx + w * 1.25, y), (cx, y - roof_h)], color)
        c.rect(cx - w * 0.30, y - roof_h * 0.4, cx + w * 0.30, y,
               color)
        y -= roof_h
    c.rect(cx - unit * 0.05, y - unit * 0.28, cx + unit * 0.05, y, color)
    c.disc_glow(cx, y - unit * 0.30, unit * 0.06, color, core_alpha=1.0,
                spread=2.0)


def softclip(c, ceil):
    hi = 0.0
    for row in c.px:
        for p in row:
            hi = max(hi, max(p[0], p[1], p[2]))
    if hi <= ceil:
        return
    f = ceil / hi
    for y in range(c.S):
        row = c.px[y]
        for x in range(c.S):
            r, g, b, a = row[x]
            row[x] = (min(1.0, r * f), min(1.0, g * f), min(1.0, b * f), a)


def write_png(c, path):
    S = c.S
    ctype = 6 if c.alpha else 2
    data = bytearray()
    for y in range(S):
        data.append(0)
        row = c.px[y]
        for x in range(S):
            r, g, b, a = row[x]
            data.append(int(r * 255 + 0.5))
            data.append(int(g * 255 + 0.5))
            data.append(int(b * 255 + 0.5))
            if c.alpha:
                data.append(int(a * 255 + 0.5))
    compressed = zlib.compress(bytes(data), 6)

    def chunk(tag, payload):
        return (struct.pack('>I', len(payload)) + tag + payload +
                struct.pack('>I', zlib.crc32(tag + payload) & 0xffffffff))

    ihdr = struct.pack('>IIBBBBB', S, S, 8, ctype, 0, 0, 0)
    png = (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) +
           chunk(b'IDAT', compressed) + chunk(b'IEND', b''))
    with open(os.path.join(OUT, path), 'wb') as f:
        f.write(png)
    print('%s: %d bytes' % (path, len(png)))


def paint(c, motif_scale=1.0):
    """Dawn over the immortal peaks: moon, ridges, pagoda, mist."""
    S = c.S
    c.gradient([
        (0.00, (0.030, 0.036, 0.070)),
        (0.42, (0.110, 0.085, 0.200)),
        (0.68, (0.420, 0.180, 0.230)),
        (0.80, (0.640, 0.310, 0.180)),
        (1.00, (0.080, 0.050, 0.100)),
    ])
    c.stars(int(S * 0.07), ymax=0.40)
    m = motif_scale
    cx_moon, cy_moon = S * 0.70 * m + S * (1 - m) * 0.5, S * 0.26
    c.disc_glow(cx_moon, cy_moon, S * 0.115, (1.0, 0.94, 0.80),
                core_alpha=1.0, spread=3.2)
    c.ridge(0.70, 0.20, (0.16, 0.10, 0.28), seed_extra=3)
    c.ridge(0.78, 0.17, (0.10, 0.06, 0.20), seed_extra=5)
    c.ridge(0.88, 0.14, (0.05, 0.03, 0.11), seed_extra=8)
    pcx = S * 0.5 + (S * 0.33 - S * 0.5) * m
    pcol = (0.035, 0.02, 0.08)
    pagoda(c, pcx, S * 0.715, S * 0.062 * m, pcol)
    c.rect(pcx - S * 0.06 * m, S * 0.715, pcx + S * 0.06 * m, S * 0.745, pcol)
    # faint qi ribbon from the pagoda toward the moon
    steps = 40
    for i in range(steps):
        t = i / (steps - 1)
        x = pcx + (cx_moon - pcx) * t
        y = S * 0.62 - S * 0.34 * t + S * 0.03 * math.sin(t * math.pi * 2.4)
        r = S * 0.006 * (1.0 - 0.5 * t)
        c.disc_glow(x, y, r, (0.85, 0.80, 1.0), core_alpha=0.25, spread=2.0)
    softclip(c, 0.95)


def main():
    if not os.path.isdir(OUT):
        os.makedirs(OUT)
    full = Canvas(1024, seed=7)
    paint(full, motif_scale=1.0)
    write_png(full, 'app_icon.png')

    store = Canvas(512, seed=7)
    paint(store, motif_scale=1.0)
    write_png(store, 'store_icon.png')

def paint_foreground(c):
    """Adaptive-icon foreground: motif only, inset in the safe zone."""
    S = c.S
    m = 0.56
    c.stars(int(S * 0.03), ymax=0.42, color=(1, 1, 1), size_max=1)
    c.disc_glow(S * 0.5 + (S * 0.68 - S * 0.5) * m, S * 0.30, S * 0.105,
                (1.0, 0.94, 0.80), core_alpha=0.95, spread=3.0)
    pcx = S * 0.5 + (S * 0.38 - S * 0.5) * m
    pcol = (0.86, 0.82, 0.98)
    pagoda(c, pcx, S * 0.82, S * 0.055 * m, pcol)
    c.rect(pcx - S * 0.055 * m, S * 0.82, pcx + S * 0.055 * m, S * 0.835, pcol)
    steps = 32
    for i in range(steps):
        t = i / (steps - 1)
        x = pcx + (S * 0.5 + (S * 0.68 - S * 0.5) * m - pcx) * t
        y = S * 0.60 - S * 0.32 * t + S * 0.02 * math.sin(t * math.pi * 2.4)
        r = S * 0.006
        c.disc_glow(x, y, r, (0.85, 0.80, 1.0), core_alpha=0.30, spread=2.0)


def main():
    if not os.path.isdir(OUT):
        os.makedirs(OUT)
    full = Canvas(1024, seed=7)
    paint(full, motif_scale=1.0)
    write_png(full, 'app_icon.png')

    store = Canvas(512, seed=7)
    paint(store, motif_scale=1.0)
    write_png(store, 'store_icon.png')

    fg = Canvas(1024, seed=7, alpha=True)
    paint_foreground(fg)
    write_png(fg, 'app_icon_foreground.png')


if __name__ == '__main__':
    main()
