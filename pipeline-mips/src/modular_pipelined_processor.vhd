library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity processor is
    generic
        ( addr_width : integer := 8
        ; data_width : integer := 32
        );
    port
        ( clk, reset        : in  std_logic
        ; processor_enable  : in  std_logic
        ; imem_data_in      : in  word_t
        ; imem_address      : out addr_t
        ; dmem_data_in      : in  word_t
        ; dmem_address      : out addr_t
        ; dmem_data_out     : out word_t
        ; dmem_write_enable : out std_logic
        );
end processor;

architecture Behavioral of processor is

	-- All signal names follow the following format:
	--	<name>_<destination>_<in/out>
	-- example: pc_sourse_if_out is a signal named pc_source that
	-- is an input from the module instruction-fetch (if).
	
	signal incremented_pc_if_out	:	addr_t;
	signal incremented_pc_id_in	:  addr_t;
	signal incremented_pc_ex_in	:	addr_t;
	
	signal branch_adress_if_in		:	addr_t;
	
	signal pc_source					:	std_logic;
		
	signal instructions_if_out		:  std_logic_vector (31 downto 0);
	signal instructions_id_in		:  std_logic_vector (31 downto 0);
  signal instructions_ex_in		:  std_logic_vector (31 downto 0);
	
	signal data_1_id_out				:	std_logic_vector (31 downto 0);
	signal data_2_id_out				:	std_logic_vector (31 downto 0);
	signal data_1_ex_in				:	std_logic_vector (31 downto 0);
	signal data_2_ex_in				:	std_logic_vector (31 downto 0);
  
  signal alu_source         : std_logic;
  signal alu_zero_ex_out    : std_logic;
  signal alu_zero_mem_in    : std_logic;
  signal alu_operation      : alu_funct_t;
  signal alu_shamt          : alu_shamt_t;
  signal alu_result_ex_out  : word_t;
  signal alu_result_mem     : word_t;
  
  signal branch_address_ex_out : addr_t;
  
  signal write_register_ex_out : reg_t;
  signal branch_adress         : addr_t;
  
  signal register_destination : std_logic;
	
	signal write_data					:  std_logic_vector (31 downto 0);
	
	signal write_register			:  std_logic_vector (4 downto 0);
	
  signal data_wb          : word_t;
  signal alu_result_wb    : word_t;
  
  
	subtype reg_number is std_logic_vector(4 downto 0);
  
  
	
  alias rt_ex_in : reg_number is instructions_ex_in(20 downto 16);
  alias rd_ex_in : reg_number is instructions_ex_in(15 downto 11);
	
	
	signal instructions_mem_in  : reg_t;
begin
	
	--------------- Instruction Fetch --------------- 
	
	instruction_fetch:
		entity work.instruction_fetch
		port map
			( clk							=>	clk
			, reset						=> reset
			, incremented_pc 			=> incremented_pc_if_out
			, branch_adress			=> branch_adress_if_in
			, pc_source					=> pc_source
			)
		;
		
		if_to_id_pipe:
		entity work.instruction_fetch_pipe
		port map 
			( reset              => reset
			, clk                => clk
			, instructions_in    => instructions_if_out
			, instructions_out   => instructions_id_in
			, incremented_pc_in  =>	incremented_pc_if_out
			, incremented_pc_out	=> incremented_pc_id_in
			)
		;
		
	--------------- Instruction Decode --------------- 
		
	instruction_decode:
		entity work.instruction_decode
		port map
			(	clk				=> clk
			,	instruction	=>	instructions_id_in
			,	write_data		=>	write_data
			,	write_register	=>	write_register
			,	data_1			=>	data_1_id_out
			,	data_2			=> data_2_id_out
			)
		;
		
	id_to_ex_pipe:
		entity work.instruction_decode_pipe
		generic map
			( data_width => data_width
			)
		port map
			( clk               => clk
			, reset             => reset
			, incremented_PC_in => incremented_pc_id_in
			, incremented_PC_out=> incremented_pc_ex_in
			, data_1_in         => data_1_id_out
			, data_1_out        => data_1_ex_in
			, data_2_in         => data_2_id_out
			, data_2_out        => data_2_ex_in
			, instructions_in   => instructions_id_in
			, instructions_out  => instructions_ex_in
			)
		;
	
	--------------- Execution ---------------	
	
	
	execute:
		entity work.execute
		port map
			(  incremented_pc	=> incremented_pc_ex_in
			, data_1				=> data_1_ex_in
			, data_2				=> data_2_ex_in
			, instructions		=> instructions_ex_in
			, alu_source		=> alu_source
			, alu_funct	    => alu_operation
			, alu_shamt	    => alu_shamt
			, alu_result		=> alu_result_ex_out
			, alu_zero			=> alu_zero_ex_out
			, branch_address	=> branch_address_ex_out
			)
		;

	write_register_ex_out <= rd_ex_in when register_destination = '1'
							else	 rt_ex_in;
  
  dmem_address <= alu_result_mem(7 downto 0);
	ex_to_mem_pipe:
		entity work.execution_pipe

		port map
			( clk               => clk
			, reset             => reset
			, sum_in            => branch_address_ex_out
			, sum_out           => branch_adress
			, zero_in           => alu_zero_ex_out
			, zero_out          => alu_zero_mem_in
			, alu_result_in     => alu_result_ex_out
			, alu_result_out    => alu_result_mem
			, data_2_in         => data_2_ex_in
			, data_2_out        => dmem_data_out
			, instructions_in   => write_register_ex_out
			, instructions_out  => instructions_mem_in
			)
		;
		
	--------------- Memory ---------------

--	pc_source <= branch and alu_zero;
	pc_source <= '1';

	mem_to_wb_pipe:
		entity work.write_back_pipe
		port map
			(  clk              => clk
			,  reset            => reset
			,  read_data_in     => dmem_data_in
			,  read_data_out    => data_wb
			,  alu_result_in    => alu_result_mem
			,  alu_result_out   => alu_result_wb
			,  instructions_in  => instructions_mem_in
			,  instructions_out => write_register
			)
		;
		
	--------------- Write Back ---------------
	
	write_data <= data_wb;
--	write_data <= data_readback_in when memory_to_register = '1'
--			else	  alu_result_wb_in;
	
	
end Behavioral;
