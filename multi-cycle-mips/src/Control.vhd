----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:05:19 10/11/2014 
-- Design Name: 
-- Module Name:    Control - Behavioral 
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

entity Control is
	generic (
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 32
	);
    Port ( opcode : in  std_logic_vector(5 downto 0);
           reg_dest : out  STD_LOGIC;
           branch : out  STD_LOGIC;
           mem_to_reg : out  STD_LOGIC;
           alu_op : out  std_logic_vector(3 downto 0);
           mem_write_enable : out  STD_LOGIC;
           alu_src : out  STD_LOGIC;
           reg_write_enable : out  STD_LOGIC;
           jump : out  STD_LOGIC);
end Control;

architecture Behavioral of Control is

begin


end Behavioral;

