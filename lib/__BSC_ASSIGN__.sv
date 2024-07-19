// SPDX-FileCopyrightText: © 2020-2024 The Bluespec Authors
// SPDX-License-Identifier: BSD-3-Clause

`include "bluespec.svh"

// -- AMALGAMATE: start --
// ---------------------------------------------------------------------------------------------------------------------

// __BSC_ASSIGN__: Attaches an input wire to an output wire; a simple
// 'assign' statement in module-form.
module __BSC_ASSIGN__ // # MARK: __BSC_ASSIGN__
  # ( parameter int WIDTH = 1
    ) ( input  wire logic [WIDTH-1:0] data_in
      , output wire logic [WIDTH-1:0] data_out
      );

  assign data_out = data_in;
endmodule: __BSC_ASSIGN__

// ---------------------------------------------------------------------------------------------------------------------

`ifdef __BSC_SHIM_V1_PRIMS__
module SyncWire
  # ( parameter width = 1
    ) ( input  [width-1:0] DIN
      , output [width-1:0] DOUT
      );
  
  __BSC_ASSIGN__ #(.WIDTH(width))
    i_syncwire
    ( .data_in(DIN)
    , .data_out(DOUT)
    );
endmodule

module BypassWire
  # ( parameter width = 1
    ) ( input  [width-1:0] WVAL
      , output [width-1:0] WGET
      );
  
  __BSC_ASSIGN__ #(.WIDTH(width))
    i_syncwire
    ( .data_in(WVAL)
    , .data_out(WGET)
    );
endmodule
`endif // __BSC_SHIM_V1_PRIMS__

// ---------------------------------------------------------------------------------------------------------------------

`ifdef __BSC_TESTBENCH__
/* verilator lint_off DECLFILENAME */
/* verilator lint_off MULTITOP */

module __BSC_ASSIGN__TEST001; // MARK: Test: #001
  reg clk = 0;
  reg resetn = 0;

  always #5 clk <= ~clk;
  initial begin: init
    $display("### TEST: __BSC_ASSIGN__TEST001");
    # 20 resetn = 1;
    # 100 $finish();
  end: init

  initial $monitor($time, " clk=%b resetn=%b", clk, resetn);
endmodule: __BSC_ASSIGN__TEST001

`endif // __BSC_TESTBENCH__

// ---------------------------------------------------------------------------------------------------------------------
// -- AMALGAMATE: end --
