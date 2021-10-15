CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
INCLUDE(../../cmake/toolchain.cmake)

# include
INCLUDE_DIRECTORIES(./include)
INCLUDE_DIRECTORIES(./src)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-function")

ADD_DEFINITIONS(
    -DHAVE_CONFIG_H
    -DFIXED_POINT
    -DFAAD_CSKY_ASM
    -DFAAD_DEC_SBR_ENABLE
    -DFAAD_DEC_PS_ENABLE
)

SET(LIBSOURCE 
	src/bits.c
	src/cfft.c
	src/common.c
	src/decoder.c
	src/drc.c
	src/drm_dec.c
	src/error.c
	src/filtbank.c
	src/hcr.c
	src/huffman.c
	src/ic_predict.c
	src/is.c
	src/lt_predict.c
	src/mdct.c
	src/mp4.c
	src/ms.c
	src/output.c
	src/pns.c
	src/ps_dec.c
	src/ps_syntax.c
	src/pulse.c
	src/rvlc.c
	src/sbr_dct.c
	src/sbr_dec.c
	src/sbr_e_nf.c
	src/sbr_fbt.c
	src/sbr_hfadj.c
	src/sbr_hfgen.c
	src/sbr_huff.c
	src/sbr_qmf.c
	src/sbr_syntax.c
	src/sbr_tf_grid.c
	src/specrec.c
	src/ssr.c
	src/ssr_fb.c
	src/ssr_ipqf.c
	src/syntax.c
	src/tns.c
	src/cfft_asm.S
	src/dct4_kernel_asm.S
	src/fft_dif_asm.S
	src/mdct_asm.S
	src/ps_decorrelate_asm.S
	src/sbr_qmf_synthesis_64_asm.S
)

ADD_LIBRARY(faad ${LIBSOURCE})

INSTALL(TARGETS faad DESTINATION ${INSTALL_PATH}/lib)
INSTALL(DIRECTORY ./include DESTINATION ${INSTALL_PATH}/include)


