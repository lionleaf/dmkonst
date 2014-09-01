----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:11:19 09/01/2014 
-- Design Name: 
-- Module Name:    blinquay - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blinquay is
	generic (
		ticksBeforeLevelChange : integer := 24000000;
		ticksForPeriod : integer := 48000000
	);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           pulse : out  STD_LOGIC);
end blinquay;

architecture Behavioral of blinquay is
	signal tickCount : unsigned(31 downto 0);
begin
	CountPeriodTicks: process(clk, reset)
	begin
		if reset = '1' then 
			tickCount <= (others => '0');
		elsif rising_edge(clk) then
			if tickCount < ticksForPeriod then
				tickCount <= tickCount + 1;
			else
				tickCount <= (others => '0');
			end if;
		end if;
	end process;
	pulse <= '0' when tickCount < ticksBeforeLevelChange
		           else '1';
end Behavioral;