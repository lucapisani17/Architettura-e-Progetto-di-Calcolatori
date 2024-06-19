*DEFINISCO L-'AREA DATI DEL TRASMETTITORE. Mi devo chiedere cosa deve fare il trasmettirtore
	ORG	$8000
MSG	DC.B	1,2,3,4,5,6 *Dal lato trasmettitore vado a definire il mio messaggio non come spazio destinato ad accoglierlo ma effettivamente come costanti da inviare
DIM	DC.B	6


*A questo punto definisco l'area MAIN
	ORG	$8200
PIADB	EQU	$2006
PIACB	EQU	$2007

MAIN	JSR	INIZIALIZZAPIAB

*UNA VOLTA INIZIALIZZATA E RISOLTASI LA SUBROUTINE COSA FA EFFETIVAMENTE IL RICEVITORE?
*VISTO CHE STIAMO PROGRAMMANDO IL LATO TRAMSETTITORE IN POLLING DOBBIAMO FARE ATTENZIONE
*PRIMA COSA MI SPOSTO GLI INDIRIZZI DEI REGISTRI PIACB E PIACB NEI REGISTRI INTERNI DEL PROCESSORE, INSIEME A QUELLO DELL'AREA MESSAGGIO E ALLA DIM

	MOVEA.L	#PIACB,A1 *INDIRIZZO REGISTRO DI CONTROLLO CRB
	MOVEA.L #PIADB,A2
	MOVEA.L #MSG,A0
	MOVE.B	DIM,D0 *NON USO MOVEA PERCHÉ STO SPOSTANDO UNA COSTANTE IN UN REGISTRO DATO
	
	CLR D1
	CLR D2 *PULISCO DUE REGISTRI DI APPOGGIO, IN D2 ANDRÓ A CONTARE GLI ELEMENTI TRASMESSI
	
*ANDIAMO A GESTIRE LA FASE DI INVIO

INVIO	MOVE.B (A2),D1 *LETTURA FITTIZIA PER AZZERARE CRB7
		MOVE.B	(A0)+,(A2) *SPOSTO EFFETTIVAMENTE IL PRIMO DATO DA TRASMETTERE SUL BUS DEL PORTO B. SI ABBASSA CB2, SI ABBASSA CA1 DI LA CHE GENERA UNA INTERRUZIONE
		ADD.B	#1,D2 *INCREMENTO IL CONTATORE DEGLI ELEMENTI TRASMESSI

*A QUESTO PUNTO DEVO FARE IL CICLO DI POLLING, RESTO IN ATTESA DI DATA ACKOWLEDGE, ASPETTO CHE CRB7 DIVENTI 1 ED ESCO DAL CICLO SOLO QUANDO CIÓ SI VERIFICA
CICLO	MOVE.B (A1),D1
		ANDI.B #$80,D1
		BEQ		CICLO

*INFINE CONTROLLO SE HO FINITO DI TRASMETTERE CORRETTAMENTE
		CMP	D2,D0 *STO CONTROLLANDO SE IL MIO VALORE DEL CONTEGGIO É PARI A DIM
		BNE INVIO *IN CASO NEGATIVO TORNA A INVIO ALTRIMENTI CONTINUA

LOOP JMP LOOP


*-------------------Inizializzazione della PIAB, PERFETTO
INIZIALIZZAPIAB 	MOVE.B	#0,PIACB
	MOVE.B	#FF,PIADB
	MOVE.B	#$00100100,PIACB
	RTS

*-----------------------------------------------------

	END	MAIN