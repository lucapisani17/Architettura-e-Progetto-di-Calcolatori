*----------TESTING INTERCORSO
*-----AREA DATI

	ORG	$8000
DIM		DS.B	5
MSGA	DS.B	5
MSGB	DS.B	5
PRECEDENZA	DC.B	0
CONTEGGIO	DC.B	3
CHARRICEVUTIA	DC.B	0
CHARRICEVUTIB	DC.B	0

*AREA MAIN

	ORG	$8200

PIADA	EQU	$2004
PIACA	EQU $2005
USARTD	EQU $2006
USARTC	EQU	$2007

MAIN	JMP	INIZIALIZZAPIA
		JMP INIZIALIZAUSART
		
*ATTIVO LE INTERRUZIONI

		MOVE.W	SR,D0
		ANDI.W	#$D8FF,D0
		MOVE.W	D0,SR

		
		MOVEA.L	#PIADA,A1
		MOVEA.L	#USARTD,A2
		MOVEA.L #USARTC,A3
		MOVEA.L	#DIM,A0
		MOVE.B	PRECEDENZA,D0
		MOVE.B	CONTEGGIO,D1
		
		CMP D0,D1
		BEQ PRIMOB
		
*LEGGO IL PRIMO CARATTERE DA A
		
LEGGIA	MOVE.L	(A1),D2
		MOVE.L	D2,(A0)
		ADDI	#1,D0
		MOVE.B	D0,PRECEDENZA
		
LOOP 	JMP		LOOP

		CMP		D0,D1
		BNE		LEGGIA

*LEGGO IL PRIMO CARATTERE DA B

PRIMOB	MOVE.L	(A2),D2
		MOVE.L	D2,(A0)
		ADDI	#1,D0
		MOVE.B	D0,PRECEDENZA

CHECKDSR	MOVE.B	(A3),D3
			ANDI.B	#$80,D3
			BEQ		CHECKDSR
			
			
LOOP	JMP		LOOP
		
		CMP		D0,D1
		BEQ		LEGGIA



*INIZIALIZZAZIONE DELLA PIA IN RICEZIONE --- PORTO A

INIZIALIZZAPIA	MOVE.B	#0,PIACA
				MOVE.B	#$00,PIADA
				MOVE.B	#%00100101,PIACA
				RTS

*INIZIALIZZAZIONE DELLA USART IN RICEZIONE 

INIZIALIZZAUSART	MOVE.B	#%01011101,USARTC
					MOVE.B	#%00110110,USARTC
					RTS
					
					
					
*INTERRUZIONE SISTEMA A - PIA

		ORG	$8700
		ORI.W	#$0700,SR	*MASCHERA PER EVITARE CHE LA INTERRUPT 4 INTERROMPA CONTINUAMENTE
INT3	MOVE.L	A0,-(A7)
		MOVE.L 	A1,-(A7)
		MOVE.L 	D0,-(A7)
		
		MOVEA.L #PIADA,A1
		MOVEA.L #MSGA,A0
		MOVEA.L #CHARRICEVUTI,D0
		
		MOVE.L	(A1),D1
		MOVE.L 	D1,(A0,D0)
		ADD.B	#1,D0
		MOVE.B 	D0,CHARRICEVUTIA
		
		MOVE.L 	(A7)+,D0
		MOVE.L	(A7)+,A1
		MOVE.L	(A7)+,A0
		
		RTE
		
*INTERRUZIONE SISTEMA B - USART 

		ORG	$8800
		ORI.W	#$0700,SR	*MASCHERA PER EVITARE CHE LA INTERRUPT 3 INTERROMPA CONTINUAMENTE
INT4	MOVE.L	A1,-(A7)
		MOVE.L	A0,-(A7)
		MOVE.L	D0,-(A7)

		MOVEA.L	#USARTD,A1
		MOVEA.L #MSGB,A0
		MOVE.B CHARRICEVUTIB,D0
		
		MOVE.L	(A1),D1
		MOVE.L	D1,(A0,D0)
		ADD.B	#1,D0
		MOVE.B	D0,CHARRICEVUTIB
		
		MOVE.L 	(A7)+,D0
		MOVE.L 	(A7)+,A0
		MOVE.L 	(A7)+,A1
		
		RTE
		
		END	MAIN