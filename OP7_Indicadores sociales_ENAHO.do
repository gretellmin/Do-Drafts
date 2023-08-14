
**************INDICADORES POLÍTICA NACIONAL DE PUEBLOS INDÍGENAS PNPI- MINCUL**************************************************************
************************************************************************************************
***OP6. SOCIAL
**Educación
**Salud
**Servicios

**Empiezo uniendo sumaria -modulo 100- con modulo de características socioeeconómicas
*aquí está la variable result que nos ayuda a filtar las encuestas completas e incompletas

clear all

cd "C:\Users\GRETEL\Desktop\PNPI-bases\ENAHO_TODOS" 


use enaho01-2018-100.dta, clear
/* result: resultado final de la encuesta 
1: completa 
2: incompleta 
3: rechazo 
4: ausente 
5: vivienda desocupada 
6: otro */

*Se trabaja solo con las encuestas completas e incompletas 
drop if result>2

collapse (mean) nbi1 nbi2 nbi3 nbi4 nbi5 p1121, by(conglome vivienda hogar) cw
*Juntamos el modulo 100 con el modulo sumaria 
*(ambas bases presentan informacion a nivel del hogar)
merge 1:1   conglome vivienda hogar using  sumaria-2018.dta, nogenerate

*Creamos la variable factor de expansion de la poblacion
gen    facpob=factor07*mieperho

*Establecemos las caracteristicas de la encuesta 
*usando las variable factor de expansion, conglomerado y estrato
svyset [pweight=facpob], psu(conglome) strata(estrato)

//*CRUZO CON VARIABLE INDÍGENA

merge 1:m  ubigeo nconglome conglome vivienda hogar using enaho01a-2018-300.dta, nogenerate

**Variable indígena
gen IND=.
replace IND=1 if (p300a==1  | p300a==2| p300a==3| p300a==10| p300a==11| p300a==12| p300a==13| p300a==14| p300a==15)
replace IND=0 if (p300a>=4  & p300a<=9)

label define IND 0 "Lengua materna no indígena u originaria" 1 "Lengua materna indígena u originaria"
label value  IND IND
label var    IND "Población de lengua materna indígena u originaria"


////***Educación
*Defino edad
gen rango_edad=.
replace rango_edad=1 if (p208a>=25 & p208a<=64)
replace rango_edad=0 if (p208a>=0 & p208a<25 | p208a>64)

gen rango_edadind=.
replace rango_edadind=1 if (rango_edad==1 & IND==1)
replace rango_edadind=0 if (rango_edad==1 & IND==0| rango_edad==0 & IND==1| rango_edad==0 & IND==0)

///*7.1 Enseñanza en lengua materna
merge 1:1  conglome vivienda hogar ubigeo dominio estrato codperso using enaho01a-2018-300a.dta, nogenerate

tab IND p317 [aweight=factora07], row 

///*7.2 Porcentaje de población de lengua indígena u originaria que concluyó de la educación primaria 
gen educacion_prim=.
replace educacion_prim=1 if (p301a>=4 & p301a<=11)
replace educacion_prim=0 if (p301a>=1 & p301a<4| p301a>11)

tab rango_edadind educacion_prim [aweight=factora07], row
/// 7.3 Porcentaje de población de lengua indígena u originaria que concluyó de la educación secundaria
gen educacion_sec=.
replace educacion_sec=1 if (p301a>=6 & p301a<=11)
replace educacion_sec=0 if (p301a>=1 & p301a<6| p301a>11)

tab rango_edadind educacion_sec [aweight=factora07], row
/// 7.4 Porcentaje de población de lengua indígena u originaria que concluyó de la educación superior
gen educacion_sup=.
replace educacion_sup=1 if (p301a==8| p301a>=10 & p301a<=11)
replace educacion_sup=0 if (p301a>=1 & p301a<8| p301a==9| p301a>11)

tab rango_edadind educacion_sup [aweight=factora07], row
/// 7.5 Porcentaje de población de población PIIOO con problema de salud crónico
merge 1:1  conglome vivienda hogar ubigeo dominio estrato codperso using enaho01a-2018-400.dta, nogenerate
tab IND p401[aweight=factora07], row 
*/// 1 si, 2 no 9 missing

/// 7.6 YA HECHO, recordar que se debe poner solo 2 y no al menos 2

/// 7.7 Porcentaje de población de lengua materna indígena u originaria con acceso a energía eléctrica (alumbrad
o electrico en casa) https://sinia.minam.gob.pe/inea/indicadores/proporcion-de-la-poblacion-con-acceso-a-la-electricidad-segun-area-de-residencia-2014-2018/ 

tab IND p1121 [aweight=factora07], row


/// 7.8 Porcentaje de población con lengua materna indígena u originaria con acceso a servicio de internet desde el celular
*en el 2018 p314b1_3 
gen inter=.
replace inter=p314b1_8 + p314b1_9


tab IND inter [aweight=factora07], row
tab IND p314b1_3 [aweight=factora07], row 
tab IND p314b_1 [aweight=factora07], row
