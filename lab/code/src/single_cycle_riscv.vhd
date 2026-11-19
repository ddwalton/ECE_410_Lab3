------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_riscv.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Top-level RISC-V CPU combining single-cycle datapath and control logic.
--                Executes basic load, store, and arithmetic instructions.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY single_cycle_riscv IS
    PORT (
        clock     : IN STD_LOGIC;
        out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Structural OF single_cycle_riscv IS
    SIGNAL zero_flag                       : STD_LOGIC                     := '0';
    SIGNAL pc, pc_next                     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, ext_imm, alu_result: STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, rd_data     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_we                          : STD_LOGIC; -- data memory write enable
    SIGNAL rd_we                           : STD_LOGIC; 
    SIGNAL funct7_bit                      : STD_LOGIC;
    SIGNAL alu_sel, res_sel                : STD_LOGIC;
    SIGNAL funct3                          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL imm_sel                         : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL alu_ctrl                        : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL opcode                          : STD_LOGIC_VECTOR(6 DOWNTO 0);

BEGIN

    datapath : ENTITY work.lw_sw_datapath(structural)
        PORT MAP(
            clock       => clock,
            -- TODO: complete datapath port connections
            
            out_data   => out_data
        );

    control_unit : ENTITY work.controller(behavioral)
        PORT MAP(
            zero_flag   => zero_flag,
            -- TODO: complete controller port connections
        );
END Structural;
