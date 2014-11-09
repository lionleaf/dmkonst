
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.test_utils.all;
use work.defs.all;

 
ENTITY tb_decode_stage IS
END tb_decode_stage;
 
ARCHITECTURE behavior OF tb_decode_stage IS 
 
   --Inputs
   signal clk : std_logic := '0';
   signal fetch_decode_pipe : fetch_decode_pipe_t := (others => (others => '0'));
   signal inst : inst_t := (others => '0');
   signal reg_wen : std_logic := '0';
   signal reg_dst : std_logic := '0';
   signal reg_w_data : word_t := (others => '0');

 	--Outputs
   signal decode_execute_pipe : decode_execute_pipe_t;
   signal reg_val_rs : word_t;
   signal reg_val_rt : word_t;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
   alias opcode is inst(5 downto 0);

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: work.decode_stage PORT MAP (
          clk => clk,
          fetch_decode_pipe => fetch_decode_pipe,
          inst => inst,
          reg_wen => reg_wen,
          reg_dst => reg_dst,
          reg_w_data => reg_w_data,
          decode_execute_pipe => decode_execute_pipe,
          reg_val_rs => reg_val_rs,
          reg_val_rt => reg_val_rt
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
    -- stimulus process
    stim_proc: process
    begin
        -- let other messages come first
        wait for 1 ps;

        report "== Starting test ==";

        report "opcode: 000000: add, sub, and, or, slt, sll";
        opcode <= "000000";
        wait for clk_period;
        check(fetch_decode_pipe.inst_type_I         = '0', "alu instructions are r-type. fetch_decode_pipe.inst_type_I should be 1");
--        check(alu_src          = '0', "alu instructions are r-type. alu_src should be 0");
--        check(alu_override               = override_disabled, "alu_override is not orverride_disabled");
        check(fetch_decode_pipe.branch_en = '0', "Should not branch");
        check(fetch_decode_pipe.mem_to_reg = '0', "fetch_decode_pipe.mem_to_reg is not 0");
        check(fetch_decode_pipe.mem_wen = '0', "mem_write_enable is not 0");
        check(fetch_decode_pipe.reg_wen = '1', "reg_write_enable is not 1");

--
--        report "opcode: 000010: jump";
--        write_enable <= '1';
--        opcode <= "000010";
--        wait for clk_period;
--        check(pc_control       = jump, "pc control is not jump");
--        check(mem_write_enable = '0', "mem_write_enable is not 0");
--        check(reg_write_enable = '0', "reg_write_enable is not 0");
--
--
--        report "opcode: 100011: load";
--        write_enable <= '1';
--        opcode <= "100011";
--        wait for clk_period;
--        check(fetch_decode_pipe.inst_type_I         = '0', "load instructions are i-type. fetch_decode_pipe.inst_type_I should be 0");
--        check(alu_src          = '1', "load instructions are i-type. alu_src should be 1");
--        check(alu_override     = override_add, "alu_override is not override_add. jump needs to add rs and imm");
--        check(pc_control       = step, "pc control is not step");
--        check(fetch_decode_pipe.mem_to_reg       = '1', "mem_to_reg is not 1");
--        check(mem_write_enable = '0', "mem_write_enable is not 0");
--        check(reg_write_enable = '1', "reg_write_enable is not 1");
--        
--        
--        report "opcode: 000100: branch";
--        write_enable <= '1';
--        opcode <= "000100";
--        wait for clk_period;
--        check(fetch_decode_pipe.inst_type_I         = '1', "load instructions are i-type. fetch_decode_pipe.inst_type_I should be 0");
--        check(alu_src          = '0', "load instructions are i-type. alu_src should be 1");
--        check(alu_override     = override_sub, "alu_override is not override_add. jump needs to add rs and imm");
--        check(pc_control       = branch, "pc control is not step");
--        check(fetch_decode_pipe.mem_to_reg       = '0', "mem_to_reg is not 1");
--        check(mem_write_enable = '0', "mem_write_enable is not 0");
--        check(reg_write_enable = '0', "reg_write_enable is not 1");
--
--
--        report "opcode: 101011: store";
--        write_enable <= '1';
--        opcode <= "101011";
--        wait for clk_period;
--        check(fetch_decode_pipe.inst_type_I         = '0', "store instructions are i-type. fetch_decode_pipe.inst_type_I should be 0");
--        check(alu_src          = '1', "store instructions are i-type. alu_src should be 1");
--        check(alu_override     = override_add, "alu_override is not override_add. jump needs to add rs and imm");
--        check(pc_control       = step, "pc control is not step");
--        check(mem_write_enable = '1', "mem_write_enable is not 1");
--        check(reg_write_enable = '0', "reg_write_enable is not 0");
--
--
--        report "opcode: 001111: load immediate";
--        write_enable <= '1';
--        opcode <= "001111";
--        wait for clk_period;
--        check(fetch_decode_pipe.inst_type_I         = '0', "load imm instructions are i-type. fetch_decode_pipe.inst_type_I should be 0");
--        check(alu_src          = '1', "load imm instructions are i-type. alu_src should be 1");
--        check(alu_override     = override_sll16, "alu_override is not override_sll16");
--        check(pc_control       = step, "pc control is not step");
--        check(fetch_decode_pipe.mem_to_reg       = '0', "mem_to_reg is not 0");
--        check(mem_write_enable = '0', "mem_write_enable is not 0");
--        check(reg_write_enable = '1', "reg_write_enable is not 1");
--

        report "=== Testbench passed successfully! ===";

        wait;
   end process;

END;
