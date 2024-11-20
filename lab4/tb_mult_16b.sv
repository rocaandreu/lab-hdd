// Testbench Template for SystemVerilog

`timescale 1ns / 1ps

module tb_mult_16b;  // Testbench module

    // Parameters
    parameter CLK_PERIOD = 10;  // Clock period in nanoseconds

    // DUT signals
    logic        clk;        // global clock signal, 100 MHz frequency
    logic        resetn;     // global reset signal, active low
    logic        start;      // signal that activates the multiplication process by a rising edge
    logic        ack;        // Input used to deassert the IRQ and busy outputs
    logic [15:0] data_a;     // First 16-bit operand
    logic [15:0] data_b;     // Second 16-bit operand
    logic        irq_enable; // IRQ enable input

    logic [31:0] result;     // result of the multiplication
    logic        busy;       // output that indicates that a multiplication process is in progress
    logic        irq;        // IRQ signal activated when the multiplication has completed

    // Instantiate the multiplier
    booth booth_inst (
        .clk        (clk       ),
        .resetn     (resetn    ),
        .start      (start     ),
        .ack        (ack       ),
        .data_a     (data_a    ),
        .data_b     (data_b    ),
        .irq_enable (irq_enable),
        .result     (result    ),
        .busy       (busy      ),
        .irq        (irq       )
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;  // Toggle clock
    end

    // Reset logic
    initial begin
        resetn = 1'b1;  // Assert reset
        #(CLK_PERIOD);  // Hold reset up for a clock cycle
        resetn = 1'b0;
        #11;
        resetn = 1'b1;
    end

    // Stimulus generation
    initial begin
        // Initialize input_signal
        start      = '0;
        ack        = '0;
        data_a     = '0;
        data_b     = '0;
        irq_enable = '1;

        // Test with positive number
        #(CLK_PERIOD);
        data_a  = 16'h0002;
        data_b  = 16'h0004;

        for (int i = 0; i < 4; i++) begin
            // Perform multiplication and add 1 to the left of data_b

            #(CLK_PERIOD);
            start = 1'b1;

            // Wait for multiplication to end
            #(10*CLK_PERIOD); 
            start = 1'b0;

            // Send ack to set 
            ack = 1'b1;
            #(3*CLK_PERIOD);
            ack = 1'b0;

            // Wait 10 clks to have a clearer waveform
            #(10*CLK_PERIOD);
            data_b = data_b << 1 | 3'b100;
        end

        // Test with negative number
        #(CLK_PERIOD);
        data_a  = 16'hFFFE; // -2
        data_b  = 16'h0004;

        for (int i = 0; i < 4; i++) begin
            // Perform multiplication and add 1 to the left of data_b

            #(CLK_PERIOD);
            start = 1'b1;

            // Wait for multiplication to end
            #(10*CLK_PERIOD); 
            start = 1'b0;

            // Send ack to set 
            ack = 1'b1;
            #(3*CLK_PERIOD);
            ack = 1'b0;

            // Wait 10 clks to have a clearer waveform
            #(10*CLK_PERIOD);
            data_b = data_b << 1 | 3'b100;
        end

	// Test with negative number
        #(CLK_PERIOD);
        data_a  = 16'h0004;
        data_b  = 16'hFFFE; // -2

        for (int i = 0; i < 4; i++) begin
            // Perform multiplication and add 1 to the left of data_b

            #(CLK_PERIOD);
            start = 1'b1;

            // Wait for multiplication to end
            #(10*CLK_PERIOD); 
            start = 1'b0;

            // Send ack to set 
            ack = 1'b1;
            #(3*CLK_PERIOD);
            ack = 1'b0;

            // Wait 10 clks to have a clearer waveform
            #(10*CLK_PERIOD);
            data_b = data_b*3;
        end

	// Test with negative number
        #(CLK_PERIOD);
        data_a  = 16'hFFFE;
        data_b  = 16'hFFFE; // -2

        for (int i = 0; i < 4; i++) begin
            // Perform multiplication and add 1 to the left of data_b

            #(CLK_PERIOD);
            start = 1'b1;

            // Wait for multiplication to end
            #(10*CLK_PERIOD); 
            start = 1'b0;

            // Send ack to set 
            ack = 1'b1;
            #(3*CLK_PERIOD);
            ack = 1'b0;

            // Wait 10 clks to have a clearer waveform
            #(10*CLK_PERIOD);
            data_b = data_b*3;
        end
    end
endmodule

