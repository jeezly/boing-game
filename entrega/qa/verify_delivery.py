from pathlib import Path
from PIL import Image
from pypdf import PdfReader
from docx import Document
import json,hashlib
root=Path.cwd();ev=root/'docs/evidence/proyecto_parcial_2';out=root/'entrega'
names=['01_gameplay_general','02_evento_zona_caliente','03a_comportamiento_pepsin','03b_comportamiento_polar','04a_transaccion_tienda','04b_transaccion_compra','05a_accion_disparo','05b_accion_melee','06_colisiones','07_puntaje_creditos_bajas','08_vidas_respawn','09_objetos_especiales','09b_powerup_activo','10_resultado_victoria','10b_resultado_derrota']
manifest=[]
for name in names:
 f=ev/(name+'.png');im=Image.open(f);assert im.size==(1280,720)
 manifest.append({'archivo':f.name,'resolucion':[1280,720],'sha256':hashlib.sha256(f.read_bytes()).hexdigest()})
log=(ev/'capture.log').read_text('utf-8-sig')
assert 'MELEE_SUCCESS true enemy hp 43.0' in log and 'ACADEMIC_EVIDENCE_COMPLETE' in log
assert 'SCRIPT ERROR' not in log and 'ERROR:' not in log
stem='Proyecto_Parcial_2_BOING_JuanPablo_GarciaHernandez'
doc=Document(out/(stem+'.docx'));pdf=PdfReader(out/(stem+'.pdf'))
assert len(pdf.pages)==30
assert len(doc.inline_shapes)==16
alltext='\n'.join(p.text for p in doc.paragraphs)+'\n'+'\n'.join(c.text for t in doc.tables for r in t.rows for c in r.cells)
assert '\ufffd' not in alltext
assert all(t in alltext for t in ['Juan Pablo García Hernández','1,128','Pepsín','Guayaba','Storyboard','11.8 Resultado de la beta'])
(ev/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),'utf-8')
(out/'revision_final.md').write_text('''# Revisión final de entrega BOING

Documento principal: Proyecto_Parcial_2_BOING_JuanPablo_GarciaHernandez.docx
PDF: Proyecto_Parcial_2_BOING_JuanPablo_GarciaHernandez.pdf
Páginas: 30. Figuras: 16 (una captura se usa también en portada).
Capturas originales: 15 PNG de 1280 × 720 en docs/evidence/proyecto_parcial_2/.

## Verificación

Se generó el DOCX con python-docx y se exportó mediante Microsoft Word 15.0 local. Se renderizaron las 30 páginas a PNG con PDFium y se revisaron todas; se corrigieron la línea heredada de portada, una etiqueta de tabla y el encuadre del pickup. El índice coincide con las páginas. Las tablas permanecen completas, las imágenes conservan proporción y las figuras están junto a sus pies. Los caracteres españoles se comprobaron visualmente y por extracción.

El registro de captura termina con ACADEMIC_EVIDENCE_COMPLETE sin errores de script. El ataque cuerpo a cuerpo devuelve true y deja a Pepsín con 43 HP desde sus 75 HP base. La tienda muestra 1800 créditos antes y 1300 después de comprar la Chancla por 500; los puntos permanecen en 1800.

Las 1128 comprobaciones sin fallos corresponden a los últimos seis logs archivados, no a una nueva corrida de esa suite durante la documentación. Las nuevas capturas fueron ejecutadas y revisadas en esta sesión. No se documentan testers externos ni una ronda humana completa inexistente. Las pantallas finales usan las transiciones reales con tiempo/vidas preparados.

## Reproducción de evidencias

Desde la raíz del proyecto, ejecutar Godot 4.7.2 con:

    Godot_v4.7.2-stable_mono_win64_console.exe --path . --rendering-method gl_compatibility --script scripts/test/academic_evidence_review.gd

El script solo sirve para revisión; no está enlazado a la escena principal ni modifica gameplay de producción. La generación de Word está en entrega/qa/build_portfolio.py y la exportación local en entrega/qa/render_word.ps1.

## Antes de subir

Leer las conclusiones personales para confirmar que representan la experiencia del alumno. Agregar institución, asignatura o docente únicamente si la plataforma los exige: no se inventaron esos datos. Si se exige una prueba humana completa de diez minutos, sigue pendiente; el documento la distingue de los estados reproducibles. La beta no se presenta como exportación comercial final.
''','utf-8')
for ext in ['docx','pdf']:
 f=out/(stem+'.'+ext);print(str(f),f.stat().st_size,'bytes')
print('VERIFICACION FINAL: 30 paginas, 16 figuras, 15 capturas 1280x720, texto español y log correctos.')
