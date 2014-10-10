----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:43:12 10/10/2014 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
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

entity Registers is
	generic (
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 32
	);
    Port ( readReg1 : in  STD_LOGIC_VECTOR (4 downto 0);
           readReg2 : in  STD_LOGIC_VECTOR (4 downto 0);
           writeReg : in  STD_LOGIC_VECTOR (4 downto 0);
           writeData : in  STD_LOGIC_VECTOR (31 downto 0);
           regWrite : in  STD_LOGIC;
           readData1 : out  STD_LOGIC_VECTOR (31 downto 0);
           readData2 : out  STD_LOGIC_VECTOR (31 downto 0));
end Registers;

architecture Behavioral of Registers is

begin


end Behavioral;

