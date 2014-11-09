library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity alu is
    port
        ( operand_left   : in      word_t := (others => '0')
        ; operand_right  : in      word_t := (others => '0')
        ; operator       : in      alu_funct_t := (others => '0')
        ; shamt          : in      alu_shamt_t
        ; result_is_zero : out     std_logic := '1'
        ; result         : out     word_t    := (others=> '0' )
        );

end alu;

architecture behavioral of alu is
  signal op_right_i : signed(31 downto 0);
  signal op_left_i  : signed(31 downto 0);
  signal result_i   : signed(31 downto 0);
begin
  op_right_i <= signed(operand_right);
  op_left_i <= signed(operand_left);
  result <= std_logic_vector(result_i);

    process (operator, op_left_i, op_right_i, shamt)
    begin
        case operator is
            when alu_add => result_i <= op_left_i +   op_right_i;
            when alu_sub => result_i <= op_left_i -   op_right_i;
            when alu_and => result_i <= op_left_i and op_right_i;
            when alu_or  => result_i <= op_left_i or  op_right_i;
            when alu_sll => result_i <= op_right_i sll to_integer(signed(shamt));
            when alu_slt =>
                if op_left_i < op_left_i
                    then result_i <= to_signed(1, 32);
                    else result_i <= to_signed(0, 32);
                end if;
           when others => result_i <= (others => '0');
        end case;
    end process;
	 
	 
	 process(result_i)
	 begin
		 if result_i /= 0 then
			result_is_zero <= '0';
		 else
			result_is_zero <= '1';
		 end if;
	 end process;
 
end behavioral;
