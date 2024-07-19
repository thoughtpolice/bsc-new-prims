// SPDX-FileCopyrightText: © 2020-2024 The Bluespec Authors
// SPDX-License-Identifier: BSD-3-Clause

`include "bluespec.svh"

/* verilator lint_off DECLFILENAME */
/* verilator lint_off MULTITOP */

// -- AMALGAMATE: start --
// ---------------------------------------------------------------------------------------------------------------------

// __BSC_TRISTATE__: TriState buffers.
module __BSC_TRISTATE__ // # MARK: __BSC_TRISTATE__
  # ( parameter int WIDTH = 1
    ) ( input  wire logic [WIDTH-1:0] in
      , output wire logic [WIDTH-1:0] out
      , inout  wire logic [WIDTH-1:0] io

      , input  wire logic out_en
      );

  assign io  = out_en ? in : {WIDTH{1'bz}};
  assign out = io;
endmodule: __BSC_TRISTATE__

// __BSC_FROM_Z__: 
module __BSC_FROM_Z__ // # MARK: __BSC_FROM_Z__
  # ( parameter int WIDTH = 1
    ) ( input  wire logic [WIDTH-1:0] in
      , output wire logic [WIDTH-1:0] out
      );
  
  tri [WIDTH-1:0] bus;

  assign bus = in;
  assign out = bus;
endmodule: __BSC_FROM_Z__

// __BSC_TO_Z__:
module __BSC_TO_Z__ // # MARK: __BSC_TO_Z__
  # ( parameter int WIDTH = 1
    ) ( input  wire logic [WIDTH-1:0] in
      , input  wire logic             ctl
      , output wire logic [WIDTH-1:0] out
      );

  tri [WIDTH-1:0] bus;

  assign bus = ctl ? in : {WIDTH{1'bz}};
  assign out = bus;
endmodule: __BSC_TO_Z__

// ---------------------------------------------------------------------------------------------------------------------

`ifdef __BSC_SHIM_V1_PRIMS__
module TriState // MARK: Shim: TriState 
  # ( parameter width = 1
    ) ( input  [width-1:0] I
      , output [width-1:0] O
      , inout  [width-1:0] IO
      , input OE
      );

  __BSC_TRISTATE__ #(.WIDTH(width)) i_tristate
    ( .in(I)
    , .out(O)
    , .io(IO)
    , .out_en(OE)
    );
endmodule

module ConvertFromZ // MARK: Shim: ConvertFromZ
  # ( parameter width = 1
    ) ( input  [width-1:0] IN
      , output [width-1:0] OUT
      );
  __BSC_FROM_Z__ #(.WIDTH(width)) i_from_z ( .in(IN), .out(OUT) );
endmodule

module ConvertToZ // MARK: Shim: ConvertToZ
  # ( parameter width = 1
    ) ( input  [width-1:0] IN
      , input  CTL
      , output [width-1:0] OUT
      );
  __BSC_TO_Z__ #(.WIDTH(width)) i_to_z ( .in(IN), .ctl(CTL), .out(OUT) );
endmodule
`endif // __BSC_SHIM_V1_PRIMS__

// ---------------------------------------------------------------------------------------------------------------------

`ifdef __BSC_TESTBENCH__

module __BSC_TRISTATE__TEST001; // MARK: Test: #001
  reg clk = 0;
  reg resetn = 0;

  always #5 clk <= ~clk;
  initial begin: init
    $display("### TEST: __BSC_TRISTATE__TEST001");
    # 20 resetn = 1;
    # 100 $finish();
  end: init

  initial $monitor($time, " clk=%b resetn=%b", clk, resetn);
endmodule: __BSC_TRISTATE__TEST001

`endif // __BSC_TESTBENCH__

// ---------------------------------------------------------------------------------------------------------------------
// -- AMALGAMATE: end --
