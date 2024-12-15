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
// Change History:
//    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
//                 Fix bug in that behavior.
//    2019-01-04 - Fixed bug 54073 - rdy signal should not be asserted during
//                 reset
//    2018-11-19 - Improved code coverage for is_idle
//    2018-08-22 - Added is_idle to interface (as compare to
//                 ccs_ctrl_in_buf_wait_v2)
//------------------------------------------------------------------------------


module mult_add_pipeline_ccs_ctrl_in_buf_wait_v4 (clk, en, arst, srst, irdy, ivld, idat, vld, rdy, dat, is_idle);

    parameter integer rscid   = 1;
    parameter integer width   = 8;
    parameter integer ph_clk  = 1;
    parameter integer ph_en   = 1;
    parameter integer ph_arst = 1;
    parameter integer ph_srst = 1;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    input              irdy;
    output             ivld;
    input  [width-1:0] dat;
    output             rdy;
    input              vld;
    output [width-1:0] idat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    wire               lbuf;
    wire               active;
    reg    [width-1:0] abuf;
    reg                hs_init;
    wire               rdy_int;
    wire               vld_int;
    wire               ivld_int;

    assign lbuf = ~filled | irdy;
    assign filled_next = lbuf ? vld_int : filled;

    assign vld_int = vld & hs_init;
    assign rdy_int = lbuf & hs_init;
    assign rdy = rdy_int;

    assign ivld_int = filled_next;
    assign ivld = ivld_int;
    assign idat = abuf;

    assign active = (rdy_int & vld_int) | (irdy & ivld_int);
    assign is_idle = ~active & ~lbuf;

    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk==1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst==1 && ph_clk==1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst == 0 && ph_clk==0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst==1 && ph_clk==0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    endgenerate


`ifdef RDY_ASRT
    generate
    if (ph_clk==1)
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) (srst==ph_srst) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(posedge clk) (arst==ph_arst) |-> (rdy==0);
       endproperty
       a2: assert property(rdyAsrtASync);

    end else if (ph_clk==0)
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(negedge clk) (arst==ph_arst) |-> (rdy==0);
       endproperty
       a2: assert property(rdyAsrtASync);
    end
    endgenerate

`endif

endmodule


