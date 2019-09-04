/*
 *
 * void faad_imdct(
 *      mdct_info *mdct,
 *      real_t *X_in,
 *      real_t *X_out)
 */

.import imdct_Z1

    .section        .text.faad_imdct_asm,"ax",@progbits
    .align          2
    .global         faad_imdct_asm
    .type           fadd_imdct_asm, @function

faad_imdct_asm:
    push            l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    ld.h            l0, (a0, 0x0)       // mdct->N
    ld.w            l1, (a0, 0x8)       // mdct->sincos
    ld.w            l2, (a0, 0x4)       // mdct->cfft
    lrw             l3, imdct_Z1
    movi            l4, 0               // scale = 0
    mov             l9, a2

    subi            t0, l0, 1
    and             t0, l0
    bez             t0, .L6
    movi            l4, 1               // b_scale = 1
    lrw             l5, 0x11111111      // scale

.L6:
    lsri            t0, l0, 2           // N4
    mov             l6, l1
    lsli            l7, l0, 1
    subi            l7, l7, 4
    addu            l7, l7, a1          // X_in[N2-1]
    movi            t1, 8
    neg.s32.s       t9, t1
    mov             l8, l3

.L0:
    pldbi.d         t2, (l6)            // sincos[k]
    ldbir.w         t4, (a1), t1        // X_in[2k]
    ldbir.w         t5, (l7), t9        // X_in[N2-1-2k]
    mul.s32.h       t7, t5, t2          // real
    muls.s32.hs     t7, t3, t4
    lsli            t7, t7, 1
    mul.s32.h       t6, t2, t4          // image
    mula.s32.hs     t6, t3, t5
    lsli            t6, t6, 1
    stbi.w          t7, (l8)

.L1:
    stbi.w          t6, (l8)
    bloop           t0, .L0, .L1

    mov             a0, l2
    mov             a1, l3
    bsr             cfftb               // call cfftb

    lsri            t0, l0, 2           // N4
    mov             l6, l3
    mov             l7, l6
    mov             l8, l1

.L2:
    pldbi.d         t2, (l6)            // RE(x), IM(x)
    pldbi.d         t4, (l8)            // RE(sincos[k]), IM(sincos[k])
    mul.s32.h       t6, t2, t4
    muls.s32.hs     t6, t3, t5
    lsli            t6, t6, 1
    mul.s32.h       t7, t2, t5
    mula.s32.hs     t7, t3, t4
    lsli            t7, t7, 1

    bez             l4, .L3
    mul.s32         t4, t6, l5
    dexti           t6, t4, t5, 28
    mul.s32         t4, t7, l5
    dexti           t7, t4, t5, 28

.L3:
    stbi.w          t6, (l7)
    stbi.w          t7, (l7)
    subi            t0, t0, 1
    bnez            t0, .L2


    mov             a2, l9
    lsri            t9, l0, 4           // N8
    lsli            l5, l0, 1
    addu            l4, l5, l0          // N2+N4
    addu            l1, l5, a2          // X_out[N2]
    addu            l2, l0, a2          // X_out[N4]
    addu            l4, l4, a2          // X_out[N2+N4]
    addu            l5, l5, l3          // Z1[N4-1]
    subi            l5, l5, 4
    addu            l6, l0, l3          // Z1[N8]
    subi            l7, l6, 4           // Z1[N8-1]
    movi            l8, 4
    neg.s32.s       l8, l8

.L4:
    pldbi.d         t0, (l3)            // Z1[k]
    pldbi.d         t2, (l3)
    neg.s32.s       t1, t1
    neg.s32.s       t3, t3
    stbi.w          t0, (l2)            // X_out[N4+2k]
    pldbir.d        t4, (l5), l8        // z1[N4-1]
    pldbir.d        t6, (l5), l8
    neg.s32.s       t4, t4
    neg.s32.s       t6, t6
    st.w            t4, (l2, 0x0)       // X_out[N4+1+2k]
    st.w            t2, (l2, 0x4)       // X_out[N4+2+2k]
    st.w            t6, (l2, 0x8)       // X_out[N4+3+2k]
    addi            l2, l2, 12
    st.w            t1, (l4, 0x0)       // X_out[N2+N4+2k]
    st.w            t5, (l4, 0x4)       // X_out[N2+N4+1+2K]
    st.w            t3, (l4, 0x8)       // X_out[N2+N4+2+2K]
    st.w            t7, (l4, 0xc)       // X_out[N2+N4+3+2K]
    addi            l4, l4, 16

    ld.w            t0, (l6, 0x0)       // Z1[N8]
    ld.w            t1, (l6, 0x4)
    ldbir.w         t4, (l7), l8        // Z1[N8-1]
    ld.w            t2, (l6, 0x8)
    ldbir.w         t5, (l7), l8        // Z1[N8-1]
    ld.w            t3, (l6, 0xc)
    ldbir.w         t6, (l7), l8        // Z1[N8-1]
    addi            l6, l6, 16
    ldbir.w         t7, (l7), l8        // Z1[N8-1]
    neg.s32.s       t4, t4
    neg.s32.s       t5, t5
    neg.s32.s       t6, t6
    neg.s32.s       t7, t7
    st.w            t1, (a2, 0x0)       // Xout_[2k]
    st.w            t5, (a2, 0x4)       // X_out[1+2k]
    st.w            t3, (a2, 0x8)       // X_out[2+2k]
    st.w            t7, (a2, 0xc)       // X_out[3+2k]
    addi            a2, a2, 16
    st.w            t0, (l1, 0x0)       // X_out[N2+2k]
    st.w            t4, (l1, 0x4)       // X_out[N2+1+2k]
    st.w            t2, (l1, 0x8)       // X_out[N2+2+2k]
    st.w            t6, (l1, 0xc)       // X_out[N2+3+2k]

.L5:
    addi            l1, l1, 16
    bloop           t9, .L4, .L5

    pop             l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    .size           faad_imdct_asm, .-faad_imdct_asm
