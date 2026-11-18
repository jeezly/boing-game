from pathlib import Path
import pypdfium2 as pdfium
from pypdf import PdfReader
from PIL import Image,ImageDraw
root=Path('entrega');f=root/'Proyecto_Parcial_2_BOING_JuanPablo_GarciaHernandez.pdf'
pdf=pdfium.PdfDocument(str(f));reader=PdfReader(f)
for i in range(len(pdf)):
 pdf[i].render(scale=1.5).to_pil().save(root/f'qa/page-{i+1:02d}.png')
 text=reader.pages[i].extract_text()
 print(f'{i+1:02d} | {len(text)} chars | '+text[:95].replace('\n',' / '))
for k in range(5):
 canvas=Image.new('RGB',(1050,1000),'#dddddd');draw=ImageDraw.Draw(canvas)
 for j in range(6):
  i=k*6+j;im=Image.open(root/f'qa/page-{i+1:02d}.png');im.thumbnail((340,475));x=(j%3)*350;y=(j//3)*500
  canvas.paste(im,(x,y));draw.text((x+8,y+478),str(i+1),fill='black')
 canvas.save(root/f'qa/contact-{k+1}.png')
