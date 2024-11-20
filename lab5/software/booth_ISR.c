#include "address_map_arm.h"
#include "address_map_booth.h"
#include <stdio.h>

extern volatile int result_ready;
extern volatile int *slv_reg3;

/***************************************************************************************
 * booth - Interrupt Service Routine
 *
 * This routine sets result_ready flag to 1
****************************************************************************************/
void booth_ISR(void)
{
    // Send ack pulse
    *slv_reg3 |= BOOTH_SR3_ACK_BIT;  // set to 1
    *slv_reg3 &= ~BOOTH_SR3_ACK_BIT; // set to 0
    
    result_ready = 1; // Set result_ready
    return;
}
