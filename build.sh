#!/usr/bin/env sh

set -xeu
slang-tidy -DBSV_SHIM_V1_PRIMS lib/*.sv
yosys -p "read_verilog -DBSV_SHIM_V1_PRIMS -sv lib/*.sv; prep"
verilator \
  -Wall \
  --x-assign 0 \
  --assert --coverage --timing \
  --binary --exe \
  --threads 4 \
  -Ilib \
  "$@"
