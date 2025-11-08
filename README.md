FPGA-Based Overcurrent Relay

This is a Xilinx Vivado project for the "Design and Implementation of an Overcurrent Relay on FPGA." The design is implemented in Verilog and targets the XC7A100T Artix-7 FPGA.

Features

Pipelined Architecture: The design uses a three-stage pipeline (Filter $\rightarrow$ Measure $\rightarrow$ Protect) for high-speed, parallel operation.

Efficient Filtering: A 4-sample Moving Average Filter (MAF) normalizes harmonics using only bit-shifting and addition.

Accurate RMS Measurement: An efficient 16-sample moving window is used to calculate the $I_{rms}$ value.

CORDIC IP Core: Utilizes the Xilinx CORDIC IP for hardware-accelerated square root calculation.

Protection Logic: Implements an Instantaneous Overcurrent Relay (or IDMT, specify which one you implemented) that generates a latching trip signal.
