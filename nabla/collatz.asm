.data
n_0: .word 42
n_i: .word 0
n_j: .word 0
n_k: .word 0

.text
main:
la $a0, n_0
lw $a0, 0($a0)
jal collatz
la $t0, n_i
sw $v0, 0($t0)
la $t0, n_j
sw $v1, 0($t0)
la $t0, n_k
sw $t9, 0($t0)
j exit

collatz:

add $t0, $a0, $0
add $t1, $0, $0
addi $t4, $0, 1 # Constant one

loop:
# Shift previous values down a register
add $t2, $t1, $0
add $t1, $t0, $0

# Check if last value a_n is odd or even
andi $t3, $t0, 0x00000001
beq $t3, $t4, odd

# If even, divide by two
srl $t0, $t0, 1
j endif

# If odd, multiply by three
odd:
addi $t3, $0, 3
mult $t0, $t3
mflo $t0
addi $t0, $t0, 1 # and add one

endif:

beq $t0, $t4, done # Break if a_n = 1
j loop

done:

# Write last three values to result registers
add $v0, $t0, $0
add $v1, $t1, $0
add $t9, $t2, $0
jr $ra

exit:
