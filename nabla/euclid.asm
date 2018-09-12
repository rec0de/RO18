.data
x: .word 42
y: .word 13
result: .word 0

.text
main:
la $a0, x
lw $a0, 0($a0)
la $a1, y
lw $a1, 0($a1)
jal euclid
la $t0, result
sw $v0, 0($t0)
j exit

euclid:
div $a0, $a1 # calculate x mod y
add $a0, $a1, $0 # take y as new x
mfhi $a1 # use (x mod y) as new y
beqz $a1, done # if x mod y = 0, y is GCD
j euclid
done:
add $v0, $a0, $0
jr $ra

exit: