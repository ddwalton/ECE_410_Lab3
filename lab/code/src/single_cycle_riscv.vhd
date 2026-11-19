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
-- connects the datapath and controller
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY single_cycle_riscv IS
    PORT (
        clock    : IN  STD_LOGIC;
        out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Structural OF single_cycle_riscv IS
    SIGNAL zero_flag : STD_LOGIC;
    SIGNAL opcode : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL funct3, imm_sel, alu_ctrl : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL funct7_bit : STD_LOGIC;
    SIGNAL Alu_src, Res_sel, Mem_we, rd_we, Out_en, pc_src : STD_LOGIC;
BEGIN
    datapath : ENTITY work.lw_sw_datapath(structural)
        PORT MAP (
            clock => clock,
            Mem_we => Mem_we,
            rd_we => rd_we,
            Alu_src => Alu_src,
            Res_sel => Res_sel,
            Out_en => Out_en,
            pc_src => pc_src,
            imm_sel => imm_sel,
            alu_ctrl => alu_ctrl,
            opcode => opcode,
            funct3 => funct3,
            funct7_bit => funct7_bit,
            zero_flag => zero_flag,
            out_data => out_data
        );

    control_unit : ENTITY work.controller(Behavioral)
        PORT MAP (
            opcode => opcode,
            funct3 => funct3,
            funct7_bit => funct7_bit,
            zero_flag => zero_flag,
            Alu_src => Alu_src,
            Res_sel => Res_sel,
            Mem_we => Mem_we,
            rd_we => rd_we,
            Out_en => Out_en,
            pc_src => pc_src,
            imm_sel => imm_sel,
            alu_ctrl => alu_ctrl
        );
END ARCHITECTURE;