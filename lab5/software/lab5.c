#include "address_map_arm.h"
#include "address_map_booth.h"
#include <stdio.h>
#define COUNT28_BASE_ADDRESS 0xFF200020

void set_A9_IRQ_stack(void);
void config_GIC(void);
void config_BOOTH(void);
void enable_A9_interrupts(void);

/* ********************************************************************************
 * This program demonstrates use of interrupts with C code. 
 
 * Initially the value of the switches is represented on the LEDs
 
 * Each time any of the Pushbuttons is pressed the value of variable key_pressed
 * is changed. When the value of this variabl is 0 the value of the switches
 * is represented on the LEDs. When its value is 1 the value of the switches is 
 * represented on the LEDs, but LED9 is ON independently of the value establiched
 * in the switches
********************************************************************************/

volatile int *data_a   = (int *)SLV_REG_0_BOOTH;
volatile int *data_b   = (int *)SLV_REG_1_BOOTH;
volatile int *result   = (int *)SLV_REG_2_BOOTH;
volatile int *slv_reg3 = (int *)SLV_REG_3_BOOTH;

/* Flag activated by booth_IRQ. */
volatile int result_ready = 0;

int main(void)
{
    int result_store;

    set_A9_IRQ_stack();      // initialize the stack pointer for IRQ mode
    config_GIC();            // configure the general interrupt controller

    config_BOOTH();          // configure BOOTH interrupt enable

    enable_A9_interrupts();  // enable interrupts
    
    printf("\nProgram starts...\n"); 

    while (1)
    {
    	// busy bit
    	while(*slv_reg3 & BOOTH_SR3_BUSY_BIT);

	// Send ack pulse
	*slv_reg3 |= BOOTH_SR3_ACK_BIT;  // set to 1
	*slv_reg3 &= ~BOOTH_SR3_ACK_BIT; // set to 0

	// Set A and B values	
	printf("Insert A value: ");
	scanf("%d", data_a);
	printf("Insert B value: ");
	scanf("%d", data_b);
	
	// Send start signal
	*slv_reg3 |= BOOTH_SR3_START_BIT;
	*slv_reg3 &= ~BOOTH_SR3_START_BIT;
	
	// Wait for result
	while(!result_ready);
	result_ready = 0;
	
	result_store = *result;
	printf("Result = %d\n\n", result_store);
    }
}

/* setup the BOOTH interrupts in the FPGA */
void config_BOOTH()
{   
    // Write 1 to irq_enable input of the multiplier (slv_reg3[3])
    *slv_reg3 |= BOOTH_SR3_IRQ_EN_BIT;
}
