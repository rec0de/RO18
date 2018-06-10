/**
 * Copyright (c) 2018, Daniel Thuerck, GCC, TU Darmstadt
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GCC nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GCC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* ************************************************************************** */

.data

	format_b2w: .string "@@BBRR**##$$PPXX00ZZLLqqllwwooIIccvv::++??||!!==~~--..,,   "
	multiply_const: .float 0.22745098
	four: .float 4.0

/* ************************************************************************** */

.bss

	/* local variables */
	.lcomm fpu_exchg, 4
	.lcomm out_cursor, 4

	/* global variables */
	.comm in_width, 4
	.comm in_height, 4
	.comm in_length, 4
	.comm in_max, 4
	.comm in_buffer, 4194304

	.comm out_width, 4
	.comm out_height, 4
	.comm out_length, 4
	.comm out_max, 4
	.comm out_buffer, 4194304

	.comm out_ascii_buffer, 4194304

/* ************************************************************************** */

.text

	.global main
	.global end

	main:
	movl %esp, %ebp #for correct debugging
		/* read input file */
		call read_input

		/* copy maximum value */
		movl in_max, %eax
		movl %eax, out_max

		/**
		 * YOUR WORK STARTS HERE!
		 */

		/* TODO: 1.2 - replace with call to downsample_image */
		call downsample_image

		/* TODO: 1.1 - implement convert_ascii and call */
		call convert_ascii

		/**
		 * YOUR WORK ENDS HERE!
		 */

		/* write output file */
		call write_output

		/* write ascii code */
		call write_ascii

		pushl $0
		jmp end

	/* ********************************************************************** */

	end:
		# syscall: end with error code from stack
		movl $0x1, %eax
		popl %ebx
		int $0x80

	/* ********************************************************************** */

	downsample_doublepixel:

		# Create local base pointer
		pushl %ebp
		movl %esp, %ebp

		# Save registers
		pushl %ebx
		pushl %ecx
		pushl %edx

		# Load block addr 
		movl 8(%ebp), %ecx
		
		xor %eax, %eax
		xor %ebx, %ebx
		xor %edx, %edx

		movb (%ecx), %al
		movb 1(%ecx), %dl
		add %edx, %eax

		movb 2(%ecx), %bl
		movb 3(%ecx), %dl
		add %edx, %ebx
		
		add in_width, %ecx
		
		movb (%ecx), %dl
		add %edx, %eax
		movb 1(%ecx), %dl
		add %edx, %eax
		
		movb 2(%ecx), %dl
		add %edx, %ebx
		movb 3(%ecx), %dl
		add %edx, %ebx
		
		movl %eax, fpu_exchg
		xor %eax, %eax
		fild fpu_exchg
		fdiv four
		frndint
		fistp fpu_exchg
		movl fpu_exchg, %eax
		
		movl %ebx, fpu_exchg
		fild fpu_exchg
		fdiv four
		frndint
		fistp fpu_exchg
		movl fpu_exchg, %ebx
		
		movb %bl, %ah
		
		popl %edx
		popl %ebx
		popl %ecx
		popl %ebp

		ret

	/* ********************************************************************** */

	downsample_image:

		# Create local base pointer
		pushl %ebp
		movl %esp, %ebp

		# Save registers
		pushl %ebx
		pushl %ecx
		pushl %edx

		movl in_width, %ebx
		shr %ebx
		movl %ebx, out_width

		movl in_height, %ebx
		shr %ebx
		movl %ebx, out_height

		# Calculate image length
		imul out_width, %ebx
		movl %ebx, out_length

		popl %edx
		popl %ebx
		popl %ecx
		popl %ebp

		ret

	/* ********************************************************************** */

	convert_ascii:

		pushl %ecx
		pushl %eax
		
		# Calculate image length (not initialized for some reason?)
		movl in_width, %ecx
		imul in_height, %ecx
		movl %ecx, in_length
		xor %ecx, %ecx
		
		# Load conversion constant to FPU
		fld multiply_const
		
		conv_ascii_loop:
		# Load next byte to lowest byte of fpu_exchg, set rest to zero (to deal with unwanted 2's complement expansion)
		xor %eax, %eax
		movb in_buffer(%ecx), %al
		movl %eax, fpu_exchg
		fild fpu_exchg # Load byte value into FPU
		fmul %st(1), %st # Multiply by conversion factor (st(1))
		frndint # Round to integer
		fistp fpu_exchg # Read integer and pop
		
		movl fpu_exchg, %eax
		movb format_b2w(%eax), %al # Get char corresponding to result
		movb %al, out_ascii_buffer(%ecx) # Write to output buffer
		add $1, %ecx # Increment byte position
		cmp %ecx, in_length
		jne conv_ascii_loop # Loop if not done

		popl %eax
		popl %ecx

		ret
