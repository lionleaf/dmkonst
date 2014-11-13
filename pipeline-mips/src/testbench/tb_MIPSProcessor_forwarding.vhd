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
 
ENTITY tb_MIPSProcessor_forwarding IS
END tb_MIPSProcessor_forwarding;
 
ARCHITECTURE behavior OF tb_MIPSProcessor_forwarding IS
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
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
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
			constant TEST_INSTRS : integer := 44;
			type InstrData is array (0 to TEST_INSTRS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
			variable TestInstrData : InstrData := (
X"8c010000", -- lw $1 0($0)    -- Load 1 in to $1 from memory addr 0.
X"00000000", -- nop            -- Empty pipeline.
X"00000000", -- nop
X"00000000", -- nop
X"00000000", -- nop

                               -- Test simple forwarding rt from memory:
X"00201020", -- add $2 $1 $0
X"ac020004", -- sw $2 4($0)    -- Expect: 1 on addr 4

                               -- Test simple forwarding rt from writeback:
X"00201020", -- add $2 $1 $0
X"00000000", -- nop            -- Let the data propagate to writeback.
X"ac020005", -- sw $2 5($0)    -- Expect: 1 on addr 5


                               -- Test simple forwarding rs from memory:
X"00011020", -- add $2 $0 $1
X"00411020", -- add $2 $2 $1
X"00000000", -- nop            -- We are not testing rt - let it go back to the register.
X"00000000", -- nop
X"00000000", -- nop
X"00000000", -- nop
X"ac020006", -- sw $2 6($0)    -- Expect: 2 on addr 6

                               -- Test simple forwarding rs from writeback:
X"00011020", -- add $2 $0 $1
X"00000000", -- nop            -- Let the data propagate to writeback.
X"00411020", -- add $2 $2 $1
X"00000000", -- nop            -- We are not testing rt-forwarding - let the data go back to the register.
X"00000000", -- nop
X"00000000", -- nop
X"00000000", -- nop
X"ac020007", -- sw $2 7($0)    -- Expect: 2 on addr 7



                               -- Test accumulation rt:
X"00201020", -- add $2 $1 $0
X"00221020", -- add $2 $1 $2
X"00221020", -- add $2 $1 $2
X"00221020", -- add $2 $1 $2
X"00221020", -- add $2 $1 $2
X"ac020008", -- sw $2 8($0)    -- Expect: 5 on addr 8


                               -- Test accumulation rs:
X"00011020", -- add $2 $0 $1
X"00411020", -- add $2 $2 $1
X"00411020", -- add $2 $2 $1
X"00411020", -- add $2 $2 $1
X"00411020", -- add $2 $2 $1
X"00000000", -- nop            -- We are not testing rt-forwarding - let the data go back to the register.
X"00000000", -- nop
X"00000000", -- nop
X"00000000", -- nop
X"ac020009", -- sw $2 9($0)    -- Expect: 5 on addr 9

                               -- Test load nop store:
X"8c020000", -- lw $2 0($0)    -- Load 1 to $2
X"00000000", -- nop
X"ac02000a"  -- sw $2 10($0)
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
			WriteDataWord(x"00000001", 0);
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
			CheckDataWord(x"00000001", 4);
			CheckDataWord(x"00000001", 5);
			CheckDataWord(x"00000002", 6);
			CheckDataWord(x"00060002", 7);
			CheckDataWord(x"00060005", 8);
			CheckDataWord(x"00000005", 9);
			CheckDataWord(x"00000001", 10);
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
