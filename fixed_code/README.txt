ECE 410 Lab 3 - single-cycle starter project

This bundle completes the supplied base single-cycle CPU for the provided LW, SW, and ADD program. Signal port names follow the Prelab 3 table.

Compile the VHDL source files in this order:
1. adder_32.vhdl
2. alu.vhdl
3. data_memory.vhdl
4. extension_unit.vhdl
5. instruction_memory.vhdl
6. mux_2to1.vhdl
7. program_counter.vhdl
8. register_file.vhdl
9. tri_state_buffer.vhd
10. single_cycle_datapath.vhdl
11. single_cycle_controller.vhdl
12. single_cycle_riscv.vhd
13. single_cycle_riscv_tb.vhd

The supplied testbench runs four instruction cycles. This bundle does not add the BEQ branch path or implement Part 2's multi-cycle CPU; those need additional datapath/controller changes beyond the uploaded starter files.
