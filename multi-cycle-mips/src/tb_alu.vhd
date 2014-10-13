library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
 
entity tb_alu is
end tb_alu;
 
architecture behavior of tb_alu is
    -- component declaration for the unit under test (uut)
    component alu
    port
        ( operand_left   : in      signed(32 downto 0)
        ; operand_right  : in      signed(32 downto 0)
        ; operator       : in      op_t
        ; result_is_zero : out     boolean
        ; result         : buffer  signed(32 downto 0)
        );
    end component;
    

    --inputs
    signal operand_left  : signed(32 downto 0) := to_signed(42);
    signal operand_right : signed(32 downto 0) := (others => '0');
    signal operator      : op_t;

 	--outputs
    signal result_is_zero : boolean;
    signal result         : signed(32 downto 0);
 
    --clocks
    constant clock_period : time := 10 ns;
    signal   clock        : boolean;
 
begin
 
    -- instantiate the unit under test (uut)
    uut: alu port map
        ( operand_left   => operand_left
        , operand_right  => operand_right
        , operator       => operator
        , result_is_zero => result_is_zero
        , result         => result
        );

    -- clock process definitions
    clock_process :process
    begin
		clock <= true;
		wait for clock_period/2;
		clock <= false;
		wait for clock_period/2;
    end process;
 

    -- stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        wait for 100 ns;	

        wait for clock_period*10;

        -- insert stimulus here 

        wait;
    end process;

end;
