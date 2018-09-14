.data
n: .word 5
result: .word 0

.text
main:
la $a0, n
lw $a0, 0($a0)
jal fibonacci
la $t0, result
sw $v0, 0($t0)
j exit

fibonacci:
addi $t1, $0, 2
ble $a0, $t1, one
addi $t0, $0, 1
addi $t1, $0, 1
addi $a0, $a0, -2

loop:
add $t2, $t0, $t1
add $t0, $t1, $0
add $t1, $t2, $0
addi $a0, $a0, -1
bne $a0, $0, loop
add $v0, $t1, $0
jr $ra

one:
addi $v0, $0, 1
jr $ra

exit:
