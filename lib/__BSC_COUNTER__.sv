// SPDX-FileCopyrightText: © 2020-2024 The Bluespec Authors
// SPDX-License-Identifier: BSD-3-Clause

`include "bluespec.svh"

// -- AMALGAMATE: start --
// ---------------------------------------------------------------------------------------------------------------------

// __BSC_COUNTER__: N-bit counter with load, set, and 2 increment ports.
module __BSC_COUNTER__ // # MARK: __BSC_COUNTER__
  # ( parameter int WIDTH = 1
    , parameter bit [WIDTH-1:0] INIT = 0
    ) ( input wire logic clk
      , input wire logic reset

      , input wire logic add_a
      , input wire logic add_b 
      , input wire logic set_c
      , input wire logic set_f
      , input wire logic [WIDTH-1:0] data_a
      , input wire logic [WIDTH-1:0] data_b
      , input wire logic [WIDTH-1:0] data_c
      , input wire logic [WIDTH-1:0] data_f

      , output reg [WIDTH-1:0] out
      );

   reg [WIDTH-1:0] q_state
`ifndef __BSC_NO_INITIAL_BLOCKS__
`ifndef SYNTHESIS
       = `__BSC_FILL_BITS_01__(WIDTH)
`endif
`endif
       ;

   always_ff @(`__BSC_RESET_EDGE__(clk, reset)) begin: ff
     if (reset == `__BSC_RESET_VALUE__) begin
       q_state <= `__BSC_ASSIGNMENT_DELAY__ INIT;
     end else begin: high
       if (set_f) begin
         q_state <= `__BSC_ASSIGNMENT_DELAY__ data_f;
       end else begin
         q_state <= `__BSC_ASSIGNMENT_DELAY__
            (set_c ? data_c : q_state)
          + (add_a ? data_a : {WIDTH{1'b0}})
          + (add_b ? data_b : {WIDTH{1'b0}});
       end
     end: high
   end: ff

   assign out = q_state;
endmodule: __BSC_COUNTER__

// ---------------------------------------------------------------------------------------------------------------------

`ifdef __BSC_SHIM_V1_PRIMS__
module Counter
  # ( parameter width = 1
    , parameter init = 0
    ) ( input CLK
      , input RST

      , input ADDA
      , input ADDB
      , input SETC
      , input SETF
      , input [width-1:0] DATA_A
      , input [width-1:0] DATA_B
      , input [width-1:0] DATA_C
      , input [width-1:0] DATA_F

      , output reg [width-1:0] Q_OUT
      );

  __BSC_COUNTER__
    # ( .WIDTH(width)
      , .INIT(init)
      ) i_counter
    ( .clk(CLK)
    , .reset(RST)
    , .out(Q_OUT)
    , .add_a(ADDA)
    , .add_b(ADDB)
    , .set_c(SETC)
    , .set_f(SETF)
    , .data_a(DATA_A)
    , .data_b(DATA_B)
    , .data_c(DATA_C)
    , .data_f(DATA_F)
    );
endmodule
`endif // __BSC_SHIM_V1_PRIMS__

// ---------------------------------------------------------------------------------------------------------------------


`ifdef __BSC_TESTBENCH__
/* verilator lint_off DECLFILENAME */
/* verilator lint_off MULTITOP */

module __BSC_COUNTER__TEST001; // MARK: Test: #001
  reg clk = 0;
  reg reset = 0;

  always #5 clk <= !clk;
  initial begin: init
    $display("### TEST: __BSC_COUNTER__TEST001");
    # 20 reset = 1;
    # 100 $finish();
  end: init

  reg [7:0] out;
  __BSC_COUNTER__ 
    # ( .WIDTH(8), .INIT(8'b0) )
      counter0
        ( .clk(clk)
        , .reset(reset)
        , .add_a(1'b1)
        , .add_b(1'b1)
        , .set_c(1'b0)
        , .set_f(1'b0)
        , .data_a(8'b1)
        , .data_b(8'b1)
        , .data_c(8'b0)
        , .data_f(8'b0)
        , .out(out)
        );

  initial $monitor("%t reset=%b clk=%b output=%d", $time, reset, clk, out);
endmodule: __BSC_COUNTER__TEST001;

`endif // __BSC_TESTBENCH__

// ---------------------------------------------------------------------------------------------------------------------
// -- AMALGAMATE: end --
