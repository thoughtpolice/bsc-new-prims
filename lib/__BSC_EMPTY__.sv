// SPDX-FileCopyrightText: © 2020-2024 The Bluespec Authors
// SPDX-License-Identifier: BSD-3-Clause

`include "bluespec.svh"

// -- AMALGAMATE: start --
// ---------------------------------------------------------------------------------------------------------------------

// __BSC_EMPTY__: An empty module to be used as a placeholder.
module __BSC_EMPTY__ // # MARK: __BSC_EMPTY__
      ( input wire logic clk
      , input wire logic resetn
      );
  (* keep *) wire logic unused_clk;
  (* keep *) wire logic unused_resetn;

  assign unused_clk = clk;
  assign unused_resetn = resetn;
endmodule: __BSC_EMPTY__

// ---------------------------------------------------------------------------------------------------------------------

`ifdef __BSC_SHIM_V1_PRIMS__
module Empty( input CLK, input RST_N );
  __BSC_EMPTY__ i_empty ( .clk(CLK), .resetn(RST_N) );
endmodule
`endif // __BSC_SHIM_V1_PRIMS__

// ---------------------------------------------------------------------------------------------------------------------

`ifdef __BSC_TESTBENCH__
/* verilator lint_off DECLFILENAME */
/* verilator lint_off MULTITOP */

module __BSC_EMPTY__TEST001; // MARK: Test: #001
  reg clk = 0;
  reg resetn = 0;

  always #5 clk <= ~clk;
  initial begin: init
    $display("### TEST: __BSC_EMPTY__TEST001");
    # 20 resetn = 1;
    # 100 $finish();
  end: init

  __BSC_EMPTY__ uut (
    .clk(clk),
    .resetn(resetn)
  );

  initial $monitor($time, " clk=%b resetn=%b", clk, resetn);
endmodule: __BSC_EMPTY__TEST001

`endif // __BSC_TESTBENCH__

// ---------------------------------------------------------------------------------------------------------------------
// -- AMALGAMATE: end --
