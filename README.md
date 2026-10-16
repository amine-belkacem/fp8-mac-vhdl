FP8 Multiply-Accumulate (MAC) Unit in VHDL for AI Inference
Hardware multiply-accumulate operator in the FP8 E4M3 floating-point format (1 sign bit, 4 exponent bits, 3 mantissa bits, bias 7), written in VHDL, synthesized with Intel Quartus Prime and verified in simulation with Questa.
Individual project — Master 1 CSEC (Communicating Electronic Systems Design), University of Lorraine, France, 2026.
Why FP8?
Neural networks rely on millions of multiply-accumulate operations. Reducing number precision (FP32 → FP16 → FP8) cuts memory, bandwidth and operator size. FP8 (proposed in 2022 by NVIDIA, Arm and Intel) is now used for inference. This project builds, block by block, the basic operator of a neuron: acc = acc ± (a × b).
Architecture
FP8 MAC architecture
Module	Role	Type
fp8_pkg	Format parameters (widths, bias)	Package
fp8_decoder	Splits sign / exponent / mantissa, zero detection	Combinational
fp8_mult	Multiplication: sign XOR, hidden bit, significand product, normalization	Combinational
fp8_addsub	Addition / subtraction: exponent alignment, guard bits, left/right normalization	Combinational
fp8_acc	8-bit accumulator register (asynchronous reset, synchronous clear, enable)	Sequential
fp8_mac	Top level: block assembly + valid signal	Sequential
Special cases handled: zero inputs, saturation to ±448 on overflow, flush to zero on underflow.
Results
Full MAC simulation: accumulation 1 → 3 → 9, clear, accumulation 4 → 7, then subtraction 7 − 2 = 5.
MAC waveform
Hex value	38	44	51	48	4E	4A
Decimal value	1.0	3.0	9.0	4.0	7.0	5.0
Synthesis (Quartus Prime, Cyclone IV E EP4CE6E22C6):
Module	Logic elements	Registers
Decoder	2	0
Multiplier	66	0
Adder / subtractor	291	0
Accumulator	9	8
Full MAC	360 / 6,272 (≈ 6 %)	9
MAC Flow Summary
A complete MAC operator fits in about 6 % of a small entry-level FPGA, which is why FP8 is attractive for AI accelerators. The adder, because of alignment and normalization, accounts for most of the cost.
Repository structure
src/    VHDL source (package + 5 modules)
tb/     testbenches (decoder, multiplier, adder/subtractor, MAC)
docs/   full report (PDF, in French), diagrams, RTL view, waveform, Flow Summary
Running the simulation
With Questa / ModelSim: compile src/fp8_pkg.vhd first, then the other files in src/, then the desired testbench in tb/, and simulate tb_fp8_mac.
With GHDL (free):
ghdl -a --std=08 src/fp8_pkg.vhd src/fp8_decoder.vhd src/fp8_acc.vhd src/fp8_mult.vhd src/fp8_addsub.vhd src/fp8_mac.vhd tb/tb_fp8_mac.vhd
ghdl -e --std=08 tb_fp8_mac
ghdl -r --std=08 tb_fp8_mac --stop-time=200ns --wave=mac.ghw
Limitations and possible improvements
Rounding by truncation (no round-to-nearest) → slight loss of precision.
FP8 accumulation: small contributions are "swallowed" by large ones; real accelerators accumulate in extended precision (FP16/FP32).
Subnormals and NaN are not handled.
Next steps: round-to-nearest, 16-bit accumulator, pipelining to raise the clock frequency, implementation on a real board.
Author
Mohamed Amine BELKACEM — Master 2 CSEC, University of Lorraine LinkedIn · GitHub
