'Box-Jenkins including Diebold-Mariano
'**********************************************

'*************************
'Importing data
'*************************
close arma.wf1
close all

cd T:\ECO2

wfcreate(wf=arma,page=datos) q 1950q2 2013q4
read(b2,s=base) datos.xls 1


'series dlogpe=d(logpe)   ' cambiar la serie a analizar
series zserie=y
'********************************


'Box-Jenkins
'***************
'1. Transformacion
'*********************
'a) Analizar el grafico
zserie.line

'b) Identificacion
freeze(correlogram) zserie.correl

'c) Estimacion y prediccion
equation eq1.ls zserie  zserie(-1) c
equation eq2.ls zserie  zserie(-1) zserie(-2) c
equation eq3.ls zserie  zserie(-1) zserie(-2) zserie(-3) c
equation eq4.ls zserie  zserie(-1) zserie(-2) zserie(-3)  zserie(-4) c
equation eq5.ls zserie  ma(1) c
equation eq6.ls zserie  ma(1) ma(2) c
equation eq7.ls zserie  ma(1) ma(2) ma(3) c
equation eq8.ls zserie  ma(1) ma(2) ma(3) ma(4) c
equation eq9.ls zserie  zserie(-1) ma(1) c
equation eq10.ls zserie   zserie(-1) zserie(-2)  zserie(-3)  zserie(-4) ma(1) ma(2) ma(3) ma(4) c

for !h=1 to 10
	eq!h.makeresids residual!h
	scalar r2_eq!h=eq!h.@r2
	scalar r2a_eq!h=eq!h.@rbar2
	scalar sic_eq!h=eq!h.@schwarz
	scalar aic_eq!h=eq!h.@aic
	scalar hq_eq!h=eq!h.@hq

next

scalar z_auto_x 
d z_*
for !h=1 to 10
	'Breusch-Godfrey
	freeze(z_auto_{!h}_1) eq!h.auto(1)
	freeze(z_auto_{!h}_2) eq!h.auto(2)
	scalar z_auto_{!h}_p1=@val(@str(z_auto_!h_1(4,5)))	
	scalar z_auto_{!h}_p2=@val(@str(z_auto_!h_2(4,5)))
	'White and ARCH
	freeze(z_white_{!h}_1) eq!h.white
	freeze(z_white_{!h}_2) eq!h.archtest(1)
	scalar z_white_{!h}_p1=@val(@str(z_white_!h_1(3,5)))	
	scalar z_white_{!h}_p2=@val(@str(z_white_!h_2(4,5)))

	'Jarque-Bera
	freeze(z_normal_{!h}) residual!h.stats
	scalar z_normal_{!h}_p1=@val(@str(z_normal_{!h}(14,2)))
	scalar z_normal_{!h}_p2=@val(@str(z_normal_{!h}(15,2)))
	'In-sample Forecasts
	smpl @first+5 @last
	freeze(z_fit_{!h}) eq!h.fit(e)	z_y!h_f
	scalar z_fit_{!h}_p1=@val(@str(z_fit_{!h}(6,2)))	
	scalar z_fit_{!h}_p2=@val(@str(z_fit_{!h}(9,2)))	
	smpl @all
next

'Table: Diagnosis
'**************************
scalar armasx
d armas*
table(8,3) armas
armas(1,1)= "Estimación y Diagnóstico de Modelos ARMA"
armas(4,1)= "Estimates and p-values"
armas(21,1)= "Serial correlation"
armas(22,1)= "Breusch-Godfrey LM (1)"
armas(23,1)= "Breusch-Godfrey LM (2)"
armas(24,1)= "Heteroskedasticity"
armas(25,1)= "White test with no-cross terms"
armas(26,1)= "ARCH test (1)"
armas(27,1)= "Normality"
armas(28,1)= "Jarque-Bera"
armas(29,1)= "probability"
armas(30,1)= "Goodness of Fit"
armas(31,1)= "R2"
armas(32,1)= "Adjusted-R2"
armas(33,1)= "Akaike"
armas(34,1)= "Schwarz"
armas(35,1)= "Hannan-Quinn"
armas(36,1)= "Forecast performance"
armas(37,1)= "Root Mean Squared Error"
armas(38,1)= "Theil coefficient"

armas(5,1)= "Y(-1)"
armas(7,1)= "Y(-2)"
armas(9,1)= "Y(-3)"
armas(11,1)= "Y(-4)"
armas(13,1)= "MA(1)"
armas(15,1)= "MA(2)"
armas(17,1)= "MA(3)"
armas(19,1)= "MA(4)"

for !h=1 to 10
	armas(3,!h+1) ="M"+@str(!h)

	setcell(armas,22,!h+1,z_auto_{!h}_p1,3)
	setcell(armas,23,!h+1,z_auto_{!h}_p2,3)
	setcell(armas,25,!h+1,z_white_{!h}_p1,3)
	setcell(armas,26,!h+1,z_white_{!h}_p2,3)
	setcell(armas,28,!h+1,z_normal_{!h}_p1,3)
	setcell(armas,29,!h+1,z_normal_{!h}_p2,3)

	setcell(armas,31,!h+1,r2_eq{!h},3)
	setcell(armas,32,!h+1,r2a_eq{!h},3)
	setcell(armas,33,!h+1,aic_eq{!h},3)
	setcell(armas,34,!h+1,sic_eq{!h},3)
	setcell(armas,35,!h+1,hq_eq{!h},3)

	setcell(armas,37,!h+1, z_fit_{!h}_p1,3)
	setcell(armas,38,!h+1, z_fit_{!h}_p2,3)
next

'Estimates and se

	setcell(armas,5,2,eq1.@coefs(1),2)
	setcell(armas,6,2,eq1.@stderrs(1),2)

	setcell(armas,5,3,eq2.@coefs(1),2)
	setcell(armas,6,3,eq2.@stderrs(1),2)
	setcell(armas,7,3,eq2.@coefs(2),2)
	setcell(armas,8,3,eq2.@stderrs(2),2)

	setcell(armas,5,4,eq3.@coefs(1),2)
	setcell(armas,6,4,eq3.@stderrs(1),2)
	setcell(armas,7,4,eq3.@coefs(2),2)
	setcell(armas,8,4,eq3.@stderrs(2),2)
	setcell(armas,9,4,eq3.@coefs(3),2)
	setcell(armas,10,4,eq3.@stderrs(3),2)

	setcell(armas,5,5,eq4.@coefs(1),2)
	setcell(armas,6,5,eq4.@stderrs(1),2)
	setcell(armas,7,5,eq4.@coefs(2),2)
	setcell(armas,8,5,eq4.@stderrs(2),2)
	setcell(armas,9,5,eq4.@coefs(3),2)
	setcell(armas,10,5,eq4.@stderrs(3),2)
	setcell(armas,11,5,eq4.@coefs(4),2)
	setcell(armas,12,5,eq4.@stderrs(4),2)

	setcell(armas,13,6,eq5.@coefs(2),2)
	setcell(armas,14,6,eq5.@stderrs(2),2)

	setcell(armas,13,7,eq6.@coefs(2),2)
	setcell(armas,14,7,eq6.@stderrs(2),2)
	setcell(armas,15,7,eq6.@coefs(3),2)
	setcell(armas,16,7,eq6.@stderrs(3),2)

	setcell(armas,13,8,eq7.@coefs(2),2)
	setcell(armas,14,8,eq7.@stderrs(2),2)
	setcell(armas,15,8,eq7.@coefs(3),2)
	setcell(armas,16,8,eq7.@stderrs(3),2)
	setcell(armas,17,8,eq7.@coefs(4),2)
	setcell(armas,18,8,eq7.@stderrs(4),2)

	setcell(armas,13,9,eq8.@coefs(2),2)
	setcell(armas,14,9,eq8.@stderrs(2),2)
	setcell(armas,15,9,eq8.@coefs(3),2)
	setcell(armas,16,9,eq8.@stderrs(3),2)
	setcell(armas,17,9,eq8.@coefs(4),2)
	setcell(armas,18,9,eq8.@stderrs(4),2)
	setcell(armas,19,9,eq8.@coefs(5),2)
	setcell(armas,20,9,eq8.@stderrs(5),2)

	setcell(armas,5,10,eq9.@coefs(1),2)
	setcell(armas,6,10,eq9.@stderrs(1),2)
'	setcell(armas,7,10,eq9.@coefs(2),2)
'	setcell(armas,8,10,eq9.@stderrs(2),2)
	setcell(armas,13,10,eq9.@coefs(3),2)
	setcell(armas,14,10,eq9.@stderrs(3),2)
'	setcell(armas,15,10,eq9.@coefs(2),2)
'	setcell(armas,16,10,eq9.@stderrs(2),2)


	setcell(armas,5,11,eq10.@coefs(1),2)
	setcell(armas,6,11,eq10.@stderrs(1),2)
	setcell(armas,7,11,eq10.@coefs(2),2)
	setcell(armas,8,11,eq10.@stderrs(2),2)
	setcell(armas,9,11,eq10.@coefs(3),2)
	setcell(armas,10,11,eq10.@stderrs(3),2)
	setcell(armas,11,11,eq10.@coefs(4),2)
	setcell(armas,12,11,eq10.@stderrs(4),2)
	setcell(armas,13,11,eq10.@coefs(6),2)
	setcell(armas,14,11,eq10.@stderrs(6),2)
	setcell(armas,15,11,eq10.@coefs(7),2)
	setcell(armas,16,11,eq10.@stderrs(7),2)
	setcell(armas,17,11,eq10.@coefs(8),2)
	setcell(armas,18,11,eq10.@stderrs(8),2)
	setcell(armas,19,11,eq10.@coefs(9),2)
	setcell(armas,20,11,eq10.@stderrs(9),2)

'Formats
armas.setjust(21,A,38,A) left
armas.setwidth(1) 25

armas.setlines(a22:k23) +a -h -v
armas.setlines(a25:k26) +a -h -v
armas.setlines(a28:k29) +a -h -v
armas.setlines(a5:k20) +a -h -v

armas.setlines(a4:k4) +a -h -v
armas.setlines(a21:k21) +a -h -v
armas.setlines(a24:k24) +a -h -v
armas.setlines(a27:k27) +a -h -v
armas.setlines(a30:k30) +a -h -v
armas.setlines(a31:k35) +a -h -v
armas.setlines(a36:k36) +a -h -v
armas.setlines(a37:k38) +a -h -v

show armas

d z_* hq_* r2* aic* sic* residual*


