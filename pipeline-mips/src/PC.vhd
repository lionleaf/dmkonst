library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity PC is
    port
        ( reset             : in        std_logic
        ; clk               : in        std_logic
        ; processor_enable  : in        std_logic
        ; pc_source         : in        std_logic   
        ; branch_addr       : in        addr_t
        
        ; PC                : out    addr_t
        ; incremented_PC    : out    addr_t
        );
end PC;

architecture Behavioral of PC is
    signal PC_i    : addr_t;
    signal incremented_PC_i : addr_t;
    signal next_PC : addr_t;
begin

    PC <= PC_i;
    incremented_PC <= incremented_PC_i;
    
    incremented_PC_i <= std_logic_vector(resize(unsigned(PC_i) + 1, 8));
    
    next_PC <=  branch_addr       when pc_source = '1'
           else incremented_PC_i;

    process (reset, clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                PC_i <= (others => '0');
            elsif processor_enable = '1' then
                PC_i <= next_PC;
            end if;
        end if;
    end process;

end Behavioral;

