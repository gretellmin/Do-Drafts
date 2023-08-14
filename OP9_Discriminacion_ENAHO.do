*************INDICADORES POLÍTICA NACIONAL DE PUEBLOS INDÍGENAS PNPI- MINCUL**************************************************************
************************************************************************************************

**Empiezo uniendo sumaria -modulo 100- con modulo de características socioeeconómicas
*aquí está la variable result que nos ayuda a filtar las encuestas completas e incompletas

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

***CRUZAMOS CON LA VARIABLE INDÍGENA

merge 1:m  ubigeo nconglome conglome vivienda hogar using enaho01a-2022-500.dta, nogenerate
keep p558c factor07 mes conglome vivienda hogar codperso codinfor ubigeo dominio estrato nconglome sub_conglome 
merge m:m mes conglome vivienda hogar codperso codinfor ubigeo dominio estrato nconglome using enaho01b-2022-1.dta, nogenerate 
**Variable indígena

gen IND=.
replace IND=1 if (p558c<=4 |p558c==9)
replace IND=0 if (p558c>4 & p558c<9)

merge m:m  ubigeo nconglome conglome vivienda hogar using enaho01a-2022-300.dta, nogenerate

**Variable de lengua materna indígena
gen IND2=.
replace IND2=1 if (p300a==1  | p300a==2| p300a==3| p300a==10| p300a==11| p300a==12| p300a==13| p300a==14| p300a==15)
replace IND2=0 if (p300a>=4  & p300a<=9)

label define IND2 0 "Lengua materna no indígena u originaria" 1 "Lengua materna indígena u originaria"
label value IND2 IND2
label var    IND2 "Población de lengua materna indígena u originaria"
tab          IND2

*****INDICADOR 9 Porcentaje de población que se  autoidentifica como indígena u originario, que se ha sentido discriminada en los últimos 12 meses 

replace p22_1_01=0 if p22_1_01==2
replace p22_1_02=0 if p22_1_02==2
replace p22_1_03=0 if p22_1_03==2
replace p22_1_04=0 if p22_1_04==2
replace p22_1_05=0 if p22_1_05==2
replace p22_1_06=0 if p22_1_06==2
replace p22_1_07=0 if p22_1_07==2
replace p22_1_08=0 if p22_1_08==2
replace p22_1_09=0 if p22_1_09==2
replace p22_1_10=0 if p22_1_10==2
replace p22_1_11=0 if p22_1_11==2
replace p22_1_12=0 if p22_1_12==2
gen discri=.
replace discri=p22_1_01+p22_1_02+ p22_1_03 +p22_1_04 + p22_1_05 + p22_1_06 + p22_1_07 + p22_1_08 + p22_1_09 + p22_1_10 + p22_1_11 + p22_1_12
sum discri
tab discri
gen disc=.
replace disc=1 if (discri>=1)
replace disc=0 if (discri<1)
tab     IND disc , row



tab     IND2 disc , row
