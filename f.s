section .text

global swirl_effect

swirl_effect:
    push rbp  ; stos chyba pełny na pewno schodzący
    mov rbp, rsp

    sub rsp, 4  ; x_offset  [rbp-4]
    sub rsp, 4  ; y_offset  [rbp-8]
    sub rsp, 4  ; radius    [rbp-12]
    sub rsp, 4  ; angle     [rbp-16]
    sub rsp, 8  ; x^2       [rbp-24]
    sub rsp, 8  ; y^2       [rbp-32]

    sub rsp, 4  ; k (const) [rbp-36]
    sub rsp, 4  ; center_x  [rbp-40]
    sub rsp, 4  ; center_y  [rbp-44]
    sub rsp, 8  ; src_address  [rbp-52]
    sub rsp, 8  ; dst_address  [rbp-60]

    sub rsp, 4  ; width  [rbp-64]
    sub rsp, 4  ; height [rbp-68]

    sub rsp, 8  ; new_angle [rbp-76]
    sub rsp, 8  ; new_radius [rbp-84]

    sub rsp, 8  ; src_address_unchangeable  [rbp-92]
    sub rsp, 8  ; dst_address_unchangeable  [rbp-100]


    push r12  ; width counter
    push r13  ; height counter

    push r14  ; center_x
    push r15  ; center_y

    push rbx  ; counter



    ; rdi = src adress
    ; rsi = dst adress
    ; rdx = width
    mov r10d, edx
    ; rcx = height
    mov r11d, ecx
    ; r8d = bytes per row

begin:

    mov dword [k], 20  ; load const k
    mov qword [src], rdi  ; save src
    mov qword [dst], rsi  ; save dst
    mov dword [width], r10d  ; save width
    mov dword [height], r11d  ; save height

    neg r8d  ; negate bytes_per_row

    ; get padding
    lea r10d, [r10d + r10d * 2]  ; width*3
    sub r10d, r8d  ; width-total_pixels
    neg r10d
    mov [padding], r10d

    mov r10d, 0  ; height counter

get_total_bytes:
    mov r14d, r8d  ; bytes per row
    mov r15d, [height]
    mov rax, r14
    imul r15
    mov [total_bytes_number], r15

get_pixel_number:
    mov r14d, [width]
    mov r15d, [height]
    mov rax, r14
    imul r15
    mov rbx, r15  ; general counter

calculate_center:
    mov r14d, [width]
    shr r14d, 1  ; center_x
    mov r15d, [height]
    shr r15d, 1  ; center_y

    mov dword [center_x], r14d  ; save center_x
    mov dword [center_y], r15d  ; save center_y

row:
    mov r9d, 0  ; row counter
    inc r10d  ; increment height counter
    add rdi, [padding]
    add rsi, [padding]

lop:
    inc r9d  ; inrement row counter

to_polar:
    mov dword [x_offset], r9d
    sub dword [x_offset], r14d  ; row_counter-center_x

    mov dword [y_offset], r10d
    sub dword [y_offset], r15d  ; height_counter-center_y

    mov r11d, [x_offset]
    mov r12d, [y_offset]

    imul r11d, r11d  ; x^2
    mov [x^2], r11d

    imul r12d, r12d  ; y^2
    mov [y^2], r12d

    add r12d, r11d  ; x^2 + y^2
    mov [x^2+y^2], r12d

    cvtsi2ss xmm0, [x^2+y^2]  ; xmm0 = float(x² + y²)
    sqrtss xmm0, xmm0  ; xmm0 = radius

    movsd qword [radius], xmm0

    ; get_angle
    fild dword [y_offset]  ; y_offset
    fild dword [x_offset]  ; x_offset
    fpatan  ; ST(0) = atan2(y, x)
    fstp qword [angle]  ; angle

new_coordinates:
    ; new angle
    mov r11, [angle]  ; angle

    ; xmm0 = radius (already)
    movsd xmm1, qword [angle]  ; load angle into xmm1
    movsd xmm2, qword [const_K]  ; xmm2 = k = 20.0 (defined in .data section)
    mulss xmm0, xmm2  ; xmm0 = radius * k
    addss xmm1, xmm0  ; xmm1 = angle + radius * k
    movsd qword [angle], xmm1  ; store new angle back if needed

    ; new x
    fld qword [angle]  ; ST0 = θ
    fcos  ; ST0 = cos(θ)
    fld qword [radius]  ; xmm0 = radius
    fmul  ; ST0 = r * cos(θ)
    fstp qword [new_x]  ; store x

    ; new y
    fld qword [angle]  ; ST0 = θ
    fsin  ; ST0 = sin(θ)
    fld qword [radius]  ; ST0 = r, ST1 = sin(θ)
    fmul  ; ST0 = r * sin(θ)
    fstp qword [new_y]  ; store y

new_pixel:
    mov r11, [new_x]
    mov r12, [new_y]

    mov rax, 3
    mul r11  ; x*bpp
    mov rax, r8
    mul r12  ; y*bp_row
    add r11, r12

    cmp r11, [total_bytes_number]
    jg next

copy_bytes:
    mov r12, [dst]
    add r12, r11  ; cel pixela

    mov r15b, [rsi]
    mov [r12], r15b

    mov r15b, [rsi+1]
    mov [r12+1], r15b

    mov r15b, [rsi+2]
    mov [r12+2], r15b

next:
    add rsi, 3  ; next pixel
    add rdi, 3  ; next pixel

    cmp r9d, [width]
    je row

    dec rbx  ; decrement general counter
    jnz lop

end:
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret