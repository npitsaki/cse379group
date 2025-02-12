	.text

	.global lab3

U0FR: 	.equ 0x18	; UART0 Flag Register


lab3:
	PUSH {r4-r12,lr}  ; Store registers r4 through r12 and lr on the
			  ; stack. It ensures that the software convention
			  ; is preserved, and more importantly, that the return
			  ; address is preserved so that a proper return to the
			  ; C wrapper can be executed.  You may change r4-r12 to
			  ; a comma separated list of registers in the r4 through
			  ; r12 range that are actually used.  If a register in
			  ; this range is not used in the routine, it does not
			  ; need to be included in this list.

		; Your test code starts here.
		; For example, the following two lines read a character from the
		; user and then display it in PuTTy.

 		BL read_character
		BL output_character

		; Your test code ends here

	; After testing is complete, you can return to your C wrapper
	; using the POP & MOV instructions shown below.

	POP {r4-r12,lr}	  ; Restore registers r4 through r12 and lr from the
    			  ; stack. It ensures that the software convention is
    			  ; preserved, and more importantly, that the return
			  ; address is preserved so that a proper return to
			  ; the C wrapper can be executed. If you modified
			  ; the list of registers in the PUSH instruction at
			  ; the top of this routine, you MUST make sure that
			  ; the register list in this POP instruction matches
			  ; that of the PUSH instruction.
	mov pc, lr

output_character:
	PUSH {r4-r12,lr}  ; Store registers r4 through r12 and lr to the
			  ; stack to adhere to the software convention, and
			  ; more importantly, ensure that the return address
			  ; is preserved so that a proper return to the caller
			  ; is executed.  LR only needs to be included if this
			  ; routine calls another routine. You may change
			  ; r4-r12 to a comma separated list of registers in
			  ; the r4 through r12 range that are actually used.
			  ; If a register in this range is not used in the
			  ; routine, it does not need to be included in this list.
			  ; A minimal list of registers is best. Each register
			  ; in the list adds a cycle to the runtime of the
			  ; subroutine.

		; in the UART flag register, bit 7 - TxFE, 6 - RxFF, 5 - TxFF, 4 - RxFE, 3 - BUSY, 0 - CTS.
		MOV r2, #0xC000				; we need UART data register so we place it in r2. (0x4000C000 for UART0)
		MOVT r2, #0x4000
loopt:
		LDRB r1, [r2, #U0FR]		; read the UART Flag Register and place contents in r1 so we can check flags. note, #U0FR is the immediate offset we add to the base address in r2 to get to the flag register.
		AND r1, r1, #0x0020			; mask out TxFF bit 5 flag to check if 1 or 0.
		CMP r1, #0					; check TxFF flag, stop if TxFF is 0.
		BNE loopt
stopt:
		STRB r0, [r2]				; transmit character to putty by storing it into the UART data register.

	POP {r4-r12,lr}	  ; Restore registers r4 through r12 and lr from the
			  ; stack to adhere to the software convention, and
			  ; more importantly, ensure that the return address
			  ; is preserved so that a proper return to the caller
			  ; is executed.  If you modified the register list in
			  ; the PUSH instruction at the top of this routine
			  ; the register list must be modified in the POP
			  ; instruction so that it matches.
	mov pc, lr

read_character:
	PUSH {r4-r12,lr}

			  ; Store registers r4 through r12 and lr to the
			  ; stack to adhere to the software convention, and
			  ; more importantly, ensure that the return address
			  ; is preserved so that a proper return to the caller
			  ; is executed.  LR only needs to be included if this
			  ; routine calls another routine. You may change
			  ; r4-r12 to a comma separated list of registers in
			  ; the r4 through r12 range that are actually used.
			  ; If a register in this range is not used in the
			  ; routine, it does not need to be included in this list.
			  ; A minimal list of registers is best. Each register
			  ; in the list adds a cycle to the runtime of the
			  ; subroutine.

		MOV r2, #0xC000				; we need UART data register so we place it in r2. (0x4000C000 for UART0)
		MOVT r2, #0x4000			; since register is 32 bits we need to use MOV on lower half then MOVT on upper half.
loopr:
		LDRB r1, [r2, #U0FR]		; read the UARTFR register and place contents in r1 so we can check flags. note, #U0FR is the immediate offset we add to the base address in r2 to get to the flag register.
		AND r1, r1, #0x0010			; mask out RxFE bit 4 flag to check if 1 or 0.
		CMP r1, #0					; check RxFE flag, stop if RxFE is 0.
 		BNE loopr					; else loop.
stopr:
		LDRB r0, [r2]				; receive character from keyboard.

	POP {r4-r12,lr}	  ; Restore registers r4 through r12 and lr from the
			  ; stack to adhere to the software convention, and
			  ; more importantly, ensure that the return address
			  ; is preserved so that a proper return to the caller
			  ; is executed.  If you modified the register list in
			  ; the PUSH instruction at the top of this routine
			  ; the register list must be modified in the POP
			  ; instruction so that it matches.
	mov pc, lr

	.end
