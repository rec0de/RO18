.data
n: .word 13
result: .word 0

.text
main:
la $a0, n
lw $a0, 0($a0)
jal fibonacci_recursive
la $t0, result
sw $v0, 0($t0)
j exit

fibonacci_recursive:
addi $t0, $0, 2
ble $a0, $t0, one

addi $sp, $sp, -8
sw $s0, 4($sp)
sw $ra, 0($sp)

addi $s0, $a0, -2
addi $a0, $a0, -1
jal fibonacci_recursive
add $a0, $s0, $0
add $s0, $v0, $0
jal fibonacci_recursive
add $v0, $v0, $s0

lw $s0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp, 8
jr $ra

one:
addi $v0, $0, 1
jr $ra

exit: