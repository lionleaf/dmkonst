----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:27:38 09/01/2014 
-- Design Name: 
-- Module Name:    tutorial - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tutorial is
    Port ( A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           C : in  STD_LOGIC;
           X : out  STD_LOGIC;
           Y : out  STD_LOGIC;
           Z : out  STD_LOGIC;
			  clk, reset : in std_logic
	);
end tutorial;

architecture Behavioral of tutorial is
	signal temp1, temp2 : std_logic;
begin
	BlinquayInst: entity work.blinquay
	--generic map (ticksBeforeLevelChange => 100, ticksForPeriod => 200)
	port map (clk => clk, reset => reset, pulse => x);
	DriveInternalSignals: process(B, C) is
	begin
		temp1 <= B or C;
		temp2 <= B xor C;
	end process DriveInternalSignals;
	
	Y <= temp1;
	Z <= temp1 when A = '1' else temp2;
end Behavioral;

