LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.riscv_pkg.all;

ENTITY extend_unit IS
    PORT (
        din : IN STD_LOGIC_VECTOR(24 DOWNTO 0);
        ctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END extend_unit;

ARCHITECTURE Behavioral OF extend_unit IS
    -- helper function to zero-extend any STD_LOGIC_VECTOR to 32 bits
    FUNCTION zext(arg : STD_LOGIC_VECTOR; target_len : POSITIVE := 32) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(target_len - 1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        -- LSBs become arg, MSBs remain '0'
        result(arg'length - 1 DOWNTO 0) := arg;
        RETURN result;
    END FUNCTION;

    -- helper function to sign-extend any STD_LOGIC_VECTOR to 32 bits
    FUNCTION sgnext(arg : STD_LOGIC_VECTOR; target_len : POSITIVE := 32) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(target_len - 1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        -- LSBs become arg
        result(arg'length - 1 DOWNTO 0) := arg;
        -- replicate MSB of arg (sign bit) to all upper bits of result
        result(target_len - 1 DOWNTO arg'length) := (OTHERS => arg(arg'left));
        RETURN result;
    END FUNCTION;

BEGIN
    WITH ctrl SELECT
        dout <=
        sgnext(din(24 DOWNTO 13)) WHEN INST_TYPE.I,
        zext(din(24 DOWNTO 5)) WHEN INST_TYPE.U,
        sgnext(din(24 DOWNTO 18) & DIN(4 DOWNTO 0)) WHEN INST_TYPE.S,
        sgnext(din(24) & din(0) & din(23 DOWNTO 18) & din(4 DOWNTO 1) & '0') WHEN INST_TYPE.B,
        sgnext(din(24) & din(12 DOWNTO 5) & DIN(13) & DIN(23 DOWNTO 14) & '0') WHEN INST_TYPE.J,
        -- all ones if invalid
        (OTHERS => '1') WHEN OTHERS;
END Behavioral;