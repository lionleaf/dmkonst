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
	
	signal incremented_pc_if	:	addr_t;
	signal incremented_pc_id	:  addr_t;
	signal incremented_pc_ex	:	addr_t;
	
	
	signal pc_source					:	std_logic;
		
  signal instruction_ex		:  std_logic_vector (31 downto 0);
  signal instruction_id		:  std_logic_vector (31 downto 0);
	
	signal data_1_id				:	std_logic_vector (31 downto 0);
	signal data_2_id				:	std_logic_vector (31 downto 0);
	signal data_1_ex				:	std_logic_vector (31 downto 0);
	signal data_2_ex				:	std_logic_vector (31 downto 0);
  
  signal alu_source_ex      : std_logic;
  signal alu_zero_ex        : std_logic;
  signal alu_zero_mem       : std_logic;
  signal alu_result_ex      : word_t;
  signal alu_result_mem     : word_t;
  
  signal branch_addr_ex     : addr_t;
  signal branch_addr_mem		:	addr_t;

  signal write_reg_dst_ex   : reg_t;
  signal write_reg_dst_mem  : reg_t;
  signal write_reg_dst_wb   : reg_t;
  	
    
  -- The memory data that might be written to reg
  signal mem_data_wb      : word_t;
  
  -- The ALU result that might be written to reg
  signal alu_result_wb    : word_t;
  
  -- The data written back to register
  signal write_data_wb    : word_t;
  
  ----------------------------------
  --Control signals
  ----------------------------------

  -- Signals out of instruction decode
  -------------------------------------
  -- For execute stage
  signal inst_type_I_id: std_logic;
  signal imm_to_alu_id : std_logic;
  signal mem_read_id   : std_logic;
  signal alu_funct_id  : alu_funct_t;
  signal alu_shamt_id  : alu_shamt_t;

  -- For memory stage
  signal branch_en_id  : std_logic;
  signal mem_wen_id    : std_logic;

  -- For write back stage
  signal mem_to_reg_id : std_logic; 
  signal reg_wen_id    : std_logic;


  -- Signals in execute stage
  -------------------------------------
  -- Consumed in execute
  signal inst_type_I_ex : std_logic;
  signal imm_to_alu_ex  : std_logic;
  signal mem_read_ex    : std_logic;
  signal alu_funct_ex   : alu_funct_t;
  signal alu_shamt_ex   : alu_shamt_t;

  -- For memory stage
  signal branch_en_ex  : std_logic;
  signal mem_wen_ex    : std_logic;

  -- For write back stage
  signal mem_to_reg_ex : std_logic; 
  signal reg_wen_ex    : std_logic;


  -- Signals in memory stage
  -------------------------------------
  -- Consumed in memory
  signal branch_en_mem  : std_logic;
  signal mem_wen_mem    : std_logic;
  
  --Signal back to IF
  signal branch_en_if  : std_logic;


  -- For write back stage
  signal mem_to_reg_mem : std_logic; 
  signal reg_wen_mem    : std_logic;

  -- Signals in write back stage
  -------------------------------------
  -- Consumed in write back
  signal mem_to_reg_wb : std_logic; 
  signal reg_wen_wb    : std_logic;


	----------------------------------
  --     HAZARD CONTROL
  ----------------------------------
  
  --  Hazard Detection Unit
  ----------------------------------
  
  --insert_stall should invalidate instruction in ID by setting it to a nop
  --and freeze the PC register
  signal insert_stall : std_logic;

  
 -- alias rt_ex : reg_t is instruction_ex(20 downto 16);
  alias reg_rt_ex : reg_t is instruction_ex(20 downto 16);
  alias reg_rd_ex : reg_t is instruction_ex(15 downto 11);
--  alias register_rd_ex : reg_t is instruction_ex(15 downto 11);
	
  alias reg_rs_id : reg_t is instruction_id(25 downto 21);
  alias reg_rt_id : reg_t is instruction_id(20 downto 16);
	
	signal instruction_mem_in  : reg_t;
begin
	
	--------------- Instruction Fetch --------------- 
	
	instruction_fetch:
		entity work.instruction_fetch
		port map
			( clk							  =>	clk
			, reset						  => reset
      , processor_enable  => processor_enable
      , insert_stall      => insert_stall
			, incremented_pc 		=> incremented_pc_if
			, branch_addr			  => branch_addr_mem
			, branch_en					=> branch_en_if
      , pc                => imem_address
			)
		;
		
		if_to_id_pipe:
		entity work.if_to_id_pipe
		port map 
			( reset               => reset
			, clk                 => clk
			, insert_stall			  => insert_stall
			, incremented_pc_in   => incremented_pc_if
			, incremented_pc_out	=> incremented_pc_id
			, instruction_in	    => imem_data_in
			, instruction_out	    => instruction_id
			)
		;
		
	--------------- Instruction Decode --------------- 
    
	instruction_decode:
		entity work.instruction_decode
		port map
			(	clk				=> clk
			,	instruction	=>	instruction_id
      , processor_enable  => processor_enable

      -- Write back from wb stage
      ,	write_data		    =>	write_data_wb
			,	write_register	  =>	write_reg_dst_wb
      , write_reg_enable  =>  reg_wen_wb

      -- Out
			,	data_1			=> data_1_id
			,	data_2			=> data_2_id
      
      -- Hazard handling
			,	insert_stall			=> insert_stall
      
      -- Control signals out
      , branch_en   => branch_en_id
      , mem_to_reg  => mem_to_reg_id
      , mem_wen     => mem_wen_id
      , mem_read    => mem_read_id
      , reg_wen     => reg_wen_id
      , inst_type_I => inst_type_I_id
      , imm_to_alu  => imm_to_alu_id
      , alu_funct   => alu_funct_id
      , alu_shamt   => alu_shamt_id
			)
		;
    
  hazard_detection_unit:
    entity work.hazard_detection
    port map
      ( mem_read_ex => mem_read_ex 
      , reg_rt_ex   => reg_rt_ex   
      , reg_rs_id   => reg_rs_id   
      , reg_rt_id   => reg_rt_id   
      , insert_stall=> insert_stall
      );
		
	id_to_ex_pipe:
		entity work.id_to_ex_pipe
		generic map
			( data_width => data_width
			)
		port map
			( clk               => clk
			, reset             => reset
			, incremented_PC_in => incremented_pc_id
			, incremented_PC_out=> incremented_pc_ex
			, data_1_in         => data_1_id
			, data_1_out        => data_1_ex
			, data_2_in         => data_2_id
			, data_2_out        => data_2_ex
			, instructions_in   => instruction_id
			, instructions_out  => instruction_ex

      --Control signals
      --For execute
      , inst_type_I_in    => inst_type_I_id
      , inst_type_I_out   => inst_type_I_ex
      , imm_to_alu_in     => imm_to_alu_id
      , imm_to_alu_out    => imm_to_alu_ex
      , mem_read_in       => mem_read_id
      , mem_read_out      => mem_read_ex
      , alu_funct_in      => alu_funct_id
      , alu_funct_out     => alu_funct_ex
      , alu_shamt_in      => alu_shamt_id
      , alu_shamt_out     => alu_shamt_ex

      --For mem
      , branch_en_in      => branch_en_id
      , branch_en_out     => branch_en_ex
      , mem_wen_in        => mem_wen_id
      , mem_wen_out       => mem_wen_ex

      --For writeback
      , mem_to_reg_in     => mem_to_reg_id
      , mem_to_reg_out    => mem_to_reg_ex
      , reg_wen_in        => reg_wen_id
      , reg_wen_out       => reg_wen_ex

			)
		;
	
	--------------- Execution ---------------	
	
	
	execute:
		entity work.execute
		port map
			(  incremented_pc	=> incremented_pc_ex
			, data_1				=> data_1_ex
			, data_2				=> data_2_ex
			, instruction		=> instruction_ex
			, inst_type_I		=> inst_type_I_ex
			, imm_to_alu		=> imm_to_alu_ex
			, alu_funct	    => alu_funct_ex
			, alu_shamt	    => alu_shamt_ex
			, alu_result		=> alu_result_ex
			, alu_zero			=> alu_zero_ex
			, branch_address	=> branch_addr_ex
      , write_reg_dst => write_reg_dst_ex
			)
		;


  
	ex_to_mem_pipe:
		entity work.ex_to_mem_pipe
		port map
			( clk               => clk
			, reset             => reset
			, branch_addr_in    => branch_addr_ex
			, branch_addr_out    => branch_addr_mem
			, zero_in           => alu_zero_ex
			, zero_out          => alu_zero_mem
			, alu_result_in     => alu_result_ex
			, alu_result_out    => alu_result_mem
			, data_2_in         => data_2_ex
			, data_2_out        => dmem_data_out
			, write_reg_dst_in   => write_reg_dst_ex
			, write_reg_dst_out  => write_reg_dst_mem

      --Control signals
      --For mem
      , branch_en_in      => branch_en_ex
      , branch_en_out     => branch_en_mem
      , mem_wen_in        => mem_wen_ex
      , mem_wen_out       => mem_wen_mem

      --For writeback
      , mem_to_reg_in     => mem_to_reg_ex
      , mem_to_reg_out    => mem_to_reg_mem
      , reg_wen_in        => reg_wen_ex
      , reg_wen_out       => reg_wen_mem

			)
		;
		
	--------------- Memory ---------------

  branch_en_if <= branch_en_mem and alu_zero_mem;
  
  dmem_write_enable <= mem_wen_mem;
  dmem_address <= alu_result_mem(7 downto 0);
  
	mem_to_wb_pipe:
		entity work.mem_to_wb_pipe
		port map
			(  clk              => clk
			,  reset            => reset
			,  alu_result_in    => alu_result_mem
			,  alu_result_out   => alu_result_wb
			,  write_reg_dst_in  => write_reg_dst_mem
			,  write_reg_dst_out => write_reg_dst_wb

      --Control signals
      --For writeback
      , mem_to_reg_in     => mem_to_reg_mem
      , mem_to_reg_out    => mem_to_reg_wb
      , reg_wen_in        => reg_wen_mem
      , reg_wen_out       => reg_wen_wb
			)
		;
		
	--------------- Write Back ---------------
  
  --dmem_data_in is already delayed a cycle, so no need to send it through the pipe
	write_data_wb <= dmem_data_in when mem_to_reg_wb = '1'
			        else alu_result_wb;
  
	
end Behavioral;
