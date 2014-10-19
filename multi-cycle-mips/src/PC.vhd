library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC is
    generic
        ( ADDR_WIDTH : integer := 8
		; DATA_WIDTH : integer := 32
        );
    port
        ( reset : in  std_logic
        ; update_pc : in std_logic
        ; clk : in std_logic
        ; next_pc : in  std_logic_vector (ADDR_WIDTH - 1 downto 0)
        ; current_pc : out  std_logic_vector (ADDR_WIDTH - 1 downto 0)
        );
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

