.data
array: 3, 14, 15, 0 # Null - terminate array
error: .asciiz "Array not sorted!"
success: .asciiz "Array sorted!"
.text

la $t0, array
lw $t1, 0($t0)

loop:
addi $t0, $t0, 4
lw $t2, 0($t0)
beqz $t2, sorted
blt $t2, $t1, not_sorted
add $t1, $t2, $0
j loop

sorted:
la $a0, success
j print
not_sorted:
la $a0, error
print:
li $v0, 4 # print string
syscall