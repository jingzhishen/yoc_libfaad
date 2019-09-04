/*
 * static void passf4pos(
 *      const uint16_t ido,
 *      const uint16_t l1,
 *      const complex_t *cc,
 *      complex_t *ch,
 *      const complex_t *wa1,
 *      const complex_t *wa2,
 *      const complex_t *wa3)
 */

    .section        .text.passf4pos_asm,"ax",@progbits
    .align          2
    .global         passf4pos_asm
    .type           passf4pos_asm, @function

passf4pos_asm:
    push            l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    subi            sp, sp, 4
    st.w            a1, (sp, 0x0)
    cmpnei          a0, 1               // if branch
    bt              .L2
    mov             t9, a1
    lsli            l0, a1, 3

.L0:
    addi            t8, a3, 4           // the start of im
    mov             l1, a3
    pldbi.d         t0, (a2)            // cc[ac]
    pldbi.d         t2, (a2)            // cc[ac+1]
    pldbi.d         t4, (a2)            // cc[ac+2]
    pldbi.d         t6, (a2)            // cc[ac+3]
    addu            l3, t0, t4          // RE(t2)
    subu            l4, t0, t4          // RE(t1)
    addu            l5, t1, t5          // IM(t2)
    subu            l6, t1, t5          // IM(t1)
    addu            l7, t2, t6          // RE(t3)
    subu            l8, t2, t6          // IM(t4)
    addu            l9, t3, t7          // IM(t3)
    subu            t0, t7, t3          // RE(t4)

    addu            t1, l3, l7          // RE[ch[ah]]
    subu            t2, l3, l7          // RE(ch[ah+2*l1])
    stbir.w         t1, (l1), l0
    addu            t3, l5, l9          // IM(ch[ah])
    subu            t4, l5, l9          // IM(ch[ah+2*l1])
    stbir.w         t3, (t8), l0
    addu            t5, l4, t0          // RE(ch[ah+l1])
    subu            t6, l4, t0          // RE(ch[ah+3*l1])
    stbir.w         t5, (l1), l0
    stbir.w         t2, (l1), l0
    stbir.w         t6, (l1), l0
    addu            t7, l6, l8          // IM(ch[ah+l1])
    subu            t1, l6, l8          // IM(ch[ah=3*l1])
    stbir.w         t7, (t8), l0
    stbir.w         t4, (t8), l0
    stbir.w         t1, (t8), l0

.L1:
    addi            a3, a3, 8
    bloop           t9, .L0, .L1
    br              .L7

.L2:                                    // else branch
    movi            t0, 0               // k = 0

.L3:
    ld.w            a1, (sp, 0x0)
    cmplt           t0, a1              // k < l1
    bf              .L7
    ld.w            l0, (sp, 0x30)      // complex_t *wa1
    ld.w            l1, (sp, 0x34)      // complex_t *wa2
    ld.w            l2, (sp, 0x38)      // complex_t *wa3
    lsli            lr, a0, 3
    lsli            l3, a0, 5           // ac = 4*k*ido
    mult            l3, l3, t0
    addu            l3, l3, a2          // cc[ac]
    addu            l4, l3, lr          // cc[ac+ido]
    addu            l5, l4, lr          // cc[ac+2ido]
    addu            l6, l5, lr          // cc[ac+3ido]
    mult            l7, t0, lr          // ah = k*ido
    mult            lr, a1, a0          // l1*ido
    lsli            lr, lr, 3
    addu            l7, l7, a3          // ch[ah]
    addu            l8, l7, lr          // ch[ah+ido]
    addu            l9, l8, lr          // ch[ah+2ido]
    addu            lr, l9, lr          // ch[ah+3ido]
    mov             t1, a0              // i

.L4:
    pldbi.d         t2, (l3)            // cc[ac+i]
    pldbi.d         t4, (l5)            // cc[ac+i+2ido]
    addu            t6, t2, t4          // RE[t2]
    subu            t7, t2, t4          // RE[t1]
    addu            t8, t3, t5          // IM[t2]
    subu            t9, t3, t5          // IM[t1]
    ldbi.w          t2, (l4)            // cc[ac+i+ido]
    ldbi.w          t3, (l6)            // cc[ac+i+3ido]
    addu            t4, t2, t3          // RE(t3)
    subu            t5, t2, t3          // IM(t4)
    addu            t2, t4, t6          // RE(ch[ah+i])
    subu            t3, t6, t4          // RE(c3)
    stbi.w          t2, (l7)
    addu            t4, t9, t5          // IM[c2]
    subu            t6, t9, t5          // IM[c4]
    ldbi.w          t2, (l4)            // cc[ac+i+ido]
    ldbi.w          t5, (l6)            // cc[ac+i+3ido]
    addu            t9, t2, t5          // IM(t3)
    subu            t2, t5, t2          // RE(t4)
    addu            t5, t8, t9          // IM(ch[ah+i])
    subu            t9, t8, t9          // IM(c3)
    stbi.w          t5, (l7)
    addu            t8, t7, t2          // RE(c2)
    subu            t5, t7, t2          // RE(c4)

    ldbi.w          t2, (l0)            // RE(wa1[i])
    ldbi.w          t7, (l0)            // IM(wa1[i])
    mul.s32.h       a1, t4, t2
    mula.s32.hs     a1, t8, t7
    lsli            a1, a1, 1
    mul.s32.h       t8, t8, t2
    muls.s32.hs     t8, t4, t7
    lsli            t8, t8, 1
    stbi.w          t8, (l8)
    stbi.w          a1, (l8)

    ldbi.w          t2, (l1)            // RE(wa2[i])
    ldbi.w          t7, (l1)            // IM(wa2[i])
    mul.s32.h       a1, t9, t2
    mula.s32.hs     a1, t3, t7
    lsli            a1, a1, 1
    mul.s32.h       t4, t3, t2
    muls.s32.hs     t4, t9, t7
    lsli            t4, t4, 1
    stbi.w          t4, (l9)
    stbi.w          a1, (l9)

    ldbi.w          t2, (l2)            // RE(wa3[i])
    ldbi.w          t3, (l2)            // IM(wa3[i])
    mul.s32.h       t7, t5, t3
    mula.s32.hs     t7, t2, t6
    lsli            t7, t7, 1
    mul.s32.h       t9, t5, t2
    muls.s32.hs     t9, t3, t6
    lsli            t9, t9, 1
    stbi.w          t9, (lr)

.L5:
    stbi.w          t7, (lr)
    bloop           t1, .L4, .L5

.L6:
    addi            t0, t0, 1
    br              .L3

.L7:
    addi            sp, sp, 4
    pop             l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    .size           passf4pos_asm, .-passf4pos_asm
