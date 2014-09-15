-- Testbench for instantiating and testing the RPNSystem, including the UART control interface
-- Useful for debugging register control system - instruction buffer - RPNC interactions
-- each register read/write command with UARTSendCmd takes approximately 1 ms to send

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_arith.all;

 
ENTITY tb_top IS
END tb_top;
 
ARCHITECTURE behavior OF tb_top IS 
 
    constant c_BIT_PERIOD : time := 8680 ns;
   
  procedure UARTSendChar (
    i_data_in       : in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
  begin
 
    o_serial <= '0';
    wait for c_BIT_PERIOD;
 
    -- Send Data Byte
    for ii in 0 to 7 loop
      o_serial <= i_data_in(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii
 
    -- Send Stop Bit
    o_serial <= '1';
    wait for c_BIT_PERIOD;
  end UARTSendChar;
  
  procedure UARTSendString( str : in string; signal o_serial : out std_logic) is
  begin
		for i in 1 to str'high loop
			UARTSendChar( conv_std_logic_vector(character'pos(str(i)),8), o_serial);
		end loop;
  end UARTSendString;
  
  procedure UARTSendCmd( str : in string; signal o_serial : out std_logic) is
  begin
		UARTSendString(str, o_serial);
		UARTSendChar(x"0A", o_serial);
  end UARTSendCmd;

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal UART_Rx : std_logic := '0';

 	--Outputs
   signal UART_Tx : std_logic;
   signal leds : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 42 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.RPNSystem PORT MAP (
          clk => clk,
          reset => reset,
          UART_Rx => UART_Rx,
          UART_Tx => UART_Tx,
          leds => leds
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';

      wait for clk_period*10;

      -- reset sequence
		UARTSendCmd("w 01 0003", UART_Rx);
		UARTSendCmd("w 00 0003", UART_Rx);
		UARTSendCmd("w ff 0002", UART_Rx);
		-- RPN instructions: 1 2 +
		UARTSendCmd("w 01 8000", UART_Rx);
		UARTSendCmd("w 00 8001", UART_Rx);
		UARTSendCmd("w 02 8002", UART_Rx);
		UARTSendCmd("w 00 8003", UART_Rx);
		UARTSendCmd("w 00 8004", UART_Rx);
		UARTSendCmd("w 01 8005", UART_Rx);
		-- run 1 instruction at a time
		UARTSendCmd("w 01 0001", UART_Rx);
		UARTSendCmd("w 01 0001", UART_Rx);
		UARTSendCmd("w 01 0001", UART_Rx);
	
      wait;
   end process;

END;
