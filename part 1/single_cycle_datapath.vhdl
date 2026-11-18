------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_datapath.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Structural implementation of a single-cycle RISC-V datapath.
--                Includes PC, instruction fetch, decode, ALU, memory, and write-back.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY lw_sw_datapath IS
    PORT (--Added port names

        clock       : IN  STD_LOGIC;
        Mem_we      : IN  STD_LOGIC;
        rd_we       : IN  STD_LOGIC;
        Alu_src     : IN  STD_LOGIC;
        Res_sel     : IN  STD_LOGIC;
        Out_en      : IN  STD_LOGIC;
        imm_sel     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_ctrl    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        opcode      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        funct3      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        funct7_bit  : OUT STD_LOGIC;
        zero_flag   : OUT STD_LOGIC;
        out_data    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE structural OF lw_sw_datapath IS
    SIGNAL pc, pc_next : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, ext_imm, alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, mem_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL result_mux_o, alu_operand_b : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_addr, rs2_addr, rd_addr : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL instr_31_7 : STD_LOGIC_VECTOR(31 DOWNTO 7);
BEGIN
    opcode      <= instruction(6 DOWNTO 0);
    funct3      <= instruction(14 DOWNTO 12);
    funct7_bit <= instruction(30);
    rs1_addr <= instruction(19 DOWNTO 15);
    rs2_addr <= instruction(24 DOWNTO 20);
    rd_addr <= instruction(11 DOWNTO 7);
    instr_31_7 <= instruction(31 DOWNTO 7);

    pc_adder : ENTITY work.adder_32(Behavioral)
        PORT MAP (
            op_a => pc, 
            op_b => x"00000004",
            sum => pc_next
            );

    pc_register : ENTITY work.program_counter(behavioral)
        PORT MAP (clock => clock, pc_next => pc_next, pc_out => pc);

    program_rom : ENTITY work.instr_mem(rtl)
        PORT MAP (address => pc, data => instruction);

    registers : ENTITY work.register_file(behavioral)
        PORT MAP (
            clock => clock,
            rs1_addr => rs1_addr,
            rs2_addr => rs2_addr,
            rd_addr  => rd_addr,
            rd_data  => result_mux_o,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            rd_we    => rd_we
        );

    immediate : ENTITY work.extension_unit(Behavioral)
        PORT MAP (din => instr_31_7, ctrl => imm_sel, dout => ext_imm);

    alu_operand_mux : ENTITY work.mux_2to1(Behavioral)
        PORT MAP (in0 => rs2_data, in1 => ext_imm, out_y => alu_operand_b, sel => Alu_src);

    arithmetic_unit : ENTITY work.alu(Behavioral)
        PORT MAP (
            src_a => rs1_data, src_b => alu_operand_b, alu_ctrl => alu_ctrl,
            result => alu_result, zero_flag => zero_flag
        );

    data_memory : ENTITY work.data_mem(rtl)
        PORT MAP (
            address => alu_result, write_data => rs2_data, data => mem_data,
            write_en => Mem_we, clock => clock
        );

    writeback_mux : ENTITY work.mux_2to1(Behavioral)
        PORT MAP (in0 => alu_result, in1 => mem_data, out_y => result_mux_o, sel => Res_sel);

    result_output : ENTITY work.tri_state_buffer(Behavioral)
        PORT MAP (output_en => Out_en, buffer_input => result_mux_o, buffer_output => out_data);
END ARCHITECTURE;
