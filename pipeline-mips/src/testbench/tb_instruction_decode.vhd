library ieee;
use ieee.std_logic_1164.all;
use work.test_utils.all;
use work.defs.all;

 
entity tb_decode_stage is
end tb_decode_stage;
 
architecture behavior of tb_decode_stage is 

	--Inputs
   signal clk 					: std_logic := '0';
   signal processor_enable : std_logic := '0';
   signal write_data 		: word_t 	:= (others => '0');
   signal instruction 		: word_t 	:= (others => '0');
   signal write_register 	: reg_t 		:= (others => '0');
   signal write_reg_enable : std_logic := '0';
	signal imm_to_alu			: std_logic := '0';

 	--Outputs
   signal data_1 				: word_t;
   signal data_2 				: word_t;
   signal branch_en 			: std_logic;
   signal mem_to_reg 		: std_logic;
   signal mem_wen 			: std_logic;
   signal reg_wen 			: std_logic;
   signal inst_type_I 		: std_logic;
   signal alu_funct 			: alu_funct_t;
   signal alu_shamt 			: alu_shamt_t;

   -- Clock period definitions
   constant clk_period 		: time := 10 ns;
	
   alias opcode is instruction(31 downto 26);

begin
 
	-- Instantiate the Unit Under Test (UUT)
	uut: entity work.instruction_decode 
		port map 
			 ( clk => clk
          , processor_enable => processor_enable
          , write_data => write_data
          , instruction => instruction
          , write_register => write_register
          , write_reg_enable => write_reg_enable
          , data_1 => data_1
          , data_2 => data_2
          , branch_en => branch_en
          , mem_to_reg => mem_to_reg
          , mem_wen => mem_wen
          , reg_wen => reg_wen
          , inst_type_I => inst_type_I
          , alu_funct => alu_funct
          , alu_shamt => alu_shamt
			 , imm_to_alu => imm_to_alu
          )
		;

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
  
	procedure check_disabled
            ( opcode_in : std_logic_vector(5 downto 0)
            ; opcode_desc : string
            )
        is begin
            
				processor_enable <= '0';
				opcode <= opcode_in;
				
            wait for clk_period;

            report "opcode: "& opcode_desc;
				check(mem_wen   		= '0', 					opcode_desc & ": mem_wen is not 0 when processor is disabled");
				check(reg_wen   		= '0', 					opcode_desc & ": reg_wen is not 0 when processor is disabled");

        end procedure check_disabled;
  begin
    -- let other messages come first
    wait for 1 ps;

    report "== Starting test ==";
	
	-- Disabled Processor
	check_disabled("000000", "add, sub, and, or, slt, sll");
	check_disabled("100011", "load");
	check_disabled("100100", "and");
	check_disabled("000100", "branch if equal");
	check_disabled("101011", "store");
	check_disabled("001111", "load upper immediate");
	
	-- Enable processor
	processor_enable <= '1';

	wait for 10*clk_period;

    -- ADD etc
    report "opcode: 000000: add, sub, and, or, slt, sll";
    opcode <= "000000";
    
    --Set alu funct to AND
    instruction(5 downto 0) <= "100100";
    wait for clk_period;
    
    check(branch_en   = '0', "Should not branch");
    check(mem_wen     = '0', "mem_write_enable should be disabled for alu operations");
    check(mem_to_reg  = '0', "mem_to_reg should be 0 during add");
    check(reg_wen     = '1', "reg_wen should be 1 during add");
    check(alu_funct   = instruction(5 downto 0), "alu funct should come from the instruction");
    check(inst_type_I = '0', "alu instructions is an R-type. inst_type_I should be 0");
	 check(imm_to_alu = '0', "imm_to_alu should be zero for AND.");

    
    --- LOAD
    report "opcode: 100011: load";
    opcode <= "100011";
    wait for clk_period;
    
    check(branch_en   = '0', "Load does should not branch");
    check(mem_wen     = '0', "Load should not set mem_wen");
    check(mem_to_reg  = '1', "Load writes to reg and mem_to_reg should be 1");
    check(reg_wen     = '1', "reg_wen should be 1 during load");
    check(alu_funct   = alu_add, "alu should do add during load");
    check(inst_type_I = '1', "Load ");
	 check(imm_to_alu = '1', "imm_to_alu should be high for load.");


    --- BEQ
    report "opcode: 000100: branch if equal";
    opcode <= "000100";
    wait for clk_period;
    
    check(branch_en   = '1', "Branch should set branch_en");
    check(mem_wen     = '0', "Branch should not write to mem");
    check(reg_wen     = '0', "Branch should not write to registers");
    check(alu_funct   = alu_sub, "Branch should subtract with the ALU");
    check(imm_to_alu = '0', "imm_to_alu should be zero for branch.");


    --- SW
    report "1opcode: 101011: store";
    opcode <= "101011";
    wait for clk_period;
    
    check(branch_en   = '0', "Store should not branch");
    check(mem_wen     = '1', "Store should write to mem");
    check(reg_wen     = '0', "Store should not write to registers");
    check(alu_funct   = alu_add, "Store should add with ALU");
    check(inst_type_I = '1', "Store is an I type");
	 check(imm_to_alu = '1', "imm_to_alu should be high for Stor Word.");


    ---LUI
    report "opcode: 001111: load upper immediate";
    opcode <= "001111";
    wait for clk_period;
    
    check(branch_en   = '0', "LUI should not branch");
    check(mem_wen     = '0', "LUI should not write to mem");
    check(mem_to_reg  = '0', "LUI should not pipe mem to registers");
    check(reg_wen     = '1', "LUI should write to registers");
    check(alu_funct   = alu_sll, "LUI should shift left 16 with the ALU");
    check(alu_shamt   = "010000", "LUI should shift left 16 with the ALU");
    check(inst_type_I = '1', "LUI is an I type");
	 check(imm_to_alu = '1', "imm_to_alu should be high for LUI.");


--  Test complete!
    report "=== Testbench passed successfully! ===";
    wait;
    
    
  end process;

end;