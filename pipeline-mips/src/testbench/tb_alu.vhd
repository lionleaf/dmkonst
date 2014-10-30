library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
 
entity tb_alu is
end tb_alu;
 
architecture behavior of tb_alu is
    constant data_width : integer := 32;
    subtype data_t is signed(data_width-1 downto 0);
    
    
    -- Type conversion functions. Collapsed as the name is the only important part.
    function num(n: integer) return data_t is begin return to_signed(n, data_width); end num;
    function str(n: data_t) return string is begin return integer'image(to_integer(n)); end str;  
    function str(op: alu_funct_t) return string is begin return alu_funct_t'image(op); end str;    
    function str(p: boolean) return string is begin return boolean'image(p); end str;    
    function str(n: integer) return string is begin return integer'image(n); end str;

    
    -- component declaration for the unit under test (uut)
    component alu
    generic
        (data_width      : integer
        );
    port
        ( operand_left   : in      data_t
        ; operand_right  : in      data_t
        ; operator       : in      alu_funct_t
        ; result_is_zero : out     boolean
        ; result         : buffer  data_t
        );
    end component;
    

    --inputs
    signal operand_left  : data_t := num(0);
    signal operand_right : data_t := num(0);
    signal operator      : alu_funct_t   := alu_add;

 	--outputs
    signal result_is_zero : boolean := true;
    signal result         : data_t := num(0);
    
    --clocks
    constant clock_period : time := 10 ns;
    
    signal expected_result : integer := 0;

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
    
        procedure test_op(
            inp_operator  : in alu_funct_t;
            inp_operand_left    : in integer;
            inp_operand_right   : in integer;
            expected_result : in integer;
            expected_zero   : in boolean)
       is
       begin
            operator        <= inp_operator;
            operand_left    <= num(inp_operand_left);
            operand_right   <= num(inp_operand_right);
            wait for clock_period;
            assert result = expected_result 
                        report str(operand_left) & " " 
                        & str(inp_operator) & " " & str(operand_right) 
                        & " should be " & str(expected_result)
                        & " but returned " & str(result)
                        severity error;
           
           assert result_is_zero = expected_zero 
                        report str(inp_operand_left) &" " 
                        & str(inp_operator) & " "& str(inp_operand_right) 
                        & " = " & str(expected_result)
                        & " should set zero to " & str(expected_zero)
                        & " but it was set to " & str(result_is_zero)
                        severity error;
            
       end test_op;
            
       constant max_int : integer :=  2147483647;
       constant min_int : integer := -2147483648;
    begin
        wait for 100ns;
        report "====== Test starting ======";
        
        
        report "Testing operations on 0";
        -- ZEROS
        test_op(alu_add, 0, 0, 0, true);
        test_op(alu_sub, 0, 0, 0, true);
        test_op(alu_and, 0, 0, 0, true);
        test_op(alu_or,  0, 0, 0, true);
        
        report "Testing add";
        
        test_op(alu_add, 0, 0, 0, true);
        test_op(alu_add, 1, 0, 1, false);
        test_op(alu_add, 0, 1, 1, false);
        test_op(alu_add, 1, 1, 2, false);
        test_op(alu_add, 314, 1337, 1651, false);
        
        test_op(alu_add, -1, 0, -1, false);
        test_op(alu_add, 0, -3487, -3487, false);
        test_op(alu_add, 5342, -5342, 0, true);
        test_op(alu_add, -314, -1337, -1651, false);
        
        
--      Big number add
        test_op(alu_add, max_int, 1, min_int, false);
        
        
        report "Testing subtraction";

--      Subtraction
        test_op(alu_sub, 0, 0, 0, true);
        test_op(alu_sub, 8, 3, 5, false);
        test_op(alu_sub, 5, 8, -3, false);
        test_op(alu_sub, 8, 5, 3, false);
        test_op(alu_sub, max_int, max_int, 0, true);
        
        
--      Subtraction
        test_op(alu_sub, 0, 0, 0, true);
        test_op(alu_sub, 8, 3, 5, false);
        test_op(alu_sub, 5, 8, -3, false);
        test_op(alu_sub, 8, 5, 3, false);
        test_op(alu_sub, max_int, max_int, 0, true);
        
        report "Testing and";
        test_op(alu_and, 1234123, 0, 0, true);
        test_op(alu_and, 16#5555555#, 16#5555555#, 16#5555555#, false);
        test_op(alu_and, 16#123456#, 16#F0F0F0#, 16#103050#, false);
        
        report "Testing or";
        test_op(alu_or, max_int, 0, max_int, false);
        test_op(alu_or, 1, 0, 1, false);
        test_op(alu_or, 1, 1, 1, false);
        test_op(alu_or, 0, 1, 1, false);
        test_op(alu_or, 0, 0, 0, true);
        test_op(alu_or, 16#10F0F0F0#, 16#0F0F0F0F#, 16#1FFFFFFF#, false);
        test_op(alu_or, 16#10F0F0F0#, 16#1FFFFFFF#, 16#1FFFFFFF#, false);
        test_op(alu_or, max_int, max_int, max_int, false);
        
        report "Testing slt";
        test_op(alu_slt, 1, 1, 0, true);
        test_op(alu_slt, 1, 2, 1, false);
        test_op(alu_slt, -234, 231, 1, false);
        test_op(alu_slt, 0, 231, 1, false);
        test_op(alu_slt, 12, 0, 0, true);
        test_op(alu_slt, -12, 0, 1, false);

        report "Testing sll16";
        test_op(alu_sll16, 0, 1, 65536, false);
        test_op(alu_sll16, 2131, 1, 65536, false); --The first operand should not matter
        test_op(alu_sll16, -12313, 1, 65536, false);
        test_op(alu_sll16, -12313, 16#10#, 16#100000#, false);

        report "====== Test completed successfully ======";
        wait;
    end process;

end;
