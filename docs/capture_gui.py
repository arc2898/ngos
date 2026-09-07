import os, time
from PIL import ImageGrab
os.environ['DISPLAY'] = ':99'
time.sleep(2)
image = ImageGrab.grab()
image.save('/home/ubuntu/work/ngos/out/ngos-desktop.png')
print(image.size)
