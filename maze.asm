org 100h ; for dos... in linux nasm it and use dosbox to run it

maze db  "################################-END-#################################", 0x0D, 0x0A
     db  "#######             ##    #######   ###############          #########", 0x0D, 0x0A
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

player_x db 9  ; starting row position (Y)
player_y db 35 ; starting column position (X)

start:
    mov ax, 0003h  ; set text mode
    int 10h

game_loop:
    call draw_maze
    call draw_player
    call get_input
    jmp game_loop

draw_maze:
    pusha
    mov si, maze
    mov ah, 0x0E
    xor bh, bh
.print_loop:
    lodsb
    cmp al, 0
    je .done
    int 10h 
    jmp .print_loop
.done:
    popa
    ret

draw_player:
    mov ah, 02h     ; cursor position set
    mov bh, 00h
    mov dh, [player_x]
    mov dl, [player_y]
    int 10h

    mov ah, 0Eh
    mov al, 'A'     ; print player character
    int 10h
    ret

get_input:
    mov ah, 00h
    int 16h
    
    cmp ah, 48h     ; move up
    je try_move_up
    cmp ah, 50h     ; down move
    je try_move_down
    cmp ah, 4Bh     ; left move
    je try_move_left
    cmp ah, 4Dh     ; right move
    je try_move_right
    ret

try_move_up:
    dec byte [player_x]
    call check_collision
    jnc .valid
    inc byte [player_x] ; revert if collision
.valid:
    ret

try_move_down:
    inc byte [player_x]
    call check_collision
    jnc .valid
    dec byte [player_x] ; revert if collision
.valid:
    ret

try_move_left:
    dec byte [player_y]
    call check_collision
    jnc .valid
    inc byte [player_y] ; revert if collision
.valid:
    ret

try_move_right:
    inc byte [player_y]
    call check_collision
    jnc .valid
    dec byte [player_y] ; revert if collision
.valid:
    ret

check_collision:
    pusha

    ; Calculate maze offset
    movzx ax, byte [player_x]
    mov bx, 66   ; adjust for carriage return
    mul bx
    add al, [player_y]
    adc ah, 0
    mov si, ax

    cmp byte [maze + si], '#'  ; if wall, set carry flag
    je .collision
    clc
    popa
    ret

.collision:
    stc
    popa
    ret
