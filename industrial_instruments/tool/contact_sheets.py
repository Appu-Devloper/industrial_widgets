"""Create review sheets after gallery.cjs and variants.cjs (requires Pillow)."""
from PIL import Image, ImageDraw

for theme in ('light', 'dark'):
    sheet = Image.new('RGB', (1400, 1240), '#f8f9f5' if theme == 'light' else '#132320')
    draw = ImageDraw.Draw(sheet)
    for i in range(20):
        preview = Image.open(f'doc/assets/widget-{i}-{theme}.png').crop((50, 285, 355, 645))
        preview.thumbnail((270, 270))
        x, y = (i % 5) * 280, (i // 5) * 310
        sheet.paste(preview, (x, y + 25))
        draw.text((x + 12, y + 4), str(i + 1), fill='grey')
    sheet.save(f'doc/assets/contact-{theme}.png')
