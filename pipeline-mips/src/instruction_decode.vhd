library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity instruction_decode is
	port
		(	clk				: std_logic
		;	reset				: std_logic
		;	write_data		: std_logic_vector (31 downto 0)
		;	instructions	: std_logic_vector (31 downto 0)
		;	write_register	: std_logic_vector (4 downto 0)
		;	data_1			: std_logic_vector (31 downto 0)
		;	data_2			: std_logic_vector (31 downto 0)
		)
	;
end instruction_decode;

architecture Behavioral of instruction_decode is

begin


end Behavioral;

