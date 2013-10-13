
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
	pop   es							; ES := B800

Game:

	push si								; save bomb coordinate
	push bx								; save invader and player coordinates

    ; ------------------- DRAW INVADERS -------------------

    mov  di, bx                    
    mov  bh, 0AH                   
    call Paint                     
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
    lodsb                          
    stosw                          
    loop DrawAlien
    dec  dx                        
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
Zvuk:                               
    ror  al, 1
    out  61H, al                    
    loop Zvuk

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
    test al, 00001000b              
    jz   Move

Kill:
    mov  cx, 24*160 + 4             
    add  cl, bh                     
    mov  bp, cx                     
	
Move:
    and  al, 00000011b              
    jz   MoveDone     
	
    shl  al, 2                      
    sub  al, 6                      
    sub  bh, al                     

MoveDone:

    ; ----------------- MOVE ALIEN BOMB -------------------

MoveAlienBomb:

    .386                            
    bsf  eax, dword ptr Aliens      
    .286                            
    jnz  NotQuit                    

    mov  bh, 0AH                    
    jmp  short Clear

NotQuit:
    or   si, si                     
    jnz  MoveABomb            

    push ax                         
    and  al, 00000111b              
    mul  cl                         
    add  al, bl                     
    add  si, ax
    pop  ax
    shr  al, 2                      
    mul  dl
    add  si, ax

MoveABomb:
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

    mov  ax, 1003H                  
    int  10H                        


    ; -------------- PAINT THE SCREEN IN BH ---------------

Clear:

    mov  ax, 0600H
    xor  cx, cx
    mov  dx, 184FH
    int  10H

    out  61H, al                    

    sub  bh, 0AH                    
    jnz  GameOver                   

    ret

; =====================================================================
;                          16 BYTES OF DATA
; =====================================================================

AlienShip:      DB '(-*-)'
PlayerShip:     DB '(_ê_)'
MoveInc:        DB 1
PlayerMissile:  DB 'ê'

Aliens:         DB 01111110b
                DB 11100111b
                DB 11100111b
                DB 01111110b


END Start

