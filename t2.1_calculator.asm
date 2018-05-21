.data

# Array of 8k bytes used to store user input.
line_buffer: .byte 0 : 8192

# Index of current character in line buffer.
cursor_pos: .word 0

# Output strings for print_status.
message_v0: .asciiz "$v0: "
message_v1: .asciiz "$v1: "
message_cursor: .asciiz "Cursor: \n"
message_hat: .asciiz "^\n"



.text

# Program entry point.
# Arguments: none
main:
	m_loop:
	# Load address of line buffer and read new user input into it.
	la $a0, line_buffer
	li $a1, 8192
	li $v0, 8 # read string
	syscall

	# Reset the cursor so that it points at the first character in line buffer.
	la $t0, cursor_pos
	li $t1, 0
	sw $t1, 0($t0)

	jal handle_one_line

	# Repeat.
	j m_loop

# Moves the cursor to point at the next character in line buffer.
# Does not check if the cursor is moved past the terminating zero character.
# Arguments: none
# Return values: none
advance_cursor:
	# Load cursor.
	la $t0, cursor_pos
	lw $t1, 0($t0)

	# Add one.
	addi $t1, $t1, 1

	# Store cursor.
	sw $t1, 0($t0)

	# Return.
	jr $ra

# Returns the character that the cursor is pointing at right now.
# Arguments: none
# Return values: $v0: current character
get_current_char:
	# Load cursor into $t0.
	la $t0, cursor_pos
	lw $t0, 0($t0)

	# Add cursor to address of line buffer.
	la $t1, line_buffer
	add $t1, $t1, $t0

	# Load character (byte) at calculated address.
	lb $v0, 0($t1)

	# Return.
	jr $ra

# Prints the current values of $v0, $v1 and the cursor.
# Arguments: none
# Return values: none
print_status:
	addi $sp, $sp, -16
	sw $s0,  0($sp)
	sw $s1,  4($sp)
	sw $s2,  8($sp)
	sw $s3, 12($sp)

	# Copy relevant registers to saved registers.
	add $s0, $v0, $0
	add $s1, $v1, $0
	add $s2, $a0, $0

	# Print $v0.
	la $a0, message_v0
	li $v0, 4 # print string
	syscall

	add $a0, $s0, $0
	li $v0, 1 # print integer
	syscall

	li $a0, 10 # '\n' (new line)
	li $v0, 11 # print character
	syscall

	# Print $v1.
	la $a0, message_v1
	li $v0, 4 # print string
	syscall

	add $a0, $s1, $0
	li $v0, 1 # print integer
	syscall

	li $a0, 10 # '\n' (new line)
	li $v0, 11 # print character
	syscall

	# Print cursor message.
	la $a0, message_cursor
	li $v0, 4 # print string
	syscall

	# Print input.
	la $a0, line_buffer
	li $v0, 4 # print string
	syscall

	# Load cursor.
	la $s3, cursor_pos
	lw $s3, 0($s3)

	# Print a variable number of spaces based on the cursor value.
	ps_loop:
	beqz $s3, ps_done

	li $a0, 32 # ' ' (space)
	li $v0, 11 # print character
	syscall

	addi $s3, $s3, -1
	j ps_loop

	ps_done:

	# Print a '^' to mark the cursor position.
	la $a0, message_hat
	li $v0, 4 # print string
	syscall

	# Restore changed registers so that it is easier to use this function for debugging.
	add $v0, $s0, $0
	add $v1, $s1, $0
	add $a0, $s2, $0

	lw $s0,  0($sp)
	lw $s1,  4($sp)
	lw $s2,  8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra

# Arguments: none
# Return values: none
handle_one_line:
	# Save return address because we are calling other functions.
	addi $sp, $sp, -4
	sw $ra,  0($sp)

	### BEGIN EXAMPLE ###

	# Replace this example section with your application logic.
	# You can also add entries to the .data section and add functions at the end of the file.
	# Make sure to follow the MIPS calling conventions as presented in the lecture.
	# Please do not change anything else in the template.

	# Reads first character of user input into $v0 (not used here).
	jal get_current_char

	jal print_status

	jal advance_cursor

	# After advancing the cursor this will read the second character of user input into $v0.
	jal get_current_char

	jal print_status

	# Echo the input back to the user.
	la $a0, line_buffer
	li $v0, 4 # print string
	syscall

	###  END EXAMPLE  ###

	# Restore return address and return.
	lw $ra,  0($sp)
	addi $sp, $sp, 4
	jr $ra
