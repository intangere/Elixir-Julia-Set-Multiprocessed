from PIL import Image
import time
import sys
import ast
import json

f = open("dataset.txt", "r")
pic = eval(f.read())
f.close()
w, h = 500, 1000
img = Image.new('L', (w, h))
pix = img.load()
for x in range(w):
	row = pic[x]
	for y, z in enumerate(row):
		pix[x, y] = z
img.show()
img.save("julia.png")

