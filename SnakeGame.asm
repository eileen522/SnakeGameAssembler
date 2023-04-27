;;;  Zufallszahlengenerator + CASE-Anweisung + SATISTIK ----
;;;  Zufallszahl in R2 E {0,...,7}
;;;  Statistik in 030h - 038h 
;;;
ZUF8R EQU 0x20		;ein byte
CSEG At 0H
jmp init
ORG 100H

;-----------MAIN-----------------------------------
init:
	;jmp init
	MOV R1, #00000011b
	MOV R2, #00000001b
startroutine:
	call MOVERIGHT
	call MOVERIGHT
	call MOVERIGHT
	call MOVERIGHT
	call MOVERIGHT
	call MOVEDOWN
	call MOVEDOWN
	call MOVEDOWN
	jmp startroutine
	
	
	
	;MOV R1, #02H
	;MOV R2, #01H
	;call KOMPLEMENT

	;MOV R1, #04H
	;MOV R2, #01H
	;call KOMPLEMENT
	
	 ;jmp init
         ;MOV	R0, #2fh   ;Speichere die Zahlenreihe oberhalb 30h
ANF:

MOVERIGHT:
	MOV A, R1
	RL A
	MOV R1, A
	call KOMPLEMENT
	ret

MOVELEFT:
	MOV A, R1
	RR A
	MOV R1, A
	call KOMPLEMENT
	ret

MOVEUP:
	MOV A, R2
	RR A
	MOV R2, A
	call KOMPLEMENT
	ret

MOVEDOWN:
	MOV A, R2
	RL A
	MOV R2, A
	call KOMPLEMENT
	ret

KOMPLEMENT:
	MOV A, R1
	CPL A
	MOV P0, A
	MOV A, R2
	CPL A
	MOV P1, A
	ret
;-----------GENERIER EINE ZUFALLSZAHL----------
	; call ZUFALL         ;Zufallszahl A bestimmen zwischen 00h und ffh
;----------- CASE-ANWEISUNG-------------------------
         mov R2,#00h        ;Zähler initialisieren mit 0 
neu:	 add A,#020h        ;die Zufallszahl plus 32 
         inc R2            ;Zähler um 1 erhöhen
	 jnc neu           ;falls schon Überlauf, dann weiter - sonst  addiere 32
	
	 mov A, R2          ;schreib Zahl in A
END
;--------Kontrolle/Statistik------------
        cjne A,#01h, keine1
        inc 0x30
        jmp ANF 
