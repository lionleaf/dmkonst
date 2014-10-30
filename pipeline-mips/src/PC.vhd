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
        ( reset     : in  std_logic
        ; update_pc : in std_logic
        ; clk       : in std_logic
        ; pc_control: in pc_control_t       
        ; alu_zero  : in boolean
        ; immediate : in std_logic_vector(15 downto 0)
        
        ; PC        : buffer  addr_t
        );
end PC;

architecture Behavioral of PC is
    signal incremented_PC     : addr_t;
    signal branch_or_inc_addr : addr_t;
    signal branch_addr        : addr_t;
    signal next_PC            : addr_t;
    signal immediate_resized  : addr_t;
begin

    incremented_PC <= std_logic_vector(unsigned(PC) + 1);
    
    immediate_resized <= std_logic_vector(resize(signed(immediate), addr_width));
    
    branch_addr <= std_logic_vector(signed(incremented_PC) + signed(immediate_resized));
    
    
    next_PC <=  branch_addr       when pc_control = branch and alu_zero
           else immediate_resized when pc_control = jump
           else incremented_PC;

    process (reset, clk, update_pc)
    begin
        if (reset = '1') then
            PC <= (others => '0');
        elsif rising_edge(clk) and update_pc = '1' then
            PC <= next_PC;
        end if;
    end process;

end Behavioral;

