.data
array: .word 6, 17, 52, 13, 0, 14, 55, 42
array_length: .word 8
sought_element: .word 42
result: .word 0

.text
main:
la $a0, array
la $a1, array_length
lw $a1, 0($a1)
la $a2, sought_element
lw $a2, 0($a2)
jal find
la $t0, result
sw $v0, 0($t0)
j exit

find:
add $t0, $0, $0
loop:
sll $t1, $t0, 2
add $t1, $t1, $a0
lw $t4, 0($t1)
beq $t4, $a2, found
addi $t0, $t0, 1
beq $t0, $a1, notfound
j loop

found:
add $v0, $t0, $0
jr $ra

notfound:
addi $v0, $0, -1
jr $ra

exit: