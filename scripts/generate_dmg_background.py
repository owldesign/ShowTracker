#!/usr/bin/env python3
"""Generate DMG background image for ShowTracker installer."""

from PIL import Image, ImageDraw, ImageFont
import os

WIDTH = 600
HEIGHT = 400
OUTPUT = os.path.join(os.path.dirname(__file__), "..", "build", "dmg-background.png")


def create_background():
    img = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Subtle gradient background (light gray to white)
    for y in range(HEIGHT):
        ratio = y / HEIGHT
        val = int(245 + (255 - 245) * ratio)
        draw.line([(0, y), (WIDTH, y)], fill=(val, val, val, 255))

    # Arrow from app icon position to Applications folder position
    # App icon center: ~150, 200
    # Applications center: ~450, 200
    arrow_y = 210
    arrow_start = 220
    arrow_end = 380

    # Arrow shaft
    draw.line(
        [(arrow_start, arrow_y), (arrow_end, arrow_y)],
        fill=(180, 180, 180, 255),
        width=3
    )

    # Arrow head
    head_size = 12
    draw.polygon(
        [
            (arrow_end, arrow_y),
            (arrow_end - head_size, arrow_y - head_size // 2),
            (arrow_end - head_size, arrow_y + head_size // 2),
        ],
        fill=(180, 180, 180, 255)
    )

    # "Drag to install" text below arrow
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
    except (IOError, OSError):
        font = ImageFont.load_default()

    text = "Drag to Applications to install"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_x = (WIDTH - text_width) // 2
    draw.text((text_x, arrow_y + 25), text, fill=(160, 160, 160, 255), font=font)

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    img.save(OUTPUT, "PNG")
    print(f"DMG background saved to: {OUTPUT}")
    return OUTPUT


if __name__ == "__main__":
    create_background()
