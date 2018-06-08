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
        /* read input file */
		call read_input

        /* copy maximum value */
        movl in_max, %eax
        movl %eax, out_max

        /**
         * YOUR WORK STARTS HERE!
         */

        /* TODO: 1.2 - replace with call to downsample_image */
        call copy_image

        /* TODO: 1.1 - implement convert_ascii and call */

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

        /* TODO: 1.2 a) - implement */

        ret

    /* ********************************************************************** */

    downsample_image:

        /* TODO: 1.2 b) - implement */

        ret

    /* ********************************************************************** */

    convert_ascii:

        /* TODO: 1.1 - implement */

        ret
