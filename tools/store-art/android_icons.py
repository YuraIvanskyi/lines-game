"""Render Android launcher icons and the Play store icon from lines-icon.svg via Inkscape."""
import os
import re
import subprocess
import sys
import tempfile

root = sys.argv[1]
inkscape = sys.argv[2]
svg = open(os.path.join(root, 'lines-icon.svg'), encoding='utf-8').read()
res = os.path.join(root, 'app', 'android', 'app', 'src', 'main', 'res')

# Split: defs + two full-bleed rects are the background; everything after is the art.
head, body = svg.split('</defs>', 1)
head += '</defs>'
bg_rects = re.findall(r'<rect width="1024" height="1024"[^>]*/>', body)
assert len(bg_rects) == 2, bg_rects
art = body
for r in bg_rects:
    art = art.replace(r, '', 1)
art = art.replace('</svg>', '')

background_svg = head + ''.join(bg_rects) + '</svg>'
# Adaptive foreground: 108dp canvas, 66dp safe circle. Art spans ~71% of the source,
# so scaling it to 90/108 keeps it inside the safe zone.
# The head dot and end square sit on the diagonal, ~479 units from centre:
# 479 * s * 108/1024 <= 33dp  ->  s <= 0.653.
scale = 0.62
foreground_svg = head + f'<g transform="translate(512 512) scale({scale}) translate(-512 -512)">' + art + '</g></svg>'

tmp = tempfile.mkdtemp()


def render(src_text, out, size):
    src = os.path.join(tmp, 'src.svg')
    open(src, 'w', encoding='utf-8').write(src_text)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    subprocess.run([inkscape, src, '--export-type=png', f'--export-filename={out}',
                    '-w', str(size), '-h', str(size)], check=True, capture_output=True)
    print(out, size)


densities = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
for name, k in densities.items():
    d = os.path.join(res, f'mipmap-{name}')
    render(svg, os.path.join(d, 'ic_launcher.png'), int(48 * k))
    render(foreground_svg, os.path.join(d, 'ic_launcher_foreground.png'), int(108 * k))
    render(background_svg, os.path.join(d, 'ic_launcher_background.png'), int(108 * k))

anydpi = os.path.join(res, 'mipmap-anydpi-v26')
os.makedirs(anydpi, exist_ok=True)
open(os.path.join(anydpi, 'ic_launcher.xml'), 'w', encoding='utf-8', newline='\n').write(
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
    '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
    '</adaptive-icon>\n')

# Play listing icon: 512x512, full square (Play applies its own mask).
render(svg, os.path.join(root, 'store', 'play-icon-512.png'), 512)
