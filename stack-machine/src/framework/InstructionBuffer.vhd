		
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionBuffer is
	port ( 
		clk, reset : in  std_logic;
		-- interface towards the UART ports
		UART_Rx : in  std_logic;
		UART_Tx : out  std_logic;
		-- interface towards the RPNC
		rpnc_reset : out std_logic;
		empty : out  std_logic;
		read_en : in  std_logic;
		instr_data : out  std_logic_vector(15 downto 0);
		stack_top : in std_logic_vector(7 downto 0)
	);
end InstructionBuffer;

architecture Behavioral of InstructionBuffer is
	constant TDT4255_MAGIC : std_logic_vector(31 downto 0) := x"C0DECAFE";
	-- addresses for status/control registers
	constant REG_ADDR_STACK_TOP : std_logic_vector(15 downto 0) := x"0000";
	constant REG_ADDR_INSTRS_LEFT : std_logic_vector(15 downto 0) := x"0001";
	constant REG_ADDR_FIFO_PTR : std_logic_vector(15 downto 0) := x"0002";
	constant REG_ADDR_RPNC_RESET : std_logic_vector(15 downto 0) := x"0003";
	-- addresses for the magic ID register
	constant REG_ADDR_MAGIC0 : std_logic_vector(15 downto 0) := x"4000";
	constant REG_ADDR_MAGIC1 : std_logic_vector(15 downto 0) := x"4001";
	constant REG_ADDR_MAGIC2 : std_logic_vector(15 downto 0) := x"4002";
	constant REG_ADDR_MAGIC3 : std_logic_vector(15 downto 0) := x"4003";

	signal regReadData, regWriteData : std_logic_vector(7 downto 0);
	signal regAddress : std_logic_vector(15 downto 0);
	signal regReadEnable, regWriteEnable : std_logic;
	
	-- RPN data memory signals for writing
	signal dataMemWriteAddr : std_logic_vector(9 downto 0);
	signal dataMemWriteData : std_logic_vector(7 downto 0);
	signal dataMemWriteEn : std_logic;
	
	-- RPN data memory signals for reading
	signal dataMemReadAddr : std_logic_vector(8 downto 0);
	signal dataMemReadData : std_logic_vector(15 downto 0);
	
	-- control/status registers
	signal remainingInstructions : unsigned(7 downto 0);
	signal currentReadAddr : unsigned(7 downto 0);
	signal RPNCResetSignal : std_logic;
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

-- instantiate the data memory for storing RPN data
RPNDataMemInst:	entity work.RPNDataMem port map (
							clka => clk, clkb => clk, 
							-- data mem write port
							wea(0) => dataMemWriteEn, addra => dataMemWriteAddr, dina => dataMemWriteData,
							-- data mem read port
							addrb => dataMemReadAddr, doutb => dataMemReadData
						);
						
	-- register read mux
	regReadData <=	std_logic_vector(remainingInstructions) when regAddress = REG_ADDR_INSTRS_LEFT else
						stack_top when regAddress = REG_ADDR_STACK_TOP else
						std_logic_vector(currentReadAddr(7 downto 0)) when regAddress = REG_ADDR_FIFO_PTR else
						dataMemReadData(7 downto 0) when regAddress(15) = '1' and regAddress(0)='0' else
						dataMemReadData(15 downto 8) when regAddress(15) = '1'  and regAddress(0)='1' else
						TDT4255_MAGIC(31 downto 24) when regAddress = REG_ADDR_MAGIC0 else
						TDT4255_MAGIC(23 downto 16) when regAddress = REG_ADDR_MAGIC1 else
						TDT4255_MAGIC(15 downto 8) when regAddress = REG_ADDR_MAGIC2 else
						TDT4255_MAGIC(7 downto 0) when regAddress = REG_ADDR_MAGIC3 else
						x"00";

						
	-- connect UART register controller to RPN memory
	dataMemWriteEn <= regAddress(15) and regWriteEnable;
	dataMemWriteData <= regWriteData;
	dataMemWriteAddr <= regAddress(9 downto 0);
	
	-- connect mem data output
	instr_data <= dataMemReadData;
	
	
	ControlRegs: process(clk, reset)
	begin
		if reset = '1' then
			remainingInstructions <= (others => '0');
			RPNCResetSignal <= '0';
		elsif rising_edge(clk) then
			-- implement the remaining instruction counter:
			-- decrement by 1 every time read_en is high
			if regWriteEnable = '1' and regAddress = REG_ADDR_INSTRS_LEFT then
				remainingInstructions <= unsigned(regWriteData);
			elsif read_en = '1' then
				remainingInstructions <= remainingInstructions - 1;
			end if;
			-- implement the RPNC reset signal ctrl register
			if regWriteEnable = '1' and regAddress = REG_ADDR_RPNC_RESET then
				RPNCResetSignal <= regWriteData(0);
			end if;
		end if;
	end process;
	rpnc_reset <= RPNCResetSignal;
	
	-- emulate a FIFO using block RAM
	-- * use 'remainingInstructions' as FIFO elem counter
	-- * increment read address by one after each read
	-- * set empty signal when no more instructions left
	empty <= '1' when remainingInstructions = "00"
				else '0';
	NextAddressReg: process(clk, reset)
	begin
		if reset = '1' then
			currentReadAddr <= (others => '0');
		elsif rising_edge(clk) then
			if regWriteEnable = '1' and regAddress = REG_ADDR_FIFO_PTR then
				currentReadAddr <= unsigned(regWriteData);
			elsif read_en = '1' then
				currentReadAddr <= currentReadAddr + 1;
			end if;
		end if;
	end process;
	
	-- connect BRAM read address input to currentReadAddr register or reg ctrl interface
	-- need to "prefetch" the next word when read_en='1' since RPNC expects the data on the next
	-- clock cycle read_en is set high
	dataMemReadAddr <=	'0' & std_logic_vector(currentReadAddr + 1) when read_en='1' and regReadEnable='0' else
								'0' & std_logic_vector(currentReadAddr) when read_en='0' and regReadEnable='0' else
								regAddress(9 downto 1);
								-- r/w ports of the BRAM have different sizes and addressing
								-- clip off lowest bit of reg address for BRAM read
end Behavioral;


