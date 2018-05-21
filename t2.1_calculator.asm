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
message_error: .asciiz "Error\n"
message_linebreak: .asciiz "\n"


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
# Return values: 1 if current input char is a number, 0 otherwise
is_num:
	addi $sp, $sp, -4 # Save return addr on stack for subcall
	sw $ra, 0($sp)
	jal get_current_char
	lw $ra, 0($sp) # Restore ra
	addi $sp, $sp, 4
	
	# Current char is not a number if x < 48 or x > 57
	blt $v0, 48, is_not_num
	bgt $v0, 57, is_not_num
	addi $v0, $0, 1
	jr $ra
	
	is_not_num:
	add $v0, $0, $0
	jr $ra
	
	
read_num:
	# Save $s1 and $ra to stack
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s1, 4($sp)
	add $s1, $0, $0
	
	read_num_loop:
	jal get_current_char
	
	# Multiply what's already read by 10 (shifting 1 digit in decimal)
	# By shifting 3 bits (= * 8) and adding itself two times
	sll $t2, $s1, 3
	add $t2, $t2, $s1
	add $s1, $s1, $t2
	
	# Convert current char to decimal digits
	addi $t2, $v0, -48
	# Add to aggregate result
	add $s1, $s1, $t2
	
	jal advance_cursor
	jal is_num
	bgtz $v0, read_num_loop
	
	read_num_done:
	add $v0, $0, $s1
	# Restore return address and $s1 from stack
	lw $ra, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
parse_factor:
	# Save $ra to stack
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)

	# Return error if no number is present
	jal is_num
	beqz $v0, parse_factor_not_num
	# Return v0 and 0 in v1 for no error
	jal read_num
	add $v1, $0, $0
	j parse_factor_done
	
	parse_factor_not_num:
	jal get_current_char
	beq $v0, 40, parse_factor_bracket
	parse_factor_error:
	# Return error
	li $v1, 1
	add $v0, $0, $0
	parse_factor_done:
	# Load return address from stack and return
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
	parse_factor_bracket:
	jal advance_cursor
	jal parse_expression # Parse expression in bracket
	bgtz $v1, parse_factor_error # Return error on exp error
	add $s0, $v0, $0 # Save exp result
	jal get_current_char 
	bne $v0, 41, parse_factor_error # Check if next char is closing bracket
	jal advance_cursor
	add $v0, $s0, $0
	add $v1, $0, $0
	j parse_factor_done 
	
	
	
parse_term:
	# Save $ra, $s0 to stack
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	# Init operands to zero
	add $s0, $0, $0
	
	jal parse_factor # Read first number to $s0
	bgtz $v1, parse_term_error
	add $s0, $v0, $0
	
	parse_term_loop:
	
	# Get operator
	jal get_current_char
	beq $v0, 42, parse_term_mult # Jump to multiplication
	beq $v0, 47, parse_term_div # Jump to division
	 # If operator is not * or /, abort with no error and return result
	add $v0, $s0, $0
	add $v1, $0, $0
	j parse_term_done
	
	parse_term_mult:
	jal advance_cursor
	jal parse_factor # Get next number
	bgtz $v1, parse_term_error # Error on invalid number
	mult $s0, $v0
	mflo $s0
	j parse_term_loop
	
	parse_term_div:
	jal advance_cursor
	jal parse_factor # Get next number
	bgtz $v1, parse_term_error # Error on invalid number
	div $s0, $v0
	mflo $s0
	j parse_term_loop
	
	parse_term_error:
	li $v1, 1
	add $v0, $0, $0
	
	parse_term_done:
	# Load return address and $s0 from stack and return
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra

parse_expression:
	# Save $ra, $s0 to stack
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	# Init operands to zero
	add $s0, $0, $0
	add $s1, $0, $0
	
	jal parse_term # Read first evaluated term to $s0
	bgtz $v1, parse_exp_error
	add $s0, $v0, $0
	
	parse_exp_loop:
	
	# Get operator
	jal get_current_char
	
	beq $v0, 43, parse_exp_add # Jump to addition
	beq $v0, 45, parse_exp_sub # Jump to subtraction
	 # If operator is not + or -, abort with no error and return result
	add $v0, $s0, $0
	add $v1, $0, $0
	j parse_exp_done
	
	parse_exp_add:
	jal advance_cursor
	jal parse_term # Get next number
	bgtz $v1, parse_exp_error # Error on invalid number
	add $s0, $s0, $v0
	j parse_exp_loop
	
	parse_exp_sub:
	jal advance_cursor
	jal parse_term # Get next number
	bgtz $v1, parse_exp_error # Error on invalid number
	sub $s0, $s0, $v0
	j parse_exp_loop
	
	parse_exp_error:
	li $v1, 1
	add $v0, $0, $0
	
	parse_exp_done:
	# Load return address and $s0 from stack and return
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra

# Arguments: none
# Return values: none
handle_one_line:
	# Save return address because we are calling other functions.
	addi $sp, $sp, -4
	sw $ra,  0($sp)

	### BEGIN EXAMPLE ###
	
	jal parse_expression

	bgtz $v1 handle_line_error
	
	# Print result
	add $a0, $v0, $0
	li $v0, 1 # print integer
	syscall
	# Print linebreak
	la $a0, message_linebreak
	li $v0, 4 # print string
	syscall
	j handle_line_done

	handle_line_error:
	# Print error message.
	la $a0, message_error
	li $v0, 4 # print string
	syscall

	handle_line_done:
	###  END EXAMPLE  ###

	# Restore return address and return.
	lw $ra,  0($sp)
	addi $sp, $sp, 4
	jr $ra
