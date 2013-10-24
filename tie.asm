
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

	mov  bh, 0AH						; but first
	call Paint						; paint the screen light green

	and  di, 00111110b					; clear bit 0 (draw invaders every
	lea  bx, Aliens						; on new position every other frame)

DrawFormation:
	mov  dx, 8						; there are 8 positions in one formation row

DrawRow:
	lea  si, AlienShip					; this is the tie-fighter data
	ror  byte ptr [bx], 1					; test if invader is still in formation
	sbb  ah, ah						; remove it or display it
	and  ah, 13						; if displayed then the colour is 13
	mov  cl, 5						; invader ship is 5 chars long

DrawAlien:
	lodsb							; read char
	stosw							; write char and colour
	loop DrawAlien

	dec  dx							; is the entire row of the formation drawn?
	jnz  DrawRow

	add  di, 240						; skip one screen row
	inc  bx							; process next invader row,
	cmp  bl, low offset Aliens[4]				; and there are 4 of them rows
	jne  DrawFormation
	pop  bx							; restore player and invader coordinates

	; -------------------- DRAW PLAYER --------------------

	mov  ah, 0FH						; draw player in the last row
	mov  al, bh						; in white colour (0F)
	mov  di, ax
	mov  cl, 5

DrawPlayer:
	lodsb							; read char
	stosw							; write both char and attribute
	loop DrawPlayer
	
	; ------------------- MOVE INVADERS -------------------

	lodsb							; read movement (number 1 after player definition)
	add  bl, al						; BL will become odd number because
								; +1 or -1 is added to even number
	
	xor  bl, 00111111b					; because BL is odd number, this will
								; reset bit 0, so it will become even again
								; this helps calculating X screen coordinate
	
	jz   AlienMoveDone					

ChangeMove:
	neg byte ptr [si-1]					; change movement direction

AlienMoveDone:

	; ---------------- DRAW ROCKET AND BOMB ---------------

	mov  di, bp						; rocket is right after movement
	movsb
	pop  si
	mov  byte ptr es:[si], 'V'

	; ----------------- ROCKET SOUND FX  ------------------

	mov  ch, 12H
	mov  ax, bp

Sound:
	ror  al, 1
	out  61H, al						; make some noise
	loop Sound

	; ---------------- MOVE PLAYER ROCKET -----------------

	mov  dl, 160
	mov  cl, 10

MovePlayerMissile:

	; or   ax, ax                   			; control if there is rocket at all
	; jz   MovePDone                			; if you remove control (to keep under 256 bytes)
								; then the top/left invader will be killed at 
								; start and whenever there is no player rocket
								
								; formation is cleverly chosen so you don't 
								; notice this feature
								
	div  dl							; BP := Y * 160 + X
	
	cmp  al, 8						; if you remove these two instructions then 
	jae  MovePMissile					; invaders have shields and you need to destroy
								; undefined memory space above alien formation

	push ax							; Y := BP DIV 160, X := BP MOD 160
	shr  al, 1						; position of the alien formation is Y DIV 2
	cbw							; AH := 0
	mov  di, ax						; DI := position of the alien formation
	pop  ax							
	sub  ah, bl						; possibly hit invader has position in formation
	shr  ax, 8						; equal to ((X - AlienX) DIV 2) DIV 5
	div  cl							; AL := position of the invader
	cmp  al, 7
	ja   MovePMissile
	cbw							; AH := 0

	.386
	btr  word ptr Aliens[di], ax				; hit the formation
	.286							; if we have a kill, destroy missile
	jc   DestroyMissile					; otherwise, missile keeps flying

MovePMissile:
	sub  bp, dx						; fly missile fly!	
	jns  MovePDone						; if coordinate < 0 this means the missile...

DestroyMissile:
	xor  bp, bp						; ...hit the top, so destroy it

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
	or   si, si						; if there is alien bomb already flying,
	jnz  MoveAlienBomb					; then let it fly...

	push ax							; otherwise...
	and  al, 00000111b					; figure out the alien order number
	mul  cl							; in the formation and its position 
	add  al, bl						; on the screen (horizontal)
	add  si, ax
	pop  ax
	shr  al, 2						; place the bomb beneath alien
	mul  dl
	add  si, ax

MoveAlienBomb:
	add  si, dx						; bomb is falling...
	cmp  si, 25*160						; is it out of the screen?
	jb   CheckImpact
	xor  si, si						; YES, then destroy it

CheckImpact:
	mov  ax, 24*160 + 4					; check if bomb hit the player ship cabin,
	add  al, bh						; which is in the last row of the screen?
	cmp  ax, si						; are coordinates of the cabin and the bomb 
	.386							; the same? if not, then player survived 
	jne  Game						; and bomb and the game go on...
	.286							; (long 386 jump required)

GameOver:                           				; otherwise, it is game over for a player

	; ------------------- MAKE PAUSE ----------------------

Paint:
	mov  ax, 1003H						; WaitRetrace is undocumented
	int  10H						; side effect in the BIOS routine

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
