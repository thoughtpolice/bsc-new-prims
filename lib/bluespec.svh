// SPDX-FileCopyrightText: © 2020-2024 The Bluespec Authors
// SPDX-License-Identifier: BSD-3-Clause

// bluespec.svh: This file contains bluespec compiler specific macros and
// utilities that are used by generated Verilog code, and options that can be
// specified to control the behavior of the generated code, such as reset
// syncronicity and polarity. This module MUST be `included in all generated
// Verilog code.

// NOTE: The definitions provided to the SystemVerilog compiler to control these
// options e.g. -D flags, use BSV_ named options, but the internal definitions
// for use in the modules all use __BSC_ for their names. This is for backwards
// compatibility with older generated bsc code that used the original BSV_
// prefix for these options. However, we are free to use any naming convention
// we want for the internal definitions.

// -- AMALGAMATE: start --
// ---------------------------------------------------------------------------------------------------------------------

// BSV_SHIM_V1_PRIMS: Include modules that act as a Verilog-2001 compatible
// shims shims for the old module interfaces and names the Bluespec compiler
// used, like 'Counter', and translates them into the new ones -- like
// '__BSC_COUNTER__'
`ifdef BSV_SHIM_V1_PRIMS
  `define __BSC_SHIM_V1_PRIMS__
`endif

// BSV_ASSIGNMENT_DELAY: Set the delay for assignments in generated code. By
// default, bsc-generated code uses no delay. This is occasionally useful for
// some forms of simulation inside a testbench.
`ifdef BSV_ASSIGNMENT_DELAY
  `define __BSC_ASSIGNMENT_DELAY__ `BSV_ASSIGNMENT_DELAY
`else
  `define __BSC_ASSIGNMENT_DELAY__
`endif

// BSV_POSITIVE_RESET: Make the reset signal active high, i.e. a value of 1 is
// considered reset. By default, bsc-generated code uses active low reset.
`ifdef BSV_POSITIVE_RESET
  `define __BSC_RESET_VALUE__ 1'b1
  `define __BSC_ASYNC_RESET_EDGE_LIT__ posedge
`else
  `define __BSC_RESET_VALUE__ 1'b0
  `define __BSC_ASYNC_RESET_EDGE_LIT__ negedge
`endif

// BSV_ASYNC_RESET: Make the reset signal asynchronous, i.e. it is not
// synchronized to the clock domain. By default, bsc-generated code uses
// synchronous reset.
`ifdef BSV_ASYNC_RESET
  `define __BSC_RESET_EDGE__(clk, rst) posedge clk or `__BSC_ASYNC_RESET_EDGE_LIT__ rst
`else
  `define __BSC_RESET_EDGE__(clk, rst) posedge clk
`endif

// BSV_NO_INITIAL_BLOCKS: By default, bsc-generated code includes initial blocks
// that set the initial value of registers for simulation. This option disables
// those initial blocks so that simulation behaves more like synthesis.
//
// Note that this option is only for simulation; bsc does not assume initial
// blocks are supported for synthesis and turns them off in that case.
`ifdef BSV_NO_INITIAL_BLOCKS
  `define __BSC_NO_INITIAL_BLOCKS__
`endif

// __BSC_FILL_BITS_01__: A utility that can be used to fill an initial value of
// some register with 01s during 'initial' blocks. Should not be used during
// synthesis.
`define __BSC_FILL_BITS_01__(w) ({((w+1)/2){2'b10}}[w-1:0])
// ^ NOTE: when WIDTH=1 we get {1{2'b10}}, which angers the verilator gods.
// always truncate to be correct.

// ---------------------------------------------------------------------------------------------------------------------

// When Verilator is enabled, enable testbenches.
`ifdef VERILATOR
  `define __BSC_TESTBENCH__
`endif

// ---------------------------------------------------------------------------------------------------------------------
// -- AMALGAMATE: end --
