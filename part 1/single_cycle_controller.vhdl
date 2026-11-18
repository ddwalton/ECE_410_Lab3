LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY controller IS
    PORT (
        opcode      : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
        funct3      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        funct7_bit  : IN  STD_LOGIC;
        zero_flag   : IN  STD_LOGIC;
        Alu_src     : OUT STD_LOGIC;
        Res_sel     : OUT STD_LOGIC;
        Mem_we      : OUT STD_LOGIC;
        rd_we       : OUT STD_LOGIC;
        Out_en      : OUT STD_LOGIC;
        imm_sel     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_ctrl    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Behavioral OF controller IS
    SIGNAL controls : STD_LOGIC_VECTOR(9 DOWNTO 0);
    CONSTANT OPCODE_LW  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011";
    CONSTANT OPCODE_SW  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100011";
    CONSTANT OPCODE_R   : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0110011";
    -- controls = alu_src, mem_to_reg, reg_write, mem_write, imm_sel, alu_ctrl
    CONSTANT CTRL_LW  : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1110010100";
    CONSTANT CTRL_SW  : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1001100100";
    CONSTANT CTRL_ADD : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0010000100";
    CONSTANT CTRL_NOP : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
BEGIN
    PROCESS (opcode, funct3, funct7_bit)
    BEGIN
        controls <= CTRL_NOP;
        CASE opcode IS
            WHEN OPCODE_LW =>
                controls <= CTRL_LW;
            WHEN OPCODE_SW =>
                controls <= CTRL_SW;
            WHEN OPCODE_R =>
                IF funct3 = "000" AND funct7_bit = '0' THEN
                    controls <= CTRL_ADD;
                END IF;
            WHEN OTHERS =>
                controls <= CTRL_NOP;
        END CASE;
    END PROCESS;

    Alu_src    <= controls(9);
    Res_sel    <= controls(8);
    rd_we      <= controls(7);
    Mem_we     <= controls(6);
    imm_sel    <= controls(5 DOWNTO 3);
    alu_ctrl   <= controls(2 DOWNTO 0);
    Out_en     <= '1';
END ARCHITECTURE;
