.data
array: .word 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
array_length: .word 11
sought_element: .word 133
result: .word 0

.text
main:
la $a0, array
la $a1, array_length
lw $a1, 0($a1)
la $a2, sought_element
lw $a2, 0($a2)
jal binary_search
la $t0, result
sw $v0, 0($t0)
j exit

binary_search:
# Calculate low
add $t0, $a0, $0

# Calculate high
sll $t4, $a1, 2
add $t4, $t4, $a0

# Calculate pivot index
sub $t3, $t4, $t0
srl $t3, $t3, 3

loop:
# Load pivot element
sll $t1, $t3, 2
add $t1, $t1, $t0
lw $t2, 0($t1)
bgt $a2, $t2, larger
blt $a2, $t2, smaller
# Equal to search value then return
sub $v0, $t1, $a0
srl $v0, $v0, 2
jr $ra

larger: # Searched element is larger than pivot
addi $t0, $t1, 4 # Update low
beq $t4, $t0, notfound
sub $t3, $t4, $t0
srl $t3, $t3, 3
j loop

smaller:
add $t4, $t1, $0 # Update high
beq $t4, $t0, notfound
sub $t3, $t4, $t0
srl $t3, $t3, 3
j loop

notfound:
addi $v0, $0, -1
jr $ra

exit:
