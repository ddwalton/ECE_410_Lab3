------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_controller.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Single-cycle control unit for a simple RISC-V processor.
--                Decodes opcode, funct3, and funct7 fields to generate
--                ALU, memory, and register control signals.
------------------------------------------------------------------------
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
        pc_src      : OUT STD_LOGIC;
        imm_sel     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_ctrl    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Behavioral OF controller IS
    CONSTANT N_CONTROL_BITS : NATURAL := 11;

    -- "controls" is a compact control word encoding all the main control signals.
    -- Bit mapping (from MSB to LSB):
    --   [10]  - Selects source of next PC value (0 = increment by 4, 1 = output of branch)
    --   [9]   - Selects ALU B operand source (0 = register, 1 = immediate)
    --   [8]   - Selects write-back data source (0 = ALU result, 1 = memory read)
    --   [7]   - Enables register file write
    --   [6]   - Enables data memory write
    --   [5:3] - Selects immediate format depending on the instruction type (I, S, etc.)
    --   [2:0] - ALU control operation code
    --
    -- Each instruction assigns a N_CONTROL_BITS-bit pattern to "controls" that defines its full
    -- control behavior in a single line using the WITH-SELECT statement below.
    SIGNAL controls : STD_LOGIC_VECTOR(N_CONTROL_BITS - 1 DOWNTO 0);
    
    -- added for visibility in simulation
    TYPE instruction IS (LW, SW, ADD, NOP, B);
    SIGNAL instr : instruction := NOP;
    SIGNAL aux          : STD_LOGIC_VECTOR(10 DOWNTO 0);

    -- Instruction opcodes. add new values for each instruction
    CONSTANT OPCODE_LW  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011";
    CONSTANT OPCODE_I   : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010011";
    CONSTANT OPCODE_SW  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100011";
    CONSTANT OPCODE_R   : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0110011";
    CONSTANT OPCODE_B   : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100011";

    -- Control signals per instruction
    CONSTANT CTRL_LW  : STD_LOGIC_VECTOR(N_CONTROL_BITS-1 DOWNTO 0) := "01110010100";
    CONSTANT CTRL_ADDI : STD_LOGIC_VECTOR(N_CONTROL_BITS-1 DOWNTO 0) := "01010010100";
    CONSTANT CTRL_SW  : STD_LOGIC_VECTOR(N_CONTROL_BITS-1 DOWNTO 0) := "01001100100";
    CONSTANT CTRL_ADD : STD_LOGIC_VECTOR(N_CONTROL_BITS-1 DOWNTO 0) := "00010000100";
    CONSTANT CTRL_NOP : STD_LOGIC_VECTOR(N_CONTROL_BITS-1 DOWNTO 0) := "00000000000";
    CONSTANT CTRL_B : STD_LOGIC_VECTOR(N_CONTROL_BITS-1 DOWNTO 0)   := "10000101101";
BEGIN
    PROCESS (opcode, funct3, funct7_bit)
    BEGIN
        controls <= CTRL_NOP;
        CASE opcode IS
            WHEN OPCODE_LW =>
                controls <= CTRL_LW;
            WHEN OPCODE_SW =>
                controls <= CTRL_SW;
            WHEN OPCODE_I =>
                IF funct3 = "000" THEN
                    controls <= CTRL_ADDI;
                END IF;
            WHEN OPCODE_R =>
                IF funct3 = "000" AND funct7_bit = '0' THEN
                    controls <= CTRL_ADD;
                END IF;
            WHEN OPCODE_B =>
                CASE funct3 IS
                    WHEN "000" | "001" | "100" | "101" | "110" | "111" =>
                        controls <= CTRL_B;
                    WHEN OTHERS =>
                        controls <= CTRL_NOP;
                END CASE;
            WHEN OTHERS =>
                controls <= CTRL_NOP;
        END CASE;
    END PROCESS;

    pc_src     <= controls(10);
    Alu_src    <= controls(9);
    Res_sel    <= controls(8);
    rd_we      <= controls(7);
    Mem_we     <= controls(6);
    imm_sel    <= controls(5 DOWNTO 3); -- ctrl in the extension_unit
    alu_ctrl   <= controls(2 DOWNTO 0);
    Out_en     <= '1';
END ARCHITECTURE;