-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- tb_hazard_detection.vhd
-- Testbench for the MIPSProcessor component
-- Instantiates data and instruction memory, fills them with some
-- test data, enables the processor, then checks the data memory
-- to see if the expected values have been written.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_hazard_detection IS
END tb_hazard_detection;
 
ARCHITECTURE behavior OF tb_hazard_detection IS
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
			constant TEST_INSTRS : integer := 19;
			type InstrData is array (0 to TEST_INSTRS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
			variable TestInstrData : InstrData := (
              X"8c040002", --lw $4 2($0)  /$4 = 5
              X"00000000", --noop
              X"00000000", --noop
              X"00000000", --noop
              X"00000000", --noop
              
              --- TEST 1 lw then add----
              X"00800820", --add $1 $4 $0  /$1 = 5
              X"00000000", --noop
              X"00000000", --noop
              X"8c010001", --lw $1 1($0)   /$1 = 10
              X"00201020", --add $2 $1 $0  /$2 = 10 or 5 if hazard detection did not work
              X"00000000", --noop
              X"00000000", --noop
              X"00000000", --noop
              X"ac02000a", --sw $2 10($0)  / Store 10 to 10   (stores 5 if the unit fails)
              
              ----TEST 2------
              X"00800820", --add $1 $4 $0
              X"00000000", --noop
              X"00000000", --noop
              X"8c010001", --lw $1 1($0)
              X"ac01000b"  --sw $1 11($0)   / Store 10 to 11   (stores 5 if the unit fails)
				);
		begin
			for i in 0 to TEST_INSTRS-1 loop
				WriteInstructionWord(TestInstrData(i), to_unsigned(i, ADDR_WIDTH));
			end loop;
		end FillInstructionMemory;
		
		-- helper procedures for filling data memory
	 	procedure WriteDataWord(
			data : in std_logic_vector(DATA_WIDTH-1 downto 0);
			address : in integer) is
		begin
			tb_dmem_address <= std_logic_vector(to_unsigned(address, ADDR_WIDTH));
			tb_dmem_data_out <= data;
			tb_dmem_write_enable <= "1";
			wait until rising_edge(clk);
			tb_dmem_write_enable <= "0";
		end WriteDataWord;
		
		procedure FillDataMemory is
		begin
			WriteDataWord(x"00000005", 2);
			WriteDataWord(x"0000000A", 1);
		end FillDataMemory;
		
		-- helper procedures for checking the contents of data memory after
		-- the processor has finished executing the tests
		procedure CheckDataWord(
			data : in std_logic_vector(DATA_WIDTH-1 downto 0);
			address : in integer) is
		begin
			
			tb_dmem_address <= std_logic_vector(to_unsigned(address, ADDR_WIDTH));
			tb_dmem_write_enable <= "0";
			wait until rising_edge(clk);
			wait for 0.5 * clk_period;
			assert data = dmem_data_in report "Expected data not found at datamem addr " 
													& integer'image(address) & " found = " 
													& integer'image(to_integer(unsigned(dmem_data_in))) 
													& " expected " 
													& integer'image(to_integer(unsigned(data)))
													severity note;
			assert data /= dmem_data_in report "Expected data found at datamem addr " & integer'image(address) severity note;
		end CheckDataWord;
		
		procedure CheckDataMemory is
		begin
			wait until processor_enable = '0';
			-- expected data memory contents, derived from program behavior
			CheckDataWord(x"0000000A", 10);
			CheckDataWord(x"0000000A", 11);
		end CheckDataMemory;
		
   begin
      -- hold reset state for 100 ns
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
		
		processor_enable <= '0';
		-- fill instruction and data mems with test data
		FillInstructionMemory;
		FillDataMemory;

      wait for clk_period*10;

      -- enable the processor
		processor_enable <= '1';
		-- execute for 200 cycles and stop
		wait for clk_period*200;
		
		processor_enable <= '0';
		
		-- check the results
		CheckDataMemory;

      wait;
   end process;

END;
