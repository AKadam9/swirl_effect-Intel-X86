section .text
global swirl_effect

swirl_effect:
    push rbp  ; stos chyba pełny na pewno schodzący
    mov rbp, rsp

    sub rsp, 120
    ; K [rbp-8]

    ; src [rbp-16]
    ; dst [rbp-24]

    ; width [rbp-32]
    ; height [rbp-40]

    ; padding [rbp-48]
    ; total_bytes_number [rbp-56]

    ; center_x [rbp-64]
    ; center_y [rbp-72]

    ; x_offset [rbp-80]
    ; y_offset [rbp-88]

    ; radius [rbp-96]
    ; angle [rbp-104]

    ; new_x [rbp-112]
    ; new_y [rbp-120]


    push r12  ; width counter
    push r13  ; height counter

    push r14  ; center_x
    push r15  ; center_y

    push rbx  ; counter



    ; rdi = src adress
    ; rsi = dst adress

    ; rdx = width
    mov r10, rdx
    ; rcx = height
    mov r11, rcx
    ; r8 = bytes per row

begin:
    mov qword [rbp-8], 20  ; load k
    mov qword [rbp-16], rdi  ; save src
    mov qword [rbp-24], rsi  ; save dst
    mov qword [rbp-32], r10  ; save width
    mov qword [rbp-40], r11  ; save height

    mov r10, 0  ; height counter
    mov r9, 0  ; row counter

get_total_bytes:
    mov r14, r8  ; bytes per row
    mov r15, [rbp-40]  ; height
    mov rax, r14
    imul r15
    mov [rbp-56], rax  ; total_bytes_number

get_pixel_number:
    mov r14, [rbp-32]  ; width
    mov r15, [rbp-40]  ; height
    mov rax, r14
    imul r15
    mov rbx, rax  ; general counter
    sub rbx, 1  ; inaczej nie działa

calculate_center:
    mov r14, [rbp-32]  ; width
    shr r14, 1  ; center_x
    mov r15, [rbp-40]  ; height
    shr r15, 1  ; center_y

    mov qword [rbp-64], r14  ; save center_x
    mov qword [rbp-72], r15  ; save center_y

    jmp lop

row:
    mov r9, 0  ; reset row counter
    inc r10  ; increment height counter

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lop:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to_polar:
x_coordinates:
    mov qword [rbp-80], r9  ; x_offset
    sub qword [rbp-80], r14  ; row_counter-center_x  x_offset

    mov qword [rbp-88], r10  ; y_offset
    sub qword [rbp-88], r15  ; height_counter-center_y  y_offset

get_radius:
    fild qword [rbp-80]     ; ST(0) = x (int -> float)  x_offset
    fild qword [rbp-80]     ; ST(0) = x, ST(1) = x  x_offset
    fmul                      ; ST(0) = x²

    fild qword [rbp-88]     ; ST(0) = y, ST(1) = x²  y_offset
    fild qword [rbp-88]     ; ST(0) = y, ST(1) = y, ST(2) = x²  y_offset
    fmul                      ; ST(0) = y², ST(1) = x²

    fadd                      ; ST(0) = x² + y²
    fsqrt                     ; ST(0) = √(x² + y²) = r

    fstp qword [rbp-96]  ; radius

get_angle:
    fild qword [rbp-88]     ; ST(0) = y  y_offset
    fild qword [rbp-80]     ; ST(0) = x, ST(1) = y  x_offset
    fpatan                    ; ST(0) = atan2(y, x)

    fstp qword [rbp-104]  ; angle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
new_coordinates:
new_angle:
    mov r11, [rbp-104]  ; angle

    fld qword [rbp-96]        ; ST(0) = r  radius
    fld qword [rbp-8]       ; ST(0) = k, ST(1) = r  const_K
    fmul                      ; ST(0) = k * r

    fld qword [rbp-104]         ; ST(0) = θ, ST(1) = k*r  angle
    fadd                      ; ST(0) = θ + k*r

    fstp qword [rbp-104]  ; angle

new_x:
    fld qword [rbp-96]        ; ST(0) = r  radius
    fld qword [rbp-104]     ; ST(0) = θ', ST(1) = r  angle
    fcos                      ; ST(0) = cos(θ')
    fmul                      ; ST(0) = x = r * cos(θ')

    fstp qword [rbp-112]        ; store new_x

new_y:
    fld qword [rbp-96]        ; ST(0) = r  radius
    fld qword [rbp-104]     ; ST(0) = θ', ST(1) = r  angle
    fsin                      ; ST(0) = sin(θ')
    fmul                      ; ST(0) = y = r * sin(θ')

    fstp qword [rbp-120]        ; store new_y

conver_to_int:
    fld qword [rbp-112]  ; new_x
    fistp qword [rbp-112]  ; new_x

    fld qword [rbp-120]  ; new_y
    fistp qword [rbp-120]  ; new_y

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_coordinates_compared_to_left_up_corner:
    mov r11, [rbp-112]  ; new_x
    mov r12, [rbp-120]  ; new_y

    add r11, [rbp-64]  ; center_x
    jle next

    cmp [rbp-32], r11  ; width
    jle next


    add r12, [rbp-72]  ; center_y
    jle next

    cmp [rbp-40], r12  ; height
    jle next

    mov [rbp-112], r11  ; new_x
    mov [rbp-120], r12  ; new_y

new_pixel:
    mov r11, [rbp-112]  ; new_x
    mov r12, [rbp-120]  ; new_y

    ; shift in width
    mov rax, 4
    imul r11  ; x*bpp
    mov r11, rax

    ; shift in height
    mov rax, r8
    imul r12  ; y*bp_row
    mov r12, rax

    add r11, r12

    cmp r11, [rbp-56]
    jge next

copy_bytes:
    mov r12, [rbp-24]  ; dst
    add r12, r11  ; cel pixela

    mov r15b, [rdi]
    mov [r12], r15b

    mov r15b, [rdi+1]
    mov [r12+1], r15b

    mov r15b, [rdi+2]
    mov [r12+2], r15b

    mov r15b, [rdi+3]
    mov [r12+3], r15b
next:
    dec rbx  ; decrement general counter
    inc r9  ; inrement row counter

    add rdi, 4  ; read_next_pixel (source)

    cmp r9, [rbp-32]  ; width
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