/*
 *void dct4_kernel(real_t * in_real, real_t * in_imag, real_t * out_real, real_t * out_imag)
 */

.import g_bit_rev_tab
.import dct4_64_tab

    .section        .text.dct4_kernel_asm,"ax",@progbits
    .align          2
    .global         dct4_kernel_asm
    .type           dct4_kernel_asm, @function

dct4_kernel_asm:
    push            l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    lrw             l3, dct4_64_tab
    movi            t9, 32              // i = 32
    mov             l9, a0              // in_real
    mov             l8, a1              // in_imag
    mov             l7, a2              // out_real
    mov             l6, a3              // out_imag

.L0:
    ld.w            l4, (l3, 0x80)      // dct4_64_tab[i + 32]
    ld.w            l5, (l3, 0x100)     // dct4_64_tab[i + 64]
    ld.w            t0, (l9)            // x_re = in_real[i]
    ld.w            t1, (l8)            // x_im = in_imag[i]
    ldbi.w          t8, (l3)            // dct4_64_tab[i]
    add             t2, t0, t1          // x_re + x_im
    mul.s32         t4, t2, t8          // (x_re + x_im) * dct4_64_tab[i] =>>t4= LOW32, t5= H32
    dexti           t3, t4, t5, 28      // tmp
    mul.s32         t4, t0, l4          // x_re * dct4_64_tab[i + 32] =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 28      // MUL_C(x_re, dct4_64_tab[i + 32])
    add             t6, t3              // in_imag[i]
    stbi.w          t6, (l8)
    mul.s32         t4, t1, l5          // x_im * dct4_64_tab[i + 64] =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 28      // MUL_C(x_re, dct4_64_tab[i + 32])
    add             t6, t3              // in_real[i]
.L1:
    stbi.w          t6, (l9)
    bloop           t9, .L0, .L1

    mov             l9, a0              // in_real
    mov             l8, a1              // in_imag
    bsr             fft_dif_asm         // call fft_dif
    mov             a0, l9              // in_real
    mov             a1, l8              // in_imag

.L2:
    lrw             l2, g_bit_rev_tab
    lrw             l3, dct4_64_tab
    movi            t9, 16              // i = 16

.L3:
    ld.w            l4, (l3, 0x180)     // dct4_64_tab[i + 3*32]
    ld.w            l5, (l3, 0x200)     // dct4_64_tab[i + 4*32]
    ld.w            t7, (l3, 0x280)     // dct4_64_tab[i + 5*32]
    addi            l3, 4
    ldbi.bs         t0, (l2)            // i_rev
    ldr.w           t1, (a0, t0 << 2)   // x_re 
    ldr.w           t2, (a1, t0 << 2)   // x_im 
    add             t3, t1, t2          // x_re + x_im
    mul.s32         t4, t3, l4          // (x_re + x_im) * dct4_64_tab[i + 3*32] =>>t4= LOW32, t5= H32
    dexti           t3, t4, t5, 28      // tmp
    mul.s32         t4, t1, l5          // (x_re) * dct4_64_tab[i + 4*32] =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 28      // 
    add             t6, t3              // out_imag[i]
    stbi.w          t6, (l6)

    mul.s32         t4, t2, t7          // (x_im) * dct4_64_tab[i + 5*32] =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 28      // 
    add             t6, t3              // out_real[i]
.L4:
    stbi.w          t6, (l7)
    bloop           t9, .L3, .L4

    lrw             l3, dct4_64_tab
    ld.w            l4, (l3, 0x1c0)     // dct4_64_tab[16 + 3*32]
    ld.w            t0, (a0, 0x4)       // in_real[1]
    ld.w            t1, (a1, 0x4)       // in_imag[1]
    sub             t2, t1, t0          // in_imag[1] - in_real[1]
    mul.s32         t4, t2, l4          // 
    dexti           t6, t4, t5, 28      // 
    stbi.w          t6, (l6)
    add             t2, t1, t0          // in_real[1] + in_imag[1]
    mul.s32         t4, t2, l4          // 
    dexti           t6, t4, t5, 28      // 
    stbi.w          t6, (l7)

    movi            t9, 17              // i = 17
    lrw             l2, g_bit_rev_tab
    addi            l2, 17
    addi            l3, 68

.L5:
    ld.w            l4, (l3, 0x180)     // dct4_64_tab[i + 3*32]
    ld.w            l5, (l3, 0x200)     // dct4_64_tab[i + 4*32]
    ld.w            t7, (l3, 0x280)     // dct4_64_tab[i + 5*32]
    addi            l3, 4
    ldbi.bs         t0, (l2)            // i_rev
    ldr.w           t1, (a0, t0 << 2)   // x_re 
    ldr.w           t2, (a1, t0 << 2)   // x_im 
    add             t3, t1, t2          // x_re + x_im
    mul.s32         t4, t3, l4          // (x_re + x_im) * dct4_64_tab[i + 3*32] =>>t4= LOW32, t5= H32
    dexti           t3, t4, t5, 28      // tmp
    mul.s32         t4, t1, l5          // (x_re) * dct4_64_tab[i + 4*32] =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 28      // 
    add             t6, t3              // out_imag[i]
    stbi.w          t6, (l6)

    mul.s32         t4, t2, t7          // (x_im) * dct4_64_tab[i + 5*32] =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 28      // 
    add             t6, t3              // out_real[i]
    stbi.w          t6, (l7)

.L6:
    addi            t9, 1
    cmplti          t9, 32              // i < 32
    bt              .L5

.L7:
    pop             l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    .size           dct4_kernel_asm, .-dct4_kernel_asm
