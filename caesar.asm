.data:
message: .asciiz "JEVGVATZVCFNFFRZOYLFHPXF"
.text

# Find start and end of string and store in $t3 / $t2
la	$t2, message
add	$t3, $0, $t2
fndloop:
addi	$t2, $t2, 1
lb	$t0, 0($t2)
bne	$t0, $0, fndloop

# Store data length in $t5
sub	$t5, $t2, $t3
li	$t1, 26

cryptbyte:
lb	$t0, 0($t3) # Load next byte
subi	$t0, $t0, 52 # - 65 + 13
div	$t0, $t1 # Take modulo 26
mfhi	$t0
addi	$t0, $t0, 65 # + 65
add	$t4, $t3, $t5 # Calculate storage addr for encrypted byte
sb	$t0, 1($t4)
addi	$t3, $t3, 1 # Move to next byte
bne	$t3, $t2, cryptbyte # Loop if next byte is not end of input
 

