/**************************************************************************************************
*                                                                                                 *
* This file is part of BLASFEO.                                                                   *
*                                                                                                 *
* BLASFEO -- BLAS For Embedded Optimization.                                                      *
* Copyright (C) 2016-2017 by Gianluca Frison.                                                     *
* Developed at IMTEK (University of Freiburg) under the supervision of Moritz Diehl.              *
* All rights reserved.                                                                            *
*                                                                                                 *
* HPMPC is free software; you can redistribute it and/or                                          *
* modify it under the terms of the GNU Lesser General Public                                      *
* License as published by the Free Software Foundation; either                                    *
* version 2.1 of the License, or (at your option) any later version.                              *
*                                                                                                 *
* HPMPC is distributed in the hope that it will be useful,                                        *
* but WITHOUT ANY WARRANTY; without even the implied warranty of                                  *
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                                            *
* See the GNU Lesser General Public License for more details.                                     *
*                                                                                                 *
* You should have received a copy of the GNU Lesser General Public                                *
* License along with HPMPC; if not, write to the Free Software                                    *
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA                  *
*                                                                                                 *
* Author: Gianluca Frison, giaf (at) dtu.dk                                                       *
*                          gianluca.frison (at) imtek.uni-freiburg.de                             *
*                                                                                                 *
**************************************************************************************************/

//	// prologue
//	stmdb	sp!, {r4 - r10, fp, lr} // save GP registers
//	add		fp, sp, #36 // fp to old sp position
//	fstmfdd	sp!, {d8-d15} // save FP registers
#define PROLOGUE \
	stmdb	sp!, {r4 - r10, fp, lr}; \
	add		fp, sp, #36; \
	fstmfdd	sp!, {d8-d15};
//	// epilogue
//	fldmfdd	sp!, {d8-d15} // load FP registers
//	ldmia	sp!, {r4 - r10, fp, pc} // load GP registers and return
#define EPILOGUE \
	fldmfdd	sp!, {d8-d15}; \
	ldmia	sp!, {r4 - r10, fp, pc};



#if defined(OS_LINUX)
	.text
#elif defined(OS_MAC)
	.section	__TEXT,__text,regular,pure_instructions
#endif



// subroutine
//
// input arguments:
// r4   <- k
// r5   <- A
// r6   <- B
//
// output arguments:

#if MACRO_LEVEL>=2
	.macro INNER_KERNEL_GEMM_ADD_NT_4X4_LIB4
#else
//	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_kernel_gemm_add_nt_4x4_lib4, %function
inner_kernel_gemm_add_nt_4x4_lib4:
#elif defined(OS_MAC)
_inner_kernel_gemm_add_nt_4x4_lib4:
#endif
#endif

	// early return
	cmp		r4, #0
	ble		2f // return

	// prefetch
	pld		[r5, #0]
	pld		[r6, #0]

	// preload A
	vld1.64		{d0, d1}, [r5:128]! // A
	vld1.64		{d4, d5}, [r6:128]! // B

	cmp		r4, #4
	ble		0f // consider clean up loop

	// main loop
1:
	
	// prefetch
	pld		[r5, #64]
	pld		[r6, #64]

	// unroll 0
	vmla.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmla.f32	q5, q0, d4[1]
	vld1.64		{d6, d7}, [r6:128]! // B
	vmla.f32	q6, q0, d5[0]
	vmla.f32	q7, q0, d5[1]

	// unroll 1
	vmla.f32	q4, q1, d6[0]
	vld1.64		{d0, d1}, [r5:128]! // A
	vmla.f32	q5, q1, d6[1]
	vld1.64		{d4, d5}, [r6:128]! // B
	vmla.f32	q6, q1, d7[0]
	vmla.f32	q7, q1, d7[1]

	// unroll 2
	vmla.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmla.f32	q5, q0, d4[1]
	vld1.64		{d6, d7}, [r6:128]! // B
	vmla.f32	q6, q0, d5[0]
	vmla.f32	q7, q0, d5[1]

	// unroll 3
	vmla.f32	q4, q1, d6[0]
	vld1.64		{d0, d1}, [r5:128]! // A
	vmla.f32	q5, q1, d6[1]
	vld1.64		{d4, d5}, [r6:128]! // B
	vmla.f32	q6, q1, d7[0]
	vmla.f32	q7, q1, d7[1]

	sub		r4, r4, #4

	cmp		r4, #4
	bgt		1b

0:

	cmp		r4, #3
	ble		4f

	// unroll 0
	vmla.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmla.f32	q5, q0, d4[1]
	vld1.64		{d6, d7}, [r6:128]! // B
	vmla.f32	q6, q0, d5[0]
	vmla.f32	q7, q0, d5[1]

	// unroll 1
	vmla.f32	q4, q1, d6[0]
	vld1.64		{d0, d1}, [r5:128]! // A
	vmla.f32	q5, q1, d6[1]
	vld1.64		{d4, d5}, [r6:128]! // B
	vmla.f32	q6, q1, d7[0]
	vmla.f32	q7, q1, d7[1]

	// unroll 2
	vmla.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmla.f32	q5, q0, d4[1]
	vld1.64		{d6, d7}, [r6:128]! // B
	vmla.f32	q6, q0, d5[0]
	vmla.f32	q7, q0, d5[1]

	// unroll 3
	vmla.f32	q4, q1, d6[0]
//	vld1.64		{d0, d1}, [r5:128]! // A
	vmla.f32	q5, q1, d6[1]
//	vld1.64		{d4, d5}, [r6:128]! // B
	vmla.f32	q6, q1, d7[0]
	vmla.f32	q7, q1, d7[1]

	sub		r4, r4, #4

	b		2f // return

4: // consider clean1-up loop

	cmp		r4, #0
	ble		2f // return

	sub		r5, r5, #16
	sub		r6, r6, #16

3: // clean1-up loop

	// unroll 0
	vld1.64		{d0, d1}, [r5:128]! // A
	vld1.64		{d4, d5}, [r6:128]! // B
	vmla.f32	q4, q0, d4[0]
	vmla.f32	q5, q0, d4[1]
	vmla.f32	q6, q0, d5[0]
	vmla.f32	q7, q0, d5[1]

	sub		r4, r4, #1
	cmp		r4, #0
	bgt		3b

2: // return

	
#if MACRO_LEVEL>=2
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_kernel_gemm_add_nt_4x4_lib4, .-inner_kernel_gemm_add_nt_4x4_lib4
#endif
#endif





// subroutine
//
// input arguments:
// r4   <- k
// r5   <- A
// r6   <- B
//
// output arguments:

#if MACRO_LEVEL>=2
	.macro INNER_KERNEL_GEMM_SUB_NT_4X4_LIB4
#else
//	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_kernel_gemm_sub_nt_4x4_lib4, %function
inner_kernel_gemm_sub_nt_4x4_lib4:
#elif defined(OS_MAC)
_inner_kernel_gemm_sub_nt_4x4_lib4:
#endif
#endif

	// early return
	cmp		r4, #0
	ble		2f // return

	// prefetch
	pld		[r5, #0]
	pld		[r6, #0]

	// preload A
	vld1.64		{d0, d1}, [r5:128]! // A
	vld1.64		{d4, d5}, [r6:128]! // B

	cmp		r4, #4
	ble		0f // consider clean up loop

	// main loop
1:
	
	// prefetch
	pld		[r5, #64]
	pld		[r6, #64]

	// unroll 0
	vmls.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmls.f32	q5, q0, d4[1]
	vld1.64		{d6, d7}, [r6:128]! // B
	vmls.f32	q6, q0, d5[0]
	vmls.f32	q7, q0, d5[1]

	// unroll 1
	vmls.f32	q4, q1, d6[0]
	vld1.64		{d0, d1}, [r5:128]! // A
	vmls.f32	q5, q1, d6[1]
	vld1.64		{d4, d5}, [r6:128]! // B
	vmls.f32	q6, q1, d7[0]
	vmls.f32	q7, q1, d7[1]

	// unroll 2
	vmls.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmls.f32	q5, q0, d4[1]
	vld1.64		{d6, d7}, [r6:128]! // B
	vmls.f32	q6, q0, d5[0]
	vmls.f32	q7, q0, d5[1]

	// unroll 3
	vmls.f32	q4, q1, d6[0]
	vld1.64		{d0, d1}, [r5:128]! // A
	vmls.f32	q5, q1, d6[1]
	vld1.64		{d4, d5}, [r6:128]! // B
	vmls.f32	q6, q1, d7[0]
	vmls.f32	q7, q1, d7[1]

	sub		r4, r4, #4

	cmp		r4, #4
	bgt		1b

0:

	cmp		r4, #3
	ble		4f

	// unroll 0
	vmls.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmls.f32	q5, q0, d4[1]
	vld1.64		{d6, d7}, [r6:128]! // B
	vmls.f32	q6, q0, d5[0]
	vmls.f32	q7, q0, d5[1]

	// unroll 1
	vmls.f32	q4, q1, d6[0]
	vld1.64		{d0, d1}, [r5:128]! // A
	vmls.f32	q5, q1, d6[1]
	vld1.64		{d4, d5}, [r6:128]! // B
	vmls.f32	q6, q1, d7[0]
	vmls.f32	q7, q1, d7[1]

	// unroll 2
	vmls.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmls.f32	q5, q0, d4[1]
	vld1.64		{d6, d7}, [r6:128]! // B
	vmls.f32	q6, q0, d5[0]
	vmls.f32	q7, q0, d5[1]

	// unroll 3
	vmls.f32	q4, q1, d6[0]
//	vld1.64		{d0, d1}, [r5:128]! // A
	vmls.f32	q5, q1, d6[1]
//	vld1.64		{d4, d5}, [r6:128]! // B
	vmls.f32	q6, q1, d7[0]
	vmls.f32	q7, q1, d7[1]

	sub		r4, r4, #4

	b		2f // return

4: // consider clean1-up loop

	cmp		r4, #0
	ble		2f // return

	sub		r5, r5, #16
	sub		r6, r6, #16

3: // clean1-up loop

	// unroll 0
	vld1.64		{d0, d1}, [r5:128]! // A
	vld1.64		{d4, d5}, [r6:128]! // B
	vmls.f32	q4, q0, d4[0]
	vmls.f32	q5, q0, d4[1]
	vmls.f32	q6, q0, d5[0]
	vmls.f32	q7, q0, d5[1]

	sub		r4, r4, #1
	cmp		r4, #0
	bgt		3b

2: // return

	
#if MACRO_LEVEL>=2
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_kernel_gemm_sub_nt_4x4_lib4, .-inner_kernel_gemm_sub_nt_4x4_lib4
#endif
#endif





// subroutine
//
// input arguments:
// r4   <- k
// r5   <- A
// r6   <- B
// r7   <- 4*sdb*sizeof(float)
//
// output arguments:

#if MACRO_LEVEL>=2
	.macro INNER_KERNEL_GEMM_ADD_NN_4X4_LIB4
#else
//	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_kernel_gemm_add_nn_4x4_lib4, %function
inner_kernel_gemm_add_nn_4x4_lib4:
#elif defined(OS_MAC)
_inner_kernel_gemm_add_nn_4x4_lib4:
#endif
#endif

	// early return
	cmp		r4, #0
	ble		2f // return

	// prefetch
	pld		[r5, #0]
	pld		[r6, #0]

	// preload A
	vld1.64		{d0, d1}, [r5:128]! // A
	vldr		d4, [r6, #0]   // B[0,1]
	vldr		d5, [r6, #16]  // B[4,5]
	vldr		d6, [r6, #32]  // B[8,9]
	vldr		d7, [r6, #48]  // B[12,13]

	cmp		r4, #4
	ble		0f // consider clean up loop

	// main loop
1:
	
	// prefetch
	pld		[r5, #64]
	pld		[r6, r7]

	// unroll 0
	vmla.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmla.f32	q5, q0, d5[0]
	vmla.f32	q6, q0, d6[0]
	vmla.f32	q7, q0, d7[0]

	// unroll 1
	vld1.64		{d0, d1}, [r5:128]! // A
	vmla.f32	q4, q1, d4[1]
	vldr		d4, [r6, #8]  // B[2,3]
	vmla.f32	q5, q1, d5[1]
	vldr		d5, [r6, #24] // B[6,7]
	vmla.f32	q6, q1, d6[1]
	vldr		d6, [r6, #40] // B[10,11]
	vmla.f32	q7, q1, d7[1]
	vldr		d7, [r6, #56] // B[14,15]

	// unroll 2
	vmla.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmla.f32	q5, q0, d5[0]
	add		r6, r6, r7
	vmla.f32	q6, q0, d6[0]
	vmla.f32	q7, q0, d7[0]

	// unroll 3
	vld1.64		{d0, d1}, [r5:128]! // A
	vmla.f32	q4, q1, d4[1]
	vldr		d4, [r6, #0]   // B[0,1]
	vmla.f32	q5, q1, d5[1]
	vldr		d5, [r6, #16]  // B[4,5]
	vmla.f32	q6, q1, d6[1]
	vldr		d6, [r6, #32]  // B[8,9]
	vmla.f32	q7, q1, d7[1]
	vldr		d7, [r6, #48]  // B[12,13]

	sub		r4, r4, #4

	cmp		r4, #4
	bgt		1b

0:

	cmp		r4, #3
	ble		4f

	// unroll 0
	vmla.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmla.f32	q5, q0, d5[0]
	vmla.f32	q6, q0, d6[0]
	vmla.f32	q7, q0, d7[0]

	// unroll 1
	vld1.64		{d0, d1}, [r5:128]! // A
	vmla.f32	q4, q1, d4[1]
	vldr		d4, [r6, #8]  // B[2,3]
	vmla.f32	q5, q1, d5[1]
	vldr		d5, [r6, #24] // B[6,7]
	vmla.f32	q6, q1, d6[1]
	vldr		d6, [r6, #40] // B[10,11]
	vmla.f32	q7, q1, d7[1]
	vldr		d7, [r6, #56] // B[14,15]

	// unroll 2
	vmla.f32	q4, q0, d4[0]
	vld1.64		{d2, d3}, [r5:128]! // A
	vmla.f32	q5, q0, d5[0]
	add		r6, r6, r7
	vmla.f32	q6, q0, d6[0]
	vmla.f32	q7, q0, d7[0]

	// unroll 3
//	vld1.64		{d0, d1}, [r5:128]! // A
	vmla.f32	q4, q1, d4[1]
//	vldr		d4, [r6, #0]   // B[0,1]
	vmla.f32	q5, q1, d5[1]
//	vldr		d5, [r6, #16]  // B[4,5]
	vmla.f32	q6, q1, d6[1]
//	vldr		d6, [r6, #32]  // B[8,9]
	vmla.f32	q7, q1, d7[1]
//	vldr		d7, [r6, #48]  // B[12,13]

	sub		r4, r4, #4

	b		2f // return

4: // consider clean1-up loop

	cmp		r4, #0
	ble		2f // return

	sub		r5, r5, #16

3: // clean1-up loop

	// unroll 0
	vld1.64		{d0, d1}, [r5:128]! // A
	vldr		s8, [r6, #0]  // B[0]
	vmla.f32	q4, q0, d4[0]
	vldr		s8, [r6, #16] // B[4]
	vmla.f32	q5, q0, d4[0]
	vldr		s8, [r6, #32] // B[8]
	vmla.f32	q6, q0, d4[0]
	vldr		s8, [r6, #48] // B[12]
	vmla.f32	q7, q0, d4[0]

	sub		r4, r4, #1
	add		r6, r6, #4
	cmp		r4, #0
	bgt		3b

2: // return

	
#if MACRO_LEVEL>=2
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_kernel_gemm_add_nn_4x4_lib4, .-inner_kernel_gemm_add_nn_4x4_lib4
#endif
#endif





// subroutine
//
// cholesky factorization 
//
// input arguments:
// r4   <- inv_diag_D
//
// output arguments:
// r4   <- inv_diag_D

#if MACRO_LEVEL>=1
	.macro INNER_EDGE_POTRF_4X4_LIB4
#else
	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_edge_potrf_4x4_lib4, %function
inner_edge_potrf_4x4_lib4:
#elif defined(OS_MAC)
_inner_edge_potrf_4x4_lib4:
#endif
#endif
	
	fconsts		s1, #112 // 1.0
	flds		s0, .LC01 // 0.0

#if 0 // scalar

	// first column
	fcmpes		s16, s0
	fmstat
	ble			1f
	fsqrts		s16, s16
	fdivs		s2, s1, s16
	fsts		s2, [r4, #0]
2:
	fmuls		s17, s17, s2
	fmuls		s18, s18, s2
	fmuls		s19, s19, s2

	// second column
	fnmacs		s21, s17, s17
	fnmacs		s22, s17, s18
	fnmacs		s23, s17, s19
	fcmpes		s21, s0
	fmstat
	ble			3f
	fsqrts		s21, s21
	fdivs		s2, s1, s21
	fsts		s2, [r4, #4]
4:
	fmuls		s22, s22, s2
	fmuls		s23, s23, s2

	// third column
	fnmacs		s26, s18, s18
	fnmacs		s27, s18, s19
	fnmacs		s26, s22, s22
	fnmacs		s27, s22, s23
	fcmpes		s16, s0
	fmstat
	ble			5f
	fsqrts		s26, s26
	fdivs		s2, s1, s26
	fsts		s2, [r4, #8]
6:
	fmuls		s27, s27, s2

	// fourth column
	fnmacs		s31, s19, s19
	fnmacs		s31, s23, s23
	fnmacs		s31, s27, s27
	fcmpes		s31, s0
	fmstat
	ble			7f
	fsqrts		s31, s31
	fdivs		s2, s1, s31
	fsts		s2, [r4, #12]

#else // vector

	// first column
	fcmpes		s16, s0
	fmstat
	ble			1f
	fsqrts		s2, s16
	fdivs		s2, s1, s2
	fsts		s2, [r4, #0]
2:
	vmul.f32	q4, q4, d1[0]

	// second column
	vmls.f32	q5, q4, d8[1]
	fcmpes		s21, s0
	fmstat
	ble			3f
	fsqrts		s2, s21
	fdivs		s2, s1, s2
	fsts		s2, [r4, #4]
4:
	vmul.f32	q5, q5, d1[0]

	// third column
	vmls.f32	q6, q4, d9[0]
	vmls.f32	q6, q5, d11[0]
	fcmpes		s16, s0
	fmstat
	ble			5f
	fsqrts		s2, s26
	fdivs		s2, s1, s2
	fsts		s2, [r4, #8]
6:
	vmul.f32	q6, q6, d1[0]

	// fourth column
	vmls.f32	q7, q4, d9[1]
	vmls.f32	q7, q5, d11[1]
	vmls.f32	q7, q6, d13[1]
	fcmpes		s31, s0
	fmstat
	ble			7f
	fsqrts		s31, s31
	fdivs		s2, s1, s31
	fsts		s2, [r4, #12]

#endif

	b			0f

1:
	flds		s16, .LC01
	b			2b

3:
	flds		s21, .LC01
	b			4b

5:
	flds		s26, .LC01
	b			6b

7:
	flds		s31, .LC01

0:
	
#if MACRO_LEVEL>=1
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_edge_potrf_4x4_lib4, .-inner_edge_potrf_4x4_lib4
#endif
#endif

	.align 3
.LC01: // { 0 }
	.word 0
	.word 0





// subroutine
//
// triangular substitution:
// side = right
// uplo = lower
// tran = transposed
// requires explicit inverse of diagonal
//
// input arguments:
// r4   <- E
// r5   <- inv_diag_E
//
// output arguments:
// r4   <- E
// r5   <- inv_diag_E

#if MACRO_LEVEL>=1
	.macro INNER_EDGE_TRSM_RLT_INV_4X4_LIB4
#else
	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_edge_trsm_rlt_inv_4x4_lib4, %function
inner_edge_trsm_rlt_inv_4x4_lib4:
#elif defined(OS_MAC)
inner_edge_trsm_rlt_inv_4x4_lib4:
#endif
#endif
	
	// first column
	vldr.32		d0, [r5, #0] // E_inv[0]
	vmul.f32	q4, q4, d0[0];

	// second column
	vldr.32		d0, [r4, #4] // E[1+4*0]
	vmls.f32	q5, q4, d0[0];
	vldr.32		d0, [r5, #4] // E_inv[1]
	vmul.f32	q5, q5, d0[0];

	// thirs column
	vldr.32		d0, [r4, #8] // E[2+4*0]
	vmls.f32	q6, q4, d0[0];
	vldr.32		d0, [r4, #24] // E[2+4*1]
	vmls.f32	q6, q5, d0[0];
	vldr.32		d0, [r5, #8] // E_inv[2]
	vmul.f32	q6, q6, d0[0];

	// fourth column
	vldr.32		d0, [r4, #12] // E[3+4*0]
	vmls.f32	q7, q4, d0[0];
	vldr.32		d0, [r4, #28] // E[3+4*1]
	vmls.f32	q7, q5, d0[0];
	vldr.32		d0, [r4, #44] // E[3+4*2]
	vmls.f32	q7, q6, d0[0];
	vldr.32		d0, [r5, #12] // E_inv[3]
	vmul.f32	q7, q7, d0[0];

#if MACRO_LEVEL>=1
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_edge_trsm_rlt_inv_4x4_lib4, .-inner_edge_trsm_rlt_inv_4x4_lib4
#endif
#endif





// subroutine
//
// input arguments:
// r4   <- alpha
// r5   <- beta
// r6   <- C
//
// output arguments:

#if MACRO_LEVEL>=2
	.macro INNER_SCALE_AB_4X4_LIB4
#else
//	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_scale_ab_4x4_lib4, %function
inner_scale_ab_4x4_lib4:
#elif defined(OS_MAC)
_inner_scale_ab_4x4_lib4:
#endif
#endif

	flds		s8, [r4, #0] // alpha

	vmul.f32	q4, q4, d4[0]
	flds		s9, [r5, #0] // beta
	vmul.f32	q5, q5, d4[0]
	flds		s10, .LC00 // 0.0
	vmul.f32	q6, q6, d4[0]
	fcmpes		s9, s10
	vmul.f32	q7, q7, d4[0]
	fmstat

	beq		0f // end

	vld1.64		{d0, d1, d2, d3}, [r6:128]!
	vmla.f32	q4, q0, d4[1]
	vmla.f32	q5, q1, d4[1]
	vld1.64		{d0, d1, d2, d3}, [r6:128]!
	vmla.f32	q6, q0, d4[1]
	vmla.f32	q7, q1, d4[1]

0:

#if MACRO_LEVEL>=2
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_scale_ab_4x4_lib4, .-inner_scale_ab_4x4_lib4
#endif
#endif





// subroutine
//
// input arguments:
// r4   <- C
//
// output arguments:

#if MACRO_LEVEL>=2
	.macro INNER_SCALE_11_4X4_LIB4
#else
//	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_scale_11_4x4_lib4, %function
inner_scale_11_4x4_lib4:
#elif defined(OS_MAC)
_inner_scale_11_4x4_lib4:
#endif
#endif

	vld1.64		{d0, d1, d2, d3}, [r4:128]!
	vadd.f32	q4, q0, q4
	vadd.f32	q5, q1, q5
	vld1.64		{d0, d1, d2, d3}, [r4:128]!
	vadd.f32	q6, q0, q6
	vadd.f32	q7, q1, q7

#if MACRO_LEVEL>=2
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_scale_11_4x4_lib4, .-inner_scale_11_4x4_lib4
#endif
#endif





// subroutine
//
// input arguments:
// r4   <- D
//
// output arguments:

#if MACRO_LEVEL>=2
	.macro INNER_STORE_4X4_LIB4
#else
//	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_store_4x4_lib4, %function
inner_store_4x4_lib4:
#elif defined(OS_MAC)
_inner_store_4x4_lib4:
#endif
#endif

	vst1.64		{d8, d9, d10, d11}, [r4:128]!
	vst1.64		{d12, d13, d14, d15}, [r4:128]!

#if MACRO_LEVEL>=2
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_store_4x4_lib4, .-inner_store_4x4_lib4
#endif
#endif





// subroutine
//
// input arguments:
// r4   <- D
//
// output arguments:

#if MACRO_LEVEL>=2
	.macro INNER_STORE_4X4_L_LIB4
#else
//	.p2align 4,,15
#if defined(OS_LINUX)
	.type inner_store_4x4_l_lib4, %function
inner_store_4x4_l_lib4:
#elif defined(OS_MAC)
_inner_store_4x4_l_lib4:
#endif
#endif

	// first column
	vstr.64		d8, [r4, #0]
	vstr.64		d9, [r4, #8]
	// second column
	vstr.32		s21, [r4, #20]
	vstr.64		d11, [r4, #24]
	// third column
	vstr.64		d13, [r4, #40]
	// fourth column
	vstr.64		s31, [r4, #60]

#if MACRO_LEVEL>=2
	.endm
#else
	mov		pc, lr // return

#if defined(OS_LINUX)
	.size	inner_store_4x4_l_lib4, .-inner_store_4x4_l_lib4
#endif
#endif





// zero double word
	.align 3
.LC00: // { 0 }
	.word 0
	.word 0
	.word 0
	.word 0

//                               r0        r1             r2         r3         sp+0          sp+4       sp+8
// void kernel_sgemm_nt_4x4_lib4(int kmax, double *alpha, double *A, double *B, double *beta, double *C, double *D)

//	.p2align 4,,15
#if defined(OS_LINUX)
	.global	kernel_sgemm_nt_4x4_lib4
	.type	kernel_sgemm_nt_4x4_lib4, %function
kernel_sgemm_nt_4x4_lib4:
#elif defined(OS_MAC)
	.global	kernel_sgemm_nt_4x4_lib4
_kernel_sgemm_nt_4x4_lib4:
#endif

	PROLOGUE



	// zero accumulation registers
	vldr	d8, .LC00
	vldr	d9, .LC00+8
	vmov	q5, q4
	vmov	q6, q4
	vmov	q7, q4



	// call inner kernel dgemm nt
	mov		r4, r0 // kmax
	mov		r5, r2 // A
	mov		r6, r3 // B

#if MACRO_LEVEL>=2
	INNER_KERNEL_GEMM_ADD_NT_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl	inner_kernel_gemm_add_nt_4x4_lib4
#elif defined(OS_MAC)
	bl	_inner_kernel_gemm_add_nt_4x4_lib4
#endif
#endif



	// call inner blend for generic alpha and beta
	mov		r4, r1 // alpha
	ldr		r5, [fp, #0] // beta
	ldr		r6, [fp, #4] // C

#if MACRO_LEVEL>=1
	INNER_SCALE_AB_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_scale_ab_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_scale_ab_4x4_lib4
#endif
#endif



	// store n
	ldr		r4, [fp, #8] // D

#if MACRO_LEVEL>=1
	INNER_STORE_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_store_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_store_4x4_lib4
#endif
#endif



	EPILOGUE

#if defined(OS_LINUX)
	.size	kernel_sgemm_nt_4x4_lib4, .-kernel_sgemm_nt_4x4_lib4
#endif



//                               r0        r1             r2         r3         sp+0     sp+4          sp+8       sp+12
// void kernel_sgemm_nn_4x4_lib4(int kmax, double *alpha, double *A, double *B, int sdb, double *beta, double *C, double *D)

//	.p2align 4,,15
#if defined(OS_LINUX)
	.global	kernel_sgemm_nn_4x4_lib4
	.type	kernel_sgemm_nn_4x4_lib4, %function
kernel_sgemm_nn_4x4_lib4:
#elif defined(OS_MAC)
	.global	kernel_sgemm_nn_4x4_lib4
_kernel_sgemm_nn_4x4_lib4:
#endif

	PROLOGUE



	// zero accumulation registers
	vldr	d8, .LC00
	vldr	d9, .LC00+8
	vmov	q5, q4
	vmov	q6, q4
	vmov	q7, q4



	// call inner kernel dgemm nt
	mov		r4, r0 // kmax
	mov		r5, r2 // A
	mov		r6, r3 // B
	ldr		r7, [fp, #0] // sdb
	lsl		r7, r7, #4 // 4*sizeof(float)*sdb

#if MACRO_LEVEL>=2
	INNER_KERNEL_GEMM_ADD_NN_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl	inner_kernel_gemm_add_nn_4x4_lib4
#elif defined(OS_MAC)
	bl	_inner_kernel_gemm_add_nn_4x4_lib4
#endif
#endif



	// call inner blend for generic alpha and beta
	mov		r4, r1 // alpha
	ldr		r5, [fp, #4] // beta
	ldr		r6, [fp, #8] // C

#if MACRO_LEVEL>=1
	INNER_SCALE_AB_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_scale_ab_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_scale_ab_4x4_lib4
#endif
#endif



	// store n
	ldr		r4, [fp, #12] // D

#if MACRO_LEVEL>=1
	INNER_STORE_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_store_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_store_4x4_lib4
#endif
#endif



	EPILOGUE

#if defined(OS_LINUX)
	.size	kernel_sgemm_nn_4x4_lib4, .-kernel_sgemm_nn_4x4_lib4
#endif



//                                      r0        r1         r2         r3         sp+0       sp+4       rsp+8
// void kernel_strsm_nt_rl_inv_4x4_lib4(int kmax, double *A, double *B, double *C, double *D, double *E, double *inv_diag_E);

//	.p2align 4,,15
#if defined(OS_LINUX)
	.globl kernel_strsm_nt_rl_inv_4x4_lib4
	.type kernel_strsm_nt_rl_inv_4x4_lib4, %function
kernel_strsm_nt_rl_inv_4x4_lib4:
#elif defined(OS_MAC)
	.globl _kernel_strsm_nt_rl_inv_4x4_lib4
_kernel_strsm_nt_rl_inv_4x4_lib4:
#endif

	PROLOGUE



	// zero accumulation registers
	vldr	d8, .LC00
	vldr	d9, .LC00+8
	vmov	q5, q4
	vmov	q6, q4
	vmov	q7, q4



	// call inner kernel dgemm nt
	mov		r4, r0 // kmax
	mov		r5, r1 // A
	mov		r6, r2 // B

#if MACRO_LEVEL>=2
	INNER_KERNEL_GEMM_SUB_NT_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl	inner_kernel_gemm_sub_nt_4x4_lib4
#elif defined(OS_MAC)
	bl	_inner_kernel_gemm_sub_nt_4x4_lib4
#endif
#endif



	// call inner blend for alpha=1.0 and beta=1.0
	mov		r4, r3 // C

#if MACRO_LEVEL>=1
	INNER_SCALE_11_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_scale_11_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_scale_11_4x4_lib4
#endif
#endif



	// factorization
	ldr		r4, [fp, #4] // E
	ldr		r5, [fp, #8] // inv_diag_E

#if MACRO_LEVEL>=1
	INNER_EDGE_TRSM_RLT_INV_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_edge_trsm_rlt_inv_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_edge_trsm_rlt_inv_4x4_lib4
#endif
#endif



	// store l
	ldr		r4, [fp, #0] // D

#if MACRO_LEVEL>=1
	INNER_STORE_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_store_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_store_4x4_lib4
#endif
#endif



	EPILOGUE

#if defined(OS_LINUX)
	.size	kernel_strsm_nt_rl_inv_4x4_lib4, .-kernel_strsm_nt_rl_inv_4x4_lib4
#endif



//                                  r0        r1         r2         r3         sp+0       sp+4
// void kernel_spotrf_nt_l_4x4_lib4(int kmax, double *A, double *B, double *C, double *D, double *inv_diag_D);

//	.p2align 4,,15
#if defined(OS_LINUX)
	.globl kernel_spotrf_nt_l_4x4_lib4
	.type kernel_spotrf_nt_l_4x4_lib4, %function
kernel_spotrf_nt_l_4x4_lib4:
#elif defined(OS_MAC)
	.globl _kernel_spotrf_nt_l_4x4_lib4
_kernel_spotrf_nt_l_4x4_lib4:
#endif

	PROLOGUE



	// zero accumulation registers
	vldr	d8, .LC00
	vldr	d9, .LC00+8
	vmov	q5, q4
	vmov	q6, q4
	vmov	q7, q4



	// call inner kernel dgemm nt
	mov		r4, r0 // kmax
	mov		r5, r1 // A
	mov		r6, r2 // B

#if MACRO_LEVEL>=2
	INNER_KERNEL_GEMM_SUB_NT_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl	inner_kernel_gemm_sub_nt_4x4_lib4
#elif defined(OS_MAC)
	bl	_inner_kernel_gemm_sub_nt_4x4_lib4
#endif
#endif



	// call inner blend for alpha=1.0 and beta=1.0
	mov		r4, r3 // C

#if MACRO_LEVEL>=1
	INNER_SCALE_11_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_scale_11_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_scale_11_4x4_lib4
#endif
#endif



	// factorization
	ldr		r4, [fp, #4] // inv_diag_D

#if MACRO_LEVEL>=1
	INNER_EDGE_POTRF_4X4_LIB4
#else
#if defined(OS_LINUX)
	bl inner_edge_potrf_4x4_lib4
#elif defined(OS_MAC)
	bl _inner_edge_potrf_4x4_lib4
#endif
#endif



	// store l
	ldr		r4, [fp, #0] // D

#if MACRO_LEVEL>=1
	INNER_STORE_4X4_L_LIB4
#else
#if defined(OS_LINUX)
	bl inner_store_4x4_l_lib4
#elif defined(OS_MAC)
	bl _inner_store_4x4_l_lib4
#endif
#endif



	EPILOGUE

#if defined(OS_LINUX)
	.size	kernel_spotrf_nt_l_4x4_lib4, .-kernel_spotrf_nt_l_4x4_lib4
#endif







