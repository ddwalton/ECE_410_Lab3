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
USE IEEE.NUMERIC_STD.ALL;

ENTITY lw_sw_datapath IS
    PORT (
        clock       : IN  STD_LOGIC;
        Mem_we      : IN  STD_LOGIC;                  -- dp_13
        rd_we       : IN  STD_LOGIC;                  -- dp_10
        Alu_src     : IN  STD_LOGIC;                  -- dp_11
        Res_sel     : IN  STD_LOGIC;                  -- dp_14
        Out_en      : IN  STD_LOGIC;                  -- dp_15
        pc_src      : IN  STD_LOGIC; -- 0->increment +4; 1->use output of branch_adder
        imm_sel     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- dp_8
        alu_ctrl    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- dp_12
        opcode      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- dp_1
        funct3      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- dp_2
        funct7_bit  : OUT STD_LOGIC;                  -- dp_3
        zero_flag   : OUT STD_LOGIC;
        out_data    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE structural OF lw_sw_datapath IS
    SIGNAL br_taken, br_sel                  : STD_LOGIC;
    SIGNAL pc, pc_next, pc_incr, pc_branch   : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, imm_ext, alu_result  : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, rd_data       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL result_mux_o                      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL alu_mux_o                         : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN
    opcode     <= instruction(6 DOWNTO 0);
    funct3     <= instruction(14 DOWNTO 12);
    funct7_bit <= instruction(30);

    br_sel <= pc_src and br_taken;
------------------------------------------------------------------------
-- FETCH BLOCK
------------------------------------------------------------------------
    dp_pc_adder : ENTITY work.adder_32(Behavioral)
        PORT MAP (
            op_a => pc,
            op_b => x"00000004",
            sum  => pc_incr
        );

    dp_pc : ENTITY work.program_counter(Behavioral)
        PORT MAP (
            clock   => clock,
            pc_out  => pc,
            pc_next => pc_next
        );
    
    dp_branch_adder : ENTITY work.adder_32(Behavioral)
        PORT MAP (
            op_a => pc,
            op_b => imm_ext,
            sum => pc_branch
        );

    dp_branch_mux : ENTITY work.mux_2to1(Behavioral)
        PORT MAP (
            in0 => pc_incr,
            in1 => pc_branch,
            out_y => pc_next,
            sel => br_sel
        );

    dp_branch_comparator : ENTITY work.branch_comparator(Behavioral)
        PORT MAP (
            rs1 => rs1_data,
            rs2 => rs2_data,
            br_ctrl => instruction(14 DOWNTO 12), -- funct3
            br_taken => br_taken
        );

    dp_instr_mem : ENTITY work.instr_mem(rtl)
        PORT MAP (
            address => pc,
            data    => instruction
        );

------------------------------------------------------------------------
-- DECODE BLOCK
------------------------------------------------------------------------
    dp_regfile : ENTITY work.register_file(Behavioral)
        PORT MAP (
            clock    => clock,
            rs1_addr => instruction(19 DOWNTO 15),
            rs2_addr => instruction(24 DOWNTO 20),
            rd_addr  => instruction(11 DOWNTO 7),
            rd_data  => result_mux_o,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            rd_we    => rd_we
        );

    dp_extend : ENTITY work.extend_unit(rtl)
        PORT MAP (
            din  => instruction(31 DOWNTO 7),
            ctrl => imm_sel,
            dout => imm_ext
        );

------------------------------------------------------------------------
-- EXECUTE & MEMORY BLOCK
------------------------------------------------------------------------
    dp_alu_src : ENTITY work.mux_2to1(Behavioral)
        PORT MAP (
            in0   => rs2_data,
            in1   => imm_ext,
            out_y => alu_mux_o,
            sel   => Alu_src
        );

    dp_alu : ENTITY work.alu(Behavioral)
        PORT MAP (
            src_a     => rs1_data,
            src_b     => alu_mux_o,
            alu_ctrl  => alu_ctrl,
            result    => alu_result,
            zero_flag => zero_flag
        );

    dp_data_mem : ENTITY work.data_memory(rtl)
        PORT MAP (
            clock      => clock,
            address    => alu_result,
            write_data => rs2_data,
            data       => rd_data,
            write_en   => Mem_we
        );

------------------------------------------------------------------------
-- WRITE-BACK BLOCK
------------------------------------------------------------------------
    dp_result_src : ENTITY work.mux_2to1(Behavioral)
        PORT MAP (
            in0   => alu_result,
            in1   => rd_data,
            out_y => result_mux_o,
            sel   => Res_sel
        );

    dp_tri_state_buffer : ENTITY work.tri_state_buffer(Behavioral)
        PORT MAP (
            output_en     => Out_en,
            buffer_input  => result_mux_o,
            buffer_output => out_data
        );

END structural;