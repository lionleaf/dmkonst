library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity instruction_decode_pipe is

    generic
        ( data_width : integer := 32
        );

    Port
        ( clk               : in      std_logic
        ; reset             : in      std_logic
        ; PC_plus_one_in    : in      signed (data_width - 1 downto 0) := to_signed(0, data_width)
        ; PC_plus_one_out   : out     signed (data_width - 1 downto 0) := to_signed(0, data_width)
        ; data_1_in         : in      STD_LOGIC_VECTOR (31 downto 0)
        ; data_1_out        : out     STD_LOGIC_VECTOR (31 downto 0)
        ; data_2_in         : in      STD_LOGIC_VECTOR (31 downto 0)
        ; data_2_out        : out     STD_LOGIC_VECTOR (31 downto 0)
        ; instructions_in   : in      STD_LOGIC_VECTOR (31 downto 0)
        ; instructions_out  : out     STD_LOGIC_VECTOR (31 downto 0)
       );
end instruction_decode_pipe;

architecture Behavioral of instruction_decode_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
            PC_plus_one_out     <= (others => '0');
            instructions_out    <= (others => '0');
            data_1_out          <= (others => '0');
            data_2_out          <= (others => '0');
        else 
            PC_plus_one_out     <= PC_plus_one_in;
            instructions_out    <= instructions_in;
            data_1_out          <= data_1_in;
            data_2_out          <= data_2_in;
        end if;
    end if;    
    end process;

end Behavioral;

