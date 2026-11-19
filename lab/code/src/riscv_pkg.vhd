library ieee;
use ieee.std_logic_1164.all;

package riscv_pkg is
    subtype inst_bits_t is std_logic_vector(2 downto 0);

    type inst_type_map_t is record
        R : inst_bits_t;
        I : inst_bits_t;
        U : inst_bits_t;
        S : inst_bits_t;
        B : inst_bits_t;
        J : inst_bits_t;
    end record;

    constant INST_TYPE : inst_type_map_t := (
        R => "001",
        I => "010",
        U => "011",
        S => "100",
        B => "101",
        J => "110"
    );
end package;