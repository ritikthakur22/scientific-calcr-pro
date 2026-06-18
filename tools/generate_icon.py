from PIL import Image, ImageDraw, ImageFont

size = (1024, 1024)
img = Image.new('RGBA', size, color=(0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw a circular background
draw.ellipse([(0, 0), (1024, 1024)], fill=(30, 30, 35))

# Draw the inner shapes
draw.ellipse([(100, 100), (924, 924)], fill=(45, 45, 55), outline=(100, 100, 255), width=20)
draw.line((300, 300, 724, 724), fill=(0, 200, 150), width=30)
draw.line((724, 300, 300, 724), fill=(200, 50, 150), width=30)

draw.text((380, 800), "Scientific", fill=(255, 255, 255), font_size=80)
draw.text((600, 800), "PRO", fill=(100, 150, 255), font_size=80)

img.save('assets/icon.png', 'PNG')
print("Icon created.")
