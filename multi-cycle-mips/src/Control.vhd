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
use work.defs.all;

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
		clk, reset      : in   std_logic;
        processor_enable: in   std_logic;
		opcode          : in   std_logic_vector(5 downto 0);
        update_pc       : out  std_logic;
        write_enable    : out  std_logic
    );
end control;

architecture Behavioral of Control is
    type state_t is (initial_state, first_fetch, fetch, execute, stall, error_s);  --type of state machine.
    signal current_s, next_s: state_t;
begin

process (clk,reset, processor_enable)
begin
 if (reset='1' or processor_enable = '0') then
  current_s <= initial_state;  --default state on reset.
elsif (rising_edge(clk)) then
  current_s <= next_s;   --state change.
end if;
end process;

process (current_s, opcode)
begin
     update_pc <= '0';
    write_enable <= '0';

    case current_s is
    when initial_state =>
        next_s <= first_fetch;
    when first_fetch =>
        next_s <= execute;
    when fetch =>
        next_s <= execute;
        update_pc <= '1';
    when execute =>
        write_enable <= '1';
        --If lw or sw stall one cycle
        if opcode = "100011" or opcode = "101011" then
           next_s <= stall;
        else
            next_s <= fetch;
        end if; 
    when stall =>
        if(processor_enable = '1') then
            next_s <= fetch;
        else
            next_s <= stall;
        end if;
    when error_s =>
        --Do not proceed. Light LED
    end case;
 end process;

end Behavioral;
