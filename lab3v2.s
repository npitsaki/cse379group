	.data

	.global intro_prompt
	.global prompt_dividend
	.global prompt_divisor
	.global result_remainder
	.global dividend
	.global divisor
	.global remainder
	.global continue
	.global bye
	.global blank
	.global error

intro_prompt:       .string "Hit Enter if you would like to get the remainder of two numbers. Or hit 'Q' to quit. ", 0
prompt_dividend:	.string "Input your dividend, hit enter when done: ", 0
prompt_divisor:		.string "Input your divisor, hit enter when done: ", 0
result_remainder:	.string "Here's the remainder: ", 0
dividend: 			.string "xxxxxx", 0
divisor:  			.string "xxxxxx", 0
remainder:          .string "xxxxxx", 0
continue: 			.string "Hit Enter to restart or hit 'Q' to quit: ", 0
bye:				.string "Bye! ", 0
blank:				.string "xxxxxx", 0
error:				.string "Number exceeded allowable range.  Restart. ", 0


	.text

	.global lab3
U0FR: 	.equ 0x18	; UART0 Flag Register

ptr_to_intro:           .word intro_prompt
ptr_to_prompt_dividend:	.word prompt_dividend
ptr_to_prompt_divisor:	.word prompt_divisor
ptr_to_result_remainder:.word result_remainder
ptr_to_dividend:		.word dividend
ptr_to_divisor:			.word divisor
ptr_to_remainder:		.word remainder
ptr_to_continue:     	.word continue
ptr_to_bye:				.word bye
ptr_to_blank:			.word blank
ptr_to_error:			.word error

lab3:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

    BL uart_init			; initilize the UART0 for use.

    MOV r0, #13				; this part just prints out a newline and carriage return.
	BL output_character
	MOV r0, #10
	BL output_character

    LDR r0, ptr_to_intro	; move intro_prompt into r0 for output_string call.
    BL output_string		; prompt user with intro prompt. "Hit Enter if you would..."

intro_loop:
    BL read_character       ; read next char to check for enter key or quit.
    CMP r0, #13             ; did user hit Enter?
    BEQ main_loop			; Yes? go to main loop
    CMP r0, #0x51           ; did user enter a 'Q' for quit?
    BNE intro_loop          ; No? keep looping.
    B lab3_end              ; Yes? quit program.
main_loop:
    CMP r0, #0x51           ; first check if user hit 'Q' on last prompt.
    BEQ lab3_end

	; now we prompt user for input.
    MOV r0, #13				; this part just prints out a newline and carriage return.
	BL output_character
	MOV r0, #10
	BL output_character

    LDR r0, ptr_to_prompt_dividend
    BL output_string        ; output prompt for dividend.

    LDR r0, ptr_to_dividend ; load dividend string into r0.
    BL read_string          ; place user input for dividend in string pointed to ptr_to_dividend.

    MOV r0, #13				; this part just prints out a newline and carriage return.
	BL output_character
	MOV r0, #10
	BL output_character

    LDR r0, ptr_to_prompt_divisor
    BL output_string        ; prompt for divisor.

    LDR r0, ptr_to_divisor  ; load divisor string base address into r0.
    BL read_string          ; place user input for divisor in string returned in r0.



	; fun unexpected behavior where a backspace chars can
	; result in permanent deletion/overwriting of previously output line
	; to fix we want to prevent more backspaces than user input length,
	; not gonna do this rn though.
	; also same issue with overflow of strings on user input overwriting values for dividend and divisor.
	; this can be fixed by limiting to max input length of 6 for xx,xxx.


    MOV r0, #13				; this part just prints out a newline and carriage return.
	BL output_character
	MOV r0, #10
	BL output_character

    ; now we stored both the user inputs into strings located in memory.
    ; next we have to convert them to integers in order to calculate the remainder.

    LDR r0, ptr_to_dividend	; load dividend string base address into r0.
    BL string2int
    MOV r2, r0				; move integer dividend into r2.
   	;CMP r2, #0x00001000
   	;BGT num_error

    LDR r0, ptr_to_divisor  ; load divisor string base address into r0.
    BL string2int
    MOV r3, r0				; move integer divisor into r3.
    ;CMP r3, #0x00001000
   	;BGT num_error


    ; now we stored both user inputs for dividend and divisor as integers in r10 and r11 respectively.
    ; next we calculate the remainder then store it in memory.

	; note we have an error when > either input exceeds 32767 (there's an overflow that cause the string to return funny values
	; related to the last call's remainder.) since this results in a not null-terminated string we source the calculation numbers thing.
    MOV r0, r2              ; load dividend into r0.
    MOV r1, r3              ; load divisor into r1.
    BL division             ; after call r0 holds quotient and r1 holds remainder.
    LDR r0, ptr_to_remainder; load remainder base address into r0.
    BL int2string           ; pass remainder string base address into r0, integer to convert passed into r1 (remainder from division call). returns string in r0.

    ; now we have stored the remainder into memory.
    ; next we output the result to the user.

    LDR r0, ptr_to_result_remainder
    BL output_string        ; output result prompt.

    LDR r0, ptr_to_remainder
    BL output_string        ; output remainder result to user.

    MOV r0, #13				; this part just prints out a newline and carriage return.
	BL output_character
	MOV r0, #10
	BL output_character
	B clear_and_continue
;num_error:
;	LDR r0, ptr_to_error
;	BL write_string
;	MOV r0, #13				; this part just prints out a newline and carriage return.
;	BL output_character
;	MOV r0, #10
;	BL output_character
clear_and_continue:
	; clear out storage strings here for next iteration.
	LDR r0, ptr_to_dividend
	LDR r1, ptr_to_blank
	BL write_string

	LDR r0, ptr_to_divisor
	LDR r1, ptr_to_blank
	BL write_string

	LDR r0, ptr_to_remainder
	LDR r1, ptr_to_blank
	BL write_string

    ; finally we prompt the user to continue or quit.
    LDR r0, ptr_to_continue
    BL output_string
    B intro_loop
lab3_end:
	MOV r0, #13				; this part just prints out a newline and carriage return.
	BL output_character
	MOV r0, #10
	BL output_character
	LDR r0, ptr_to_bye		; output "Bye!" message.
	BL output_string


	POP {r4-r12,lr} 	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr





; input - none.
; output - none.
uart_init:
	PUSH {r4-r5,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

	;/* Provide clock to UART0  */
	MOV r4, #0xE618
	MOVT r4, #0x400F

	MOV r5, #1
	STR r5, [r4]

	;/* Enable clock to PortA  */
	MOV r4, #0xE608
	MOVT r4, #0x400F

	MOV r5, #1
	STR r5, [r4]

	;/* Disable UART0 Control  */
	MOV r4, #0xC030
	MOVT r4, #0x4000

	MOV r5, #0
	STR r5, [r4]

	;/* Set UART0_IBRD_R for 115,200 baud */
	MOV r4, #0xC024
	MOVT r4, #0x4000

	MOV r5, #8
	STR r5, [r4]

	;/* Set UART0_FBRD_R for 115,200 baud */
	MOV r4, #0xC028
	MOVT r4, #0x4000

	MOV r5, #44
	STR r5, [r4]

	;/* Use System Clock */
	MOV r4, #0xCFC8
	MOVT r4, #0x4000

	MOV r5, #0
	STR r5, [r4]

	;/* Use 8-bit word length, 1 stop bit, no parity */
	MOV r4, #0xC02C
	MOVT r4, #0x4000

	MOV r5, #0x60
	STR r5, [r4]

	;/* Enable UART0 Control  */
	MOV r4, #0xC030
	MOVT r4, #0x4000

	MOV r5, #0x301
	STR r5, [r4]

	;/* Make PA0 and PA1 as Digital Ports  */
	MOV r4, #0x451C
	MOVT r4, #0x4000

	LDR r5, [r4]
	ORR r5, r5, #0x03

	STR r5, [r4]

	;/* Change PA0,PA1 to Use an Alternate Function  */
	MOV r4, #0x4420
	MOVT r4, #0x4000

	LDR r5, [r4]
	ORR r5, r5, #0x03

	STR r5, [r4]

	;/* Configure PA0 and PA1 for UART  */
	MOV r4, #0x452C
	MOVT r4, #0x4000

	LDR r5, [r4]
	ORR r5, r5, #0x11

	STR r5, [r4]

	POP {r4-r5,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr




; input - none.
; return - r0 base address for character read.
read_character:
	PUSH {r4-r5,lr}

	MOV r5, #0xC000					; we need UART data register so we place it in r2. (0x4000C000 for UART0)
	MOVT r5, #0x4000				; since register is 32 bits we need to use MOV on lower half then MOVT on upper half.
loop_read:
	LDRB r4, [r5, #U0FR]			; read the UARTFR register and place contents in r1 so we can check flags. note, #U0FR is the immediate offset we add to the base address in r2 to get to the flag register.
	AND r4, r4, #0x0010				; mask out RxFE bit 4 flag to check if 1 or 0.
	CMP r4, #0						; check RxFE flag, stop if RxFE is 0.
	BNE loop_read					; else loop.
stop_read:
	LDRB r0, [r5]					; receive character from keyboard.
    STRB r0, [r5]               	; output character as it's entered. placed here to meet spec.

	POP {r4-r5,lr}
	mov pc, lr




; input - r0 base address for string to be returned.
; return - r0 base addres of string read.
read_string:
	PUSH {r4-r5,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.
	MOV r4, r0 						; save r0, the base address of the string, to r1 so we can manipulate it.

loop_read_string:
	BL read_character				; get character
	CMP r0, #13						; is it an enter key?
	BNE add_to_str					; go to add_to_str if not

	MOV r5, #0						; else NULL terminate string
	STRB r5, [r4]
	B stop_read_string				; end

add_to_str:							; add char to string
	STRB r0, [r4]
	ADD r4, r4, #1					; increment memory address
	B loop_read_string

stop_read_string:					; function finished. null terminated string stored MSD first with r0 as base address.


	POP {r4-r5,lr}
	mov pc, lr




; input - r0 character to be output.
; return - none.
output_character:
	PUSH {r4-r5,lr}
	; bits in the UART flag register UARTFR 0x4000C018: bit 7 - TxFE, 6 - RxFF, 5 - TxFF, 4 - RxFE, 3 - BUSY, 0 - CTS.
	MOV r4, #0xC000					; we need UART data register so we place it in r2. (0x4000C000 for UART0)
	MOVT r4, #0x4000
loop_output:
	LDRB r5, [r4, #U0FR]			; read the UART Flag Register and place contents in r1 so we can check flags. note, #U0FR is the immediate offset we add to the base address in r2 to get to the flag register.
	AND r5, r5, #0x0020				; mask out TxFF bit 5 flag to check if 1 or 0.
	CMP r5, #0						; check TxFF flag, stop if TxFF is 0.
	BNE loop_output
stop_output:
	STRB r0, [r4]					; transmit character to putty by storing it into the UART data register.

	POP {r4-r5,lr}
	mov pc, lr




; input - r0 string to be output.
; return - none.
output_string:
	PUSH {r4-r5,lr}

	MOV r4, r0						; base address passed in r0, place in r12 to use as memory index.
loop_output_string:
	LDRB r5, [r4]					; load current char from string into r1.
	CMP r5, #0 						; is it NULL?
	BEQ null
	MOV r0, r5						; if not, send to uart data register/screen by calling output_character.
	BL output_character				; prep by putting current char into r0 before call.
	ADD r4, r4, #1					; increment mem addr to next byte/char of string.
	B loop_output_string
null:
	;MOV r0, r3						; load base address for string into r0 for return.

	POP {r4-r5,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr




; input - r1 integer, r0 base address of string.
; output - r0 base address of string version of integer input into r1.
int2string:
	PUSH {r4-r12,lr}

	MOV r7, r1						; r7 holds the integer we start with and we use reduce it until it reaches 0.
    MOV r3, r1                      ; save integer for comparison later.
	MOV r6, r0						; r6 and r5 hold base address of string.
	MOV r5, r0
	MOV r4, #0						; counter to keep track of how many digits the integer has.

	CMP r7, #0						; handle zero input right away so rest of algo works.
	BNE div_loop
zero:
	ADD r7, r7, #0x30				; store ascii zero into string.
	STRB r7, [r6]
	B end_string

div_loop:							; store integer digit by digit (msd to lsd) as string starting at base address passed into function.
	CMP r7, #0						; check if we're done with division portion/our number has decreased to 0.
	BEQ done_with_div_loop


	MOV r0, r7						; if not, keep reducing number via / 10 and % 10 to get Least Significant Digit.
	MOV r1, #10
	BL division
	MOV r7, r0						; move division quotient result to r7. remainder/digit is in r1.
	ADD r1, r1, #0x30				; convert remainder to ascii.
	ADD r4, r4, #1                  ; increment digit counter.

	CMP r4, #1						; determine if we're on digit 1-5.
	BEQ first_digit					; this helps us reverse the number's order in memory from LSD stored first to MSD stored first.

	CMP r4, #2
	BEQ second_digit

	CMP r4, #3
	BEQ third_digit

	CMP r4, #4
	BEQ fourth_digit

	CMP r4, #5
	BEQ fifth_digit

									; Here we store our digits as we receive them (in LSD to MSD order) so we can reverse them later.
first_digit:						; if we're on the first digit, move to r8, and start next iteration of div_loop.
	MOV r8, r1
	B div_loop

second_digit:
	MOV r9, r1
	B div_loop

third_digit:
	MOV r10, r1
	B div_loop

fourth_digit:
	MOV r11, r1
	B div_loop

fifth_digit:
	MOV r12, r1
	B div_loop

done_with_div_loop:					; once we've fully reduced our integer to zero we begin to store it into memory in
	CMP r4, #5						; order from MSD to LSD (lowest memory address to highest memory address).
	BEQ dig_five					; this part uses the counter to determine the number of digits our integer had.
									; we then use this to store the integer from MSD to LSD using the counter/digits
	CMP r4, #4						; along with fall through from the appropriate labels below.
	BEQ dig_four

	CMP r4, #3
	BEQ dig_three

	CMP r4, #2
	BEQ dig_two

	CMP r4, #1
	BEQ dig_one


dig_five:
	STRB r12, [r6]					; store integer digit by digit (msd to lsd) as string starting at base address passed into function.
	ADD r6, r6, #1					; increment memory address to next digit.

dig_four:                           ; comma added in this step if needed.
	STRB r11, [r6]
	MOV r12, #999
    CMP r3, r12                     ; is input integer > 999?
    BGT add_comma                   ; yes? add comma.
	B after_comma                   ; no? skip comma.
add_comma:
	ADD r6, r6, #1					; move to next position in string.
	MOV r11, #44					; 44 is ascii decimal value for a comma.
	STRB r11, [r6]                  ; add comma.
after_comma:
	ADD r6, r6, #1                  ; increment to next digit.

dig_three:
	STRB r10, [r6]
	ADD r6, r6, #1

dig_two:
	STRB r9, [r6]
	ADD r6, r6, #1

dig_one:
	STRB r8, [r6]					; store final least significant digit.

end_string:
	MOV r8, #0						; null terminate string.
	STRB r8, [r6, #1]

	MOV r0, r5						; restore base address to r0 for return to user.

	POP {r4-r12,lr}
	mov pc, lr



; input - r0 string version of int,
; return - r0 int version of string.
; note that this "fixes" misplaced commas s.t. any comma is removed regardless of position and the signifcance of digits remains same relative to lsd position.
string2int:
	PUSH {r4-r7,lr}

	MOV r7, r0                 		; save r0 into r10 to use as index into string.
	MOV r4, #0                  	; set r4 to 0 to hold our accumulating sum.
	MOV r5, #10                 	; save 10 into r15 for multiplication.
loop_s2i:
	LDRB r6, [r7]					; load current character.
	ADD r7, r7, #1			    	; increment index to next char.
	CMP r6, #0						; is cur char a null?
	BEQ null_s2i
	CMP r6, #44						; is cur char a comma?
	BEQ loop_s2i
	SUB r6, r6, #0x30				; if not convert char to int.
	MUL r4, r4, r5					; multiply cur sum by 10.
	ADD r4, r4, r6					; and add cur char.
	B loop_s2i
null_s2i:
	MOV r0, r4                  	; return the integer version of the string passed into r0 in r0.

	POP {r4-r7,lr}

	mov pc, lr



; Additional subroutines may be included here

; input - r0 holds dividend, r1 holds divisor.
; return - r0 holds quotient, r1 holds remainder.
; note that division by zero returns dividend.
division:
        PUSH {r4-r5,lr}        ; Store registers r4 through r12 and lr on the
                                ; stack. Do NOT modify this line of code.  It
                                ; ensures that the return address is preserved
                                ; so that a proper return to the C wrapped can be
                                ; executed.
; BEGIN DIVISION FUNCTION
        LSL r1, #15              	; left shift divisor.
        MOV r4, #15                 ; counter.
        MOV r5, #0                  ; quotient.
div:
        CMP r4, #0                  ; check counter.
        BLT stop                    ; changed this from BLE to BLT, stopped one iteration short otherwise.
        SUB r0, r0, r1              ; calculate remainder.
        LSL r5, #1                  ; shift quotient here, occurs in both branches and the quanitity has no dependency later in loop.
        CMP r0, #0                  ; check remainder < 0,
        BLT yes                     ; branch to yes if so,
        ORR r5, r5, #1              ; else continue as though >= 0.  set lsb of quotient.
        LSR r1, #1                  ; right shift divisor.
        SUB r4, r4, #1              ; decrement counter second.
        B div                       ; branch to top.
yes:
        ADD r0, r0, r1              ; correct for remainder value calculated above in case it ends up < 0.
        LSR r1, #1                  ; right shift divisor.
        SUB r4, r4, #1              ; decrement counter second.
        B div                       ; branch to top.
stop:
		MOV r1, r0					; remainder into r1.
        MOV r0, r5                  ; quotient into r0 as counter reached zero.
; END DIVISION FUNCTION

        POP {r4-r5,lr}

        MOV pc, lr




; input - r0 base address in memory to write to. r1 the string to write from.
; return - none
; just writes a string from one location in memory to another location.
write_string:
	PUSH {r4-r5,lr}

	MOV r4, r0						; base addres of string we're writing to.
	MOV r5, r1						; base address of string we're writing from.
loop_write:
	LDRB r6, [r5]					; load cur char.
	CMP r6, #0						; is it null?
	BEQ null_write
	STRB r6, [r4]					; write cur char to string.
	ADD r4, r4, #1					; increment string index.
	ADD r5, r5, #1					; move to next char.
	B loop_write
null_write:
	STRB r6, [r4]

	POP {r4-r5,lr}
	MOV pc, lr


	.end
