.data
array: .long 1, 9, 3, 5, 6, 7, 4, 8, 2, 10
len: .long 10

.text
.global main

main:

lea array, %eax
pushl %eax
pushl len
call bubble
add $8, %esp # Free stack

# Terminate
movl $0x01, %eax
xor %ebx, %ebx
int $0x80

bubble:
	# Save registers and create base pointer
	pushl %ebp
	movl %esp, %ebp
	pushl %ecx
	pushl %ebx
	pushl %edx

	# load array length in ecx
	movl 8(%ebp), %ecx
	add $-1, %ecx # convert to last index of array
	movl 12(%ebp), %ebx # load array start address to ebx

	sort_loop:
		xor %edx, %edx # edx = 0
		inner_loop:
		movl (%ebx, %edx, 4), %eax # Load array value at position edx
		cmp %eax, 4(%ebx, %edx, 4) # Compare to value at edx + 1
		jae skip # No need to swap if value at edx+1 >= value at edx
		pushl 4(%ebx, %edx, 4) # Temporarily save value at edx+1
		popl (%ebx, %edx, 4) # Write value at edx+1 to position edx
		movl %eax, 4(%ebx, %edx, 4) # Write value at edx to position edx+1
		skip:
		add $1, %edx # increment edx
		cmp %edx, %ecx # loop as long as ecx > edx
		ja inner_loop
	loop sort_loop # loop as long as ecx > 0

	# Restore registers
	popl %edx
	popl %ebx
	popl %ecx
	popl %ebp
ret