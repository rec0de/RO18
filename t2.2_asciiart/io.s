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

    in_file: .string "input.pgm"
    in_mode: .string "r"
	out_file: .string "output.pgm"
    out_mode: .string "w"
    out_ascii: .string "output.html"

	magic: .int 0x00003550

    /* error strings */
	error_in_file: .string "Error while reading input file!\n"
	error_out_file: .string "Error while reading output file\n"
	error_divisible: .string "Image dimensions are not divisible by 8, exiting...\n"
	error_exceeds: .string "Image width x height exceeds 1048576, exiting...\n"
	error_format: .string "Input file is not in PGM format, exiting...\n"

    /* info strings */
	info_magic: .string "Magic byte: 0x%04x\n"
	info_in_width: .string "Input image width: %d\n"
	info_in_height: .string "Input image height: %d\n"
    info_in_max: .string "Input image maximum: %d\n"
	info_out_width: .string "Output image width: %d\n"
	info_out_height: .string "Output image height: %d\n"
    info_out_max: .string "Output image maximum: %d\n"
    info_pixel: .string "Output image pixel: %d\n"

    /* format templates */
    format_int: .string "%d\n"
    format_header: .string "P5\n%d\n%d\n%d\n"
    format_char: .string "%c"
    format_newline: .string "\n"
    format_string: .string "%s"

    /* export */
    export_html_1: .string "<!doctype html><html><head><meta charset=\"UTF-8\"><title>RO Ascii Art</title><style type=\"text/css\">@font-face {font-family: Square; src: url(\"square.ttf\") format(\"truetype\")}</style></head><body><pre style=\"font-family:Square, bold; width: 100%;height: 100%\">\n"
    export_html_2: .string "\n</pre></body></html>"

/* ************************************************************************** */

.bss

        /* local variables */
        .lcomm ascii_accu, 4

        .lcomm in_fd, 4
        .lcomm out_fd, 4

/* ************************************************************************** */

.text

    .global error
    .global print_number
    .global read_number
    .global read_input
    .global write_output
    .global write_ascii
    .global copy_image

    /* ********************************************************************** */

	error:
		/* print error message */
		call printf
        addl $4, %esp

		/* set return value to error */
		pushl $-0x1
		jmp end

    /* ********************************************************************** */

	/**
	 * Parameters (from bottom to top on the stack):
     * - the value to use
	 * - address of info string
	 *
	 * Uses stdlib's printf.
	 */
	print_number:

		/* create local base pointer */
		pushl %ebp
		movl %esp, %ebp

        /* save registers */
        pushl %eax
        pushl %ebx
        pushl %ecx

		/* load arguments into registers */
		movl 12(%ebp), %eax
		movl 8(%ebp), %ebx

		/* call printf */
		pushl %eax
		pushl %ebx
		call printf
        addl $8, %esp

		/* restore registers */
        popl %ecx
        popl %ebx
        popl %eax

		popl %ebp

		ret

    /* ********************************************************************** */

    /**
     * reads an ascii number from in_fd that is terminated by byte 0A
     * and returns the result in %eax
     */
    read_number:

        /* use fscanf */
        leal ascii_accu, %eax
        pushl %eax
        pushl $format_int
        pushl in_fd
        call fscanf
        addl $12, %esp

        /* return parsed result */
        movl ascii_accu, %eax
        ret

    /* ********************************************************************** */

    copy_image:

        pushl %ebp
        movl %esp, %ebp

        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %edx

        /* copy meta information */
        movl in_width, %eax
        movl %eax, out_width

        movl in_height, %eax
        movl %eax, out_height

        movl in_max, %eax
        movl %eax, out_max

        /* compute length */
        movl out_width, %eax
        movl out_height, %edx
        mull %edx

        /* memcpy data */
        pushl %eax
        pushl $in_buffer
        pushl $out_buffer
        call memcpy
        addl $12, %esp

        /* clean up */
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax

        popl %ebp
        ret

    /* ********************************************************************** */

	read_input:

        /* calling conventions */
        pushl %ebp
        movl %esp, %ebp

        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %edx

		/* open file, return id in %eax */
        pushl $in_mode
        pushl $in_file
        call fopen
        addl $8, %esp

		/* check if file was openend successfully */
        pushl $error_in_file
        cmpl $0, %eax
		jz error
        addl $4, %esp

		/* save file id in memory */
		movl %eax, in_fd

		/* read two magic bytes [plus newline] (should be P5) */
        pushl in_fd
		pushl $3
        pushl $1
        pushl $in_buffer
        call fread
        addl $16, %esp

        /* print magic byte */
        movl in_buffer, %eax
        andl $0x0000FFFF, %eax
        pushl %eax
        pushl $info_magic
        call print_number
        add $8, %esp

		/* compare magic bytes (little endian -> 5 at 2, P at 3) */
		movl magic, %eax
		movl in_buffer, %ebx
        andl $0x0000FFFF, %ebx
		cmpl %eax, %ebx

        pushl $error_in_file
		jne error
        addl $4, %esp

		/* read image sizes (two ASCII integers) */
		call read_number
        movl %eax, in_width

        call read_number
        movl %eax, in_height

        call read_number
        movl %eax, in_max

		/* print image sizes */
        pushl in_width
        pushl $info_in_width
        call print_number
        add $8, %esp

        pushl in_height
        pushl $info_in_height
        call print_number
        add $8, %esp

        pushl in_max
        pushl $info_in_max
        call print_number
        add $8, %esp

		leal in_width, %eax
		movl 0(%eax), %eax

		/* check width, height for divisibility by 8 (last 3 bit must be 0) */
		movl in_width, %eax
		movl $0x07, %ebx
		and %ebx, %eax

        pushl $error_divisible
		jnz error
        addl $4, %esp

		movl in_width, %eax
		and %ebx, %eax

        pushl $error_divisible
		jnz error
        addl $4, %esp

		/* compute width * height */
		movl in_width, %eax
		movl in_height, %ebx
		mull %ebx

		/* check if image is small enough */
		movl $1048576, %edx
		cmpl %eax, %edx

        pushl $error_exceeds
		jl error
        addl $4, %esp

		/* read all image bytes */
		pushl in_fd
        pushl %edx
        pushl $1
        pushl $in_buffer
        call fread
        addl $16, %esp

		/* all bytes in buffer, close file and return */
		pushl in_fd
        call fclose
        addl $4, %esp

        /* clean up */
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax

        popl %ebp

		ret

    /* ********************************************************************** */

	write_output:

        /* calling conventions */
        pushl %ebp
        movl %esp, %ebp

        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %edx

		/* open file for writing */
		pushl $out_mode
        pushl $out_file
        call fopen
        addl $8, %esp

		/* check if file was openend successfully */
        pushl $error_out_file
        cmpl $0, %eax
		jz error
        addl $4, %esp

		/* save file id in memory */
		movl %eax, out_fd

        /* print out information about the output file */
        pushl out_width
        pushl $info_out_width
        call print_number
        add $8, %esp

        pushl out_height
        pushl $info_out_height
        call print_number
        add $8, %esp

        pushl out_max
        pushl $info_out_max
        call print_number
        add $8, %esp

        /* write out header */
        pushl out_max
        pushl out_height
        pushl out_width
        pushl $format_header
        pushl out_fd
        call fprintf
        addl $20, %esp

		/* compute size of transformed image */
		movl out_width, %eax
		movl out_height, %edx
		mull %edx

		/* write out computed pixels */
		pushl out_fd
        pushl %eax
        pushl $1
        pushl $out_buffer
        call fwrite
        addl $16, %esp

		# close file and return
		pushl out_fd
        call fclose
        addl $4, %esp

        /* clean up */
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax

        popl %ebp

		ret

    /* ********************************************************************** */

    /**
     * Write out ASCII image
     */
    write_ascii:

        pushl %ebp
        movl %esp, %ebp

        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %edx
        pushl %edi

        /* open file for writing */
		pushl $out_mode
        pushl $out_ascii
        call fopen
        addl $8, %esp

        /* check if file was openend successfully */
        pushl $error_out_file
        cmpl $0, %eax
		jz error
        addl $4, %esp

		/* save file id in memory */
		movl %eax, out_fd

        /* write out first html part */
        pushl $export_html_1
        pushl $format_string
        pushl out_fd
        call fprintf
        addl $12, %esp

        /* print each row */
        xorl %ecx, %ecx
        movl $out_ascii_buffer, %edi
        print_ascii_row:

            /* save row for later */
            pushl %ecx

            xorl %ecx, %ecx
            print_ascii_step:

                /* print first characters */
                pushl %ecx
                movzbl 0(%edi), %eax
                pushl %eax
                pushl $format_char
                pushl out_fd
                call fprintf
                addl $12, %esp
                popl %ecx

                pushl %ecx
                movzbl 1(%edi), %eax
                pushl %eax
                pushl $format_char
                pushl out_fd
                call fprintf
                addl $12, %esp
                popl %ecx

                /* move pointer */
                addl $2, %edi

                /* go to next doubleword */
                addl $2, %ecx
                cmpl out_width, %ecx
                jl print_ascii_step

            /* print newline */
            pushl $format_newline
            pushl out_fd
            call fprintf
            addl $8, %esp

            /* restore row */
            popl %ecx

            /* go to next row or cancel */
            inc %ecx
            cmpl out_height, %ecx
            jl print_ascii_row

        /* write out second html part */
        pushl $export_html_2
        pushl $format_string
        pushl out_fd
        call fprintf
        addl $12, %esp

        # close file and return
		pushl out_fd
        call fclose
        addl $4, %esp

        /* clean up and return */
        popl %edi
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax

        popl %ebp
        ret
