#!/bin/bash

ghdl -a lab/code/src/riscv_pkg.vhd

ghdl -a lab/code/src/adder_32.vhdl
ghdl -a lab/code/src/alu.vhdl
ghdl -a lab/code/src/data_memory.vhdl
ghdl -a lab/code/src/extend_unit.vhdl
ghdl -a lab/code/src/instruction_memory.vhdl
ghdl -a lab/code/src/mux_2to1.vhdl
ghdl -a lab/code/src/program_counter.vhdl
ghdl -a lab/code/src/register_file.vhdl
ghdl -a lab/code/src/tri_state_buffer.vhd
ghdl -a lab/code/src/single_cycle_datapath.vhdl
ghdl -a lab/code/src/single_cycle_controller.vhdl
ghdl -a lab/code/src/single_cycle_riscv.vhd

ghdl -a lab/code/test/data_memory_tb.vhdl
ghdl -a lab/code/test/extend_unit_tb.vhdl
ghdl -a lab/code/test/single_cycle_riscv_tb.vhd

ghdl -e data_memory_tb
ghdl -e extend_unit_tb
ghdl -e single_cycle_riscv_tb