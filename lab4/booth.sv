module booth (
    input  logic        clk,        // global clock signal, 100 MHz frequency
    input  logic        resetn,     // global reset signal, active low
    input  logic        start,      // signal that activates the multiplication process by a rising edge
    input  logic        ack,        // Input used to deassert the IRQ and busy outputs
    input  logic [15:0] data_a,     // First 16-bit operand
    input  logic [15:0] data_b,     // Second 16-bit operand
    input  logic        irq_enable, // IRQ enable input

    output logic [31:0] result,     // result of the multiplication
    output logic        busy,       // output that indicates that a multiplication process is in progress
    output logic        irq         // IRQ signal activated when the multiplication has completed
);

    logic    [31:0] result_r;
    logic    [31:0] result_n;
    logic    [15:0] operand;     // Input to the adder
    logic    [15:0] data_a_comp; // op_a's compliment (op_a = 12 -> op_a_comp = -12)
    logic    [16:0] data_b_pad = {data_b, 1'b0}; // data_b with an additional 0 for the first window
    logic    [ 2:0] win_cnt_r;
    logic    [ 2:0] win_cnt_n;
    logic    [ 2:0] action;
    logic           busy_n;
    logic           busy_r;
    logic           irq_n;
    logic           irq_r;
    logic           start_r;
    logic           start_posedge;

    // Direct assignmets of simple comb signals and registers to outputs
    assign data_a_comp   = (~data_a) + 1'b1;
    assign result        = result_r;
    assign busy          = busy_r;
    assign irq           = irq_r;
    assign start_posedge = start & (~start_r);

    always_comb begin : set_action
        // Set register inputs to current ouput
        busy_n = busy_r;
        result_n = result_r;

        // Set action depending on the 3 bit window we are seeing
        action = data_b_pad[(2*win_cnt_r)+:3];

        unique case (action)
            3'b001, 3'b010: begin
                // Add MULT
                operand = data_a;
            end

            3'b011: begin
                // Add 2*MULT
                operand = data_a << 1;
            end

            3'b100: begin
                // Sub 2*MULT
                operand = data_a_comp << 1;
            end

            3'b101, 3'b110: begin
                // Sub MULT
                operand = data_a_comp;
            end

            default: begin
                // Do nothing
                operand = '0;
            end
        endcase

        // TODO: Here we calculate the sum and the rest of outputs
        if (start_posedge) begin
            // Start variables and add stuff
        end else if (|win_cnt_r) begin
            // Add stuff
            if (&win_cnt_r) begin
                // Do not shift result for next cycle and indicate we have finished the operation
            end else begin
                // Shift result
            end
        end
    end

    always_ff @(posedge clk) begin
        if (~resetn) begin
            // Set everything to 0
            result_r <= '0;
            start_r  <= '0;
            busy_r   <= '0;
            irq_r    <= '0;
            irq_r    <= '0;
        end else begin
            start_r   <= start;
            busy_r    <= busy_n;
            irq_r     <= irq_n;
            result_r  <= result_n;
            win_cnt_r <= win_cnt_n;
        end
    end

endmodule: booth
