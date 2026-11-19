------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : data_memory.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 1 KB data memory with 32-bit read/write interface.
--                Supports synchronous writes and asynchronous reads.
------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY data_mem IS
    PORT (
        address    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_data : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        data       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_en   : IN  STD_LOGIC;
        clock      : IN  STD_LOGIC
    );
END ENTITY data_mem;

ARCHITECTURE rtl OF data_mem IS
    CONSTANT N_ADDR_BITS   : NATURAL := 10;
    CONSTANT MEM_DEPTH     : NATURAL := 2**N_ADDR_BITS; -- 1024 bytes
    CONSTANT MAX_WORD_ADDR : NATURAL := MEM_DEPTH - 4;  -- 1020

    TYPE memory_data IS ARRAY (0 TO MEM_DEPTH - 1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : memory_data := (
        -- Initial test values (little-endian)
        4  => x"78", 5  => x"56", 6  => x"34", 7  => x"12", -- Address 4:  0x12345678
        8  => x"EF", 9  => x"BE", 10 => x"AD", 11 => x"DE", -- Address 8:  0xDEADBEEF
        12 => x"11", 13 => x"11", 14 => x"11", 15 => x"11", -- Address 12: 0x11111111
        OTHERS => (OTHERS => '0')
    );

    SIGNAL addr_int : NATURAL RANGE 0 TO MEM_DEPTH - 1 := 0;
BEGIN
    -- Convert lower 10 bits of 32-bit address to integer
    addr_int <= to_integer(unsigned(address(N_ADDR_BITS - 1 DOWNTO 0)));

    -- Combinational read in little-endian order with bounds protection
    data <= RAM(addr_int + 3) & RAM(addr_int + 2) & RAM(addr_int + 1) & RAM(addr_int)
            WHEN addr_int <= MAX_WORD_ADDR ELSE (OTHERS => '0');

    -- Synchronous write in little-endian order
    sync_write : PROCESS (clock)
    BEGIN
        IF RISING_EDGE(clock) THEN
            IF write_en = '1' AND addr_int <= MAX_WORD_ADDR THEN
                RAM(addr_int)     <= write_data(7 DOWNTO 0);
                RAM(addr_int + 1) <= write_data(15 DOWNTO 8);
                RAM(addr_int + 2) <= write_data(23 DOWNTO 16);
                RAM(addr_int + 3) <= write_data(31 DOWNTO 24);
            END IF;
        END IF;
    END PROCESS sync_write;
END ARCHITECTURE rtl;