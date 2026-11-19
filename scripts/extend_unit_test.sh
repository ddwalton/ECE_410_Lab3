ghdl -a ./lab/code/src/riscv_pkg.vhd
ghdl -a ./lab/code/src/extend_unit.vhdl
ghdl -a ./lab/code/src/extend_unit_tb.vhdl
ghdl -e extend_unit_tb
ghdl -r extend_unit_tb --vcd=wave.vcd