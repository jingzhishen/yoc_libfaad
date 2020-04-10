/*
** FAAD2 - Freeware Advanced Audio (AAC) Decoder including SBR decoding
** Copyright (C) 2003-2005 M. Bakker, Nero AG, http://www.nero.com
**  
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
** 
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
** 
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software 
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
**
** Any non-GPL usage of this software or parts of this software is strictly
** forbidden.
**
** The "appropriate copyright message" mentioned in section 2c of the GPLv2
** must read: "Code from FAAD2 is copyright (c) Nero AG, www.nero.com"
**
** Commercial non-GPL licensing of this software is possible.
** For more info contact Nero AG through Mpeg4AAClicense@nero.com.
**
** $Id: mdct.h,v 1.30 2007/11/01 12:33:31 menno Exp $
**/

#ifndef __MDCT_H__
#define __MDCT_H__

#ifdef __cplusplus
extern "C" {
#endif


mdct_info *faad_mdct_init(uint16_t N);
void faad_mdct_end(mdct_info *mdct);
#if ((defined(__ck804ef__) || defined(__ck805ef__)) && defined(FAAD_CSKY_ASM))
void faad_imdct_asm(mdct_info *mdct, real_t *X_in, real_t *X_out);
#else
void faad_imdct(mdct_info *mdct, real_t *X_in, real_t *X_out);
#endif
void faad_mdct(mdct_info *mdct, real_t *X_in, real_t *X_out);


#ifdef __cplusplus
}
#endif
#endif
