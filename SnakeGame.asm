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
; ALLE BEFEHLE FINDET MAN HIER: https://moodle.dhbw.de/pluginfile.php/270544/mod_resource/content/1/Befehlssatz8051.pdf
    ;jmp init
    ; Verschieben des StackPointers, damit mehrere RegisterSets(RS) benutzt werden können und nicht kollidieren.
    MOV 0x81, #1Bh
    ; Counter ist das Register 1
    MOV COUNTER, #08h

    ; Wechseln  in das Register Set 1
    ; Im Register Set 1 werdne durch die Register 0 bis 7 die ersten 4 Punkte (länge) der Schlange dargestellt.
    call loaddata
    ; R0 und R1 im Register Set 1 sind der Kopf der Schlange. (Quasi x und y Koordinate) Dem Schlangen Kopf wird eine Position gesetzt.
    MOV R0, #00000001b
    MOV R1, #00000010b
    ; Zu Test zwekcken wird dem zweiten Teil der Schlange auch noch werte gesetzt
    MOV R2, #00000001b
    MOV R3, #00000001b
    ; Die Restlichen 2 Punkte der Schlange werden auf aus(also alles 0) gesetzt
    MOV R4, #00000000b
    MOV R5, #00000000b
    MOV R6, #00000000b
    MOV R7, #00000000b

    ; Da die Überlegung war, die Schlange bis zu 8 Punkte lang werden zu lassen, wird ein weitere Register Set benötigt, da im ersten nur 4 Punkte
    ; dagestellt werden können. Mit loaddata2 wird das Register Set 2 geladen.
    call loaddata2
    ; R0 und R1 im RegisterSet 2 sind quasi x und y des 5ten Punktes, R2 und R3 des 6ten etc.
    ; Theoretisch könnte man auch sagen das die Schlange nur 4 Groß werden kann und man könnte auf das 2te RS verzichten.
    ; Unten in der Anzeige der Register sieht man auch mit RS1 und RS0 in welchem Register Set man sich grade befindet. Sind beide rot (also beide auf 0)
    ; ist man im Register Set 0. Ist RS0 Grün und RS1 rot ist man im Register set 1 ist RS0 rot und RS1 grün ist man im Register Set 2. sind beide Grün ist man im
    ; Register Set 3. Somit stehen einem also nicht nur 8 Register zu Verfügung sondern durch die 4 RegisterSets insgesammt 4 * 8 also 32 Register um Daten zu speichern.
    
    MOV R0, #00000000b
    MOV R1, #00000000b
    MOV R2, #00000000b
    MOV R3, #00000000b
    MOV R4, #00000000b
    MOV R5, #00000000b
    MOV R6, #00000000b
    MOV R7, #00000000b
   ; Laden des Register Sets 0. Hier werden allgemeine Daten gespeichert, wie zum Beispiel die Richtung in die sich die Schlange bewegen soll.
    call loadstandard
    
    ; DIR 0 = RECHTS, DIR 1 = LINKS, DIR 2 = OBEN, DIR 3 = UNTEN
    ; Standardmäßig bewegt sich die Schlange erstmal nach Rechts, deswegen wird 0 geladen. DIR ist auf Port 2 gesezt, dies bedeutet, dass man über den Port2 während das Programm läuft die Richtung ändern kann.
    MOV DIR, #00h

; Die Dauerschleife geht immer wieder durch und führt alle nötigen Aktionen durch, wie zum Beispiel das aktuelle Feld anzeigen oder die Schlange zu bewegen
dauerschleife:
; Siehe Kommentar loadstandard oben
   call loadstandard
   ; Das @ Symbol kann nur vor Register 0 oder 1 gesetzt werden. Mit diesem wird NICHT Register 0/1 angesprochen sondern das Register Welches als wert in diesem Steht. Beispiel: Register 1 wurde oben bei MOV Counter auf 8 gesetzt. 8 ist das Register 0 im RegisterSet 1 (wenn die Rakete gedrückt wurde und das Programm läuft, kann man RS0 und RS1 anklicken, um zwischen den RegisterSets zu wechseln. Hovert man über die Register steht da welche Speicher Stelle die haben, also Register 0 im RS 1 z.B. 8. Das Register 0 im RS 0 hat den Wert 0.)
; Dadurch, dass R1 den Wert 8 hat, wird mit dem @ Symbol auf das Register 0 gezeigt von RS 1. Wird R1 auf 9 gesetzt, würde  @R1 auf Register 1 im RS 1 zeigen.
; CJNE  bedeuter, dass zu drawField gesprungen wird, wenn der Wert durch das Indirekt addressierte Register über @R1 NICHT 0 ist.
   CJNE @R1, #00h, drawField
   ; Ansonsten wird in den Akku der Wert welcher in dem indirekte addressierte Register steht geladen (also ganz am Anfang immer noch Der Wert der in Register 0 im RS 1 steht.)
   MOV A, @R1
   ; WERT == NULL : Counter wird reset
   
   MOV COUNTER, #08h
   ; Hier wird der Kopf der Schlange in die aktuell ausgewählte Richtung bewegt
   call moveDir

   ; @EILEEN! Wichtige Zeile die auskommentiert wurde, weil es noch nicht funktioniert. Hier soll quasi die ganze schlange von hinten eins nachrücken.
   ; Um es einfacher zu machen versuche die Komplette schlange zu bewegen, selbst wenn die Länge der Schlange nur 1 ist. Also quasi davon ausgehen als ob die Schlange 8 lang ist. Im endeffekt passiert dann ja auch nichts weil du den Wert 0 weitergibst und somit nichts aktivierst.
   ; Das Ende der Schlange ist das Register 7 und 6 im RegisterSet 2 (also call loaddata2). Gehe die Register von Hinten nach vorne durch. Setzte dem Register 7 (also der x koordinate von der Länge 8) den Wert von R5 und R6 den Wert von R4. Dann R5 den wert von R3 und R4 den Wert von R2 etc. bist du mit dem RegisterSet fertig, wechsel ins RegisterSet 1 also call loaddata. und mache dort das gleiche. Du siehst, das sieht schon schleifen mäßig aus. Du könntest im Optimal Fall dir mit Sprüngen einen basteln. und um nicht alle 16 Register per hand durchzugehen kannst du die indirekte addressierung nutzen (also @R0 oder @R1). Da die Register set 0 bis 2 viel in benutztung sind, nutze R0, R1 von Register set 3  (dahin kannst du wechseln mit call LOADMOVEALL). Du Könntest das Register R0 z.B. mit 19 laden (grade nicht sicher, aber das müsste dann auf den vorletzten Teil der Schlange zeigen bzw auf die x Koordinate davon. Kannst du ja nochmal nachauen welchen Wert das Register genau hat). Auf jeden Fall kannst du dann mit @R0 die X Koordinate ansprechen. in R1 könntest du 21 laden damit dieser auf die X Koordinate des letzten Teils zeigt. Dann könntest du (wahr. musst du das über den Akku machen) den Wert von @R0 in das indirekt addressierte Register durhc @R1 laden. Dannach den Wert von R0 und R1 um 1 decrementieren damit diese auf die jeweiligen y koordinaten zeigen. Usw. bis du alle durch bist, also quasi bis R0 den Wert 8 hat, und den aktuellen Kopf der Schlange in den zweiten Teil der Schlange schiebt.
   ;call moveall
   jmp dauerschleife

; Hier wird das Feld gemalt, da muss nichts gemacht werden, obwohl ich mir nicht mehr sicher bin über den eigentliuchen sinn vom Counter, kann sein das ich da nochmal was machen muss
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
; Hier wird für den Kopf der Schlange ein neuer Wert geladen, abhängig von der Aktuellen Position des Kopfes und der angegebenen Richtuing in Port 2.
; Es wird erst geschaut ob die richtung auf Rechts schaut, wenn nicht wird geschaut ob die richtung nach links zeigt, wenn das nicht dann nach oben und abschließend ob die richtung nach unten zeigt. d.H. wenn die Richtung auf unten eingestellt ist, werden 3 checks vorher gemacht. Sollte aber keinen EInfluss auf performance haben.
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

; @Eileen hier deinen Code reinschreiben. Ich hab mal meinen Code noch drinn gelassen falls du da irgendwas von abschauen willst aber wahr. kannst du alles löschen bis zu KOMPLEMENT (also moveAll, loop, loopend, movereg, findLastUsedRegister, inc und moveRegisterForward) kann weg. Ich hatte ja auch probiert die Länge zu berechnen, um nicht immer alle 16 Register durchzugehen wenn die schlange z.B. nur aus 4 Registern besteht. Aber da hat was nicht funktioniert von daher vielleichnt weg machen
moveAll:
   call loadmoveall
   MOV R0,#09h

loop:
   cjne @R0, #00h, findLastUsedRegister
   DEC R0
   DEC R0
loopend:



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
