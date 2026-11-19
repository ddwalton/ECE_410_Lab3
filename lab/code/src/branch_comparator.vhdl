LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY branch_comparator IS
    PORT (
        rs1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        rs2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        br_ctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        br_taken : OUT STD_LOGIC
    );
END ENTITY branch_comparator;

ARCHITECTURE Behavioral OF branch_comparator IS
    -- helper that converts booleans to std_logic
    FUNCTION bool_to_std_logic(val : BOOLEAN) RETURN STD_LOGIC IS
        VARIABLE ret : STD_LOGIC;
    BEGIN
        IF val THEN
            ret := '1';
        ELSE
            ret := '0';
        END IF;

        RETURN ret;

    END FUNCTION bool_to_std_logic;
BEGIN
    WITH br_ctrl SELECT
        br_taken <= bool_to_std_logic(rs1 = rs2) WHEN "000", -- BEQ
        bool_to_std_logic(rs1 /= rs2) WHEN "001", -- BNE
        bool_to_std_logic(signed(rs1) < signed(rs2)) WHEN "100", -- BLT
        bool_to_std_logic(signed(rs1) >= signed(rs2)) WHEN "101", -- BGE
        bool_to_std_logic(unsigned(rs1) < unsigned(rs2)) WHEN "110", -- BLTU
        bool_to_std_logic(unsigned(rs1) >= unsigned(rs2)) WHEN "111", -- BGEU
        '0' WHEN OTHERS;
END ARCHITECTURE Behavioral;