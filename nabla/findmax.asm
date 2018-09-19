.data
array: .word 6, 17, 52, 13, 0, 14, 55, 42
array_length: .word 8
result: .word 0

.text
main:
la $a0, array
la $a1, array_length
lw $a1, 0($a1)
jal max
la $t0, result
sw $v0, 0($t0)
j exit

max:
addi $t0, $0, 1
lw $v0, 0($a0)
loop:
sll $t1, $t0, 2
add $t1, $t1, $a0
lw $t2, 0($t1)
ble $t2, $v0, skip
add $v0, $t2, $0
skip:
beq $t0, $a1, done
addi $t0, $t0, 1
j loop
done:
jr $ra

exit: