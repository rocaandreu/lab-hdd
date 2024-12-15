//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module mult_add_pipeline_ccs_out_buf_wait_v5 (clk, en, arst, srst, ivld, irdy, idat, rdy, vld, dat, is_idle);

    parameter integer  rscid   = 1;
    parameter integer  width   = 8;
    parameter integer  ph_clk  = 1;
    parameter integer  ph_en   = 1;
    parameter integer  ph_arst = 1;
    parameter integer  ph_srst = 1;
    parameter integer  rst_val = 0;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    output             irdy;
    input              ivld;
    input  [width-1:0] idat;
    input              rdy;
    output             vld;
    output [width-1:0] dat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    reg                lbuf;
    wire               lbuf_next;
    reg    [width-1:0] abuf;
    wire               active;
    reg                is_idle;
    wire               is_idle_drv;
    wire               irdy_int;
    wire               vld_int;

    assign lbuf_next = ~vld_int | rdy;
    assign filled_next = lbuf ? ivld : filled;

    assign irdy_int = lbuf_next;
    assign irdy = irdy_int;

    assign vld_int = filled_next;
    assign vld = vld_int;
    assign dat = lbuf ? idat : abuf;

    assign active = (irdy_int & ivld) | (rdy & vld_int);
    assign is_idle_drv = ~active & ~lbuf;

    // Generate is_idle flag
    always@(*)
    begin
        if (lbuf == lbuf_next)
            is_idle = is_idle_drv;
        else
            is_idle = 0;
    end

    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk==1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{rst_val}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{rst_val}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst==1 && ph_clk==1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{rst_val}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{rst_val}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst == 0 && ph_clk==0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{rst_val}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{rst_val}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst==1 && ph_clk==0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{rst_val}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{rst_val}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    endgenerate

endmodule



