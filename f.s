section .text
global swirl_effect

swirl_effect:
    push rbp  ; stos chyba pełny na pewno schodzący
    mov rbp, rsp




    push r12  ; width counter
    push r13  ; height counter

    push r14  ; center_x
    push r15  ; center_y

    push rbx  ; counter



    ; rdi = src adress
    ; rsi = dst adress
    ; rdx = width
    mov r10, edx
    ; rcx = height
    mov r11, ecx
    ; r8 = bytes per row

begin:

    mov qword [k], 20  ; load const k
    mov qword [src], rdi  ; save src
    mov qword [dst], rsi  ; save dst
    mov qword [width], r10  ; save width
    mov qword [height], r11  ; save height

get_padding:
    lea r10, [r10 + r10 * 2]  ; width*3
    sub r10, r8  ; width-total_pixels
    neg r10
    mov [padding], r10

    mov r10, 0  ; height counter
    mov r9, 0  ; row counter

get_total_bytes:
    mov r14, r8  ; bytes per row
    mov r15, [height]
    mov rax, r14
    imul r15
    mov [total_bytes_number], r15

get_pixel_number:
    mov r14, [width]
    mov r15, [height]
    mov rax, r14
    imul r15
    mov rbx, r15  ; general counter

calculate_center:
    mov r14, [width]
    shr r14, 1  ; center_x
    mov r15, [height]
    shr r15, 1  ; center_y

    mov qword [center_x], r14  ; save center_x
    mov qword [center_y], r15  ; save center_y

    j lop

row:
    mov r9, 0  ; row counter
    inc r10  ; increment height counter
    add rdi, [padding]
    add rsi, [padding]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lop:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to_polar:
x_coordinates:
    mov qword [x_offset], r9
    sub qword [x_offset], r14  ; row_counter-center_x

    mov qword [y_offset], r10
    sub qword [y_offset], r15  ; height_counter-center_y

get_radius:
    fild qword [x_offset]     ; ST(0) = x (int -> float)
    fild qword [x_offset]     ; ST(0) = x, ST(1) = x
    fmul                      ; ST(0) = x²

    fild qword [y_offset]     ; ST(0) = y, ST(1) = x²
    fild qword [y_offset]     ; ST(0) = y, ST(1) = y, ST(2) = x²
    fmul                      ; ST(0) = y², ST(1) = x²

    fadd                      ; ST(0) = x² + y²
    fsqrt                     ; ST(0) = √(x² + y²) = r

    fstp qword [radius]

get_angle:
    fild qword [y_offset]     ; ST(0) = y
    fild qword [x_offset]     ; ST(0) = x, ST(1) = y
    fpatan                    ; ST(0) = atan2(y, x)

    fstp qword [angle]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
new_coordinates:
new_angle:
    mov r11, [angle]  ; angle

    fld qword [radius]        ; ST(0) = r
    fld qword [const_K]       ; ST(0) = k, ST(1) = r
    fmul                      ; ST(0) = k * r

    fld qword [angle]         ; ST(0) = θ, ST(1) = k*r
    fadd                      ; ST(0) = θ + k*r

    fstp qword [new_angle]

new_x:
    fld qword [radius]        ; ST(0) = r
    fld qword [new_angle]     ; ST(0) = θ', ST(1) = r
    fcos                      ; ST(0) = cos(θ')
    fmul                      ; ST(0) = x = r * cos(θ')

    fstp qword [new_x]        ; store new_x

new_y:
    fld qword [radius]        ; ST(0) = r
    fld qword [new_angle]     ; ST(0) = θ', ST(1) = r
    fsin                      ; ST(0) = sin(θ')
    fmul                      ; ST(0) = y = r * sin(θ')

    fstp qword [new_y]        ; store new_y

conver_to_int:
    fld qword [new_x]
    fistp qword [new_x]

    fld qword [new_y]
    fistp qword [new_y]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_coordinates_compared_to_left_up_corner:
    mov r11, [new_x]
    mov r12, [new_y]

    add r11, [center_x]
    jle next
    cmp [width], r11
    jle next

    add r12, [center_y]
    j next
    cmp [height], r12
    jle next

    mov [new_x], r11
    mov [new_y], r12

new_pixel:

    mov rax, 3
    imul r11  ; x*bpp
    mov rax, r8
    imul r12  ; y*bp_row
    add r11, r12

copy_bytes:
    mov r12, [dst]
    add r12, r11  ; cel pixela

    mov r15b, [rdi]
    mov [r12], r15b

    mov r15b, [rdi+1]
    mov [r12+1], r15b

    mov r15b, [rdi+2]
    mov [r12+2], r15b

next:
    dec rbx  ; decrement general counter
    inc r9  ; inrement row counter

    add rdi, 3  ; read_next_pixel (source)

    cmp r9, [width]
    jge row

    cmp rbx, 0
    jnz lop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end:
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret