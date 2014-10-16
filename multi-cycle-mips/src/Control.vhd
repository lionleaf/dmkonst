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
    type state_t is (disabled, first_fetch, fetch, execute, stall);  --type of state machine.
    signal state: state_t;
begin

process (clk)
begin

    
    if rising_edge(clk) then
        case state is
            when disabled =>
                state <= first_fetch;
            when first_fetch =>
                state <= execute;
            when fetch =>
                state <= execute;
            when execute =>
                if opcode = "100011" or opcode = "101011" then
                    state <= stall;
                else 
                    state <= fetch;
                end if;
            when stall =>
                state <= fetch;
        end case;
        
        if reset = '1' then
            state <= disabled;
        end if;
        
        if processor_enable = '0' then
            state <= disabled;
        end if;
    end if;
end process;


process (state)
begin
    case state IS
        when disabled =>
            update_pc <= '0';
            write_enable <= '0';
        when first_fetch =>
            update_pc <= '0';
            write_enable <= '0';
        when fetch =>
            update_pc <= '1';
            write_enable <= '0';
        when execute =>
            update_pc <= '0';
            write_enable <= '1';
        when stall =>
            update_pc <= '0';
            write_enable <= '1';
    end case;
end process;
 

end Behavioral;
