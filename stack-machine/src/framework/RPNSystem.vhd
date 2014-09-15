library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RPNSystem is
    port ( 
		clk, reset : in  STD_LOGIC;
		-- interface towards the UART ports
		UART_Rx : in  STD_LOGIC;
		UART_Tx : out  STD_LOGIC;
		-- LED output
		leds : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end RPNSystem;

architecture Behavioral of RPNSystem is
	signal emptySignal, readEnableSignal, RPNCResetSignal, RPNCIdleSignal : std_logic;
	signal instrDataSignal : std_logic_vector(15 downto 0);
	signal stackTopSignal : std_logic_vector(7 downto 0);
begin

RPNC:		    entity work.stack_machine 
            generic map (size => 256)
            port map (
							clk => clk, rst => RPNCResetSignal, 
							empty => emptySignal, read_instruction => readEnableSignal,
							instruction => instrDataSignal, stack_top => stackTopSignal
						);
						
InstrBufferInst: 	entity work.InstructionBuffer port map (
							clk => clk, reset => reset,
							UART_Rx => UART_Rx, UART_Tx => UART_Tx,
							empty => emptySignal, read_en => readEnableSignal, 
							instr_data => instrDataSignal, stack_top => stackTopSignal,
							rpnc_reset => RPNCResetSignal
						);

	-- drive the LEDs
	leds(3) <= emptySignal;
	leds(2 downto 0) <= "000";

end Behavioral;

