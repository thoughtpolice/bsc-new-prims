# bsc-new-prims

The "primitive operations" in the [Bluespec Compiler `bsc`][bsc] are written in
Verilog, used by all non-trivial designs emitted by the compiler, and are
written in vintage 1995 style. This codebase is an attempt to rewrite them using
modern SystemVerilog style, and test them with modern open source components to
ensure high quality and compatibility, and eventually upstream them.

The goal of this repository is to be deprecated and all these modules moved
upstream and used directly by the compiler and tested there; in the mean time,
this repo is easier to iterate on and it's easier to discuss and talk about
requirements too.

For now, to provide use to existing users of `bsc`, shim wrappers that provide
compatibility with the existing compiler output are also provided.

[bsc]: https://github.com/b-lang-org/bsc

## Usage

```bash
./amalgamate.py > prims.sv
```

This script sweeps all the code in `lib/` and puts it in `prims.sv` &mdash; it
includes all the required modules in a single file.

Nothing more is needed and you can just include this in your synthesis tool;
unlike the old primitives, which required you to include the specific set of
modules your generated Verilog required.

> [!NOTE]
>
> Most Verilog frontends can be given a list of search directories and match
> unidentified module names to file paths within those directories, allowing the
> synthesis tool to load new modules on demand. However, the `bsc` primitives
> are very small and fast to parse; synthesis flows won't elaborate the
> underlying modules if they aren't used, making the overhead very small. They
> are also the smallest part of the generated design; anything non-trivial will
> reuslt in far more compiler-generated code than hand-written code. Ultimately,
> just including all the code in a single file is much easier to conceptually
> understand for users and distributors.

For usage with the existing `bsc` compiler output, define `BSV_SHIM_V1_PRIMS`
in your synthesis/simulation tool. This will include Verilog-2001 compatible
wrappers for the old primitives, in terms of the new one. Practically speaking
this is a requirement for all designs right now, but one day will only be needed
with old versions of the compiler.

### Supported tools

| Tool       | Version | Status             |
| ---------- | ------- | ------------------ |
| yosys      | 0.43    | :white_check_mark: |
| slang-tidy | 0.6     | :white_check_mark: |
| verilator  | 5.026   | :white_check_mark: |

Every single module under `lib/` must pass with all these tools out of the box.
The `build.sh` script will run all the tests for you if you give it the name of
`.sv` file under `lib/`.

## Basic design ideas

Verilator is the testing tool of choice, thanks to its high performance and
increasing focus on SystemVerilog/UVM support (including features like
constrained randomization) meaning that C++ harnesses are not necessarily
required for many scenarios.

A single file under `lib/` requires:

- A name like `__BSC_FOOBAR__.sv` for the relevant code;
- One-or-more fancy SystemVerilog modules that port existing functionality;
- One-or-more wrappers under the `BSV_SHIM_V1_PRIMS` conditional, that match the
  existing Verilog 95 interfaces from the upstream `bsc` compiler;
- A set of Verilator testbenches, that test the module in isolation.

This means you can effectively test and develop every module independently of
the others. These constraints also ensure that the code is correctly included in
the amalgamated output produced by `amalgamate.py` so it works immediately.

Unlike the original primitives, which directly model one file to one module
(again something most frontends support natively), the primitives here group
related functionality into single files. This is because the ultimate
distribution mechanism is the amalgamated single file; separate files are then
just a helpful development aid, and we are free to rstructure them as we like.
(Certain modules for example were identical, like `SyncWire` and `BypassWire`,
which are now grouped together under `__BSC_ASSIGN__.sv` instead, which provides
all necessary shims.)

Modules should not require any external dependencies, and should be as clear and
rigidly defined and tested as possible, and include as many tests as needed to
define their behavior.

## Linting/testing

Use `slang-tidy` from the [`sv-lang`](https://github.com/MikePopoloski/slang)
toolkit to lint the code and check for issues. This is a very robust and
compatible frontend that you can just use immediately to lint your SystemVerilog
code. You can lint every file in `lib` by just running `slang-tidy lib/*.sv`

Verilator has enough support for SystemVerilog/UVM testbenches that you don't
need C++ wrappers anymore. Therefore, we include testbench modules inside every
single module (an improvement over the prior versions, which essentially relied
on compiler integration tests instead.)

Full CI tests will happen soon, hopefully.

## Modules covered

Synthesis modules:

- [ ] [`BRAM1`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BRAM1.v)
- [ ] [`BRAM1Load`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BRAM1Load.v)
- [ ] [`BRAM1BE`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BRAM1BE.v)
- [ ] [`BRAM1BELoad`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BRAM1BELoad.v)
- [ ] [`BRAM2`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BRAM2.v)
- [ ] [`BRAM2Load`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BRAM2Load.v)
- [ ] [`BRAM2BE`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BRAM2BE.v)
- [ ] [`BRAM2BELoad`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BRAM2BELoad.v)
- [x] [~~`BypassWire`~~](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BypassWire.v):
      `__BSC_ASSIGN__`
- [x] [~~`BypassWire0`~~](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/BypassWire0.v):
      `__BSC_NULL`
- [ ] [`CRegA5`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/CRegA5.v)
- [ ] [`CRegN5`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/CRegN5.v)
- [ ] [`CRegUN5`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/CRegUN5.v)
- [ ] [`ClockDiv`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ClockDiv.v)
- [ ] [`ClockGen`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ClockGen.v)
- [ ] [`ClockInverter`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ClockInverter.v)
- [ ] [`ClockMux`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ClockMux.v)
- [ ] [`ClockSelect`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ClockSelect.v)
- [x] [~~`ConvertFromZ`~~](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ConvertFromZ.v):
      `__BSC_TRISTATE__`
- [x] [~~`ConvertToZ`~~](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ConvertToZ.v):
      `__BSC_TRISTATE__`
- [x] [~~`Counter`~~](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/Counter.v):
      `__BSC_COUNTER__`
- [ ] [`CrossingBypassWire`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/CrossingBypassWire.v)
- [ ] [`CrossingRegA`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/CrossingRegA.v)
- [ ] [`CrossingRegN`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/CrossingRegN.v)
- [ ] [`CrossingRegUN`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/CrossingRegUN.v)
- [ ] [`DualPortRAM`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/DualPortRAM.v)
- [x] [~~`Empty`~~](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/Empty.v):
      `__BSC_EMPTY__`
- [ ] [`FIFO1`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFO1.v)
- [ ] [`FIFO10`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFO10.v)
- [ ] [`FIFO2`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFO2.v)
- [ ] [`FIFO20`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFO20.v)
- [ ] [`FIFOL1`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFOL1.v)
- [ ] [`FIFOL10`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFOL10.v)
- [ ] [`FIFOL2`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFOL2.v)
- [ ] [`FIFOL20`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFOL20.v)
- [ ] [`Fork`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/Fork.v)
- [ ] [`GatedClock`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/GatedClock.v)
- [ ] [`GatedClockDiv`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/GatedClockDiv.v)
- [ ] [`GatedClockInverter`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/GatedClockInverter.v)
- [ ] [`InitialReset`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/InitialReset.v)
- [ ] [`InoutConnect`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/InoutConnect.v)
- [ ] [`LatchCrossingReg`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/LatchCrossingReg.v)
- [ ] [`MakeClock`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/MakeClock.v)
- [ ] [`MakeReset`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/MakeReset.v)
- [ ] [`MakeReset0`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/MakeReset0.v)
- [ ] [`MakeResetA`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/MakeResetA.v)
- [ ] [`McpRegUN`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/McpRegUN.v)
- [ ] [`ProbeCapture`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ProbeCapture.v)
- [ ] [`ProbeHook`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ProbeHook.v)
- [ ] [`ProbeMux`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ProbeMux.v)
- [ ] [`ProbeTrigger`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ProbeTrigger.v)
- [ ] [`ProbeValue`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ProbeValue.v)
- [ ] [`RWire`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RWire.v)
- [ ] [`RWire0`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RWire0.v)
- [ ] [`RegA`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RegA.v)
- [ ] [`RegFile`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RegFile.v)
- [ ] [`RegFileLoad`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RegFileLoad.v)
- [ ] [`RegN`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RegN.v)
- [ ] [`RegTwoA`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RegTwoA.v)
- [ ] [`RegTwoN`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RegTwoN.v)
- [ ] [`RegTwoUN`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RegTwoUN.v)
- [ ] [`RegUN`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RegUN.v)
- [ ] [`ResetEither`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ResetEither.v)
- [ ] [`ResetInverter`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ResetInverter.v)
- [ ] [`ResetMux`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ResetMux.v)
- [ ] [`ResetToBool`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ResetToBool.v)
- [ ] [`ResolveZ`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ResolveZ.v)
- [ ] [`RevertReg`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/RevertReg.v)
- [ ] [`SampleReg`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/SampleReg.v)
- [ ] [`ScanIn`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ScanIn.v)
- [ ] [`SizedFIFO`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFO1.v)
- [ ] [`SizedFIFO0`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFO10.v)
- [ ] [`SizedFIFOL`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFO2.v)
- [ ] [`SizedFIFOL0`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFO20.v)
- [ ] [`SyncBit`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFOL1.v)
- [ ] [`SyncBit05`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFOL10.v)
- [ ] [`SyncBit1`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFOL2.v)
- [ ] [`SyncBit15`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/FIFOL20.v)
- [ ] [`SyncFIFO`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/Fork.v)
- [ ] [`SyncFIFO0`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/GatedClock.v)
- [ ] [`SyncFIFO1`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/GatedClockDiv.v)
- [ ] [`SyncFIFO10`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/GatedClockInverter.v)
- [ ] [`SyncFIFOLevel`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/InitialReset.v)
- [ ] [`SyncFIFOLevel0`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/InoutConnect.v)
- [ ] [`SyncHandshake`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/LatchCrossingReg.v)
- [ ] [`SyncPulse`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/MakeClock.v)
- [ ] [`SyncRegister`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/MakeReset.v)
- [ ] [`SyncReset`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/MakeReset0.v)
- [ ] [`SyncReset0`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/MakeResetA.v)
- [ ] [`SyncResetA`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/McpRegUN.v)
- [x] [~~`SyncWire`~~](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/SyncWire.v):
      `__BSC_ASSIGN__`
- [x] [~~`TriState`~~](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/TriState.v):
      `__BSC_TRISTATE__`
- [ ] [`UngatedClockMux`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/UngatedClockMux.v)
- [ ] [`UngatedClockSelect`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/UngatedClockSelect.v)

Simulation:

- [ ] [`ConstrainedRandom`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/ConstrainedRandom.v)
- [ ] [`main.v`](https://github.com/B-Lang-org/bsc/blob/main/src/Verilog/main.v)

# License

BSD-3-Clause, like the upstream Bluespec Verilog code, though ideally I think it
would be something like [`CERN-OHL-P-2.0`][CERN-OHL-P-2.0].

[CERN-OHL-P-2.0]: https://spdx.org/licenses/CERN-OHL-P-2.0.html
