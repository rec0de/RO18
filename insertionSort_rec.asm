.data:
array: 1337, 42, 84, 7, 443, 80, 8080, 22, 1998
.text:

j	main

insertionSort:
beq	$a0, 4, insertDone
# Find smallest element
add	$t0, $a1, $0
add	$t1, $a1, $a0
lw	$t3, 0($t0)
minloop:
lw	$t2, 0($t0)
sub	$t4, $t2, $t3
bgtz	$t4, minloopskip
add	$t3, $t2, $0
add	$t5, $t0, $0 # Save index of min elem
minloopskip:
addi	$t0, $t0, 4
bne	$t0, $t1, minloop
# Swap first and smallest element
lw	$t6, 0($a1)
sw	$t3, 0($a1)
sw	$t6, 0($t5)
#Recursive call
addi	$a0, $a0, -4
addi	$a1, $a1, 4
addi	$sp, $sp, -4
sw	$ra, 0($sp)
jal	insertionSort
lw	$ra, 0($sp)
addi	$sp, $sp, 4
addi	$v0, $v0, -4
jr	$ra # Return

insertDone:
add	$v0, $a1, $0 # Return array if length is zero
jr	$ra


main:
# Find array start and end addresses and store in $t8 / $t9
la	$t8, array
add	$t9, $0, $t8
fndloop:
addi	$t9, $t9, 4
lw	$t0, 0($t9)
bne	$t0, $0, fndloop

# Load array length into $a0
sub	$a0, $t9, $t8
add	$a1, $0, $t8

jal	insertionSort
