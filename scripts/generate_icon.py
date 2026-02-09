#!/usr/bin/env python3
"""Generate ShowTracker app icon at 1024x1024.

Design: Teal/green gradient squircle with white TV screen and bookmark ribbon.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import os

SIZE = 1024
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "build", "icon")


def superellipse_path(cx, cy, rx, ry, n=5, steps=360):
    """Generate points for a squircle (superellipse) path."""
    points = []
    for i in range(steps):
        t = 2 * math.pi * i / steps
        cos_t = math.cos(t)
        sin_t = math.sin(t)
        x = cx + rx * abs(cos_t) ** (2 / n) * (1 if cos_t >= 0 else -1)
        y = cy + ry * abs(sin_t) ** (2 / n) * (1 if sin_t >= 0 else -1)
        points.append((x, y))
    return points


def draw_gradient(draw, bbox, color_top, color_bottom, mask=None):
    """Draw a vertical gradient within a bounding box."""
    x0, y0, x1, y1 = bbox
    for y in range(int(y0), int(y1)):
        ratio = (y - y0) / (y1 - y0)
        r = int(color_top[0] + (color_bottom[0] - color_top[0]) * ratio)
        g = int(color_top[1] + (color_bottom[1] - color_top[1]) * ratio)
        b = int(color_top[2] + (color_bottom[2] - color_top[2]) * ratio)
        draw.line([(x0, y), (x1, y)], fill=(r, g, b))


def create_icon():
    # Create base image
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # --- Background squircle with gradient ---
    # Draw gradient on full canvas first
    gradient = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    grad_draw = ImageDraw.Draw(gradient)

    # Teal to green gradient (top-left to bottom-right approximated as top-to-bottom)
    color_top = (13, 148, 136)      # #0D9488 teal
    color_bottom = (16, 185, 129)   # #10B981 green
    draw_gradient(grad_draw, (0, 0, SIZE, SIZE), color_top, color_bottom)

    # Create squircle mask
    mask = Image.new("L", (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    margin = 20
    squircle = superellipse_path(SIZE / 2, SIZE / 2, SIZE / 2 - margin, SIZE / 2 - margin, n=5)
    mask_draw.polygon(squircle, fill=255)

    # Apply squircle mask to gradient
    img.paste(gradient, mask=mask)

    # --- Subtle inner shadow on squircle edges ---
    shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    # Draw a darker border inside the squircle
    for offset in range(6):
        alpha = int(30 * (1 - offset / 6))
        inner = superellipse_path(SIZE / 2, SIZE / 2,
                                  SIZE / 2 - margin - offset,
                                  SIZE / 2 - margin - offset, n=5)
        shadow_draw.polygon(inner, outline=(0, 0, 0, alpha))
    img = Image.alpha_composite(img, shadow)
    draw = ImageDraw.Draw(img)

    # --- TV Screen (white rounded rectangle) ---
    tv_margin = int(SIZE * 0.22)
    tv_left = tv_margin
    tv_top = int(SIZE * 0.24)
    tv_right = SIZE - tv_margin
    tv_bottom = int(SIZE * 0.72)
    tv_radius = 40

    # TV screen with slight transparency for depth
    tv_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    tv_draw = ImageDraw.Draw(tv_layer)
    tv_draw.rounded_rectangle(
        [tv_left, tv_top, tv_right, tv_bottom],
        radius=tv_radius,
        fill=(255, 255, 255, 230)
    )
    img = Image.alpha_composite(img, tv_layer)
    draw = ImageDraw.Draw(img)

    # --- TV Stand (small centered trapezoid below screen) ---
    stand_top_width = 80
    stand_bottom_width = 140
    stand_height = 30
    stand_y = tv_bottom + 15
    stand_cx = SIZE // 2

    stand_points = [
        (stand_cx - stand_top_width // 2, stand_y),
        (stand_cx + stand_top_width // 2, stand_y),
        (stand_cx + stand_bottom_width // 2, stand_y + stand_height),
        (stand_cx - stand_bottom_width // 2, stand_y + stand_height),
    ]
    draw.polygon(stand_points, fill=(255, 255, 255, 180))

    # --- Base bar under stand ---
    base_width = 200
    base_height = 8
    base_y = stand_y + stand_height + 5
    draw.rounded_rectangle(
        [stand_cx - base_width // 2, base_y,
         stand_cx + base_width // 2, base_y + base_height],
        radius=4,
        fill=(255, 255, 255, 180)
    )

    # --- Play triangle inside TV screen ---
    play_cx = (tv_left + tv_right) // 2
    play_cy = (tv_top + tv_bottom) // 2
    play_size = 70

    play_points = [
        (play_cx - play_size // 2 + 10, play_cy - play_size // 2),
        (play_cx + play_size // 2 + 10, play_cy),
        (play_cx - play_size // 2 + 10, play_cy + play_size // 2),
    ]

    play_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    play_draw = ImageDraw.Draw(play_layer)
    # Teal play button inside screen
    play_draw.polygon(play_points, fill=(13, 148, 136, 160))
    img = Image.alpha_composite(img, play_layer)
    draw = ImageDraw.Draw(img)

    # --- Bookmark ribbon on top-right of TV ---
    ribbon_width = 55
    ribbon_height = 100
    ribbon_x = tv_right - 80
    ribbon_y = tv_top - 20

    ribbon_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ribbon_draw = ImageDraw.Draw(ribbon_layer)

    # Ribbon body (rectangle with notch at bottom)
    ribbon_points = [
        (ribbon_x, ribbon_y),
        (ribbon_x + ribbon_width, ribbon_y),
        (ribbon_x + ribbon_width, ribbon_y + ribbon_height),
        (ribbon_x + ribbon_width // 2, ribbon_y + ribbon_height - 20),
        (ribbon_x, ribbon_y + ribbon_height),
    ]
    ribbon_draw.polygon(ribbon_points, fill=(6, 95, 70, 230))  # #065F46

    # Subtle highlight on left edge of ribbon
    ribbon_draw.line(
        [(ribbon_x + 2, ribbon_y), (ribbon_x + 2, ribbon_y + ribbon_height - 5)],
        fill=(255, 255, 255, 60), width=3
    )

    img = Image.alpha_composite(img, ribbon_layer)

    return img


def generate_all_sizes(img):
    """Generate all required macOS icon sizes from the 1024 source."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    sizes = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }

    for filename, px in sizes.items():
        resized = img.resize((px, px), Image.LANCZOS)
        path = os.path.join(OUTPUT_DIR, filename)
        resized.save(path, "PNG")
        print(f"  {filename} ({px}x{px})")

    # Also save the 1024 source
    source_path = os.path.join(OUTPUT_DIR, "icon_1024.png")
    img.save(source_path, "PNG")
    print(f"  icon_1024.png (1024x1024)")

    return OUTPUT_DIR


if __name__ == "__main__":
    print("Generating ShowTracker icon...")
    icon = create_icon()
    out = generate_all_sizes(icon)
    print(f"\nAll icons saved to: {out}")
