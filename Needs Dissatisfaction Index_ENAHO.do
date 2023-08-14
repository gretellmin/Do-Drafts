*********
/* NBI indígena

nbi1: Poblacion en Viviendas con Características Físicas Inadecuadas
nbi2: Poblacion en Viviendas con Hacinamiento
nbi3: Poblacion en Viviendas sin Desagüe de ningún Tipo
nbi4: Poblacion en hogares con Niños (6 a 12 años) que No Asisten a la Escuela
nbi5: Poblacion en hogares con Alta Dependencia Económica

Las variables ya se encuentran elaboradas en el modulo 100 de la ENAHO. */
clear all
cd "C:\Users\GRETEL\Desktop\PNPI-bases\ENAHO_TODOS" 


use enaho01-2022-100.dta, clear
/* result: resultado final de la encuesta 
1: completa 
2: incompleta 
3: rechazo 
4: ausente 
5: vivienda desocupada 
6: otro */

*Se trabaja solo con las encuestas completas e incompletas 
drop if result>2

*NECESIDADES BASICAS INSATISFECHAS (ya se encuentran en el modulo 100)
sum nbi*

collapse (mean) nbi1 nbi2 nbi3 nbi4 nbi5, by(conglome vivienda hogar) cw

*Juntamos el modulo 100 con el modulo sumaria 
*(ambas bases presentan informacion a nivel del hogar)
merge 1:1   conglome vivienda hogar using  sumaria-2022.dta, nogenerate

*Creamos la variable factor de expansion de la poblacion
gen    facpob=factor07*mieperho

*Establecemos las caracteristicas de la encuesta 
*usando las variable factor de expansion, conglomerado y estrato
svyset [pweight=facpob], psu(conglome) strata(estrato)


gen          nbihog=nbi1 + nbi2 + nbi3 + nbi4 + nbi5

gen    		 NBI1_POBRE=.
replace 	 NBI1_POBRE=1 if (nbihog==1) 
replace 	 NBI1_POBRE=2 if (nbihog==2)
replace 	 NBI1_POBRE=3 if (nbihog>=3 & nbihog<=5)
replace		 NBI1_POBRE=0 if nbihog==0

label define NBI1_POBRE 0 "ninguna NBI" 1 "al menos 1 NBI" 2 "2 NBI" 3 "de 3 a 5"
label value  NBI1_POBRE NBI1_POBRE NBI1_POBRE NBI1_POBRE
label var    NBI1_POBRE "NBI"
tab          NBI1_POBRE



*Cambiamos el nombre de la variable ahno y le damos 
*nombre a los nbi para eliminar los caracteres que no reconoce STATA
rename a*o anio
label var nbi1 "Poblacion en viviendas con caracteristicas fisicas inadecuadas"
label var nbi2 "Poblacion en viviendas con hacinamiento"
label var nbi3 "Poblacion en viviendas sin desague de ningun tipo"
label var nbi4 "Poblacion en hogares con ninos (6 a 12) que no asisten a la escuela"
label var nbi5 "Poblacion en hogares con alta dependencia economica"



***CRUZAMOS CON LA VARIABLE INDÍGENA

merge 1:m  ubigeo nconglome conglome vivienda hogar using enaho01a-2022-300.dta, nogenerate
**Variable indígena
gen IND=.
replace IND=1 if (p300a==1  | p300a==2| p300a==3| p300a==10| p300a==11| p300a==12| p300a==13| p300a==14| p300a==15)
replace IND=0 if (p300a>=4  & p300a<=9)

label define IND 0 "Lengua materna no indígena u originaria" 1 "Lengua materna indígena u originaria"
label value IND IND
label var    IND "Población de lengua materna indígena u originaria"
tab          IND

*****Cruzamos
tab IND NBI1_POBRE [aweight = factor07], row



