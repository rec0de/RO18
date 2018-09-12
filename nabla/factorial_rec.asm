.data
n: .word 8
result: .word 0

.text
main:
la $a0, n
lw $a0, 0($a0)
jal factorial_recursive
la $t0, result
sw $v0, 0($t0)
j exit

factorial_recursive:
beqz $a0, one
blez $a0, error

addi $t0, $a0, 0
addi $a0, $a0, -1
addi $sp, $sp, -8
sw $t0, 4($sp)
sw $ra, 0($sp)
jal factorial_recursive
lw $t0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp, 8
mult $v0, $t0
mflo $v0
jr $ra

one:
addi $v0, $0, 1
jr $ra

error:
addi $v0, $0, -1
jr $ra

exit:
