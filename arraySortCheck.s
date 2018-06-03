.data
array: .int 10, 10, 11, 12, 13, 0
error: .string "Array not sorted!"
success: .string "Array sorted!"

.text
.global main

main:

lea array, %eax
movl (%eax), %ebx

loop:
add $4, %eax
movl (%eax), %ecx
cmp $0, %ecx
je sorted
cmp %ecx, %ebx
jg not_sorted
movl %ecx, %ebx
jmp loop

sorted:
lea success, %eax
jmp print

not_sorted:
lea error, %eax

print:
pushl %eax
call puts
add $8, %esp

# Terminate
movl $0x01, %eax
xor %ebx, %ebx
int $0x80