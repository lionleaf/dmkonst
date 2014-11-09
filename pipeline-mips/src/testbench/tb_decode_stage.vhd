                    
library ieee;
use ieee.std_logic_1164.all;
use work.test_utils.all;
use work.defs.all;

 
entity tb_decode_stage is
end tb_decode_stage;
 
architecture behavior of tb_decode_stage is 

  --inputs
  signal clk : std_logic := '0';
  signal pipe_in : fetch_decode_pipe_t := (others => (others => '0'));
  signal inst : inst_t := (others => '0');
  signal reg_wen : std_logic := '0';
  signal reg_dst : reg_n_t := (others => '0');
  signal reg_w_data : word_t := (others => '0');

  --Outputs
  signal pipe_out : decode_execute_pipe_t;
  signal reg_val_rs : word_t;
  signal reg_val_rt : word_t;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  alias opcode is inst(31 downto 26);

begin
 
	-- Instantiate the Unit Under Test (UUT)
  uut: entity work.decode_stage PORT MAP (
          clk => clk,
          fetch_decode_pipe => pipe_in,
          inst => inst,
          reg_wen => reg_wen,
          reg_dst => reg_dst,
          reg_w_data => reg_w_data,
          decode_execute_pipe => pipe_out,
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


    -- ADD etc
    report "opcode: 000000: add, sub, and, or, slt, sll";
    opcode <= "000000";
    
    --Set alu funct to AND
    inst(5 downto 0) <= "100100";
    wait for clk_period;
    
    check(pipe_out.branch_en   = '0', "Should not branch");
    check(pipe_out.mem_wen     = '0', "mem_write_enable should be disabled for alu operations");
    check(pipe_out.mem_to_reg  = '0', "mem_to_reg should be 0 during add");
    check(pipe_out.reg_wen     = '1', "reg_wen should be 1 during add");
    check(pipe_out.alu_funct   = to_alu_funct_t(inst(5 downto 0)), "alu funct should come from the instruction");
    check(pipe_out.inst_type_I = '0', "alu instructions is an R-type. inst_type_I should be 0");
    
    --- LOAD
    report "opcode: 100011: load";
    opcode <= "100011";
    wait for clk_period;
    
    check(pipe_out.branch_en   = '0', "Load does should not branch");
    check(pipe_out.mem_wen     = '0', "Load should not set mem_wen");
    check(pipe_out.mem_to_reg  = '1', "Load writes to reg and mem_to_reg should be 1");
    check(pipe_out.reg_wen     = '1', "reg_wen should be 1 during load");
    check(pipe_out.alu_funct   = alu_add, "alu should do add during load");
    check(pipe_out.inst_type_I = '1', "Load ");


    --- BEQ
    report "opcode: 000100: branch if equal";
    opcode <= "000100";
    wait for clk_period;
    
    check(pipe_out.branch_en   = '1', "Branch should set branch_en");
    check(pipe_out.mem_wen     = '0', "Branch should not write to mem");
    check(pipe_out.reg_wen     = '0', "Branch should not write to registers");
    check(pipe_out.alu_funct   = alu_sub, "Branch should subtract with the ALU");
    check(pipe_out.inst_type_I = '1', "Branch is an I-type");


    --- SW
    report "1opcode: 101011: store";
    opcode <= "101011";
    wait for clk_period;
    
    check(pipe_out.branch_en   = '0', "Store should not branch");
    check(pipe_out.mem_wen     = '1', "Store should write to mem");
    check(pipe_out.reg_wen     = '0', "Store should not write to registers");
    check(pipe_out.alu_funct   = alu_add, "Store should add with ALU");
    check(pipe_out.inst_type_I = '1', "Store is an I type");


    ---LUI
    report "opcode: 001111: load upper immediate";
    opcode <= "001111";
    wait for clk_period;
    
    check(pipe_out.branch_en   = '0', "LUI should not branch");
    check(pipe_out.mem_wen     = '0', "LUI should not write to mem");
    check(pipe_out.mem_to_reg  = '0', "LUI should not pipe mem to registers");
    check(pipe_out.reg_wen     = '1', "LUI should write to registers");
    check(pipe_out.alu_funct   = alu_sll16, "LUI should shift left 16 with the ALU");
    check(pipe_out.inst_type_I = '1', "LUI is an I type");


--  Test complete!
    report "=== Testbench passed successfully! ===";
    wait;
    
    
  end process;

end;
