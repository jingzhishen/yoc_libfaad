/*
 *void sbr_qmf_synthesis_64(sbr_info *sbr, qmfs_info *qmfs, qmf_t X[MAX_NTSRHFG][64], real_t *output)
 */

.import qmf_c
.import dct4_kernel_asm

    .section        .text.sbr_qmf_synthesis_64_asm,"ax",@progbits
    .align          2
    .global         sbr_qmf_synthesis_64_asm
    .type           sbr_qmf_synthesis_64_asm, @function

sbr_qmf_synthesis_64_asm:
    push            l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
	subi            sp, sp, 1040        // 32*8*4 = 1024

	movi            l9, 0               // -4
	subi            l9, 4
	ld.w            l8, (a1, 0x0)       // qmfs <==> qmfs->v
	mov             l7, a2              // X
	mov             l6, a3              // output
	movi            l5, 0xbea8
	addu            l5, a0
    ld.b            l5, (l5, 0x0)       // sbr->numTimeSlotsRate

	addi            l4, a1, 0x4         // &qmfs->v_index
	ld.h            l3, (a1, 0x4)       // qmfs->v_index

    movi            l2, 0x1400          // 1280*4

.L0:
    addi            t9, sp, 16          // in_real1
    addi            t8, sp, 144         // in_imag1
    addi            t7, sp, 272         // in_real2
    addi            t6, sp, 400         // in_imag2

	addi            t5, t8, 0x7c        // in_imag1[31]
	addi            t4, t7, 0x7c        // in_real2[31]

	movi            t3, 32              // k = 32
.L1:
	pldbi.d         t0, (l7)            // pX[k]
	asri            t0, t0, 1           // in_real1
	asri            t1, t1, 1           // in_imag2
    stbi.w          t0, (t9)
    stbi.w          t1, (t6)

	pldbi.d         t0, (l7)            // pX[k + 1]
	asri            t0, t0, 1           // in_imag1
	asri            t1, t1, 1           // in_real2
    stbir.w         t0, (t5), l9
.L2:
    stbir.w         t1, (t4), l9
    bloop           t3, .L1, .L2

    addi            a0, sp, 16          // in_real1
    addi            a1, sp, 144         // in_imag1
    addi            a2, sp, 528         // out_real1
    addi            a3, sp, 656         // out_imag1
    bsr             dct4_kernel_asm     // call dct4_kernel_asm

    addi            a0, sp, 272         // in_real2
    addi            a1, sp, 400         // in_imag2
    addi            a2, sp, 784         // out_real2
    addi            a3, sp, 912         // out_imag2
    bsr             dct4_kernel_asm     // call dct4_kernel_asm

    lsli            t9, l3, 2
	add             t9, l8              // pring_buffer_1 = qmfs->v + qmfs->v_index
	add             t8, t9, l2          // pring_buffer_3

	addi            t7, t9, 508         // pring_buffer_1[127]
	addi            t6, t8, 508         // pring_buffer_3[127]
	mov             t5, t9

	movi            t3, 32              // n = 32
    addi            a0, sp, 528         // out_real1
    addi            a1, sp, 780         // out_imag1[31] = 656 + 31*4
    addi            a2, sp, 784         // out_real2
    addi            a3, sp, 1036        // out_imag2[31] = 912 + 31*4
.L3:
    ldbi.w          t0, (a0)            // out_real1[n]
    ldbi.w          t1, (a2)            // out_real2[n]
	sub             t2, t1, t0
	stbi.w          t2, (t9)            // pring_buffer_1[2*n]
	stbi.w          t2, (t8)            // pring_buffer_3[2*n]
	add             t2, t1, t0
	stbir.w         t2, (t7), l9        // pring_buffer_1[127 - 2*n]
	stbir.w         t2, (t6), l9        // pring_buffer_3[127 - 2*n]

    ldbir.w         t0, (a1), l9        // out_imag1[31 - n]
    ldbir.w         t1, (a3), l9        // out_imag2[31 - n]
	add             t2, t1, t0
	stbi.w          t2, (t9)            // pring_buffer_1[2*n + 1]
	stbi.w          t2, (t8)            // pring_buffer_3[2*n + 1]
	sub             t2, t1, t0
	stbir.w         t2, (t7), l9        // pring_buffer_1[127 - (2*n+1)]
.L4:
	stbir.w         t2, (t6), l9        // pring_buffer_3[127 - (2*n+1)]
    bloop           t3, .L3, .L4

	movi            t3, 64              // k = 64
	lrw             t2, qmf_c

.L5:
    movi            t9, 0

	ldbi.w          t4, (t2)            // qmf_c[k+0]
	ldbi.w          t6, (t5)            // pring_buffer_1[k+0]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0xfc)     // qmf_c[k+64]
	ld.w            t6, (t5, 0x2fc)     // pring_buffer_1[k+192]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0x1fc)     // qmf_c[k+128]
	ld.w            t6, (t5, 0x3fc)     // pring_buffer_1[k+256]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0x2fc)     // qmf_c[k+192]
	ld.w            t6, (t5, 0x6fc)     // pring_buffer_1[k+448]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0x3fc)     // qmf_c[k+256]
	ld.w            t6, (t5, 0x7fc)     // pring_buffer_1[k+512]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0x4fc)     // qmf_c[k+320]
	ld.w            t6, (t5, 0xafc)     // pring_buffer_1[k+704]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0x5fc)     // qmf_c[k+384]
	ld.w            t6, (t5, 0xbfc)     // pring_buffer_1[k+768]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0x6fc)     // qmf_c[k+448]
	ld.w            t6, (t5, 0xefc)     // pring_buffer_1[k+960]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0x7fc)     // qmf_c[k+512]
	ld.w            t6, (t5, 0xffc)    // pring_buffer_1[k+1024]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

	ld.w            t4, (t2, 0x8fc)     // qmf_c[k+576]
	ld.w            t6, (t5, 0x12fc)    // pring_buffer_1[k+1216]
    mul.s32         t6, t6, t4
    dexti           t8, t6, t7, 31
	add             t9, t8

.L6:
	stbi.w          t9, (l6)            // output[out++]
    bloop           t3, .L5, .L6

    subi            l3, 128
    bhsz            l3, .L7 
    movi            l3, 1152
.L7:
    st.h            l3, (l4, 0x0)       // qmfs->v_index
	subi            l5, 1
	bhz             l5, .L0

.L20:
    addi            sp, sp, 1040
    pop             l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    .size           sbr_qmf_synthesis_64_asm, .-sbr_qmf_synthesis_64_asm
