;;;  Zufallszahlengenerator + CASE-Anweisung + SATISTIK ----
;;;  Zufallszahl in R2 E {0,...,7}
;;;  Statistik in 030h - 038h 
;;;
ZUF8R EQU 0x20        ;ein byte
DIR EQU 0xA0 ; DIRECTION
COUNTER EQU 0x01 ; COUNTER
CSEG At 0H
jmp init
ORG 100H

;-----------MAIN-----------------------------------
init:
    ;jmp init
    MOV 0x81, #1Bh
    MOV COUNTER, #08h
    call loaddata
    MOV R0, #00000001b
    MOV R1, #00000010b
    MOV R2, #00000001b
    MOV R3, #00000001b
    MOV R4, #00000000b
    MOV R5, #00000000b
    MOV R6, #00000000b
    MOV R7, #00000000b
    call loaddata2
    MOV R0, #00000000b
    MOV R1, #00000000b
    MOV R2, #00000000b
    MOV R3, #00000000b
    MOV R4, #00000000b
    MOV R5, #00000000b
    MOV R6, #00000000b
    MOV R7, #00000000b

    call loadstandard
    ; DIR 0 = RECHTS, DIR 1 = LINKS, DIR 2 = OBEN, DIR 3 = UNTEN
    MOV DIR, #00h

; Die Dauerschleife geht eine Reihe durc
dauerschleife:
   call loadstandard
   CJNE @R1, #00h, drawField
   MOV A, @R1
   ; WERT == NULL : reset
   MOV COUNTER, #08h
   call moveDir
   call moveall
   jmp dauerschleife

drawField:
   call KOMPLEMENT
   MOV P0, @R1
   call komplement
   INC counter
   call KOMPLEMENT
   MOV P1, @R1
   call komplement
   INC counter

   JMP DAUERSCHLEIFE

moveDir:
   call loaddata
   MOV R3, DIR
   CJNE R3, #00h, left
    ; Move to right
    MOV A, R1
    RL A
    MOV R1, A
    ret
left:
   CJNE R3, #01h, up
   ; Move to left
   MOV A, R1
   RR A
   MOV R1, A
   ret
up:
   CJNE R3, #02h, down
   ; Move up
   MOV A, R0
   RL A
   MOV R0, A
   ret
down:
   ; Move down
   MOV A,R0
   RR A
   MOV R0, A
   ret
moveAll:
   call loadmoveall
   MOV R0,#09h

loop:
   cjne @R0, #00h, findLastUsedRegister
   DEC R0
   DEC R0
loopend:
; CHECK EINBAUEN FALLS SCHLANGE LÄNGE 1 HAT!


movereg:
   cjne R0, #009h, moveregisterforward
   ret

findLastUsedRegister:
   cjne R0, #017h, inc
   jmp loopend
inc:
   INC R0
   INC R0
   jmp loop
moveRegisterForward:
   MOV A, R0
   DEC A 
   DEC A
   MOV R1, A
   MOV A, @R1
   MOV @R0, A

   DEC R0
   
   MOV A, R0
   DEC A 
   DEC A
   MOV R1, A
   MOV A, @R1
   MOV @R0, A

   DEC R0
   
   jmp movereg
KOMPLEMENT:
    MOV A, @R1
    CPL A
    MOV @R1, A
    ret
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
         ;MOV    R0, #2fh   ;Speichere die Zahlenreihe oberhalb 30h
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

LOADSTANDARD:
    CLR RS0
    CLR RS1
    ret
LOADMOVEALL:
    SETB RS0
    SETB RS1
    ret
LOADDATA:
    SETB RS0
    CLR RS1
    ret
LOADDATA2:
    SETB RS1
    CLR RS0
    ret

;-----------GENERIER EINE ZUFALLSZAHL----------
    ; call ZUFALL         ;Zufallszahl A bestimmen zwischen 00h und ffh
;----------- CASE-ANWEISUNG-------------------------
         mov R2,#00h        ;Zähler initialisieren mit 0 
neu:     add A,#020h        ;die Zufallszahl plus 32 
         inc R2            ;Zähler um 1 erhöhen
     jnc neu           ;falls schon Überlauf, dann weiter - sonst  addiere 32

     mov A, R2          ;schreib Zahl in A
END
;--------Kontrolle/Statistik------------
        cjne A,#01h, keine1
        inc 0x30
        jmp ANF
