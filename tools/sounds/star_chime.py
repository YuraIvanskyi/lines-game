"""Writes app/assets/sounds/star.wav: the cue for landing on a star.

Two quick rising sine notes (E6 then B6) with a soft bell decay, mono 16-bit 44.1 kHz,
peak about 10 000 to sit level with the other cues. Standard library only:

    python tools/sounds/star_chime.py
"""

import math
import struct
import wave
from pathlib import Path

RATE = 44100
PEAK = 10000
NOTES = [(1318.5, 0.0, 0.11), (1975.5, 0.07, 0.17)]  # (hz, start s, length s)
LENGTH = 0.24

out = Path(__file__).resolve().parents[2] / "app" / "assets" / "sounds" / "star.wav"
samples = [0.0] * int(RATE * LENGTH)
for hz, start, length in NOTES:
    first = int(start * RATE)
    for i in range(int(length * RATE)):
        t = i / RATE
        attack = min(1.0, t / 0.004)
        decay = math.exp(-t * 18)
        # A quiet octave on top gives the bell its shine.
        tone = math.sin(2 * math.pi * hz * t) + 0.25 * math.sin(2 * math.pi * hz * 2 * t)
        if first + i < len(samples):
            samples[first + i] += attack * decay * tone

loudest = max(abs(s) for s in samples)
frames = b"".join(struct.pack("<h", int(s / loudest * PEAK)) for s in samples)
with wave.open(str(out), "wb") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(frames)
print(f"wrote {out} ({len(samples) / RATE:.2f}s)")
