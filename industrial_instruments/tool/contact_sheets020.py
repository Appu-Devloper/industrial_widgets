"""Contact sheets from actual catalog screenshots (requires Pillow)."""
from PIL import Image, ImageDraw
for theme in ('light', 'dark'):
    for page in range(2):
        sheet = Image.new('RGB', (1280, 1600), '#f8f9f5' if theme == 'light' else '#132320')
        draw = ImageDraw.Draw(sheet)
        for j, i in enumerate(range(page * 20, min(33, (page + 1) * 20))):
            preview = Image.open(f'doc/assets/v020/widget-{i}-{theme}.png').crop((58, 285, 350, 830))
            preview.thumbnail((245, 290))
            x, y = j % 5 * 256, j // 5 * 400
            sheet.paste(preview, (x, y + 25))
            draw.text((x + 10, y + 5), str(i + 1), fill='grey')
        sheet.save(f'doc/assets/v020/contact-{theme}-{page}.png')
