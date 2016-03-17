# Memos-1.s
# Joe Zhou jzhou94@bu.edu
# Ekaterina Prokopeva katerin@bu.edu
 	
# To assemble: as --32 memos-1.s -o memos-1.o
# To link to MBR: ld -T memos-1.ld memos-1.o -o memos-1
# To test: qemu-system-i386 -hda memos-1 -m XXX(memory size) -vnc :1 &
# To access vnc: /root/vnc/opt/TigerVNC/bin/vncviewer :1
# To unbind socked: kill -9 XXX (process number)

# Resources: Lecture notes, OSDev, Piazza, uruk, VGA16 and other examples

	.globl _start
	.code16					# Run code in 16 bit mode

_start:
	movw $0x9000, %ax		# Temporary register to store value
	movw %ax, %ss			# Set stack segment to 9000
	xorw %sp, %sp			# Set stack pointer to 0

	movw $0x0, %dx			# Bios loads master boot record at 0x7C00
	movw %dx, %ds			# Done through linker script
	
	leaw message, %si       # Puts message in %si
	movw length, %cx        # Puts message length in %cx
	
1:
	lodsb					# Loads character in %si
	movb $0x0E, %ah			
	int $0x10               # Print character to screen
	loop 1b                 # Decrements cx to print next character
	
	movb $'0, %al			# Prints 0
	movb $0x0E, %ah
	int $0x10
	movb $'x, %al			# Prints x
	movb $0x0E, %ah
	int $0x10
	
    #movw $0x0000, %bx 		# Move to temporary register then to es
    #movw %bx, %es       	# Load memory map to es:di
    #movw $0x2100, %di   	# es:di is destination of unsorted list from E820
    
    #call do_e820
	
#   0xE801: stores avaiable memory from 0 - 15MB in 1KB blocks in %ax and %dx
#  		stores avaiable memory from 16MB - 4GB in 64KB blocks in %bx and %dx
	
    xorw %cx, %cx			# Clears %cx
	xorw %dx, %dx			# Clears %dx
	movw $0xE801, %ax		# Loads E801 function to %ax
	int $0x15				# Bios Interrupt 15 for E801
 
    shr $10, %ax			# Changes unit of %ax from KB to MB
    shr $4, %bx				# Changes unit of %bx from 64KB to MB
    addw %bx, %ax			# Adds value of %bx to %ax to find total memory
	movw %ax, %cx			# Store version of %ax to %cx
	movw %bx, %dx			# Store version of %bx to %dx
    
#   Hexidecimal Print
	shr $8, %ax				# Puts first half of original %ax in %ax
	call print				# Prints first half of value stored in %ax
	movw %cx, %ax			# Stores original %ax in %ax
	andb $0xFF, %al			# Puts second half of original %ax in %ax
	call print				# Prints second half of value stored in %ax
	
#	This will print in hexidecimal value the amount of available memory
#		determined by qemu call in terminal
		
	movb $'M, %al			# Prints M
	movb $0x0E, %ah
	int $0x10
	movb $'B, %al			# Prints B
	movb $0x0E, %ah
	int $0x10
	
jmp end

# HEX print provided by Professor Rich West of Boston University
print:	
    pushw %dx
	movb %al, %dl
	shrb $4, %al
	cmpb $10, %al
	jge 1f
	addb $48, %al
	jmp 2f
1:	addb $55, %al		
2:	movb $0x0E, %ah
	int $0x10

	movb %dl, %al
	andb $0x0F, %al
	cmpb $10, %al
	jge 1f
	addb $48, %al
	jmp 2f
1:	addb $55, %al		
2:	movb $0x0E, %ah
	int $0x10
	popw %dx
	ret
	
message:
	.asciz "MemOS: Welcome *** System Memory is:"
length:
	.word .-message

end: 
	hlt
	
#   Boot signature
	.org 0x1FE
	.byte 0x55
	.byte 0xAA
