#!/usr/bin/env python3
"""Generate minimal VANVASI app icon (1024x1024 PNG). Requires Pillow."""
from pathlib import Path
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Install Pillow: python3 -m pip install --user pillow", file=sys.stderr)
    sys.exit(1)

OUT = Path(__file__).resolve().parents[1] / "VANVASI/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
SIZE = 1024

img = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
draw = ImageDraw.Draw(img)

# Outer ring
cx, cy = SIZE // 2, SIZE // 2
ring_r = 280
draw.ellipse(
    [cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r],
    outline=(235, 235, 235),
    width=8,
)

# Inner fill
inner_r = 220
draw.ellipse(
    [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
    fill=(18, 18, 18),
)

# Lock body
body_w, body_h = 100, 78
body_x = cx - body_w // 2
body_y = cy + 10
draw.rounded_rectangle(
    [body_x, body_y, body_x + body_w, body_y + body_h],
    radius=14,
    fill=(235, 235, 235),
)

# Lock shackle
shackle_w = 56
shackle_h = 44
draw.arc(
    [cx - shackle_w, cy - 70, cx + shackle_w, cy + shackle_h],
    start=180,
    end=0,
    fill=(235, 235, 235),
    width=10,
)

OUT.parent.mkdir(parents=True, exist_ok=True)
img.save(OUT, "PNG")
print(f"Saved {OUT}")
