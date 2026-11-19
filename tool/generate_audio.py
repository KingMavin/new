"""Procedural xianxia audio synthesizer - pure stdlib, writes WAV assets.

Produces four seamless music loops and seven one-shot sound effects into
assets/audio/. Deterministic (seeded). Run: python3 tool/generate_audio.py
"""
import math
import os
import random
import struct
import wave

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')

PENTA = [220.0, 261.63, 293.66, 329.63, 392.0, 440.0, 523.25, 587.33, 659.26, 784.0]


def write_wav(name, samples):
    path = os.path.join(OUT, name)
    ints = [max(-32767, min(32767, int(s * 32767))) for s in samples]
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(struct.pack('<%dh' % len(ints), *ints))
    print(name, len(samples) / SR, 's', os.path.getsize(path), 'bytes')


def silence(dur):
    return [0.0] * int(dur * SR)


def mix_at(base, start, samples, wrap_len=None):
    L = len(base)
    s0 = int(start * SR)
    for j, v in enumerate(samples):
        idx = s0 + j
        if wrap_len is not None:
            idx %= wrap_len
        if 0 <= idx < L:
            base[idx] += v


def bell(freq, dur, vol):
    n = int(dur * SR)
    out = []
    partials = [(1.0, 1.0), (2.76, 0.42), (5.4, 0.2), (8.93, 0.07)]
    for i in range(n):
        t = i / SR
        env = math.exp(-t * 3.2 / dur)
        s = sum(a * math.sin(2 * math.pi * freq * m * t) for m, a in partials)
        out.append(s * env * vol)
    return out


def pluck(freq, dur, vol):
    n = int(dur * SR)
    out = []
    for i in range(n):
        t = i / SR
        env = math.exp(-t * 5.5 / dur)
        s = sum(
            (1.0 / k) * math.sin(2 * math.pi * freq * k * t)
            for k in range(1, 7)
        )
        out.append(s * env * vol)
    return out


def drum(dur, base, vol, noise_frac=0.35):
    n = int(dur * SR)
    out = []
    rng = random.Random(int(base * 1000) + n)
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = base * math.exp(-t * 9.0) + 42.0
        phase += 2 * math.pi * f / SR
        body = math.sin(phase) * math.exp(-t * 7.0)
        crack = (rng.random() * 2 - 1) * math.exp(-t * 42.0) * noise_frac
        out.append((body + crack) * vol)
    return out


def gong(freq, dur, vol):
    n = int(dur * SR)
    out = []
    partials = [(1.0, 1.0), (1.48, 0.62), (2.09, 0.5), (2.83, 0.34), (3.8, 0.28), (5.42, 0.18)]
    for i in range(n):
        t = i / SR
        env = math.exp(-t * 1.1 / (dur / 3.0)) * (0.55 + 0.45 * math.exp(-t * 7.0))
        s = sum(a * math.sin(2 * math.pi * freq * m * t) for m, a in partials)
        out.append(s * env * vol)
    return out


def horn(freq, dur, vol):
    n = int(dur * SR)
    out = []
    for i in range(n):
        t = i / SR
        attack = min(1.0, t / 0.18)
        release = math.exp(-max(0.0, t - dur * 0.7) * 6.0)
        s = (
            1.0 * math.sin(2 * math.pi * freq * t)
            + 0.45 * math.sin(2 * math.pi * freq * 2 * t)
            + 0.3 * math.sin(2 * math.pi * freq * 3 * t)
        )
        out.append(s * attack * release * vol)
    return out


def lowpassed_noise(dur, alpha, vol, lfo_cycles=0, loop_len=None):
    n = int(dur * SR)
    rng = random.Random(99 + n)
    out = []
    y = 0.0
    for i in range(n):
        t = i / SR
        amp = vol
        if lfo_cycles:
            amp *= 0.65 + 0.35 * math.sin(2 * math.pi * lfo_cycles * t / dur)
        x = rng.random() * 2 - 1
        y += alpha * (x - y)
        out.append(y * amp)
    return out


def fit(base, span, vol):
    peak = max(abs(s) for s in base) or 1.0
    k = vol / peak
    for i in range(len(base)):
        j = i + span
        if 0 <= j < len(base) and base[j] * k > 32767:
            pass
    return []


def softclip(samples, ceiling=0.92):
    peak = max((abs(s) for s in samples), default=1.0) or 1.0
    if peak <= ceiling:
        return samples
    k = ceiling / peak
    return [s * k for s in samples]


# ---------------- music loops ----------------

def music_cultivation():
    L = 24.0
    n = int(L * SR)
    loop = [0.0] * n
    wrap = n
    for freq, amp in ((55.0, 0.05), (110.0, 0.045), (220.0, 0.02)):
        drone = []
        k = freq * L
        assert abs(k - round(k)) < 1e-6
        for i in range(n):
            t = i / SR
            swell = 0.75 + 0.25 * math.sin(2 * math.pi * (freq / 2) * t / 12.0)
            drone.append(math.sin(2 * math.pi * freq * t) * amp * swell)
        mix_at(loop, 0, drone)
    mist = lowpassed_noise(L, 0.05, 0.015, lfo_cycles=1, loop_len=wrap)
    mix_at(loop, 0, mist, wrap_len=wrap)
    rng = random.Random(11)
    step = 1.15
    t = 0.2
    last = 2
    while t < L - 3.0:
        idx = max(0, min(9, last + rng.choice((-2, -1, -1, 1, 1, 2))))
        note = PENTA[idx]
        vol = rng.uniform(0.1, 0.17)
        mix_at(loop, t, bell(note, 2.6, vol), wrap_len=wrap)
        if rng.random() < 0.3:
            mix_at(loop, t + 0.28, bell(note * 2, 1.8, vol * 0.4), wrap_len=wrap)
        last = idx
        t += step + rng.uniform(-0.35, 0.55)
    return softclip(loop)


def music_exploration():
    L = 16.0
    n = int(L * SR)
    loop = [0.0] * n
    wrap = n
    for freq, amp in ((110.0, 0.035), (165.0, 0.02)):
        drone = [math.sin(2 * math.pi * freq * i / SR) * amp for i in range(n)]
        mix_at(loop, 0, drone)
    wind = lowpassed_noise(L, 0.08, 0.02, lfo_cycles=2, loop_len=wrap)
    mix_at(loop, 0, wind, wrap_len=wrap)
    eighth = 0.25
    rng = random.Random(23)
    phrase = [0, 2, 3, 2, 4, 3, 5, 4, 6, 5, 4, 3, 2, 3, 1, 0]
    for bar in range(8):
        for step in range(16):
            t = (bar * 16 + step) * eighth
            if rng.random() < 0.22:
                continue
            note = PENTA[phrase[(bar * 3 + step) % len(phrase)]]
            vol = 0.11 if step % 4 == 0 else 0.075
            mix_at(loop, t, pluck(note, 0.55, vol), wrap_len=wrap)
    for beat in range(8):
        mix_at(loop, beat * 2.0, drum(0.32, 320, 0.09, noise_frac=0.15), wrap_len=wrap)
    return softclip(loop)


def music_tournament():
    L = 12.0
    n = int(L * SR)
    loop = [0.0] * n
    wrap = n
    beat = 0.75
    for b in range(16):
        t = b * beat
        if b % 4 == 0:
            mix_at(loop, t, drum(0.4, 150, 0.3), wrap_len=wrap)
        elif b % 2 == 0:
            mix_at(loop, t, drum(0.3, 180, 0.22), wrap_len=wrap)
        if b % 2 == 1:
            mix_at(loop, t, drum(0.12, 500, 0.1, noise_frac=0.6), wrap_len=wrap)
        if b in (6, 14):
            mix_at(loop, t + beat * 0.5, drum(0.14, 640, 0.13, noise_frac=0.7), wrap_len=wrap)
    mix_at(loop, 0, gong(140, 3.2, 0.24), wrap_len=wrap)
    mix_at(loop, L - 5.0, gong(187, 3.4, 0.16), wrap_len=wrap)
    for t, freq in ((2.25, 220.0), (4.5, 261.63), (9.0, 329.63), (11.25, 293.66)):
        mix_at(loop, t, bell(freq, 1.4, 0.07), wrap_len=wrap)
    return softclip(loop)


def music_war():
    L = 12.0
    n = int(L * SR)
    loop = [0.0] * n
    wrap = n
    mix_at(loop, 0, [math.sin(2 * math.pi * 55.0 * i / SR) * 0.05 for i in range(n)])
    beat = 1.0
    for b in range(12):
        base = 78 if b % 4 == 0 else 64
        vol = 0.32 if b % 4 == 0 else 0.2
        mix_at(loop, b * beat, drum(0.5, base, vol, noise_frac=0.2), wrap_len=wrap)
        if b % 4 == 2:
            mix_at(loop, b * beat + 0.5, drum(0.3, 110, 0.16), wrap_len=wrap)
    for start, f1, f2 in ((1.0, 110.0, 164.8), (7.0, 123.47, 146.83)):
        horn_dur = 4.5
        for freq, hv in ((f1, 0.13), (f2, 0.09)):
            mix_at(loop, start, horn(freq, horn_dur, hv), wrap_len=wrap)
    return softclip(loop)


# ---------------- sound effects ----------------

def sfx_breakthrough():
    out = silence(1.9)
    for i, f in enumerate((261.63, 329.63, 392.0, 523.25)):
        mix_at(out, i * 0.16, bell(f, 1.4, 0.22 - i * 0.02))
    mix_at(out, 0.05, lowpassed_noise(0.5, 0.3, 0.05))
    return softclip(out)


def sfx_tribulation():
    out = silence(1.9)
    rng = random.Random(77)
    crack = [(rng.random() * 2 - 1) * math.exp(-i / SR * 18.0) * 0.85 for i in range(int(0.7 * SR))]
    for i in range(len(crack)):
        j = int(0.08 * SR) + i
        if j < len(out):
            out[j] += crack[i]
    rum = lowpassed_noise(1.75, 0.045, 0.22)
    for i, v in enumerate(rum):
        out[int(0.15 * SR) + i] += v * math.exp(-i / len(rum) * 2.2)
    mix_at(out, 0.2, bell(98.0, 1.4, 0.12))
    return softclip(out)


def sfx_battle():
    out = silence(0.9)
    mix_at(out, 0.0, drum(0.28, 180, 0.5, noise_frac=0.45))
    mix_at(out, 0.16, drum(0.4, 120, 0.55, noise_frac=0.3))
    mix_at(out, 0.16, pluck(392.0, 0.5, 0.16))
    return softclip(out)


def sfx_forge():
    out = silence(1.0)
    mix_at(out, 0.0, gong(310, 0.8, 0.3))
    mix_at(out, 0.02, drum(0.16, 210, 0.4, noise_frac=0.5))
    return softclip(out)


def sfx_event():
    out = silence(1.3)
    mix_at(out, 0.0, bell(523.25, 0.9, 0.2))
    mix_at(out, 0.22, bell(784.0, 1.0, 0.15))
    return softclip(out)


def sfx_acquire():
    out = silence(1.3)
    for i, f in enumerate((392.0, 523.25, 659.26, 784.0)):
        mix_at(out, i * 0.11, bell(f, 0.8, 0.18))
    return softclip(out)


def sfx_ledger():
    out = silence(1.0)
    mix_at(out, 0.0, drum(0.2, 150, 0.4, noise_frac=0.3))
    mix_at(out, 0.12, bell(659.26, 0.7, 0.16))
    return softclip(out)


def main():
    os.makedirs(OUT, exist_ok=True)
    write_wav('music_cultivation.wav', music_cultivation())
    write_wav('music_exploration.wav', music_exploration())
    write_wav('music_tournament.wav', music_tournament())
    write_wav('music_war.wav', music_war())
    write_wav('sfx_breakthrough.wav', sfx_breakthrough())
    write_wav('sfx_tribulation.wav', sfx_tribulation())
    write_wav('sfx_battle.wav', sfx_battle())
    write_wav('sfx_forge.wav', sfx_forge())
    write_wav('sfx_event.wav', sfx_event())
    write_wav('sfx_acquire.wav', sfx_acquire())
    write_wav('sfx_ledger.wav', sfx_ledger())


if __name__ == '__main__':
    main()
