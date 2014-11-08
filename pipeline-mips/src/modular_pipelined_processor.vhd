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
        ; imem_data_in      : in  std_logic_vector(data_width-1 downto 0)
        ; imem_address      : buffer std_logic_vector(addr_width-1 downto 0)
        ; dmem_data_in      : in  std_logic_vector(data_width-1 downto 0)
        ; dmem_address      : out std_logic_vector(addr_width-1 downto 0)
        ; dmem_data_out     : out std_logic_vector(data_width-1 downto 0)
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
	
	signal write_data					:  std_logic_vector (31 downto 0);
	
	signal write_register			:  std_logic_vector (4 downto 0);
	
	subtype reg_number is std_logic_vector(4 downto 0);
	
   alias rt_ex_in : reg_number is instructions_ex_in(20 downto 16);
   alias rd_ex_in : reg_number is instructions_ex_in(15 downto 11);
	
	
	 
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
			, instructions				=> instructions_if_out
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
			,	reset				=> reset
			,	instructions	=>	instructions_id_in
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
			( clk					=> clk
			, reset				=> reset
			, incremented_pc	=> incremented_pc_ex_in
			, data_1				=> data_1_ex_in
			, data_2				=> data_2_ex_in
			, instructions		=> instructions_ex_in
			, alu_source		=> alu_source
			, alu_operation	=> alu_operation
			, alu_result		=> alu_result_ex_out
			, alu_zero			=> alu_zero_ex_out
			, branch_address	=> branch_address_ex_out
			)
		;

	write_register_ex_out <= rd_ex_in when register_destination = '1'
							else	 rt_ex_in;
							
	ex_to_mem_pipe:
		entity work.execution_pipe
		generic map
        ( data_width : integer := 32
        )
		port map
			( clk               => clk
			, reset             => reset
			, sum_in            => branch_address_ex_out
			, sum_out           => branch_adress
			, zero_in           => alu_zero_ex_out
			, zero_out          => alu_zero_mem_in
			, alu_result_in     => alu_result_ex_out
			, alu_result_out    => dmem_address
			, data_2_in         => data_2_ex_in
			, data_2_out        => dmem_data_out
			, instructions_in   => write_register_ex_out
			, instructions_out  => instructions_mem_in
			)
		;
		
	--------------- Memory ---------------

	pc_source <= branch and alu_zero;

	mem_to_wb_pipe:
		entity work.write_back_pipe
		generic map
        ( data_width : integer := 32
        );
		port map
			(  clk              => clk
			,  reset            => reset
			,  read_data_in     => dmem_data_out
			,  read_data_out    => data_readback_in
			,  alu_result_in    => dmem_address
			,  alu_result_out   => alu_result_wb_in
			,  instructions_in  => instructions_mem_in
			,  instructions_out => write_register
			)
		;
		
	--------------- Write Back ---------------
	
	write_data <= data_readback_in when memory_to_register = '1'
			else	  alu_result_wb_in;
	
	
end Behavioral;