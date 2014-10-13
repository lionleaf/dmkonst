library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
 
entity tb_alu is
end tb_alu;
 
architecture behavior of tb_alu is
    constant data_width : integer := 32;
    subtype data_t is signed(data_width-1 downto 0);
    
    function num(n: integer) return data_t is begin return to_signed(n, data_width); end num;
    function str(n: data_t) return string is begin return integer'image(to_integer(n)); end str;
    function str(n: integer) return string is begin return integer'image(n); end str;

    
    -- component declaration for the unit under test (uut)
    component alu
    generic
        (data_width      : integer
        );
    port
        ( operand_left   : in      data_t
        ; operand_right  : in      data_t
        ; operator       : in      op_t
        ; result_is_zero : out     boolean
        ; result         : buffer  data_t
        );
    end component;
    

    --inputs
    signal operand_left  : data_t;
    signal operand_right : data_t;
    signal operator      : op_t;

 	--outputs
    signal result_is_zero : boolean;
    signal result         : data_t;
 
    --clocks
    constant clock_period : time := 10 ns;

    signal expected_result : integer;
begin
 
    -- instantiate the unit under test (uut)
    uut: alu
        generic map
            (data_width      => data_width
            )
        port map
            ( operand_left   => operand_left
            , operand_right  => operand_right
            , operator       => operator
            , result_is_zero => result_is_zero
            , result         => result
            );

    -- stimulus process
    stim_proc: process
    begin		
        report "====== Test starting ======";
        
        operator <= op_add;
        operand_left <= num(1);
        operand_right <= num(2);
        expected_result <= 3;
        wait for clock_period;
        assert result = expected_result report str(operand_left) &"+"& str(operand_right) &" should be "& str(expected_result);
        assert result_is_zero = false report "0 + 0 should give result_is_zero";
      
        --for i in integer'low to integer'high loop
        --for j in integer'low to integer'high loop
            --report integer'image(i);
        --end loop;
        --end loop;
        
        -- end of simulation
        report "====== Test completed successfully ======";
        wait;
    end process;

end;
