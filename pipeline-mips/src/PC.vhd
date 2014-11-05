library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity PC is
    generic
        ( ADDR_WIDTH : integer := 8
        ; DATA_WIDTH : integer := 32
        );
    port
        ( reset             : in        std_logic
        ; clk               : in        std_logic
        ; pc_source         : in        std_logic   
        ; branch_addr       : in        addr_t
        
        ; PC                : buffer    addr_t
        ; incremented_PC    : buffer    addr_t
        );
end PC;

architecture Behavioral of PC is
    signal next_PC            : addr_t;
begin

    incremented_PC <= std_logic_vector(unsigned(PC) + 1);
    
    next_PC <=  branch_addr       when pc_source = '1'
           else incremented_PC;

    process (reset, clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                PC <= (others => '0');
            else
                PC <= next_PC;
            end if;
        end if;
    end process;

end Behavioral;

