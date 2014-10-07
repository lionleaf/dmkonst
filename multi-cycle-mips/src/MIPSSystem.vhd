-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- MIPSSystem.vhd
-- The MIPS processor system to be used in Exercise 1 and 2 during FPGA
-- testing. The system consists of a MIPSProcessor, two memories
-- and a HostComm module that can be used for controlling the processor
-- state or reading/writing the memories. The hostcomm utility (delivered
-- as part of the exercise) can be used from a host computer for this purpose.
-- Make sure you have thoroughly tested your solution with testbenches
-- (including tb_MIPSProcessor.vhd) before attempting FPGA test.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MIPSSystem is
	-- do not change these, the memories are pregenerated at the moment
	-- and do not support changing the address width/word size
	generic (
		ADDR_WIDTH : integer := 8;	
		DATA_WIDTH : integer := 32
	);
	port ( 
		clk, reset : in  STD_LOGIC;
		-- interface towards the UART ports
		UART_Rx : in  STD_LOGIC;
		UART_Tx : out  STD_LOGIC;
		-- LED output
		leds : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end MIPSSystem;

architecture Behavioral of MIPSSystem is
	-- signals for processor control
	signal processorEnable 	: std_logic;
	signal processorReset 	: std_logic;
	
	-- signals for instruction memory, processor port (read only!)
	signal procIMemReadData			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal procIMemAddr				: std_logic_vector(ADDR_WIDTH-1 downto 0);
	-- signals for data memory, processor port
	signal procDMemWriteEnable 	: std_logic;
	signal procDMemWriteData		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal procDMemReadData			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal procDMemAddr				: std_logic_vector(ADDR_WIDTH-1 downto 0);
	
	-- signals for instruction memory, hostcomm port
	signal hcIMemWriteEnable 	: std_logic;
	signal hcIMemWriteData		: std_logic_vector(7 downto 0);
	signal hcIMemReadData		: std_logic_vector(7 downto 0);
	signal hcIMemAddr				: std_logic_vector(9 downto 0);
	-- signals for data memory, hostcomm port
	signal hcDMemWriteEnable 	: std_logic;
	signal hcDMemWriteData		: std_logic_vector(7 downto 0);
	signal hcDMemReadData		: std_logic_vector(7 downto 0);
	signal hcDMemAddr				: std_logic_vector(9 downto 0);
	
	
begin
-- instantiate the processor
MIPSProcInst:	entity work.MIPSProcessor(Behavioral) 
					generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH) 
					port map (
						clk => clk, reset => processorReset,
						processor_enable	=> processorEnable,
						-- instruction memory connection
						imem_data_in		=> procIMemReadData,		-- instruction data from memory
						imem_address		=> procIMemAddr,			-- instruction address to memory
						-- data memory connection
						dmem_data_in		=> procDMemReadData,		-- read data from memory
						dmem_address		=> procDMemAddr,			-- address to memory
						dmem_data_out		=> procDMemWriteData,	-- write data to memory
						dmem_write_enable	=> procDMemWriteEnable	-- write enable to memory
					);

-- instantiate the host communication module
HostCommInst: 	entity work.HostComm port map (
						clk => clk, reset => reset,
						UART_Rx => UART_Rx, UART_Tx => UART_Tx,
						proc_en => processorEnable, proc_rst => processorReset,
						-- instruction memory connection
						imem_data_in => hcIMemReadData, imem_data_out => hcIMemWriteData,
						imem_wr_en => hcIMemWriteEnable, imem_addr => hcIMemAddr,
						-- data memory connection
						dmem_data_in => hcDMemReadData, dmem_data_out => hcDMemWriteData,
						dmem_wr_en => hcDMemWriteEnable, dmem_addr => hcDMemAddr
					);

-- instantiate the instruction memory
InstrMem:		entity work.DualPortMem port map (
						clka => clk, clkb => clk,
						-- port A: processor connection, read only
						wea(0) => '0', 
						dina => x"00000000",
						addra => procIMemAddr, douta => procIMemReadData,
						-- port B: hostcomm connection, read+write
						web(0) => hcIMemWriteEnable, addrb => hcIMemAddr, 
						dinb => hcIMemWriteData, doutb => hcIMemReadData
					);
 
 -- instantiate the data memory
DataMem:			entity work.DualPortMem port map (
						clka => clk, clkb => clk,
						-- port A: processor connection, read+write
						wea(0) => procDMemWriteEnable, dina => procDMemWriteData,
						addra => procDMemAddr, douta =>procDMemReadData,
						-- port B: hostcomm connection, read+write
						web(0) => hcDMemWriteEnable, addrb => hcDMemAddr, 
						dinb => hcDMemWriteData, doutb => hcDMemReadData
					);
	
	-- drive the LEDs
	leds(3 downto 0) <= "1010";

end Behavioral;

