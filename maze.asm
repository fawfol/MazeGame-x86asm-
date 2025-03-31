org 100h
; 70 * 24 map
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
     db  "################################START#################################", 0x0D, 0x0A
     db  "#                                                                    #", 0

player_x db 23  ; start position (row 24)
player_y db 35  ; Column position (X)

start:
    mov ax, 0003h
    int 10h     ; fixed space in interrupt call

game_loop:
    call clear_screen
    call draw_maze
    call draw_player
    call get_input
    jmp game_loop

clear_screen:
    mov ax, 0600h  ; AH=06 (scroll), AL=00 fulscreen
    mov cx, 0000h  ; Upper left corner
    mov dx, 184Fh  ; Lower right corner
    mov bh, 07h    ; Normal attribute
    int 10h        ; Fixed space
    ret

draw_maze:
    pusha
    mov si, maze
    mov ah, 0x0E   ; BIOS teletype output
    xor bh, bh     ; Page 0
.print_loop:
    lodsb          ; load next character
    cmp al, 0      ; check for null terminator
    je .done
    int 10h        ; fixed space
    jmp .print_loop
.done:
    popa
    ret

draw_player:
    mov ah, 02h    ; set cursor position
    mov bh, 00h    ; page 0
    mov dh, [player_x] ; row (Y)
    mov dl, [player_y] ; column (X)
    int 10h        ; fixed space
    
    mov ah, 0Eh    ; teletype output
    mov al, '@'    ; player character
    int 10h        ; fixed space
    ret

get_input:
    mov ah, 00h
    int 16h        ; get keyboard input
    
    cmp ah, 48h    ; up
    je move_up
    cmp ah, 50h    ; down
    je move_down
    cmp ah, 4Bh    ; left
    je move_left
    cmp ah, 4Dh    ; right
    je move_right
    cmp ah, 'q'    ; escape key not wporking in dosbox idk why
    je exit_program
    ret

check_collision:
    pusha
    ; boundary checks
    cmp byte [player_x], 0
    jb .collision
    cmp byte [player_x], 22
    ja .collision
    cmp byte [player_y], 0
    jb .collision
    cmp byte [player_y], 69
    ja .collision

    ;calculate maze offset
    mov al, [player_x]
    mov bl, 72      ; 70 chars + CRLF per line (CRLF takes 2)
    mul bl          ; AX = X * 72
    add al, [player_y]
    adc ah, 0       ; handle carry
    mov di, maze
    add di, ax

    cmp byte [di], '#'
    je .collision
    popa
    clc             ; clear carry (no collision)
    ret

.collision:
    popa
    stc             ; set carry (collision)
    ret

move_up:
    dec byte [player_x]
    call check_collision
    jc .undo
    ret
.undo:
    inc byte [player_x]
    ret

move_down:
    inc byte [player_x]
    call check_collision
    jc .undo
    ret
.undo:
    dec byte [player_x]
    ret

move_left:
    dec byte [player_y]
    call check_collision
    jc .undo
    ret
.undo:
    inc byte [player_y]
    ret

move_right:
    inc byte [player_y]
    call check_collision
    jc .undo
    ret
.undo:
    dec byte [player_y]
    ret

exit_program:
    mov ax, 4C00h   ; dos exit function
    int 21h
