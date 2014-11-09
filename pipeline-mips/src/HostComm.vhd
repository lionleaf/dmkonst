-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- HostComm.vhd
-- A module which wraps some registers, address mapping logic and 
-- a UART-to-register control interface to control TDT4255 exercises.
-- This particular variant is to be used for exercises 1 and 2, and
-- contains the following registers:

-- * Magic word (for identification) at address 0x4000. Always returns 0xCAFEC0DE.
-- * Processor enable register (1-bit) at address 0x0000
-- * Processor reset register (1-bit) at address 0x0001
		
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HostComm is
	port ( 
		clk, reset : in  std_logic;
		-- interface towards the UART ports
		UART_Rx : in  std_logic;
		UART_Tx : out  std_logic;
		-- interface towards the processor
		proc_en, proc_rst : out std_logic;
		-- interface towards the instruction memory
		imem_data_in : in std_logic_vector(7 downto 0);
		imem_data_out : out std_logic_vector(7 downto 0);
		imem_addr : out std_logic_vector(9 downto 0);
		imem_wr_en : out std_logic;
		-- interface towards the data memory
		dmem_data_in : in std_logic_vector(7 downto 0);
		dmem_data_out : out std_logic_vector(7 downto 0);
		dmem_addr : out std_logic_vector(9 downto 0);
		dmem_wr_en : out std_logic
	);
end HostComm;

architecture Behavioral of HostComm is
	constant TDT4255_EX1_MAGIC : std_logic_vector(31 downto 0) := x"CAFEC0DE";
	-- addresses for status/control registers
	constant REG_ADDR_PROC_EN : std_logic_vector(15 downto 0) := x"0000";
	constant REG_ADDR_PROC_RESET : std_logic_vector(15 downto 0) := x"0001";
	-- addresses for the magic ID register
	constant REG_ADDR_MAGIC0 : std_logic_vector(15 downto 0) := x"4000";
	constant REG_ADDR_MAGIC1 : std_logic_vector(15 downto 0) := x"4001";
	constant REG_ADDR_MAGIC2 : std_logic_vector(15 downto 0) := x"4002";
	constant REG_ADDR_MAGIC3 : std_logic_vector(15 downto 0) := x"4003";
	
	-- UART register control interface signals
	signal regReadData, regWriteData : std_logic_vector(7 downto 0);
	signal regAddress : std_logic_vector(15 downto 0);
	signal regReadEnable, regWriteEnable : std_logic;
	
	-- control/status registers
	signal procResetSignal, procEnableSignal : std_logic;
begin
-- instantiate the UART register controller
UARTHandlerInst: 	entity work.uart2BusTop
						-- 16 bits address width (for register addressing over UART)
						generic map (AW => 16)
						port map (
							clr => reset, clk => clk, serIn => UART_Rx, serOut => UART_Tx,
							intAccessGnt => '1', intRdData => regReadData, intWrData => regWriteData,
							intAddress => regAddress, intWrite => regWriteEnable, intRead => regReadEnable
						);
						
	-- register read mux
	regReadData <=	dmem_data_in when regAddress(15 downto 14) = "10" else
						imem_data_in when regAddress(15 downto 14) = "11" else
						"0000000" & procEnableSignal when regAddress = REG_ADDR_PROC_EN else
						"0000000" & procResetSignal when regAddress = REG_ADDR_PROC_RESET else
						TDT4255_EX1_MAGIC(31 downto 24) when regAddress = REG_ADDR_MAGIC0 else
						TDT4255_EX1_MAGIC(23 downto 16) when regAddress = REG_ADDR_MAGIC1 else
						TDT4255_EX1_MAGIC(15 downto 8) when regAddress = REG_ADDR_MAGIC2 else
						TDT4255_EX1_MAGIC(7 downto 0) when regAddress = REG_ADDR_MAGIC3 else
						x"00";

	
	-- instruction memory connections
	imem_wr_en <= regWriteEnable and (regAddress(15) and regAddress(14)) and (not procEnableSignal);
	imem_addr <= regAddress(9 downto 0);
	imem_data_out <= regWriteData;
	
	-- data memory connections
	dmem_wr_en <= regWriteEnable and (regAddress(15) and (not regAddress(14))) and (not procEnableSignal);
	dmem_addr <= regAddress(9 downto 0);
	dmem_data_out <= regWriteData;
	
	
	ControlRegs: process(clk, reset)
	begin
		if reset = '1' then
			procResetSignal <= '0';
			procEnableSignal <= '0';
		elsif rising_edge(clk) then
			-- implement the enable signal ctrl register
			if regWriteEnable = '1' and regAddress = REG_ADDR_PROC_EN then
				procEnableSignal <= regWriteData(0);
			end if;
			-- implement the reset signal ctrl register
			if regWriteEnable = '1' and regAddress = REG_ADDR_PROC_RESET then
				procResetSignal <= regWriteData(0);
			end if;
		end if;
	end process;
	proc_rst <= procResetSignal;
	proc_en <= procEnableSignal;
	
	
end Behavioral;


