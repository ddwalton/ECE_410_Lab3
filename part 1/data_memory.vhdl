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
        data       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);--It carries the 32-bit value read from memory to the rest of the CPU
        write_en   : IN  STD_LOGIC;
        clock      : IN  STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF data_mem IS
    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : memory_data := (
        --preload the data memory with test values
        4  => x"78", 5  => x"56", 6  => x"34", 7  => x"12",
        8  => x"EF", 9  => x"BE", 10 => x"AD", 11 => x"DE",
        12 => x"11", 13 => x"11", 14 => x"11", 15 => x"11",
        OTHERS => (OTHERS => '0')
    );
BEGIN
    -- Asynchronous 32-bit read; the memory stores bytes in little-endian order.
    PROCESS (address, RAM)
        VARIABLE addr : INTEGER;
    BEGIN
        addr := TO_INTEGER(UNSIGNED(address(9 DOWNTO 0)));--takes the lowest 10 bits of the address, treats them as an unsigned number, and converts them to an integer index for the memory array
        IF addr <= 1020 THEN
            data <= RAM(addr + 3) & RAM(addr + 2) & RAM(addr + 1) & RAM(addr);--joins those four bytes into a 32-bit word
        ELSE
            data <= (OTHERS => '0');
        END IF;
    END PROCESS;

    -- Synchronous 32-bit write as four little-endian bytes.
    PROCESS (clock)
        VARIABLE addr : INTEGER;
    BEGIN
        IF RISING_EDGE(clock) THEN
        -- 32-bit word to memory in little-endian byte order 
            addr := TO_INTEGER(UNSIGNED(address(9 DOWNTO 0)));
            IF write_en = '1' AND addr <= 1020 THEN -- 1020 is here because of the TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0); line
                RAM(addr)     <= write_data(7 DOWNTO 0);
                RAM(addr + 1) <= write_data(15 DOWNTO 8);
                RAM(addr + 2) <= write_data(23 DOWNTO 16);
                RAM(addr + 3) <= write_data(31 DOWNTO 24);
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
