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
    Port ( 
		clk, reset  : in std_logic;
		opcode      : in  std_logic_vector(5 downto 0);
      reg_dest      : out  std_logic;
      branch        : out  std_logic;
      mem_to_reg    : out  std_logic;
      alu_op        : out  std_logic;
      mem_write_enable : out  std_logic;
      alu_src       : out  std_logic;
      reg_write_enable : out  std_logic;
      jump          : out  std_logic);
end control;

architecture Behavioral of Control is

begin


end Behavioral;

