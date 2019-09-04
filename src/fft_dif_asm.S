/*
 *void fft_dif(real_t * Real, real_t * Imag)
 */

.import w_array_real
.import w_array_imag

    .section        .text.fft_dif_asm,"ax",@progbits
    .align          2
    .global         fft_dif_asm
    .type           fft_dif_asm, @function

fft_dif_asm:
    push            l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    lrw             a3, w_array_real
    lrw             a2, w_array_imag
    movi            t9, 16              // i = 16
    mov             l9, a0              // Real
    mov             l8, a1              // Imag

.L0:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x40)      // Real[i2], point2_real
    ld.w            t3, (l8, 0x40)      // Imag[i2], point2_imag
    ldbi.w          l2, (a2)            // w_array_imag[i]
    ldbi.w          l3, (a3)            // w_array_real[i]

    add             t4, t0, t2          // Real[i] + point2_real
    stbi.w          t4, (l9)
    add             t5, t1, t3          // Imag[i] + point2_imag
    stbi.w          t5, (l8)

    sub             t0, t2              // point1_real - point2_real
    sub             t1, t3              // point1_imag - point2_imag

    mul.s32         t4, t0, l3          // point1_real * w_real =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    mul.s32         t4, t1, l2          // point1_imag * w_imag =>>t4= LOW32, t5= H32
    dexti           t7, t4, t5, 31      // 
    sub             t6, t7              // Real[i2]
	st.w            t6, (l9, 0x3c)

    mul.s32         t4, t0, l2          // point1_real * w_imag =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    mul.s32         t4, t1, l3          // point1_imag * w_real =>>t4= LOW32, t5= H32
    dexti           t7, t4, t5, 31      // 
    add             t6, t7              // Imag[i2]
.L1:
	st.w            t6, (l8, 0x3c)
    bloop           t9, .L0, .L1

    lrw             a3, w_array_real
    lrw             a2, w_array_imag
    movi            t9, 8               // j = 8
    movi            t8, 8               // w_index += 2
    mov             l9, a0              // Real
    mov             l8, a1              // Imag

.L2:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x20)      // Real[i2], point2_real
    ld.w            t3, (l8, 0x20)      // Imag[i2], point2_imag
    ldbir.w         l2, (a2), t8        // w_array_imag[w_index]
    ldbir.w         l3, (a3), t8        // w_array_real[w_index]

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	stbi.w          t4, (l9)
	stbi.w          t5, (l8)

    sub             t0, t2              // point1_real
    sub             t1, t3              // point1_imag

    mul.s32         t4, t0, l3          // point1_real * w_real =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    mul.s32         t4, t1, l2          // point1_imag * w_imag =>>t4= LOW32, t5= H32
    dexti           t7, t4, t5, 31      // 
    sub             t6, t7              // Real[i2]
	st.w            t6, (l9, 0x1c)

    mul.s32         t4, t0, l2          // point1_real * w_imag =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    mul.s32         t4, t1, l3          // point1_imag * w_real =>>t4= LOW32, t5= H32
    dexti           t7, t4, t5, 31      // 
    add             t6, t7              // Imag[i2]
	st.w            t6, (l8, 0x1c)


    ld.w            t0, (l9, 0x3c)      // Real[j + 16], point1_real
    ld.w            t1, (l8, 0x3c)      // Imag[j + 16], point1_imag
    ld.w            t2, (l9, 0x5c)      // Real[i2 = i + 8], point2_real
    ld.w            t3, (l8, 0x5c)      // Imag[i2 = i + 8], point2_imag

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	st.w            t4, (l9, 0x3c)
	st.w            t5, (l8, 0x3c)

    sub             t0, t2              // point1_real
    sub             t1, t3              // point1_imag

    mul.s32         t4, t0, l3          // point1_real * w_real =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    mul.s32         t4, t1, l2          // point1_imag * w_imag =>>t4= LOW32, t5= H32
    dexti           t7, t4, t5, 31      // 
    sub             t6, t7              // Real[i2]
	st.w            t6, (l9, 0x5c)

    mul.s32         t4, t0, l2          // point1_real * w_imag =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    mul.s32         t4, t1, l3          // point1_imag * w_real =>>t4= LOW32, t5= H32
    dexti           t7, t4, t5, 31      // 
    add             t6, t7              // Imag[i2]
.L3:
	st.w            t6, (l8, 0x5c)
    bloop           t9, .L2, .L3

    movi            t9, 0               // i = 0
    movi            t8, 32              // i += 8
    mov             l9, a0              // Real
    mov             l8, a1              // Imag

.L4:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x10)      // Real[i2], point2_real
    ld.w            t3, (l8, 0x10)      // Imag[i2], point2_imag

    sub             t6, t0, t2          // point1_real
    sub             t7, t1, t3          // point1_imag
    st.w            t6, (l9, 0x10)      // Real[i2]
    st.w            t7, (l8, 0x10)      // Imag[i2]

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	stbir.w         t4, (l9), t8
	stbir.w         t5, (l8), t8

.L5:
    addi            t9, 8
    cmplti          t9, 32              // i < 32
    bt              .L4

    lrw             a3, w_array_real
    movi            t9, 1               // i = 1
    movi            t8, 32              // i += 8
    addi            l9, a0, 4           // Real
    addi            l8, a1, 4           // Imag
    ld.w            l7, (a3, 0x10)      // w_array_real[4]

.L6:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x10)      // Real[i2], point2_real
    ld.w            t3, (l8, 0x10)      // Imag[i2], point2_imag

    sub             l2, t0, t2          // new point1_real
    sub             l3, t1, t3          // new point1_imag

	add             l4, l2, l3
    mul.s32         t4, l4, l7          // (point1_real+point1_imag) * w_real =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    st.w            t6, (l9, 0x10)      // Real[i2]

	sub             l4, l3, l2
    mul.s32         t4, l4, l7          // (point1_real-point1_imag) * w_real =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    st.w            t6, (l8, 0x10)      // Imag[i2]

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	stbir.w         t4, (l9), t8
	stbir.w         t5, (l8), t8

.L7:
    addi            t9, 8
    cmplti          t9, 32              // i < 32
    bt              .L6

    movi            t9, 2               // i = 2
    movi            t8, 32              // i += 8
    addi            l9, a0, 8           // Real
    addi            l8, a1, 8           // Imag
.L8:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x10)      // Real[i2], point2_real
    ld.w            t3, (l8, 0x10)      // Imag[i2], point2_imag

    sub             t4, t1, t3          // Real[i2]
    sub             t5, t2, t0          // Imag[i2]
    st.w            t4, (l9, 0x10)      // Real[i2]
    st.w            t5, (l8, 0x10)      // Imag[i2]

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	stbir.w         t4, (l9), t8
	stbir.w         t5, (l8), t8
.L9:
    addi            t9, 8
    cmplti          t9, 32              // i < 32
    bt              .L8

    lrw             a3, w_array_real
    movi            t9, 3               // i = 3
    movi            t8, 32              // i += 8
    addi            l9, a0, 12          // Real
    addi            l8, a1, 12          // Imag
    ld.w            l7, (a3, 0x30)      // w_array_real[12]

.L10:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x10)      // Real[i2], point2_real
    ld.w            t3, (l8, 0x10)      // Imag[i2], point2_imag

    sub             l2, t0, t2          // new point1_real
    sub             l3, t1, t3          // new point1_imag

	sub             l4, l2, l3
    mul.s32         t4, l4, l7          // (point1_real-point1_imag) * w_real =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    st.w            t6, (l9, 0x10)      // Real[i2]

	add             l4, l3, l2
    mul.s32         t4, l4, l7          // (point1_real+point1_imag) * w_real =>>t4= LOW32, t5= H32
    dexti           t6, t4, t5, 31      // 
    st.w            t6, (l8, 0x10)      // Imag[i2]

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	stbir.w         t4, (l9), t8
	stbir.w         t5, (l8), t8
.L11:
    addi            t9, 8
    cmplti          t9, 32              // i < 32
    bt              .L10

    movi            t9, 0               // i = 0
    movi            t8, 16              // i += 4
    mov             l9, a0              // Real
    mov             l8, a1              // Imag

.L12:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x8)       // Real[i2], point2_real
    ld.w            t3, (l8, 0x8)       // Imag[i2], point2_imag

    sub             t4, t0, t2          // Real[i2]
    sub             t5, t1, t3          // Imag[i2]
    st.w            t4, (l9, 0x8)       // Real[i2]
    st.w            t5, (l8, 0x8)       // Imag[i2]

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	stbir.w         t4, (l9), t8
	stbir.w         t5, (l8), t8
.L13:
    addi            t9, 4
    cmplti          t9, 32              // i < 32
    bt              .L12

    movi            t9, 1               // i = 1
    movi            t8, 16              // i += 4
    addi            l9, a0, 4           // Real
    addi            l8, a1, 4           // Imag

.L14:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x8)       // Real[i2], point2_real
    ld.w            t3, (l8, 0x8)       // Imag[i2], point2_imag

    sub             t4, t1, t3          // Real[i2]
    sub             t5, t2, t0          // Imag[i2]
    st.w            t4, (l9, 0x8)       // Real[i2]
    st.w            t5, (l8, 0x8)       // Imag[i2]

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	stbir.w         t4, (l9), t8
	stbir.w         t5, (l8), t8
.L15:
    addi            t9, 4
    cmplti          t9, 32              // i < 32
    bt              .L14

    movi            t9, 0               // i = 0
    movi            t8, 8               // i += 2
    mov             l9, a0              // Real
    mov             l8, a1              // Imag

.L16:
    ld.w            t0, (l9)            // Real[i], point1_real
    ld.w            t1, (l8)            // Imag[i], point1_imag
    ld.w            t2, (l9, 0x4)       // Real[i2], point2_real
    ld.w            t3, (l8, 0x4)       // Imag[i2], point2_imag

    sub             t4, t0, t2          // Real[i2]
    sub             t5, t1, t3          // Imag[i2]
    st.w            t4, (l9, 0x4)       // Real[i2]
    st.w            t5, (l8, 0x4)       // Imag[i2]

    add             t4, t0, t2          // Real[i] += point2_real
    add             t5, t1, t3          // Imag[i] += point2_imag
	stbir.w         t4, (l9), t8
	stbir.w         t5, (l8), t8
.L17:
    addi            t9, 2
    cmplti          t9, 32              // i < 32
    bt              .L16

.L20:
    pop             l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    .size           fft_dif_asm, .-fft_dif_asm
