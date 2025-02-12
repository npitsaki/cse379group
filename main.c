#include <stdint.h>
extern int lab3(void);
void serial_init(void);

void serial_init(void)
{
    /************************************************/
    /* When translating the following to assembly   */
    /* it is advised to use LDR and STR as opposed  */
    /* to LDRB and STRB.                            */
    /************************************************/
    /* Provide clock to UART0  */
    /*
     *  MOV r0, #0xE618
     *  MOVT r0, #0x400F
     *  MOV r1, #1
     *  STRB r1, [r0]
     *
     */
    (*((volatile uint32_t *)(0x400FE618))) = 1;
    /* Enable clock to PortA  */
    /*
     *  MOV r0, #0xE608
     *  MOVT r0, #0x400F
     *  MOV r1, #1
     *  STRB r1, [r0]
     *
     */
    (*((volatile uint32_t *)(0x400FE608))) = 1;
    /* Disable UART0 Control  */
    /*
     *  MOV r0, #0xC030
     *  MOVT r0, #0x4000
     *  MOV r1, #0
     *  STRB r1, [r0]
     *
     */
    (*((volatile uint32_t *)(0x4000C030))) = 0;
    /* Set UART0_IBRD_R for 115,200 baud */
    /*
     *  MOV r0, #0xC024
     *  MOVT r0, #0x4000
     *  MOV r1, #8
     *  STRB r1, [r0]
     *
     */
    (*((volatile uint32_t *)(0x4000C024))) = 8;
    /* Set UART0_FBRD_R for 115,200 baud */
    /*
     *  MOV r0, #0xC028
     *  MOVT r0, #0x4000
     *  MOV r1, #44
     *  STRB r1, [r0]
     *
     */
    (*((volatile uint32_t *)(0x4000C028))) = 44;
    /* Use System Clock */
    /*
     *  MOV r0, #0xCFC8
     *  MOVT r0, #0x4000
     *  MOV r1, #0
     *  STRB r1, [r0]
     *
     */
    (*((volatile uint32_t *)(0x4000CFC8))) = 0;
    /* Use 8-bit word length, 1 stop bit, no parity */
    /*
     *  MOV r0, #0xC02C
     *  MOVT r0, #0x4000
     *  MOV r1, #0x60
     *  STRB r1, [r0]
     *
     */
    (*((volatile uint32_t *)(0x4000C02C))) = 0x60;
    /* Enable UART0 Control  */
    /*
     *  MOV r0, #0xC030
     *  MOVT r0, #0x4000
     *  MOV r1, #0x301
     *  STRB r1, [r0]
     *
     */
    (*((volatile uint32_t *)(0x4000C030))) = 0x301;
    /*************************************************/
    /* The OR operation sets the bits that are OR'ed */
    /* with a 1.  To translate the following lines   */
    /* to assembly, load the data, OR the data with  */
    /* the mask and store the result back.           */
    /*************************************************/
    /* Make PA0 and PA1 as Digital Ports  */
    /*
     *  MOV r0, #0x451C
     *  MOVT r0, #0x4000
     *  LDRB r1, [r0]
     *  ORR r1, r1, #0x03
     *  STRB r1, [r0]
     */
    (*((volatile uint32_t *)(0x4000451C))) |= 0x03;  // load value from register then or it with 0x03, then store back into register
    /* Change PA0,PA1 to Use an Alternate Function  */
    /*
     *  MOV r0, #0x4420
     *  MOVT r0, #0x4000
     *  LDRB r1, [r0]
     *  ORR r1, r1, #0x03
     *  STRB r1, [r0]
     */
    (*((volatile uint32_t *)(0x40004420))) |= 0x03;
    /* Configure PA0 and PA1 for UART  */
    /*
     *  MOV r0, #0x452C
     *  MOVT r0, #0x4000
     *  LDRB r1, [r0]
     *  ORR r1, r1, #0x11
     *  STRB r1, [r0]
     */
    (*((volatile uint32_t *)(0x4000452C))) |= 0x11;
}


int main()
{
   serial_init();
   // did this infinite while loop to make testing easier.
   while(1) {
       lab3();
   }

}
