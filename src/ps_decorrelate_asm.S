/*
 *void ps_decorrelate(ps_info *ps, qmf_t X_left[38][64], qmf_t X_right[38][64],
 *                         qmf_t X_hybrid_left[32][32], qmf_t X_hybrid_right[32][32])
 */

.import memset
.import g_filter_a
.import Phi_Fract_Qmf
.import Phi_Fract_SubQmf34
.import Phi_Fract_SubQmf20
.import Q_Fract_allpass_SubQmf34
.import Q_Fract_allpass_SubQmf20
.import Q_Fract_allpass_Qmf

    .section        .text.ps_decorrelate_asm,"ax",@progbits
    .align          2
    .global         ps_decorrelate_asm
    .type           ps_decorrelate_asm, @function

ps_decorrelate_asm:
    push            l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
	movi            l9, 8824
	subu            sp, l9              // 32*34*2*4 + 30*4=8824
    ld.b            l7, (a0, 0x2d7)     // ps->num_hybrid_groups
    ld.w            l6, (a0, 0x2dc)     // ps->group_border
    ld.w            l5, (a0, 0x2e0)     // ps->map_group2bk
    addi            l4, a0, 0xa         // ps->border_position
    ld.b            l3, (a0, 0x9)       // ps->num_env

	st.w            a0, (sp, 0x0)
	st.w            a1, (sp, 0x4)
	st.w            a2, (sp, 0x8)
	st.w            a3, (sp, 0xc)

	movi            a2, 4352            // 32*34*4 
	movi            a1, 0
	addi            a0, sp, 120         // P
	bsr             memset
	movi            a2, 4352            // 32*34*4 
	movi            a1, 0
	movi            l9, 4472
	add             a0, sp, l9          // G_TransientRatio
	bsr             memset

	ld.w            a0, (sp, 0x0)       // restore a0
	ld.w            a3, (sp, 0xc)       // restore a3
    ld.b            l9, (a0, 0x2d4)     // ps->use34hybrid_bands
	lrw             t9, Phi_Fract_SubQmf34
	bnez            l9, .Ln1
	lrw             t9, Phi_Fract_SubQmf20
.Ln1:
	st.w            t9, (sp, 0x10)      // Phi_Fract_SubQmf

	add             l3, l4              // border_position + 1*ps->num_env
    ld.b            l9, (l3, 0x0)       // ps->border_position[ps->num_env]
	st.w            l9, (sp, 0x14)      // ps->border_position[ps->num_env]

	movi            t4, 34              // P[32][34] => col = 34
	movi            t0, 0               // gr

	addi            a1, sp, 120         // P
	movi            a2, 136             // P[32][34] ==> 34*4 
    ld.b            lr, (a0, 0x2d6)     // ps->num_groups

.L0:                                    // for (gr = 0; gr < ps->num_groups; gr++)
	movi            t1, 0xff
    ldbi.h          t9, (l5)
	and             t9, t1              // bk

    ldbi.b          t8, (l6)            // sb = ps->group_border[gr]
	addi            t7, t8, 1           // maxsb
	//ld.w            l2, (sp, 0xc)       // X_hybrid_left or X_left ==> input = X_hybrid_left
	mov             l2, a3              // X_hybrid_left or X_left ==> input = X_hybrid_left
	movi            l3, 256             // complex_t X_hybrid_left[32][32] ==> 32*8 
	movi            t1, 32              // X_hybrid_left => col = 32
    cmplt           t0, l7              // gr < ps->num_hybrid_groups
    bt              .L1
    ld.b            t7, (l6, 0x0)       // maxsb = group_border[gr+1]
    ld.w            l2, (sp, 0x4)       // X_hybrid_left or X_left ==> input = X_left
	movi            l3, 512             // complex_t X_left[38][64] ==> 64*8 
	movi            t1, 64              // X_left => col = 64
.L1:
    ld.b            l8, (l4, 0x0)       // n = ps->border_position[0]
	mov             t6, t8              // sb
	mula.32.l       t6, l8, t1          // col*n+sb
	lsli            t6, t6, 3           // 8*(col*n+sb)
	add             l1, l2, t6          // &input[n][sb][0] = input + 8*(col*n+sb)
	addi            l0, l1, 4           // &input[n][sb][1] = input + 8*(col*n+sb) + 4

	mov             t6, t9              // bk
	mula.32.l       t6, l8, t4          // 34*n+bk
	lsli            t6, t6, 2           // 4*(34*n+bk)
	add             t5, a1, t6          // &P[n][bk]==> P + 4*(34*n+bk)
.L2:
	ld.w            t3, (t5)            // P[n][bk]

	ldbir.w         t2, (l1), l3        // t2 = inputLeft[0]
	asri            t2, t2, 14
	mula.32.l       t3, t2, t2          // in_re*in_re
	ldbir.w         t2, (l0), l3        // t2 = inputLeft[1]
	asri            t2, t2, 14
	mula.32.l       t3, t2, t2          // in_re*in_re + in_im*in_im

	stbir.w         t3, (t5), a2        // P[n][bk] += in_re*in_re + in_im*in_im

    addi            l8, 1               // n++
    cmplt           l8, l9              // n < ps->border_position[ps->num_env]
    bt              .L2

    addi            t8, 1               // sb++
    cmplt           t8, t7              // sb < maxsb
    bt              .L1

.L3:
    addi            t0, 1               // gr++
	cmplt           t0, lr
	bt              .L0                 // gr < ps->num_groups


	movi            l7, 4472            // 32*34*4+30*4
	add             l7, sp              // G_TransientRatio
	movi            l6, 0x0             // bk = 0
    ld.b            l5, (a0, 0x2d8)     // ps->nr_par_bands
	movi            t9, 0x4000  
	add             t9, a0              // a0 + 16k
    addi            l3, t9, 0xf84       // &ps->P_SmoothPeakDecayDiffNrg_prev ==> (a0 + 0x4f84)
	movih           l2, 0x1800          // gamma
    ld.w            l1, (t9, 0xe6c)     // ps->alpha_decay    ==> (a0 + 0x4e6c)
	addi            l0, t9, 0xe74       // ps->P_PeakDecayNrg ==> (a0 + 0x4e74)
    addi            t3, t9, 0xefc       // &ps->P_prev        ==> (a0 + 0x4efc)
    ld.w            t0, (t9, 0xe70)     // ps->alpha_smooth   ==> (a0 + 0x4e70)

.L4:
    movi            t4, 34
    ld.b            l8, (l4, 0x0)       // n = ps->border_position[0]
	mov             t6, l6              // bk
	mula.32.l       t6, l8, t4          // 34*n+bk
	lsli            t6, t6, 2           // 4*(34*n+bk)
	add             t5, a1, t6          // &P[n][bk]==> P + 4*(34*n+bk)
	add             lr, l7, t6          // &G_TransientRatio[n][bk]
	ld.w            t2, (l3, 0x0)       // ps->P_SmoothPeakDecayDiffNrg_prev[bk]
	ld.w            t1, (l0, 0x0)       // ps->P_PeakDecayNrg[bk]
	ld.w            t7, (t3, 0x0)       // ps->P_prev[bk]
.L5:
    mul.s32         t8, t1, l1
    dexti           t1, t8, t9, 31      // ps->P_PeakDecayNrg[bk] = MUL_F(ps->P_PeakDecayNrg[bk], ps->alpha_decay)

	ldbir.w         t6, (t5), a2        // P[n][bk]
    cmplt           t1, t6              // ps->P_PeakDecayNrg[bk] < P[n][bk]
    bf              .L6
	mov             t1, t6              // ps->P_PeakDecayNrg[bk] = P[n][bk]
.L6:
	sub             t4, t1, t6          // ps->P_PeakDecayNrg[bk] - P[n][bk]
	sub             t4, t2              // ps->P_PeakDecayNrg[bk] - P[n][bk] - ps->P_SmoothPeakDecayDiffNrg_prev[bk]
    mul.s32         t8, t4, t0          // *ps->alpha_smooth
    dexti           t4, t8, t9, 31      // 
	add             t2, t4              // P_SmoothPeakDecayDiffNrg +=

	sub             t4, t6, t7          // P[n][bk] - ps->P_prev[bk]
    mul.s32         t8, t4, t0          // *ps->alpha_smooth
    dexti           t4, t8, t9, 31      // 
	add             t7, t4              // nrg +=

    mul.s32         t8, t2, l2          //
    dexti           t4, t8, t9, 28      // P_SmoothPeakDecayDiffNrg*gamma 

    cmplt           t7, t4              // !(P_SmoothPeakDecayDiffNrg*gamma <= nrg) 
	movi            t8, 0x4000
    bf              .L7
	mul.s32         t8, t7, t8          // (int64_t)nrg << 14 ==> t8 = low32, t9 = high32
	divsl           t8, t8, t4          // ((int64_t)nrg << 14)/(P_SmoothPeakDecayDiffNrg*gamma) ==> t8 = low32, t9 = high32
.L7:
	stbir.w         t8, (lr), a2        // G_TransientRatio[n][bk]

    addi            l8, 1               // n++
    cmplt           l8, l9              // n < ps->border_position[ps->num_env]
    bt              .L5

	stbi.w          t7, (t3)            // ps->P_prev[bk] = nrg
	stbi.w          t1, (l0)            // ps->P_PeakDecayNrg[bk]
	stbi.w          t2, (l3)            // ps->P_SmoothPeakDecayDiffNrg_prev[bk] = P_SmoothPeakDecayDiffNrg

.L8:
    addi            l6, 1               // bk++
	cmplt           l6, l5
	bt              .L4                 // bk < ps->nr_par_bands




.L12:
    ld.b            l7, (a0, 0x2d7)     // ps->num_hybrid_groups
    ld.b            l5, (a0, 0x2e4)     // temp_delay = ps->saved_delay
	movi            lr, 0               // gr
    /* for (gr = 0; gr < ps->num_groups; gr++) */
.L13:
    ld.b            t0, (a0, 0x2d6)     // ps->num_groups
	cmplt           lr, t0              // gr < ps->num_groups
	bf              .L44
    ld.w            t0, (a0, 0x2e0)     // ps->map_group2bk
	lsli            t1, lr, 1
	add             t0, t1              // &ps->map_group2bk[gr]
	movi            t1, 0xff
    ld.h            t0, (t0, 0x0)
	and             t0, t1              // bk
	st.w            t0, (sp, 0x28)      // bk => sp + 10*4

	/* for (sb = ps->group_border[gr]; sb < maxsb; sb++) */
    ld.w            t6, (a0, 0x2dc)     // ps->group_border
	add             t6, lr
    ldbi.b          t8, (t6)            // sb = ps->group_border[gr]
	addi            t7, t8, 1           // maxsb
    cmplt           lr, l7              // gr < ps->num_hybrid_groups
    bt              .L14
    ld.b            t7, (t6, 0x0)       // maxsb = group_border[gr+1]
	/* t6 is no used here*/
.L14:
	cmplt           t8, t7              // sb < maxsb
	bf              .L43
	bmaski          t0, 31              // g_DecaySlope = 0x7FFFFFFF
    cmplt           lr, l7              // gr < ps->num_hybrid_groups
	bt              .L17
.L15:
    ld.b            t9, (a0, 0x2da)     // ps->decay_cutoff
    cmplt           t9, t8              // !(sb <= ps->decay_cutoff)
	bf              .L17
.L16:
	sub             t1, t9, t8          // decay = ps->decay_cutoff - sb
	movi            t2, 0
	subi            t2, 20              // -20
	cmplt           t2, t1              // !(decay <= -20)
	movi            t0, 0
    bf              .L17
	lrw             t2, 0x6666666       // DECAY_SLOPE 
	bmaski          t0, 31              // g_DecaySlope = 0x7FFFFFFF
	mula.32.l       t0, t2, t1          // FRAC_CONST(1.0) + DECAY_SLOPE * decay 
	/* t1, t2, t3, t9 is no used here*/
.L17:
	/* for (m = 0; m < 3; m++) and for (n = 0; n < 3; n++) */
	addi            t1, sp, 80         // 20*4 => g_DecaySlope_filt
	lrw             t2, g_filter_a
	ldbi.w          t3, (t2)
    mul.s32         t4, t0, t3         // g_DecaySlope * filter_a[0]
    dexti           t4, t4, t5, 31     //
	stbi.w          t4, (t1)
	ldbi.w          t3, (t2)
    mul.s32         t4, t0, t3         // g_DecaySlope * filter_a[1]
    dexti           t4, t4, t5, 31     //
	stbi.w          t4, (t1)
	ldbi.w          t3, (t2)
    mul.s32         t4, t0, t3         // g_DecaySlope * filter_a[2]
    dexti           t4, t4, t5, 31     //
	stbi.w          t4, (t1)

	/* save temp_delay_ser below */
	addi            t0, sp, 92         // (20+3)*1 => temp_delay_ser
	addi            t1, a0, 0x2e5      // ps->

	ldbi.h          t2, (t1)           // n = 0, 1 
	stbi.h          t2, (t0)
	ldbi.b          t2, (t1)           // n = 2 
	stbi.b          t2, (t0)
	/* t0, t1, t2, t3, t4, t5 is no used here*/

	/* push ps->delay_buf_index_delay[sb] to stack before loop(n), don't forget save the new value */
	addi            t1, a0, 0x32b       // ps->delay_buf_index_delay
	add             t1, t8              // ps->delay_buf_index_delay + sb
    ld.b            t1, (t1, 0x0)       // ps->delay_buf_index_delay[sb]
	st.w            t1, (sp, 0x2c)      // sp + 11*4 = ps->delay_buf_index_delay[sb]

	addi            t1, a0, 0x2eb       // ps->delay_D
	add             t1, t8              // ps->delay_D + sb
    ld.b            t1, (t1, 0x0)       // ps->delay_D[sb]
	st.w            t1, (sp, 0x30)      // sp + 12*4 = ps->delay_D[sb]
	/* t0, t1, t2, t3, t4, t5 is no used here*/

.L18:
	/* for (n = ps->border_position[0]; n < ps->border_position[ps->num_env]; n++) */
    ld.b            t0, (a0, 0xa)       // n = ps->border_position[0]
.L19:
	ld.w            l2, (sp, 0xc)       // X_hybrid_left or X_left ==> input = X_hybrid_left (a3)
	movi            t2, 256             // complex_t X_hybrid_left[32][32] ==> 32*8 
	movi            t1, 32              // X_hybrid_left => col = 32
    cmplt           lr, l7              // gr < ps->num_hybrid_groups
    bt              .L20
    ld.w            l2, (sp, 0x4)       // X_hybrid_left or X_left ==> input = X_left (a1)
	movi            t2, 512             // complex_t X_left[38][64] ==> 64*8 
	movi            t1, 64              // X_left => col = 64
.L20:
	mov             t3, t8              // sb
	mula.32.l       t3, t1, t0          // col*n+sb
	lsli            t3, t3, 3           // 8*(col*n+sb)
	add             l1, l2, t3          // &input[n][sb][0] = input + 8*(col*n+sb)
	addi            l0, l1, 4           // &input[n][sb][1] = input + 8*(col*n+sb) + 4
	/* t1, t3, t4, t5, t6 is no used here, t0, t2, l0, l1, l2 used*/
.L21:
	/* if (sb > ps->nr_allpass_bands && gr >= ps->num_hybrid_groups) */
    ld.b            t1, (a0, 0x2d9)     // ps->nr_allpass_bands
	cmplt           t1, t8              // sb > ps->nr_allpass_bands
	/* t1 is no used here */
    bf              .L22
    cmplt           lr, l7              // gr < ps->num_hybrid_groups
    bt              .L22

	//addi            t1, a0, 0x32b       // ps->delay_buf_index_delay
	//add             t1, t8              // ps->delay_buf_index_delay + sb
    //ld.b            t1, (t1, 0x0)       // ps->delay_buf_index_delay[sb]
	ld.w            t1, (sp, 0x2c)      // sp + 11*4 = ps->delay_buf_index_delay[sb]

	addi            t3, a0, 0x36c       // ps->delay_Qmf ==> [14][64]
	lsli            t1, t1, 6           // (col = 64)*ps->delay_buf_index_delay[sb]
	add             t1, t8
	lsli            t1, t1, 3           // 8*((col = 64)*ps->delay_buf_index_delay[sb] + sb)
	add             t3, t1              // ps->delay_Qmf[ps->delay_buf_index_delay[sb]][sb]

	ld.w            t6, (t3, 0x0)       // R0[0] = ps->delay_Qmf[ps->delay_buf_index_delay[sb]][sb][0]
	ld.w            t9, (t3, 0x4)       // R0[1] = ps->delay_Qmf[ps->delay_buf_index_delay[sb]][sb][1]
	ldbir.w         t4, (l1), t2        // inputLeft[0]
	ldbir.w         t5, (l0), t2        // inputLeft[1]
	stbi.w          t4, (t3)
	st.w            t5, (t3, 0x0)
	/* t1, t3, t4, t5 is no used here, t6, t9 is used*/
    br              .L34
.L22:
    cmplt           lr, l7              // gr < ps->num_hybrid_groups
    bf              .L23

	movi            t3, 0x1f6c 
	add             t3, a0              // ps->delay_SubQmf => [2][32]
	lsli            t1, l5, 5           // (col = 32)*temp_delay
	add             t1, t8
	lsli            t1, t1, 3           // 8*((col = 32)*temp_delay + sb)
	add             t3, t1              // ps->delay_SubQmf[temp_delay][sb]

	ld.w            l8, (t3, 0x0)       // tmp0[0] = ps->delay_SubQmf[temp_delay][sb][0]
	ld.w            l9, (t3, 0x4)       // tmp0[1] = ps->delay_SubQmf[temp_delay][sb][1]
	ldbir.w         t4, (l1), t2        // inputLeft[0]
	ldbir.w         t5, (l0), t2        // inputLeft[1]
	stbi.w          t4, (t3)
	st.w            t5, (t3, 0x0)
	/* t1, t3, t4, t5 is no used here, l8, l9 is used*/

	lsli            t1, t8, 3           // Phi_Fract_SubQmf[sb] => sb*8
	ld.w            t3, (sp, 0x10)      // Phi_Fract_SubQmf
	add             t3, t1              // &Phi_Fract_SubQmf[sb]
	ld.w            l3, (t3, 0x0)       // Phi_Fract[0] = Phi_Fract_SubQmf[sb][0]
	ld.w            l4, (t3, 0x4)       // Phi_Fract[1] = Phi_Fract_SubQmf[sb][1]
	/* t1, t3, t4, t5 is no used here, l3, l4, l8, l9 is used*/
    br              .L24

.L23:
	addi            t3, a0, 0x36c       // ps->delay_Qmf ==> [14][64]
	lsli            t1, l5, 6           // (col = 64)*temp_delay
	add             t1, t8
	lsli            t1, t1, 3           // 8*((col = 64)*temp_delay + sb)
	add             t3, t1              // ps->delay_Qmf[temp_delay][sb]

	ld.w            l8, (t3, 0x0)       // tmp0[0] = ps->delay_Qmf[temp_delay][sb][0]
	ld.w            l9, (t3, 0x4)       // tmp0[1] = ps->delay_Qmf[temp_delay][sb][1]
	ldbir.w         t4, (l1), t2        // inputLeft[0]
	ldbir.w         t5, (l0), t2        // inputLeft[1]
	stbi.w          t4, (t3)
	st.w            t5, (t3, 0x0)
	/* t1, t3, t4, t5 is no used here, l8, l9 is used*/

	lsli            t1, t8, 3           // Phi_Fract_SubQmf[sb] => sb*8
	lrw             t3, Phi_Fract_Qmf
	add             t3, t1              // &Phi_Fract_SubQmf[sb]
	ld.w            l3, (t3, 0x0)       // Phi_Fract[0] = Phi_Fract_SubQmf[sb][0]
	ld.w            l4, (t3, 0x4)       // Phi_Fract[1] = Phi_Fract_SubQmf[sb][1]
	/* t1, t3, t4, t5 is no used here, l3, l4, l8, l9 is used*/

.L24:
	/* ComplexMult(&tmp[0], &tmp[1], tmp0[0], tmp0[1], Phi_Fract[0], Phi_Fract[1]) */
    mul.s32.h       t6, l8, l3
    mula.s32.hs     t6, l9, l4
	lsli            t6, t6, 1           // t6 = R0[0]
    mul.s32.h       t9, l9, l3
    muls.s32.hs     t9, l8, l4
	lsli            t9, t9, 1           // t9 = R0[1]
	/* t1, t3, t4, t5, l3, l4, l8, l9 is no used, t6, t9 is used*/

.L25:
	/* for (m = 0; m < 3; m++) */
	movi            a1, 0
	movi            a3, 3
	addi            t1, sp, 92         // (20+3)*1 => temp_delay_ser
.L26:
	ldbi.b          t3, (t1)            // temp_delay_ser[m] == ps->delay_buf_index_ser[m] 
    cmplt           lr, l7              // gr < ps->num_hybrid_groups
    bf              .L30
	//addi            t3, a0, 0x2e5       // &ps->delay_buf_index_ser == temp_delay_ser[m]
	//add             t3, a1              // &ps->delay_buf_index_ser[m] = ps->delay_buf_index_ser + m
	//ld.b            t3, (t3, 0x0)       // temp_delay_ser[m] == ps->delay_buf_index_ser[m] 

	movi            t5, 5
	mula.32.l       t3, a1, t5          // ps->delay_SubQmf_ser[m][temp_delay_ser[m]] => m*5 + temp_delay_ser[m]
	lsli            t3, t3, 5           // 32*(ps->delay_SubQmf_ser[m][temp_delay_ser[m]])
	add             t3, t8              // 32*(ps->delay_SubQmf_ser[m][temp_delay_ser[m]]) + sb
	lsli            t3, t3, 3           // 8*(64*(ps->delay_SubQmf_ser[m][temp_delay_ser[m]]) + sb)

	movi            a2, 0x3f6c
	add             a2, a0              // ps->delay_SubQmf_ser
	add             a2, t3              // &ps->delay_SubQmf_ser[m][temp_delay_ser[m]][sb]
	ld.w            l8, (a2, 0x0)       // tmp0[0] = ps->delay_SubQmf_ser[m][temp_delay_ser[m]][sb][0]
	ld.w            l9, (a2, 0x4)       // tmp0[1] = ps->delay_SubQmf_ser[m][temp_delay_ser[m]][sb][1]
	/* t1, t3, t4, t5, l3, l4 is no used, t6, t9, a2, l8, l9 is used*/
    ld.b            t3, (a0, 0x2d4)     // ps->use34hybrid_bands
	lrw             t5, Q_Fract_allpass_SubQmf34
	bnez            t3, .L27
	lrw             t5, Q_Fract_allpass_SubQmf20
.L27:
	movi            t3, 3
	mult            t3, t8, t3          // Q_Fract_allpass_SubQmf[][3]   => sb*3
	add             t3, a1              // Q_Fract_allpass_SubQmf[sb][m] => sb*3 + m
	lsli            t3, t3, 3           // 8*(Q_Fract_allpass_SubQmf[sb][m])

	add             t5, t3              // &Q_Fract_allpass_Qmf[sb][m]
	ld.w            l3, (t5, 0x0)       // Q_Fract_allpass[0] = Q_Fract_allpass_Qmf[sb][m][0]
	ld.w            l4, (t5, 0x4)       // Q_Fract_allpass[1] = Q_Fract_allpass_Qmf[sb][m][1]
	/* t1, t3, t4, t5 is no used, t6, t9, a2, l3, l4, l8, l9 is used*/

	/* ComplexMult(&tmp[0], &tmp[1], tmp0[0], tmp0[1], Q_Fract_allpass[0], Q_Fract_allpass[1]); */
    mul.s32.h       t4, l8, l3
    mula.s32.hs     t4, l9, l4
	lsli            t4, t4, 1           // t4 = tmp[0]
    mul.s32.h       t5, l9, l3
    muls.s32.hs     t5, l8, l4
	lsli            t5, t5, 1           // t5 = tmp[1]
	/* t1, t3, l3, l4, l8, l9 is no used, t4, t5, t6, t9 is used*/
	lsli            t3, a1, 2
	add             t3, sp
	addi            t3, 80              // (20)*4 => g_DecaySlope_filt
	ld.w            t3, (t3, 0x0)       // g_DecaySlope_filt[m] 

    mul.s32         l3, t3, t6          // g_DecaySlope_filt[m]*R0[0]
    dexti           l3, l3, l4, 31
	sub             t4, l3              // tmp[0] += -

    mul.s32         l3, t3, t9          // g_DecaySlope_filt[m]*R0[1]
    dexti           l3, l3, l4, 31
	sub             t5, l3              // tmp[1] += -
	/* t1, l3, l4, l8, l9 is no used, t3, t4, t5, t6, t9, a2 is used*/
    mul.s32         l3, t3, t4          // g_DecaySlope_filt[m]*tmp[0]
    dexti           l3, l3, l4, 31
	add             l8, t6, l3          // tmp2[0] = R0[0] + g_DecaySlope_filt[m]*tmp[0]
    mul.s32         l3, t3, t5          // g_DecaySlope_filt[m]*tmp[1]
    dexti           l3, l3, l4, 31
	add             l9, t9, l3          // tmp2[1] = R0[1] + g_DecaySlope_filt[m]*tmp[1]
	/* t1, t3, t6, t9, l3, l4 is no used, t4, t5, a2, l8, l9 is used*/
	st.w            l8, (a2, 0x0)       // ps->delay_Qmf_ser[m][temp_delay_ser[m]][sb][0] = tmp2[0]
	st.w            l9, (a2, 0x4)       // ps->delay_Qmf_ser[m][temp_delay_ser[m]][sb][1] = tmp2[1]
	mov             t6, t4              // R0[0] = tmp[0]
	mov             t9, t5              // R0[1] = tmp[1]
	/* t1, t3, t4, t5, l3, l4, l8, l9 is no used, t6, t9, a2 is used*/

    br              .L32
.L30:
	//lsli            t3, a1, 2
	//add             t3, sp
	//addi            t3, 92              // (20+3)*4 => temp_delay_ser
	//ld.w            t3, (t3, 0x0)       // temp_delay_ser[m] 

	movi            t5, 5
	mula.32.l       t3, a1, t5          // ps->delay_Qmf_ser[m][temp_delay_ser[m]] => m*5 + temp_delay_ser[m]
	lsli            t3, t3, 6           // 64*(ps->delay_Qmf_ser[m][temp_delay_ser[m]])
	add             t3, t8              // 64*(ps->delay_Qmf_ser[m][temp_delay_ser[m]]) + sb
	lsli            t3, t3, 3           // 8*(64*(ps->delay_Qmf_ser[m][temp_delay_ser[m]]) + sb)

	movi            a2, 0x216c
	add             a2, a0              // ps->delay_Qmf_ser
	add             a2, t3              // &ps->delay_Qmf_ser[m][temp_delay_ser[m]][sb]
	ld.w            l8, (a2, 0x0)       // tmp0[0] = ps->delay_Qmf_ser[m][temp_delay_ser[m]][sb][0]
	ld.w            l9, (a2, 0x4)       // tmp0[1] = ps->delay_Qmf_ser[m][temp_delay_ser[m]][sb][1]
	/* t1, t3, t4, t5, l3, l4 is no used, t6, t9, a2, l8, l9 is used*/

	movi            t3, 3
	mult            t3, t8, t3          // Q_Fract_allpass_Qmf[][3]   => sb*3
	add             t3, a1              // Q_Fract_allpass_Qmf[sb][m] => sb*3 + m 
	lsli            t3, t3, 3           // 8*(Q_Fract_allpass_Qmf[sb][m])

	lrw             t5, Q_Fract_allpass_Qmf
	add             t5, t3              // &Q_Fract_allpass_Qmf[sb][m]
	ld.w            l3, (t5, 0x0)       // Q_Fract_allpass[0] = Q_Fract_allpass_Qmf[sb][m][0]
	ld.w            l4, (t5, 0x4)       // Q_Fract_allpass[1] = Q_Fract_allpass_Qmf[sb][m][1]
	/* t1, t3, t4, t5 is no used, t6, t9, a2, l3, l4, l8, l9 is used*/

	/* ComplexMult(&tmp[0], &tmp[1], tmp0[0], tmp0[1], Q_Fract_allpass[0], Q_Fract_allpass[1]); */
    mul.s32.h       t4, l8, l3
    mula.s32.hs     t4, l9, l4
	lsli            t4, t4, 1           // t4 = tmp[0]
    mul.s32.h       t5, l9, l3
    muls.s32.hs     t5, l8, l4
	lsli            t5, t5, 1           // t5 = tmp[1]
	/* t1, t3, l3, l4, l8, l9 is no used, t4, t5, t6, t9 is used*/
	lsli            t3, a1, 2
	add             t3, sp
	addi            t3, 80              // (20)*4 => g_DecaySlope_filt
	ld.w            t3, (t3, 0x0)       // g_DecaySlope_filt[m] 

    mul.s32         l3, t3, t6          // g_DecaySlope_filt[m]*R0[0]
    dexti           l3, l3, l4, 31
	sub             t4, l3              // tmp[0] += -

    mul.s32         l3, t3, t9          // g_DecaySlope_filt[m]*R0[1]
    dexti           l3, l3, l4, 31
	sub             t5, l3              // tmp[1] += -
	/* t1, l3, l4, l8, l9 is no used, t3, t4, t5, t6, t9, a2 is used*/
    mul.s32         l3, t3, t4          // g_DecaySlope_filt[m]*tmp[0]
    dexti           l3, l3, l4, 31
	add             l8, t6, l3          // tmp2[0] = R0[0] + g_DecaySlope_filt[m]*tmp[0]
    mul.s32         l3, t3, t5          // g_DecaySlope_filt[m]*tmp[1]
    dexti           l3, l3, l4, 31
	add             l9, t9, l3          // tmp2[1] = R0[1] + g_DecaySlope_filt[m]*tmp[1]
	/* t1, t3, t6, t9, l3, l4 is no used, t4, t5, a2, l8, l9 is used*/
	st.w            l8, (a2, 0x0)       // ps->delay_Qmf_ser[m][temp_delay_ser[m]][sb][0] = tmp2[0]
	st.w            l9, (a2, 0x4)       // ps->delay_Qmf_ser[m][temp_delay_ser[m]][sb][1] = tmp2[1]
	mov             t6, t4              // R0[0] = tmp[0]
	mov             t9, t5              // R0[1] = tmp[1]
	/* t1, t3, t4, t5, l3, l4, l8, l9 is no used, t6, t9, a2 is used*/
.L32:
    addi            a1, 1               // m++
    cmplt           a1, a3              // m < 3
    bt              .L26
.L34:
	ld.w            t4, (sp, 0x28)      // bk => sp + 10*4
	movi            t3, 34
	mula.32.l       t4, t0, t3          // &G_TransientRatio[n][bk] = 34*n + bk
	lsli            t3, t4, 2           // 4*G_TransientRatio[n][bk]

	movi            t4, 4472            // 32*34*4+30*4
	add             t4, sp              // G_TransientRatio
	add             t3, t4

    ld.w            t3, (t3, 0x0)       // G_TransientRatio[n][bk]

    mul.s32         l3, t3, t6          // G_TransientRatio[n][bk]*R0[0]
    dexti           t6, l3, l4, 14
    mul.s32         l3, t3, t9          // G_TransientRatio[n][bk]*R0[1]
    dexti           t9, l3, l4, 14

    cmplt           lr, l7              // gr < ps->num_hybrid_groups
    bt              .L35
	/* t1, t3, t4, t5, l3, l4, l8, l9, a1, a2, a3 is no used, t6, t9 is used*/
	ld.w            a2, (sp, 0x8)       // complex_t X_right[38][64]
	lsli            t3, t0, 6           // 64*n
	add             t3, t8              // 64*n + sb
	lsli            t3, t3, 3           // 8*(64*n + sb)
	add             t3, a2
	st.w            t6, (t3, 0x0)       // X_right[n][sb][0] = R0[0]
	st.w            t9, (t3, 0x4)       // X_right[n][sb][1] = R0[1]
    br              .L36
.L35:
	ld.w            a2, (sp, 0x22a4)    // complex_t X_hybrid_right[32][32]: sp + 8868 = sp + 32*34*2*4 + 30*4 + 11*4
	lsli            t3, t0, 5           // 32*n
	add             t3, t8              // 32*n + sb
	lsli            t3, t3, 3           // 8*(32*n + sb)
	add             t3, a2
	st.w            t6, (t3, 0x0)       // X_hybrid_right[n][sb][0] = R0[0]
	st.w            t9, (t3, 0x4)       // X_hybrid_right[n][sb][1] = R0[1]
	/* t1, t3, t4, t5, t6, t9, l3, l4, l8, l9, a1, a2, a3 is no used, is used*/
.L36:
	addi            l5, 1               // ++temp_delay
	movi            t3, 2
	cmplt           l5, t3              // !(++temp_delay >= 2)
    bt              .L37
	movi            l5, 0
.L37:
    ld.b            t1, (a0, 0x2d9)     // ps->nr_allpass_bands
	cmplt           t1, t8              // sb > ps->nr_allpass_bands
	bf              .L38
    cmplt           lr, l7              // gr < ps->num_hybrid_groups
    bt              .L38

	ld.w            t1, (sp, 0x2c)      // sp + 11*4 = ps->delay_buf_index_delay[sb]
	addi            t1, 1               // ++ps->delay_buf_index_delay[sb]
	ld.w            t3, (sp, 0x30)      // sp + 12*4 = ps->delay_D[sb]
	cmplt           t1, t3              // !(++ps->delay_buf_index_delay[sb] >= ps->delay_D[sb])
	bt              .L37_1
	movi            t1, 0
.L37_1:
	st.w            t1, (sp, 0x2c)      // sp + 11*4 = ps->delay_buf_index_delay[sb] ==> ps->delay_buf_index_delay[sb] = 0
	/* t1, t3, t4, t5, t6, t9, l3, l4, l8, l9, a1, a2, a3 is no used, is used*/
	/* after the loop(n), dont't forget to set the lastest value(in the stack) to ps->delay_buf_index_delay[sb] */
.L38:
	/* for (m = 0; m < 3; m++) */
	addi            t3, sp, 92          // (20+3)*1 => temp_delay_ser
	addi            t5, a0, 0x2e8       // &ps->num_sample_delay_ser
.L39:
	ld.b            t4, (t3)            // temp_delay_ser[m] == ps->delay_buf_index_ser[m] 
	addi            t4, 1
	ldbi.b          t6, (t5)            // ps->num_sample_delay_ser[m] 
	cmplt           t4, t6              // !((++temp_delay_ser[m] >= ps->num_sample_delay_ser[m]))
	bt              .L39_1
	movi            t4, 0               // temp_delay_ser[m] = 0
.L39_1:
	stbi.b          t4, (t3)

	ld.b            t4, (t3)            // temp_delay_ser[m] == ps->delay_buf_index_ser[m] 
	addi            t4, 1
	ldbi.b          t6, (t5)            // ps->num_sample_delay_ser[m] 
	cmplt           t4, t6              // !((++temp_delay_ser[m] >= ps->num_sample_delay_ser[m]))
	bt              .L39_2
	movi            t4, 0               // temp_delay_ser[m] = 0
.L39_2:
	stbi.b          t4, (t3)

	ld.b            t4, (t3)            // temp_delay_ser[m] == ps->delay_buf_index_ser[m] 
	addi            t4, 1
	ldbi.b          t6, (t5)            // ps->num_sample_delay_ser[m] 
	cmplt           t4, t6              // !((++temp_delay_ser[m] >= ps->num_sample_delay_ser[m]))
	bt              .L40
	movi            t4, 0               // temp_delay_ser[m] = 0
.L40:
	stbi.b          t4, (t3)
	/* t1, t3, t4, t5, t6, t9, l3, l4, l8, l9, a1, a2, a3 is no used, is used*/

.L41:
	addi            t0, 1               // n++
	ld.w            t3, (sp, 0x14)      // ps->border_position[ps->num_env]
    cmplt           t0, t3              // n < ps->border_position[ps->num_env]
    bt              .L19
.L42:
	addi            t8, 1               // sb++
    br              .L14
.L43:
	addi            lr, 1               // gr++
    br              .L13
.L44:
    st.b            l5, (a0, 0x2e4)     // ps->saved_delay = temp_delay

	/* save delay_ser below */
	addi            t0, sp, 92         // (20+3)*1 => temp_delay_ser
	addi            t1, a0, 0x2e5      // ps->delay_buf_index_ser
	ldbi.h          t2, (t0)           // n = 0, 1 
	stbi.h          t2, (t1)
	ldbi.b          t2, (t0)           // n = 2 
	stbi.b          t2, (t1)

.L50:
	movi            l9, 8824
    add             sp, l9
    pop             l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, lr
    .size           ps_decorrelate_asm, .-ps_decorrelate_asm
