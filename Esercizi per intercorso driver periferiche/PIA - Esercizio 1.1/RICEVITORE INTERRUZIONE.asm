*DEFINISCO L-'AREA DATI DEL RICEVITORE, mi devo chiedere cosa deve fare il ricevitore. Ricordiamoci che il ricevitore dovrá avere il meccanismo di interruzione, quindicrico la memoria. quando arriva la interrupt allora la isr acquisice il carattere e lo salva in memoria
	ORG	$8000
MSG	DS.B	6 *Allora sicuramente mi serve definire il messaggio che il ricevitore deve ricevere e con ds riservo lo spazio in memoria. in particolare 6 byte, si vede che ho un vettore di N byte
DIM	DC.B	6 *Definisco un valore DIM in modo da poter contare le N ricezioni che appunto saranno 6, é una const
COUNT	DC.B	0 *Inizializzo un contatore a zero che si incrementerá ogni volta che viene effettuata una ricezione.


*A questo punto definisco l'area MAIN, CHE COSA SUCCEDE? prima cosa si deve inizializzare il tutto
	ORG	$8200
PIADA	EQU	$2004	*indirizzo del porto A della PIA A per i dati, lo stiamo usando in input perché il dato arriverá da fuori
PIACA	EQU	$2005	*indirizzo di del registro di stato/controllo della PIA del ricevitore

MAIN	JSR	INIZIALIZZAPIAA *DOPO AVER localizzaoto gli indirizzi di memoria per andare ad accedere alla pia procedo alla sua subroutine di inizializzaizonie


*UNA VOLTA INIZIALIZZATA E RISOLTASI LA SUBROUTINE COSA FA EFFETIVAMENTE IL RICEVITORE?
*SICURAMENTE SI METTERÁ IN UN SITUAZIONE DI LOOP JUMP LOOP IN CUI RESTERÁ IN ATTESA DELL'INTERRUZIONE
*DOPODICHE LEGGE IL REGISTRO DI STATO, APPLICA UNA MASCHERA E PONE IL LIVELLO DI INTERRUZIONE A 000

*DI BASE STE TRE ISTRUZIONI SPOSTANO SR IN D0, APPLICO LA MASCHERA E POI RITORNA IN SR

	MOVE.W	SR,D0
	ANDI.W	#%D8FF,D0
	MOVE.W	D0,SR


LOOP	JMP	LOOP




*----------------------------------PROCEDO AD INIZIALIZZARE, CIOÉ NON FACCIO ALTRO CHE INIZIALIZARE I REGISTRI CHE HO APPENA ALLOCATO
INIZIALIZZAPIAA	MOVE.B	#0,PIACA *Metto 0 in PIACA perché metto 0 nel registro di controllo cosí che col prosismo accesso in memoria si selezionerá il registro direzione del porto A
	MOVE.B	#$00,PIADA	*Pone DRA=0, sto selezionando le linee di A come input
	MOVE.B	#$00100101,PIACA *vado a programmare il registro di controllo, pongo IRQA1=1 e IRQA2=1, i bit CRA6 e 7 SONO di sola lettura
	RTS

*-----------------------------------ISR, PRIMA COSA DA FARE SEMPRE, IL SALVATAGGIO DEL CONTESTO A CUI CORRISPONDERÁ IL RIPRISTINO DEL CONTESTO AL CONTRARIO
	ORG	$8700
	*SALVATAGGIO DEL CONTESTO
INT3 	MOVE.L	A1,-(A7)
		MOVE.L  A0,-(A7)
		MOVE.L	D0,-(A7)

		MOVEA.L	#PIADA,A1
		MOVEA.L #MSG,A0
		MOVE.B	COUNT,D0

		MOVE.B (A1),(A0,D0) *ISTRUZIONE CHIAVE:ACQUISICE IL CARATTERE E LO TRASFERISCE, DALL ALTRO LATO DI ALZA CBR7

		ADD.B #1,D0
		MOVE.B D0,COUNT


	*RIPRISTINO DEL CONTESTO
		MOVE.L	(A7)+,D0
		MOVE.L  (A7)+,A0
		MOVE.L	(A7)+,A1


*-----------------------------------------------------

	END	MAIN