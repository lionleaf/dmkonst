-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- tb_MIPSProcessor.vhd
-- Testbench for the MIPSProcessor component
-- Instantiates data and instruction memory, fills them with some
-- test data, enables the processor, then checks the data memory
-- to see if the expected values have been written.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_data_hazzard_detection IS
END tb_data_hazzard_detection;
 
ARCHITECTURE behavior OF tb_data_hazzard_detection IS
	constant ADDR_WIDTH : integer := 8;
	constant DATA_WIDTH : integer := 32;
	
	--Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal processor_enable : std_logic := '0';
   signal imem_data_in : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal dmem_data_in : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

 	--multiplexed memory outputs
   signal imem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
   signal dmem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
   signal dmem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal dmem_write_enable : std_logic_vector(0 downto 0) := (others => '0');
	
	-- driven only from processor
	signal proc_imem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal proc_dmem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal proc_dmem_write_enable : std_logic_vector(0 downto 0) := (others => '0');
	signal proc_dmem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	
	-- driven only from testbench
	signal imem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal imem_write_enable : std_logic_vector(0 downto 0) := (others => '0');
	signal tb_imem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal tb_dmem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal tb_dmem_write_enable : std_logic_vector(0 downto 0) := (others => '0');
	signal tb_dmem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns; 
BEGIN
-- Instantiate the processor
Processor: entity work.processor(Behavioral) port map (
						clk => clk,	reset => reset,
						processor_enable => processor_enable,
						imem_data_in => imem_data_in,
						imem_address => proc_imem_address,
						dmem_data_in => dmem_data_in,
						dmem_address => proc_dmem_address,
						dmem_data_out => proc_dmem_data_out,
						dmem_write_enable => proc_dmem_write_enable(0)
					);
		  
-- instantiate the instruction memory
InstrMem:		entity work.DualPortMem port map (
						clka => clk, clkb => clk,
						wea => imem_write_enable, 
						dina => imem_data_out,
						addra => imem_address, douta => imem_data_in,
						-- plug unused memory port
						web => "0", dinb => x"00", addrb => "0000000000"
					);
 
 -- instantiate the data memory
DataMem:			entity work.DualPortMem port map (
						clka => clk, clkb => clk,
						wea => dmem_write_enable, dina => dmem_data_out,
						addra => dmem_address, douta => dmem_data_in,
						-- plug unused memory port
						web => "0", dinb => x"00", addrb => "0000000000"
					);		  

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	imem_address <= proc_imem_address when processor_enable = '1' else tb_imem_address;
	dmem_address <= proc_dmem_address when processor_enable = '1' else tb_dmem_address;
	dmem_data_out <= proc_dmem_data_out when processor_enable = '1' else tb_dmem_data_out;
	dmem_write_enable <= proc_dmem_write_enable when processor_enable = '1' else tb_dmem_write_enable;
 

   -- Stimulus process
   stim_proc: process
		-- helper procedures for filling instruction memory
	 	procedure WriteInstructionWord(
			instruction : in std_logic_vector(DATA_WIDTH-1 downto 0);
			address : in unsigned(ADDR_WIDTH-1 downto 0)) is
		begin
			tb_imem_address <= std_logic_vector(address);
			imem_data_out <= instruction;
			imem_write_enable <= "1";
			wait until rising_edge(clk);
			imem_write_enable <= "0";
		end WriteInstructionWord;
		
		procedure FillInstructionMemory is
			constant TEST_INSTRS : integer := 27;
			type InstrData is array (0 to TEST_INSTRS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
			variable TestInstrData : InstrData := 
				( X"8C010001" --lw $1, 1($0)		/$1 =  2	
				
				, X"3c01f0f0" -- lui $1, 0xF0F0
				, X"3c0200ff" -- lui $2, 0x00FF
				, X"8c030014" -- lw $3 20($0)
				, X"00221824" -- and $3 $1 $2
				, X"ac030001" -- sw $3 1($0) -- This should result in 0x00F0
				
				, X"8c030001" -- lw $3 1($0) 
				, X"00221825" -- or $3 $1 $2
				, X"ac030002" -- sw $3 2($0) -- Should be 0x0F0FF
				
				, X"3c0100f0" -- lui $1 0x00F0
				, X"8c030002" -- lw $3 2($0)
				, X"00221820" -- add $3 $1 $2
				, X"ac030003" -- sw $3 3($0) -- Should be 0x01D0
				
				, X"8c030003" -- lw $3 3($0)
				, X"00221822" -- subb $3 $1 $2
				, X"ac030004" -- sw $3 4($0) -- Should be 0x0010				
				);
                constant n_noops : integer := 5;
		begin
			for i in 0 to TEST_INSTRS-1 loop
				WriteInstructionWord(TestInstrData(i), to_unsigned(i*(n_noops), ADDR_WIDTH));
        for j in 1 to n_noops - 1 loop
            WriteInstructionWord(X"00000000", to_unsigned(i*(n_noops)+j, ADDR_WIDTH));
        end loop;
			end loop;
		end FillInstructionMemory;
		
		
		
	
	
		
   begin
      -- hold reset state for 100 ns
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
		
		processor_enable <= '1';
		-- fill instruction and data mems with test data
		FillInstructionMemory;
	

      
		

      wait;
   end process;

END;
