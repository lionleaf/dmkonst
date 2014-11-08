library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity instruction_decode is
	port
		(	clk             : std_logic
		;	write_data      : in word_t
		;	instruction     : in word_t
		;	write_register	: in reg_t
		;	data_1			: buffer word_t
		;	data_2			: buffer word_t
		)
	;
end instruction_decode;

architecture Behavioral of instruction_decode is

    --Control signals
    signal write_reg_enable: std_logic;


    -- decomposition of instruction
    alias rs        : reg_t   is instruction(25 downto 21);
    alias rt        : reg_t    is instruction(20 downto 16);

begin

    register_file:
        entity work.register_file
            port map
                ( clk           => clk
                , read_reg_1    => rs
                , read_reg_2    => rt
                , write_reg     => write_register
                , write_enable  => write_reg_enable
                , write_data    => write_data
                , read_data_1   => data_1
                , read_data_2   => data_2
                )
            ;

end Behavioral;

