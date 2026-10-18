from PIL import Image, ImageDraw
from pathlib import Path

def icon(size):
    im=Image.new('RGB',(1024,1024),'#234B3B')
    d=ImageDraw.Draw(im)
    d.line([(512,755),(512,400)],fill='#DCEBB7',width=38)
    d.ellipse((285,280,507,490),fill='#DCEBB7')
    d.ellipse((520,385,742,595),fill='#B7CD8F')
    d.line([(512,545),(390,405)],fill='#DCEBB7',width=32)
    d.line([(512,655),(630,510)],fill='#B7CD8F',width=30)
    return im.resize((size,size),Image.Resampling.LANCZOS)

for folder,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    icon(size).save(f'android/app/src/main/res/mipmap-{folder}/ic_launcher.png')
for p in Path('ios/Runner/Assets.xcassets/AppIcon.appiconset').glob('*.png'):
    with Image.open(p) as old: size=old.width
    icon(size).save(p)
