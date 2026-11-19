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
END ENTITY;

ARCHITECTURE rtl OF data_mem IS
    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : memory_data := (-- Test valuesd
        4  => x"78", 5  => x"56", 6  => x"34", 7  => x"12",
        8  => x"EF", 9  => x"BE", 10 => x"AD", 11 => x"DE",
        12 => x"11", 13 => x"11", 14 => x"11", 15 => x"11",
        OTHERS => (OTHERS => '0')
    );

BEGIN
    -- Asynchronous 32-bit read 
    -- The memory stores bytes in little-endian order.
    PROCESS (address, RAM) -- makes the read logic respond to changes in the address or memory
        VARIABLE addr : INTEGER; -- temporary integer index for accessing the RAM array
    BEGIN
        addr := TO_INTEGER(UNSIGNED(address(9 DOWNTO 0))); -- 10 bits are enough to select 1024 bytes of memory decleared
        IF addr <= 1020 THEN --the largest valid starting address is 1020 so basically checking if the adderess is valid
            data <= RAM(addr + 3) & RAM(addr + 2) & RAM(addr + 1) & RAM(addr); --joins the four 8-bit bytes into the 32-bit output
        ELSE
            data <= (OTHERS => '0'); 
        END IF;
    END PROCESS;

    -- Synchronous 32-bit write as four little-endian bytes.
    PROCESS (clock)
        VARIABLE addr : INTEGER; 
    BEGIN
        IF RISING_EDGE(clock) THEN --The following write can happen only at a rising edge. That makes the memory write synchronous.
            addr := TO_INTEGER(UNSIGNED(address(9 DOWNTO 0)));
            IF write_en = '1' AND addr <= 1020 THEN -- the largest valid starting address is 1020 so basically checking if the adderess is valid and also enable should be 1
                -- The lowest byte goes at the starting address
                RAM(addr)     <= write_data(7 DOWNTO 0);
                RAM(addr + 1) <= write_data(15 DOWNTO 8);
                RAM(addr + 2) <= write_data(23 DOWNTO 16);
                RAM(addr + 3) <= write_data(31 DOWNTO 24);
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
