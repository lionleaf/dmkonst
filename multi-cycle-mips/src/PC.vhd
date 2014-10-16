----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:24:52 10/13/2014 
-- Design Name: 
-- Module Name:    PC - Behavioral 
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

entity PC is
	generic (
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 32
	);
    Port ( reset : in  std_logic;
           update_pc : in std_logic;
           clk : in std_logic;
           next_pc : in  std_logic_vector (ADDR_WIDTH - 1 downto 0);
           current_pc : out  std_logic_vector (ADDR_WIDTH - 1 downto 0));
end PC;

architecture Behavioral of PC is
begin

process (reset, clk, update_pc)
begin
    if (reset = '1') then
        current_PC <= (others => '0');
    elsif falling_edge(clk) and update_pc = '1' then
        current_PC <= next_PC;
    end if;
end process;

end Behavioral;

