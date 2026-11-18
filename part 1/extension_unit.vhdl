--converts the instruction’s immediate bits into a 32-bit value for the ALU

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY extension_unit IS
    PORT (
        din  : IN  STD_LOGIC_VECTOR(31 DOWNTO 7);
        ctrl : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Behavioral OF extension_unit IS
BEGIN
    PROCESS (din, ctrl)
        VARIABLE imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    BEGIN
        imm := (OTHERS => '0');
        CASE ctrl IS
            WHEN "010" => -- I type
                imm := (OTHERS => din(31));
                imm(11 DOWNTO 0) := din(31 DOWNTO 20);
            WHEN "011" => -- U type
                imm(31 DOWNTO 12) := din(31 DOWNTO 12);
            WHEN "100" => -- S type
                imm := (OTHERS => din(31));
                imm(11 DOWNTO 5) := din(31 DOWNTO 25);
                imm(4 DOWNTO 0) := din(11 DOWNTO 7);
            WHEN "101" => -- B type
                imm := (OTHERS => din(31));
                imm(12) := din(31);
                imm(11) := din(7);
                imm(10 DOWNTO 5) := din(30 DOWNTO 25);
                imm(4 DOWNTO 1) := din(11 DOWNTO 8);
                imm(0) := '0';
            WHEN "110" => -- J type
                imm := (OTHERS => din(31));
                imm(20) := din(31);
                imm(19 DOWNTO 12) := din(19 DOWNTO 12);
                imm(11) := din(20);
                imm(10 DOWNTO 1) := din(30 DOWNTO 21);
                imm(0) := '0';
            WHEN OTHERS =>
                NULL;
        END CASE;
        dout <= imm;
    END PROCESS;
END ARCHITECTURE;
