
**************INDICADORES POLÍTICA NACIONAL DE PUEBLOS INDÍGENAS PNPI- MINCUL**************************************************************
************************************************************************************************
**Pobreza
**Empleo
**Empleo mujer indígena
**Productividad

**Empiezo uniendo sumaria -modulo 100- con modulo de características socioeeconómicas
*aquí está la variable result que nos ayuda a filtar las encuestas completas e incompletas

clear all
cd "C:\Users\GRETEL\Desktop\PNPI-bases\ENAHO_TODOS" 


use enaho01-2017-100.dta, clear
/* result: resultado final de la encuesta 
1: completa 
2: incompleta 
3: rechazo 
4: ausente 
5: vivienda desocupada 
6: otro */

*Se trabaja solo con las encuestas completas e incompletas 
drop if result>2

collapse (mean) nbi1 nbi2 nbi3 nbi4 nbi5, by(conglome vivienda hogar) cw

*Juntamos el modulo 100 con el modulo sumaria 
*(ambas bases presentan informacion a nivel del hogar)
merge 1:1   conglome vivienda hogar using  sumaria-2017.dta, nogenerate

*Creamos la variable factor de expansion de la poblacion
gen    facpob=factor07*mieperho

*Establecemos las caracteristicas de la encuesta 
*usando las variable factor de expansion, conglomerado y estrato
svyset [pweight=facpob], psu(conglome) strata(estrato)

//*CRUZO CON VARIABLE INDÍGENA

merge 1:m  ubigeo nconglome conglome vivienda hogar using enaho01a-2017-300.dta, nogenerate

keep ubigeo nconglome conglome vivienda hogar codperso codinfor p300a pobreza factor07
**Variable indígena
gen IND=.
replace IND=1 if (p300a==1  | p300a==2| p300a==3| p300a==10| p300a==11| p300a==12| p300a==13| p300a==14| p300a==15)
replace IND=0 if (p300a>=4  & p300a<=9)

label define IND 0 "Lengua materna no indígena u originaria" 1 "Lengua materna indígena u originaria"
label value  IND IND
label var    IND "Población de lengua materna indígena u originaria"

/// INDICADOR 8.1 POBREZA
gen pobre=.
replace pobre=1 if (pobreza<=2)
replace pobre=0 if (pobreza==3)
tab IND pobre [aweight = factor07], row

/// INDICADOR 8.3 EMPLEO INFORMAL(mayor de 14 años)

merge 1:m  ubigeo nconglome conglome vivienda hogar codperso codinfor  using enaho01a-2017-500.dta, nogenerate

gen empleadoinf=.
replace empleadoinf=1 if (ocupinf==1)
replace empleadoinf=2 if (ocupinf==2)
replace empleadoinf=0 if (ocu500==0| ocu500==2| ocu500==3) 
replace empleadoinf=3 if (ocu500==4)

label define 	empleadoinf 0 "no empleado" 1 "empleado informal" 2 "empleado formal" 3 "no pea"
label value  	empleadoinf empleadoinf empleadoinf empleadoinf
label var  		empleadoinf "Empleo formal, informal y no pea"

tab IND empleadoinf [aweight = fac500a], row

////// INDICADOR 7. tasa de empleo de mujeres

gen mujerind=.
replace mujerind=1 if (p207==2 & IND==1)
replace mujerind=0 if (p207==2 & IND==0| p207==1  & IND==1| p207==1  & IND==0)


tab mujerind empleadoinf [aweight = fac500a], row


// INDICADOR 8.2 PRODUCTIVIDAD DE HOGARES INDÍGENAS
****Paso 1. Hallamos los hogares con producción de mercado: a PEA Ocupada por categoría de ocupación en tres grandes grupos: hogares con producción para uso final propio, sociedades y hogares con producción de mercado. 
/*Hallamos:
a. trabajadores familiares no remunerados
a.1 empleado u obrero en parte b o c
b. empleador o trabajador independiente con negocio sin personeria juridica en el sector agropecuario
	Sector agrario identificado por la FAO https://www.fao.org/3/cc4897es/cc4897es.pdf
c. empleador o trabajador independiente con negocio con personeria juridica con menos de 30 trabajadores
*creamos la variable de hogar no juridico*/

* Hallo parte b.
gen negocionojurd=.
replace negocionojurd=1 if (p510a1==2| p510a1==3)
replace negocionojurd=0 if (p510a1==1)

gen njurdagro=.
replace njurdagro=1 if (negocionojurd==1 & p506>=111 & p506<=322| negocionojurd==1 & p506r4>=111 & p506r4<=322 )
replace njurdagro=0 if (negocionojurd==0 & p506<111| negocionojurd==0 & p506>322| negocionojurd==0 & p506r4<111| negocionojurd==0 & p506r4>322)

* Hallo parte c.
gen negociojurd=.
replace negociojurd=1 if (p510a1==1)
replace negociojurd=0 if (p510a1==2| p510a1==3)

gen negomenor50=.
replace negomenor50=1 if (negociojurd==1 & p512a<=2)
replace negomenor50=0 if (negociojurd==0 & p512a>2)

* Hallo parte a.1, empleado u obrero agricola o que trabaja en una empresa con menos de 50 trabajadores
gen empuobrero=.
replace empuobrero=1 if (p507>=3 & p507<=4| p510>=6)
replace empuobrero=2 if (empuobrero==1 & njurdagro==1)
replace empuobrero=3 if (empuobrero==1 & negomenor50==1)

***Hallamos los hogares de producción con especificacion de empelado u patrono o trab independiente
gen HOGPROD=.
replace HOGPROD=1 if (p507==5| empuobrero>=1 | njurdagro==1 & p507==1| njurdagro==1 & p507==2| negomenor50==1 & p507==1|  negomenor50==1 & p507==2)
replace HOGPROD=0 if (p507==6| njurdagro==0 | negomenor50==0)

tab empleadoinf HOGPROD
tab IND HOGPROD [aweight = fac500a], row

gen HOGPRODIND=.
replace HOGPRODIND=1 if (IND==1 & HOGPROD==1)
replace HOGPRODIND=0 if (IND==0 & HOGPROD==1)
* Entonces solo hacemos la comparacion de hogares de produccion ind y no ind, y los que no son de prod se quedan afuera| IND==1 & HOGPROD==0| IND==0 & HOGPROD==0)

*********PRODUCTIVIDAD****************************************

////. Ingreso promedio

*Establecer a los residentes habituales
gen resi=1 if ((p204==1 & p205==2) | (p204==2 & p206==1))

/* Ingreso proveniente del trabajo
i524a1  Ingreso total trimestral (Imputado, deflactado, Anualizado)
d529t   Pago en especie dependiente (Deflactado, Anualizado)
i530a   Ganancia (ocupación principal independiente) (Imputado, deflactado, Anualizado)
d536    Valor de los productos para su consumo (Deflactado, Anualizado)
i538a1  Ingreso total (Imputado, deflactado, Anualizado)
d540t   Pago en especie (dependiente) (Deflactado, Anualizado)
i541a   Ganancia (ocupación secundaria independiente) (Imputado, deflactado, Anualizado)
d543    Valor de los productos utilizados para su consumo (Deflactado, Anualizado)
d544t   Ingreso extraordinario (Deflactado, Anualizado) */


egen  ingtrabw= rowtotal(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t) 
gen   ingtra_n= ingtrabw/12
label var   ingtrabw "ingreso por trabajo anual"
label var   ingtra_n "ingreso por trabajo mensual"
keep if ocu500 == 1 & ingtra_n > 0 

*Perú: Ingreso promedio mensual proveniente del trabajo de
*la población ocupada, según poblacion INDIgena
table HOGPRODIND [iw=fac500a] if resi==1 , c(mean ingtra_n) row



