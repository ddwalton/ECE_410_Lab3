#!/bin/bash

ghdl -a ./lab/code/src/riscv_pkg.vhd
ghdl -a ./lab/code/src/$1.vhdl
ghdl -a ./lab/code/test/$1_tb.vhdl
ghdl -e $1_tb
ghdl -r $1_tb --vcd=wave.vcd