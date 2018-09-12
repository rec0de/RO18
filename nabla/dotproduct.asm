.data
vec_A: .word 1, 2, 3
vec_B: .word 4, 5, 6
dimension: .word 3
result: .word 0

.text
main:
la $a0, vec_A
la $a1, vec_B
la $a2, dimension
lw $a2, 0($a2)
jal dotproduct
la $t0, result
sw $v0, 0($t0)
j exit

dotproduct:
add $t0, $0, $0 # Vector part index
add $v0, $0, $0 # Accumulated result

innerloop:

# Load t0-th vector entry (shift by 2 for entire words)
sll $t3, $t0, 2
add $t3, $a0, $t3
lw $t1, 0($t3)

# Load t0-th vector entry (shift by 2 for entire words)
sll $t3, $t0, 2
add $t3, $a1, $t3
lw $t2, 0($t3)

# Multiply and add to result
mult $t1, $t2
mflo $t3
add $v0, $v0, $t3

# Increment index, done if index = dimension
addi $t0, $t0, 1
beq $t0, $a2, done
j innerloop

done:
jr $ra

exit: