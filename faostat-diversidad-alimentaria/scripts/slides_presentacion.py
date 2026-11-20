import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt, matplotlib.image as mi, textwrap as tw
from matplotlib.backends.backend_pdf import PdfPages
BG,TX,MU,AC='#fbfaf7','#1d2327','#5b646b','#1b6ca8'
GR='#87868A'
LG=mi.imread('docs/img/logo_gris.png');LW=mi.imread('docs/img/logo_blanco.png')
def logo(f,im,x,y,h):
    r=im.shape[1]/im.shape[0];a=f.add_axes([x,y,h*r*7.5/13.333,h]);a.imshow(im);a.axis('off')
W,H=13.333,7.5
pdf=PdfPages('docs/presentacion.pdf');n=[0]
def wr(t,c):return '\n'.join(tw.fill(l,c) for l in t.split('\n'))
def slide(title,sub=None):
    f=plt.figure(figsize=(W,H),facecolor=BG);n[0]+=1
    f.text(.06,.90,wr(title,60),fontsize=28,weight='bold',color=TX,va='center')
    if sub:f.text(.06,.835,sub,fontsize=15,color=MU,va='center')
    f.add_artist(plt.Rectangle((0,0),.012,1,color=GR,transform=f.transFigure));logo(f,LG,.865,.855,.1)
    f.text(.94,.03,str(n[0]),fontsize=11,color=MU,ha='right');f.text(.06,.03,'FAOSTAT · Diversidad alimentaria en Sudamérica · Salazar y Ríos',fontsize=10,color=MU);return f
def bullets(f,items,x=.06,y=.74,fs=18,step=.12,c=80):
    for t in items:
        t=wr(t,c);f.text(x,y,'•',fontsize=fs,color=AC,va='top');f.text(x+.02,y,t,fontsize=fs,color=TX,va='top',linespacing=1.3);y-=step*(1+(t.count('\n'))*.45)
def img(f,p,box):a=f.add_axes(box);a.imshow(mi.imread(p));a.axis('off')
def cover(lines,lp=(.62,.5,.34)):
    f=plt.figure(figsize=(W,H),facecolor=GR);n[0]+=1;logo(f,LW,*lp)
    for x,y,t,fs,col,wt in lines:f.text(x,y,t,fontsize=fs,color=col,weight=wt,va='top',linespacing=1.5)
    pdf.savefig(f);plt.close(f)
def save(f):pdf.savefig(f);plt.close(f)
cover([(.07,.68,'¿Más variedad, mejor\noferta alimentaria?',42,'w','bold'),(.07,.42,'Diversidad, energía, grasa y calidad de la oferta en 10 países\nde Sudamérica, 2010-2023',20,'#ececee','normal'),(.07,.2,'Juan Salazar y Luz Ríos · Minería de datos · ITM\nDatos: FAOSTAT, balances alimentarios (FAO)',15,'w','normal')])
f=slide('La pregunta','"Más variedad" suele leerse como "mejor dieta". ¿Se sostiene con datos?')
bullets(f,['Dentro de cada país, ¿los años de oferta más diversa son también años con más energía, más grasa y mejor calidad?','Panel equilibrado: 10 países × 14 años = 140 observaciones (Argentina, Bolivia, Brasil, Chile, Colombia, Ecuador, Paraguay, Perú, Uruguay, Venezuela).','Son datos de disponibilidad de alimentos (balances), no de consumo.'],y=.72,fs=19,step=.14,c=85);save(f)
f=slide('Tres etapas de análisis')
for i,(t,d) in enumerate([('1 · Descriptivo','Calidad de datos, tendencias (Mann-Kendall), correlaciones, PCA y conglomerados.'),('2 · Diagnóstico','Panel FE/RE y Hausman; errores por país, Driscoll-Kraay, bootstrap salvaje + Holm; pronóstico.'),('3 · Multivariado','ACP de 13 grupos de alimentos, Ward y MANCOVA con bootstrap salvaje por país.')]):
    a=f.add_axes([.06+i*.3,.25,.27,.5]);a.axis('off');a.add_patch(plt.Rectangle((0,0),1,1,color='white',ec='#e2e0d9',transform=a.transAxes))
    a.text(.06,.88,t,fontsize=19,weight='bold',color=AC,transform=a.transAxes,va='top');a.text(.06,.7,wr(d,26),fontsize=15,color=TX,va='top',transform=a.transAxes,linespacing=1.4)
f.text(.06,.14,'Con solo 10 países la inferencia usual no es fiable: se comparan varias formas de inferencia.',fontsize=15,color=MU);save(f)
f=slide('Hallazgo 1: más diversidad dentro de cada país\nva con más energía y grasa');f.text(.06,.78,'Asociación, no causalidad',fontsize=15,color=MU);img(f,'docs/img/diversidad_vs_energia.png',[.05,.08,.55,.68])
for j,(k,t) in enumerate([('+74 kcal','por +1 DE de diversidad (+2,5 %)\nHolm = 0,038'),('+11,4 g','de grasa por día (+12 %)\nResiste 6 verificaciones'),('Sin efecto','en calidad de la oferta')]):
    f.text(.66,.72-j*.2,k,fontsize=30,weight='bold',color=AC);f.text(.66,.66-j*.2,t,fontsize=14,color=MU,va='top')
save(f)
f=slide('Una precisión sobre la escala','La "DE" del titular es la de todos los datos, no la de un país en el tiempo')
a=f.add_axes([.08,.12,.4,.6]);a.set_facecolor(BG);b=a.bar(['DE total','DE dentro\ndel país'],[0.0564,0.0189],color=[MU,AC],width=.55)
for s in['top','right']:a.spines[s].set_visible(False)
a.set_ylabel('Desviación estándar del índice');[a.text(r.get_x()+r.get_width()/2,r.get_height()+.001,f'{r.get_height():.3f}',ha='center',fontsize=14) for r in b]
bullets(f,['El +74 kcal corresponde a 0,056 de diversidad: unas 3 veces la variación típica dentro de un país.','Un cambio típico dentro de un país se asocia con del orden de 25 kcal (ajuste simple con tendencia): efecto modesto.','Conviene reportar ambas escalas.'],x=.54,y=.68,fs=16,step=.13,c=48);save(f)
f=slide('Hallazgo 2: es frágil');img(f,'docs/img/coeficientes.png',[.04,.08,.5,.72])
bullets(f,['Con efectos de año, ninguna asociación sobrevive a Holm.','En primeras diferencias el efecto en energía desaparece (−14,5 kcal; p = 0,53); el de grasa se mantiene.','Entre países (n = 10) nada sobrevive.','Prueba conjunta: Pillai p < 0,001, pero bootstrap por país p = 0,064 y 0,083.'],x=.58,y=.74,fs=15.5,step=.12,c=42);save(f)
f=slide('Patrones de oferta y pronóstico');img(f,'docs/img/tendencia_energia.png',[.03,.2,.45,.58]);img(f,'docs/img/pronostico_energia.png',[.5,.2,.45,.58])
f.text(.06,.14,wr('93 % de la varianza de composición es entre países; 6 conglomerados (silueta 0,58) = tipologías de países.',58),fontsize=12.5,color=MU,va='top')
f.text(.52,.14,wr('Repetir el último valor supera a Holt y ARIMA. 2026 ≈ 2 996 kcal/día [2 920 – 3 072].',58),fontsize=12.5,color=MU,va='top');save(f)
f=slide('Limitaciones y próximos pasos')
bullets(f,['10 países y 14 años: poca potencia; los resultados dependen de la inferencia elegida.','Disponibilidad ≠ consumo. El índice de diversidad sale de la misma oferta que determina energía y grasa: parte puede ser mecánica.','Índice de calidad parcial (frutas, hortalizas y % de energía de grasa).','Pendiente: confirmar dominio FAOSTAT, añadir datos crudos y script de construcción de los CSV, definir licencia.'],y=.74,fs=18,step=.12,c=85);save(f)
cover([(.07,.68,'Conclusión',38,'w','bold'),(.07,.56,'Los años más diversos coinciden con más energía y grasa, pero la señal\nes débil y no resiste todas las especificaciones. Sin relación con la calidad.',20,'#ececee','normal'),(.07,.22,'Panel interactivo: jps4l4.github.io/faostat-diversidad-alimentaria\nCódigo: github.com/JPS4L4/faostat-diversidad-alimentaria',15,'w','normal')],lp=(.74,.06,.24))
pdf.close()