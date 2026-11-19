library ieee;
use ieee.std_logic_1164.all;

package riscv_pkg is
    subtype inst_bits_t is std_logic_vector(2 downto 0);

    constant R_TYPE : inst_bits_t := "001";
    constant I_TYPE : inst_bits_t := "010";
    constant U_TYPE : inst_bits_t := "011";
    constant S_TYPE : inst_bits_t := "100";
    constant B_TYPE : inst_bits_t := "101";
    constant J_TYPE : inst_bits_t := "110";
end package;