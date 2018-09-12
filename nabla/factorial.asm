.data
n: .word 5
result: .word 0

.text
main:
la $a0, n
lw $a0, 0($a0)
jal factorial
la $t0, result
sw $v0, 0($t0)
j exit

factorial:
bltz $a0, error # Return error if < 0
beqz $a0, zero # Return one if = 0
add $v0, $a0, $0 # Set v0 to first factor

loop:
addi $a0, $a0, -1
beqz $a0, done # Done if next factor would be zero
mult $v0, $a0 # Multiply result with factor
mflo $v0
j loop

error:
addi $v0, $0, -1
jr $ra
zero:
addi $v0, $0, 1
done:
jr $ra 

exit: