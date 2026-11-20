------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : instruction_memory.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 1 KB instruction memory (ROM) storing a simple RISC-V program.
--                Provides 32-bit instruction fetch based on byte address.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY instr_mem IS
    PORT (
        address : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0'); -- added initial value
        data    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF instr_mem IS

    -- Byte-addressable ROM
    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT ROM : memory_data := (
        -- Program (little-endian)

        -- BEGIN: (Address 0)
        0 => x"83", 1 => x"25", 2 => x"45", 3 => x"00",     -- lw x11, 4(x10)
        4 => x"23", 5 => x"24", 6 => x"B5", 7 => x"00",     -- sw x11, 8(x10)
        8 => x"03", 9 => x"26", 10 => x"C0", 11 => x"00",   -- lw x12, 12(x0)
        12 => x"B3", 13 => x"06", 14 => x"B6", 15 => x"00", -- add x13, x12, x11
        16 => x"93", 17 => x"00", 18 => x"00", 19 => x"00", -- addi x1, x0, 0      ; val = 0
        20 => x"13", 21 => x"01", 22 => x"90", 23 => x"01", -- addi x2, x0, 25     ; len = 25
        24 => x"93", 25 => x"01", 26 => x"00", 27 => x"00", -- addi x3, x0, 0      ; i = 0
        -- LOOP: (Address 28)
        28 => x"93", 29 => x"80", 30 => x"A0", 31 => x"00", -- addi x1, x1, 10     ; val = val + 10
        32 => x"E3", 33 => x"CE", 34 => x"20", 35 => x"FE", -- blt  x1, x2, LOOP   ; branch to 28 (offset = -4)
        36 => x"E3", 37 => x"0E", 38 => x"00", 39 => x"FC", -- beq  x0, x0, BEGIN  ; branch to 0  (offset = -36)
        OTHERS => (OTHERS => '0')
    );

    SIGNAL addr_int : INTEGER := 0;

BEGIN
    -- Address conversion fits 1 KB of ROM
    addr_int <= 0 WHEN is_x(address(9 DOWNTO 0)) ELSE to_integer(unsigned(address(9 DOWNTO 0))); 

    -- read 4 consecutive bytes form one 32-bit word
    data <= ROM(addr_int + 3) &
            ROM(addr_int + 2) &
            ROM(addr_int + 1) &
            ROM(addr_int)
            WHEN addr_int <= 1020 ELSE (OTHERS => '0');

END ARCHITECTURE rtl;
