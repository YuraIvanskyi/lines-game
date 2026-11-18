"""Play feature graphic 1024x500: sky gradient, icon art left, ENDS wordmark + tagline right."""
import os
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

root, inkscape = sys.argv[1], sys.argv[2]
W, H = 1024, 500

# Background: same vertical gradient as the icon.
top, bottom = (0x0B, 0x4F, 0xBE), (0x08, 0x34, 0x7A)
bg = Image.new('RGB', (W, H))
px = bg.load()
for y in range(H):
    t = y / (H - 1)
    c = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom))
    for x in range(W):
        px[x, y] = c

# Icon art (with its own square background) at 380px, rounded corners.
tmp = tempfile.mkdtemp()
icon_png = os.path.join(tmp, 'icon.png')
subprocess.run([inkscape, os.path.join(root, 'lines-icon.svg'), '--export-type=png',
                f'--export-filename={icon_png}', '-w', '380', '-h', '380'], check=True, capture_output=True)
icon = Image.open(icon_png).convert('RGBA')
mask = Image.new('L', icon.size, 0)
ImageDraw.Draw(mask).rounded_rectangle((0, 0, 379, 379), radius=84, fill=255)
bg.paste(icon, (70, 60), mask)

font_path = os.path.join(root, 'app', 'assets', 'fonts', 'Nunito-Variable.ttf')


def font(size, weight):
    f = ImageFont.truetype(font_path, size)
    try:
        f.set_variation_by_axes([weight])
    except Exception as e:  # older FreeType: falls back to the default instance
        print('variation not applied:', e)
    return f


d = ImageDraw.Draw(bg)
ink = (0x10, 0x2A, 0x4C)
title = font(150, 900)
d.text((505, 105), 'ENDS', font=title, fill='white', stroke_width=10, stroke_fill=ink)
tag = font(40, 800)
d.text((512, 300), 'Grow the line.', font=tag, fill=(0xFF, 0xC1, 0x07))
d.text((512, 352), "Don't get stuck.", font=tag, fill='white')

out = os.path.join(root, 'store', 'play-feature-graphic.png')
bg.save(out)
print(out, bg.size)
