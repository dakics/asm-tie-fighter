
; =====================================================================
;
;   Tie Fighter
;   Srdjan Dakic
;   January 1997
;
;   WINNER in "256 bytes" compo at YALP '97  (Belgrade, RS)
;
;   Globals:
;
;   BL register - X coordinate of the invaders
;   BH register - X coordinate of the player
;   BP register - screen coordinate of the missile
;   SI register - screen coordinate of the invader bomb
;   ES register - video memory text segment (B800)
;
;   Assumes that all general purpose registers (AX,BX,CX,DX,SI,DI)
;   are zero at DOS prompt start.
;
; =====================================================================

.MODEL TINY
.CODE
.286
ORG 100H

Start:
	xor   bp, bp						; BP is not always 0 at start
	push  0B800H
	pop   es						; ES := B800

Game:
	push si							; save bomb coordinate
	push bx							; save invader and player coordinates

	; ------------------- DRAW INVADERS -------------------

	mov  di, bx						; start from BL/2 position

	mov  bh, 0AH						; but first,
	call Paint						; paint the screen light green

	and  di, 00111110b
	lea  bx, Aliens

DrawFormation:
	mov  dx, 8

DrawRow:
	lea  si, AlienShip
	ror  byte ptr [bx], 1
	sbb  ah, ah
	and  ah, 13
	mov  cl, 5

DrawAlien:
	lodsb							; read char
	stosw							; write char and color
	loop DrawAlien

	dec  dx							; is the entire row of the formation drawn?
	jnz  DrawRow

	add  di, 240
	inc  bx
	cmp  bl, low offset Aliens[4]
	jne  DrawFormation
	pop  bx

	; -------------------- DRAW PLAYER --------------------

	mov  ah, 0FH
	mov  al, bh
	mov  di, ax
	mov  cl, 5

DrawPlayer:
	lodsb
	stosw
	loop DrawPlayer
	
	; ------------------- MOVE INVADERS -------------------

	lodsb
	add  bl, al
	xor  bl, 00111111b
	jz   AlienMoveDone

ChangeMove:
	neg byte ptr [si-1]

AlienMoveDone:

	; ---------------- DRAW ROCKET AND BOMB ---------------

	mov  di, bp
	movsb
	pop  si
	mov  byte ptr es:[si], 'V'

	; ----------------- ROCKET SOUND FX  ------------------

	mov  ch, 12H
	mov  ax, bp

Sound:
	ror  al, 1
	out  61H, al
	loop Sound

	; ---------------- MOVE PLAYER ROCKET -----------------

	mov  dl, 160
	mov  cl, 10

MovePlayerMissile:
	div  dl
	cmp  al, 8
	jae  MovePMissile

	push ax
	shr  al, 1
	cbw
	mov  di, ax
	pop  ax
	sub  ah, bl
	shr  ax, 8
	div  cl
	cmp  al, 7
	ja   MovePMissile

	cbw

	.386
	btr  word ptr Aliens[di], ax
	.286
	jc   DestroyMissile

MovePMissile:
	sub  bp, dx
	jns  MovePDone

DestroyMissile:
	xor  bp, bp

MovePDone:

	; ---------- READ KEYBOARD AND MOVE PLAYER ------------

	mov  ah, 2
	int  16H
	test al, 00001000b					; check if ALT key is pressed
	jz   Move

Kill:
	mov  cx, 24*160 + 4					; fire new rocket and destroy old one,
	add  cl, bh						; if still flying (just one is available)
	mov  bp, cx						; fire from the middle of the ship

Move:
	and  al, 00000011b					; check if SHIFT keys are pressed
	jz   MoveDone						; if not, do nothing

	shl  al, 2						; transform keyboard status bits to 
	sub  al, 6						; +2 or -2 , which will be added to 
	sub  bh, al						; position of the player ship
	
	; and  bh, 01111111b					; if left commented, player can go outside
								; visible screen where it can not be hit
								; bug/feature to keep .COM size <= 256 bytes
								
MoveDone:

	; ----------------- MOVE ALIEN BOMB -------------------

	.386							; create new bomb
	bsf  eax, dword ptr Aliens				; fired by AL-th alien
	.286							; (first from the top/left)
	jnz  NotQuit						; if no more aliens, mission accomplished!

	mov  bh, 0AH						; prepare last screen clear
	jmp  short Clear

NotQuit:
	or   si, si
	jnz  MoveAlienBomb

	push ax
	and  al, 00000111b
	mul  cl
	add  al, bl
	add  si, ax
	pop  ax
	shr  al, 2
	mul  dl
	add  si, ax

MoveAlienBomb:
	add  si, dx
	cmp  si, 25*160
	jb   CheckImpact
	xor  si, si

CheckImpact:
	mov  ax, 24*160 + 4
	add  al, bh
	cmp  ax, si
	.386
	jne  Game
	.286

GameOver:                           

	; ------------------- MAKE PAUSE ----------------------

Paint:
	mov  ax, 1003H						; WaitRetrace is undocumented
	int  10H						; side effect in BIOS routine

	; -------------- PAINT THE SCREEN IN BH ---------------

Clear:
	mov  ax, 0600H
	xor  cx, cx
	mov  dx, 184FH
	int  10H

	out  61H, al						; turn off the sound

	sub  bh, 0AH						; rotate color
	jnz  GameOver						; if not last color, keep flashing

	ret

; =====================================================================
;                          16 BYTES OF DATA
; =====================================================================

AlienShip:      	DB '(-*-)'
PlayerShip:     	DB '(_ê_)'
MoveInc:        	DB 1
PlayerMissile:  	DB 'ê'

Aliens:			DB 01111110b				; formation at start
			DB 11100111b
			DB 11100111b
			DB 01111110b
			
END Start
