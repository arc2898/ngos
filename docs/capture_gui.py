import os
import time
from pathlib import Path
from PIL import ImageGrab

os.environ.setdefault("DISPLAY", ":99")
time.sleep(1)
image = ImageGrab.grab()
out = Path(__file__).resolve().parents[1] / "out" / "ngos-desktop.png"
out.parent.mkdir(parents=True, exist_ok=True)
image.save(out)
print(image.size)
