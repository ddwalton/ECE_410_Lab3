LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY data_mem_tb IS
END ENTITY data_mem_tb;

ARCHITECTURE sim OF data_mem_tb IS
    CONSTANT CLK_PERIOD : TIME := 10 ns;

    SIGNAL address    : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL write_en   : STD_LOGIC := '0';
    SIGNAL clock      : STD_LOGIC := '0';
    SIGNAL sim_done   : BOOLEAN   := FALSE;
BEGIN
    -- Instantiate Device Under Test
    dut : ENTITY work.data_mem
        PORT MAP (
            address    => address,
            write_data => write_data,
            data       => data,
            write_en   => write_en,
            clock      => clock
        );

    -- Clock generator (stops automatically when sim_done is TRUE)
    clk_proc : PROCESS
    BEGIN
        WHILE NOT sim_done LOOP
            clock <= '0';
            WAIT FOR CLK_PERIOD / 2;
            clock <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS clk_proc;

    -- Stimulus and verification
    stim_proc : PROCESS
    BEGIN
        -- 1. Verify pre-initialized little-endian values (combinational reads)
        address <= std_logic_vector(to_unsigned(4, 32));
        WAIT FOR 1 ns;
        ASSERT data = x"12345678"
            REPORT "FAIL: Address 4 did not return 0x12345678" SEVERITY ERROR;

        address <= std_logic_vector(to_unsigned(8, 32));
        WAIT FOR 1 ns;
        ASSERT data = x"DEADBEEF"
            REPORT "FAIL: Address 8 did not return 0xDEADBEEF" SEVERITY ERROR;

        address <= std_logic_vector(to_unsigned(12, 32));
        WAIT FOR 1 ns;
        ASSERT data = x"11111111"
            REPORT "FAIL: Address 12 did not return 0x11111111" SEVERITY ERROR;

        -- 2. Verify synchronous write at address 200 (tests > 100 range)
        address    <= std_logic_vector(to_unsigned(200, 32));
        write_data <= x"CAFEBABE";
        write_en   <= '1';
        WAIT FOR 1 ns; -- Still before rising clock edge
        ASSERT data = x"00000000"
            REPORT "FAIL: Memory updated asynchronously before rising clock edge" SEVERITY ERROR;

        WAIT UNTIL RISING_EDGE(clock);
        WAIT FOR 1 ns;
        write_en <= '0';
        ASSERT data = x"CAFEBABE"
            REPORT "FAIL: Write to address 200 failed on rising clock edge" SEVERITY ERROR;

        -- 3. Verify write_en = '0' prevents overwriting
        write_data <= x"FFFFFFFF";
        write_en   <= '0';
        WAIT UNTIL RISING_EDGE(clock);
        WAIT FOR 1 ns;
        ASSERT data = x"CAFEBABE"
            REPORT "FAIL: Memory was overwritten while write_en = '0'" SEVERITY ERROR;

        -- 4. Verify highest valid word-aligned address (1020)
        address    <= std_logic_vector(to_unsigned(1020, 32));
        write_data <= x"87654321";
        write_en   <= '1';
        WAIT UNTIL RISING_EDGE(clock);
        WAIT FOR 1 ns;
        write_en <= '0';
        ASSERT data = x"87654321"
            REPORT "FAIL: Write/read failed at max valid address 1020" SEVERITY ERROR;

        -- 5. Verify out-of-bounds address (1022) does not crash or corrupt address 1020
        address    <= std_logic_vector(to_unsigned(1022, 32));
        write_data <= x"AAAAAAAA";
        write_en   <= '1';
        WAIT UNTIL RISING_EDGE(clock);
        WAIT FOR 1 ns;
        write_en <= '0';
        ASSERT data = x"00000000"
            REPORT "FAIL: Out-of-bounds read at 1022 did not return 0" SEVERITY ERROR;

        address <= std_logic_vector(to_unsigned(1020, 32));
        WAIT FOR 1 ns;
        ASSERT data = x"87654321"
            REPORT "FAIL: Out-of-bounds write at 1022 corrupted address 1020" SEVERITY ERROR;

        REPORT "ALL TESTS PASSED SUCCESSFULLY" SEVERITY NOTE;
        sim_done <= TRUE;
        WAIT;
    END PROCESS stim_proc;
END ARCHITECTURE sim;