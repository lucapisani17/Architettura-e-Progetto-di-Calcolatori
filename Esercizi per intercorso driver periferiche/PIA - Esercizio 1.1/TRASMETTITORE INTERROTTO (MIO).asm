TESTING: TRASMETTITORE IN INTERRUZIONE

	ORG	$8000
MSG	DC.B	1,2,3,4,5,6
DIM	DC.B	6
COUNT DC.B 0

	ORG $8200
PIADB	EQU	$2006
PIACB	EQU $2007

MAIN	JSR	INIZIALIZZAPIAB

	MOVEA.L #PIACB,A1
	MOVEA.L #PIADB,A2
	MOVEA.L #MSG,A0
	


	MOVE.B	SR,D0
	ADDI.B #$D8FF,D0
	MOVE.B	D0,SR
	
PRIMOINVIO	MOVE.B (A2),D1	*FITTIZIA
	MOVE.B(A0),(A2)
	MOVE.B #1,COUNT
	

LOOP	JMP	LOOP


*-----------------------------------------ROUTINE DI INIZIALIZZAZIONE DI PIAB

INIZIALIZZAPIAB 	MOVE.B #0,PIACB
	MOVE.B	#FF,PIADB
	MOVE.B	#$00100101, PIACB
	RTS

*----------------------------------------------ISR

	ORG	$8700
INT4	MOVEA.L A1,-(A7)
		MOVEA.L A0,-(A7)
		MOVE.L	D0,-(A7)
		MOVEA.L D1,-(A7)
		MOVEA.L D2,-(A7)
		
		CLR D1
		CLR D2
		
		MOVE.L #PIADB,A1
		MOVE.L #MSG,A0
		MOVE.B	COUNT,D1
		MOVE.B	DIM,D0
		
		CMP	D1,D0
		BNE	ESCI
		
INVIO	MOVE.B (A1),D2 *LETTURA FITTIZIA
		MOVE.B (A0,D1),(A2)
		ADDI #1,D1
		MOVE.B D1,COUNT
		
ESCI	MOVEA.L (A7)+,D2
		MOVEA.L (A7)+,D1
		MOVEB.L	(A7)+,D0
		MOVEA.L	(A7)+,A0
		MOVEA.L	(A7)+,A1
		
		
		RTS