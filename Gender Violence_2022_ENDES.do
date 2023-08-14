clear all
cd "C:\Users\GRETEL\Desktop\PNPI-bases\ENDES"


***MERGE

*Unir las bases
use                            REC91.dta, clear
merge 1:1 CASEID      using     REC0111.dta, nogenerate
save 2022_rec91_rec0111.dta, replace
sort CASEID


use                             REC42.dta, clear
merge 1:1 caseid      using     RE516171.dta, nogenerate
rename caseid CASEID
merge 1:1 CASEID      using     RE223132.dta, nogenerate
merge 1:1 CASEID      using     REC84dv.dta, nogenerate
save 2022_re223132_rec42_re516171_rec84dv.dta, replace

use                     2022_rec91_rec0111.dta, clear
merge 1:1 CASEID  using 2022_re223132_rec42_re516171_rec84dv.dta
rename _m merge
save 2022_rec91_rec0111_re223132_rec42_re516171_rec84dv.dta, replace

use 2022_rec91_rec0111_re223132_rec42_re516171_rec84dv.dta, clear


*****PONDERACION
*Generar factor de ponderacion
gen    peso=V005/1000000
label define yesno 0 "no" 1 "yes"
*** Variable INDÍGENA
gen IND=.
replace IND=1 if (S119>=1 & S119<=9)
replace IND=0 if (S119>=10)


*VIOLENCIA PSICOLOGICA Y/O VERBAL EJERCIDA POR EL ESPOSO O COMPAhnERO
*****************************************************************************
*****************************************************************************
*Situaciones humillantes
		gen       dv_prtnr_humil = 0 if V044==1 & v502>0
		replace   dv_prtnr_humil = 1 if D103A>0 & D103A<=3
		label val dv_prtnr_humil yesno
		label var dv_prtnr_humil "Situaciones humillantes"
tab  dv_prtnr_humil [iweight=peso]


*Situaciones de control
//Es celoso o molesto
	gen       dv_prtnr_jeals = 0 if V044==1 & v502>0
	replace   dv_prtnr_jeals = 1 if D101A==1
	label val dv_prtnr_jeals yesno
	label var dv_prtnr_jeals "Es celoso o molesto"
tab dv_prtnr_jeals [iweight=peso]	

//Acusa de ser infiel
	gen       dv_prtnr_accus = 0 if V044==1 & v502>0
	replace   dv_prtnr_accus = 1 if D101B==1
	label val dv_prtnr_accus yesno
	label var dv_prtnr_accus "Acusa de ser infiel"
tab dv_prtnr_accus [iweight=peso]	

//Impide que visite o la visiten sus amistades/familiares
	gen       dv_prtnr_friends = 0 if V044==1 & v502>0
	replace   dv_prtnr_friends = 1 if D101C==1
	replace   dv_prtnr_friends = 1 if D101D==1
	label val dv_prtnr_friends yesno
	label var dv_prtnr_friends	"Impide que visite o la visiten sus amistades/familiares"
tab dv_prtnr_friends [iweight=peso]	

//Insiste en saber donde va
	gen       dv_prtnr_where = 0 if V044==1 & v502>0
	replace   dv_prtnr_where = 1 if D101E==1
	label val dv_prtnr_where yesno
	label var dv_prtnr_where "Insiste en saber donde va"
tab dv_prtnr_where [iweight=peso]	

//Desconfia con el dinero
	gen       dv_prtnr_money = 0 if V044==1 & v502>0
	replace   dv_prtnr_money = 1 if D101F==1
	label val dv_prtnr_money yesno
	label var dv_prtnr_money "Desconfia con el dinero"
tab  dv_prtnr_money [iweight=peso]	

//Algún control
	egen         dv_prtnr_cntrl = rowtotal(dv_prtnr_jeals dv_prtnr_accus dv_prtnr_where dv_prtnr_money dv_prtnr_friends) if V044==1 & v502>0
	recode       dv_prtnr_cntrl  (1/6=1)
	label val    dv_prtnr_cntrl  yesno 
	label var    dv_prtnr_cntrl "Algun control"
tab dv_prtnr_cntrl [iweight=peso]	



*Amenazas
//Amenaza con hacerle dahno
		gen       dv_prtnr_ame1 = 0 if V044==1 & v502>0
		replace   dv_prtnr_ame1 = 1 if D103B>0 & D103B<=3
		label val dv_prtnr_ame1 yesno
		label var dv_prtnr_ame1	"Amenaza con hacerle dahno"
tab dv_prtnr_ame1 [iweight=peso]	

//Amenaza con irse de casa, quitarle hijos, detener ayuda economica 
		gen       dv_prtnr_ame2 = 0 if V044==1 & v502>0
		replace   dv_prtnr_ame2 = 1 if D103D>0 & D103D<=3
		label val dv_prtnr_ame2 yesno
		label var dv_prtnr_ame2	"Amenaza con irse de casa, quitarle hijos, detener ayuda economica"
tab dv_prtnr_ame2 [iweight=peso]	
	

***Total Violencia psico-logica y/o verbal
		gen       dv_prtnr_psi = 0 if V044==1 & v502>0
        replace   dv_prtnr_psi =1 if dv_prtnr_humil == 1 | dv_prtnr_cntrl == 1 | dv_prtnr_ame1 ==1 |  dv_prtnr_ame2 == 1
		label val dv_prtnr_psi yesno
		label var dv_prtnr_psi "Violencia psicologica"
tab  dv_prtnr_psi [iweight=peso]

****CRUZAMOS CON VARIABLE INDÍGENA
tab IND dv_prtnr_psi [iweight=peso], row


//////ALGUN CONTROL EN LOS ULTIMOS 12 MESES
*Situaciones de control
//Es celoso o molesto
	gen       dv_prtnr_jeals_12 = 0 if V044==1 & v502>0
	replace   dv_prtnr_jeals_12= 1 if QI1003AN<3
	label val dv_prtnr_jeals_12 yesno
	label var dv_prtnr_jeals_12 "Es celoso o molesto 1"	

//Acusa de ser infiel
	gen       dv_prtnr_accus_12  = 0 if V044==1 & v502>0
	replace   dv_prtnr_accus_12  = 1 if QI1003BN<3
	label val dv_prtnr_accus_12  yesno
	label var dv_prtnr_accus_12  "Acusa de ser infiel"
tab dv_prtnr_accus [iweight=peso]	

//Impide que visite o la visiten sus amistades y/o familiares
	gen       dv_prtnr_friends_12  = 0 if V044==1 & v502>0
	replace   dv_prtnr_friends_12  = 1 if QI1003CN<3
	replace   dv_prtnr_friends_12  = 1 if QI1003DN<3
	label val dv_prtnr_friends_12  yesno
	label var dv_prtnr_friends_12 	"Impide que visite o la visiten sus amistades/familiares"
	

//Insiste en saber donde va
	gen       dv_prtnr_where_12  = 0 if V044==1 & v502>0
	replace   dv_prtnr_where_12  = 1 if QI1003EN<3
	label val dv_prtnr_where_12  yesno
	label var dv_prtnr_where_12  "Insiste en saber donde va"

//Desconfia con el dinero
	gen       dv_prtnr_money_12  = 0 if V044==1 & v502>0
	replace   dv_prtnr_money_12  = 1 if QI1003FN<3
	label val dv_prtnr_money_12  yesno
	label var dv_prtnr_money_12  "Desconfia con el dinero"

//Algún control: indice de 0 a 1
	egen         dv_prtnr_cntrl_12  = rowtotal(dv_prtnr_jeals dv_prtnr_accus dv_prtnr_where dv_prtnr_money dv_prtnr_friends) if V044==1 & v502>0
	recode       dv_prtnr_cntrl_12   (1/6=1)
	label val    dv_prtnr_cntrl_12   yesno 
	label var    dv_prtnr_cntrl_12  "Algun control"


tab IND  dv_prtnr_cntrl_12 [iweight=peso], row


****EMBARAZO ADOLESCENTE
	gen embadole=0 if V213==0 & V012<20
	replace embadole=1 if (V213==1 & V012<20| V218>=1 & V012<20| V234==1 & V012<20)
	label val embadole  yesno
	label var embadole "Embarazo adolescente"
	
tab  embadole

tab IND embadole [iweight=peso], row  

****EMBARAZO ADOLESCENTE IND DE ACUERDO A LA PNNNA 2030
gen embadole1=0 if V213==0 & V012>14 & V012<18
	replace embadole1=1 if (V213==1 & V012>14 & V012<18| V218>=1 & V012>14 & V012<18| V234==1 & V012>14 & V012<18)
	label val embadole1  yesno
	label var embadole1 "Embarazo adolescente PNNA"
	
tab  embadole1

tab IND embadole1 [iweight=peso], row  

****EMBARAZO ADOLESCENTE IND DE ACUERDO A LA PNNNA 2030
gen embadole2=0 if V213==0 & V012>14 & V012<18
	replace embadole2=1 if (V213==1 & V012>14 & V012<18| V218>=1 & V012>14 & V012<18)
	label val embadole2  yesno
	label var embadole2 "Embarazo adolescente PNNA"
	
tab  embadole2

tab IND embadole2 [iweight=peso], row 

*****Acceso a servicios de conocimiento en SSR

tab IND V384A [iweight=peso], row 

tab IND V384B [iweight=peso], row 

tab IND V384C [iweight=peso], row 
******Uso de método anticonceptivo
tab IND V364 [iweight=peso], row 
****** ETS
tab IND S815AA [iweight=peso], row 
tab IND S815AB [iweight=peso], row 
tab IND S815AC [iweight=peso], row 
tab IND S815AD [iweight=peso], row 
tab IND S815AE [iweight=peso], row 
tab IND S815AX [iweight=peso], row 
tab IND S815AZ [iweight=peso], row 
