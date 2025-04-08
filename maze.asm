org 100h
; 70 * 24 map
maze db  "################################-END-#################################", 0x0D, 0x0A
     db  "################################-END-#################################", 0x0D, 0x0A
     db  "#######             ##    #######   ##############            ########", 0x0D, 0x0A
     db  "#         #######   ##  ###                      ##########        ###", 0x0D, 0x0A
     db  "#    ##   #######       ###   #################         ###   ##   ###", 0x0D, 0x0A
     db  "#    ##        ##   #######   ##        ##    ########  ###   ##   ###", 0x0D, 0x0A
     db  "#      #####   ##   #         ##   ##   ##  ##########  ###   ##     #", 0x0D, 0x0A
     db  "#####  #####   ##   #######   ##   ##   ##                    #####  #", 0x0D, 0x0A
     db  "##                       ##   ##   ##   #######   #########   ##     #", 0x0D, 0x0A
     db  "##   ############   ##   ##   ##   ##   ##   ##   #########   ##  ####", 0x0D, 0x0A
     db  "##   ############   ##   #######   ##   ##   ##   ##          ##     #", 0x0D, 0x0A
     db  "##             ##   ##             ##        ##   ##   ############  #", 0x0D, 0x0A
     db  "##   #######   ##  ############################   ##   ####   #####  #", 0x0D, 0x0A
     db  "##   #######       ########                       ##   ####       #  #", 0x0D, 0x0A
     db  "##             ##        ##   ######################   ####   ##  #  #", 0x0D, 0x0A
     db  "#######   ##   ##   ##   ##                                   ##     #", 0x0D, 0x0A
     db  "##   ##   ##   ##   ##   ##############   ##   ############   ##  #  #", 0x0D, 0x0A
     db  "##   ##   ##   ##   ##               ##        ##             ##  ####", 0x0D, 0x0A
     db  "##   ##   ##   ##   ########   ###   #######   ##   #######   ###   ##", 0x0D, 0x0A
     db  "##   ##   ##   ##   ########   ###        ##        ##   ##   ####   #", 0x0D, 0x0A
     db  "##   ##   ##   ##   ##               ##   #######   ##   ##       #  #", 0x0D, 0x0A
     db  "##   ##   ##   ##   ##   ##############   #######   ##   ##   ##  #  #", 0x0D, 0x0A
     db  "##   ##   ##   ##   ##   ##############             ##   ##   ##  #  #", 0x0D, 0x0A
     db  "##        ##        ##               ###########              ##     #", 0x0D, 0x0A
     db  "################################START#################################", 0

player_x db 24 ; start position (row)
player_y db 35 ; column position (X)
player_dir db 'A' ;defaut direction of plyer

start:
    mov ax,0003h
    int 10h       ; set video mode

game_loop:
    call clear_screen
    call draw_maze
    call draw_player
    call get_input
    jmp game_loop

clear_screen:
    mov ax,06000h ; clear screen function
    mov cx,00000h ; upper left corner
    mov dx,184Fh ; lower right corner
    mov bh,07h ; normal attribute
    int 10h        ; bios interrupt to clear the screen
    ret

draw_maze:
    pusha
    mov si, maze ; point to the maze data
    mov ah, 00Eh ; bios teletype output function 
    xor bh, bh ; page number = 
.print_loop:
    lodsb          ; load next byte from maze into AL
    cmp al,00      ; check for null terminator
    je .done       ; if null terminator, exit loop
    int 10h        ; print character in AL
    jmp .print_loop
.done:
    popa
    ret

draw_player:
    mov ah, 02h    ; Set cursor position
    mov bh, 00h
    mov dh, [player_x]
    mov dl, [player_y]
    int 10h
    
    mov ah, 00Eh   ; Teletype output
    mov al, [player_dir]  ; Use direction-based character
    int 10h
    ret

get_input:
    mov ah, 00h ; keyboard input function
    int 16h         ; wait for key press
    
; check for arrow keys and 'q' for exit.
    
cmp ah, 'H'     ; up arrow key (scan code)
je move_up
cmp ah, 'P'     ; down arrow key (scan code)
je move_down
cmp ah, 'K'     ; left arrow key (scan code)
je move_left
cmp ah, 'M'     ; right arrow key (scan code)
je move_right
cmp al, 'q'     ; quit key ('q')
je exit_program  
ret

check_collision:
    pusha
    
; boundary checks for player position.
    
cmp byte [player_x], 1    
jb .collision_detected  
cmp byte [player_x], 24   
ja .collision_detected  
cmp byte [player_y], 1    
jb .collision_detected  
cmp byte [player_y], 69   
ja .collision_detected  

; calculate maze offset based on player position.
mov al, [player_x]
mov bl, 72          ; each row has a width of characters including CRLF.
mul bl              ; AX = X * width (72)
add al, [player_y]
adc ah, 00          ; handle carry if needed.
mov di, maze    
add di, ax          

; check for wall at new position.
cmp byte [di], '#'
je .collision_detected

; Check for win conditions ('-', 'E', 'N', 'D')
cmp byte [di], '-'
je .win_condition 
cmp byte [di], 'E'
je .win_condition 
cmp byte [di], 'N'
je .win_condition 
cmp byte [di], 'D'
je .win_condition 

popa 
clc                 ; clear carry flag (no collision)
ret 

.win_condition:
    call clear_screen
    call reset_cursor
    call display_message 
    jmp exit_program      ; Exit after winning.

.collision_detected:
    popa 
    stc                 ; set carry flag (collision detected)
    ret

move_up:
    mov byte [player_dir], 'A'
    dec byte [player_x]
    call check_collision
    jc .undo_up  
    ret

.undo_up:
    inc byte [player_x]
    ret

move_down:
    mov byte [player_dir], 'V'
    inc byte [player_x]
    call check_collision
    jc .undo_down  
    ret

.undo_down:
    dec byte [player_x]
    ret

move_left:
    mov byte [player_dir], '<'
    dec byte [player_y]
    call check_collision
    jc .undo_left  
    ret

.undo_left:
    inc byte [player_y]
    ret

move_right:
    mov byte [player_dir], '>'
    inc byte [player_y]
    call check_collision
    jc .undo_right  
    ret

.undo_right:
    dec byte [player_y]
    ret 

exit_program:
    mov ax, 4C00h       ; dos terminate program function
    int 21h             ; exit to dos

reset_cursor:
    mov ah, 02h
    mov bh, 00h
    mov dh, 0
    mov dl, 0
    int 10h
    ret

display_message:
    mov ah, 0x0E
    mov si, win_msg
.print_message:
    lodsb              ; load next byte from the message into AL
    cmp al, 0
    je .done
    int 10h
    jmp .print_message
.done:
    ret

win_msg db "You win! Now get the hell outta here.", 0
