# RTL Source Code - 3-bit FPGA Calculator

This directory contains the Verilog Hardware Description Language (HDL) files for the 3-bit calculator implemented on the Digilent Nexys 4 DDR (Artix-7).

## Module Directory

| File | Description |
| :--- | :--- |
| **top_alu_nexys4.v** | Top-level module. Connects the ALU logic with the FPGA peripherals (switches, buttons, and 7-segment display). |
| **alu3.v** | Arithmetic Logic Unit. Contains the core logic for operations (ADD, SUB, MUL, etc.). |
| **adder3.v** | 3-bit structural/behavioral adder implementation. |
| **sub3_c2.v** | Subtractor module using 2's complement logic. |
| **mul3.v** | Multiplier module for 3-bit operands. |
| **bin_to_bcd.v** | Binary to BCD converter to drive the decimal display. |
| **sevseg_two_digits.v**| Controller for the 7-segment display multiplexing. |
| **full_adder.v** | Base building block for arithmetic operations. |

## Design Flow
The design follows a hierarchical approach, where the `top_alu_nexys4` instantiates the ALU and the necessary display drivers. All modules were synthesized using **Vivado 2023.1**.
