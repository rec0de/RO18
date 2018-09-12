.data
string1: .asciiz "Lorem ipsum dolor sit amet, consetetur sadipscing"
string2: .asciiz "Lorem ipsum dolor sit amet, consetetur sadipscing"
result: .word 0

.text
main:
la $a0, string1
la $a1, string2
jal equal_strings
la $t0, result
sw $v0, 0($t0)
j exit

equal_strings:
add $t0, $0, $0

loop:
add $t3, $t0, $a0
lb $t1, 0($t3)
add $t3, $t0, $a1
lb $t2, 0($t3)

addi $t0, $t0, 1
bne $t1, $t2, notequal
beq $t1, $0, done
j loop

notequal:
addi $v0, $0, -1
jr $ra

done:
addi $v0, $0, 1
jr $ra

exit: