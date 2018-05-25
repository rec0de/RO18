.data
format: .string "Wert: %d\n"

.text
.global main
.global _start

main:
movl $4, %eax
movl %eax, %ecx # Copy original value to ecx
xor %ebx, %ebx # Init ebx to zero

call get_parity # Load parity bit into LSB of ebx
movl $1, %eax
and %ebx, %eax # Discard rest of ebx and save to eax
shl $31, %eax # Shift LSB to MSB position
or %ecx, %eax # Combine original number and parity bit in eax

# print eax
print_number:
pushl %eax
lea format, %ebx
pushl %ebx
call printf
add $8, %esp

# Terminate
movl $0x01, %eax
xor %ebx, %ebx
int $0x80

get_parity:
cmp $0, %eax
je parity_anchor # Done if eax is zero
xor %eax, %ebx # "Accumulate" parity in LSB of ebx
shr $1, %eax # Shift eax to right to get next bit
call get_parity
parity_anchor:
ret