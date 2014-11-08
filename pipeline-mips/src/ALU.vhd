library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity alu is

	generic
        ( data_width : integer := 32
        );

    port
        ( operand_left   : in      signed (data_width - 1 downto 0) := to_signed(0, data_width)
        ; operand_right  : in      signed (data_width - 1 downto 0) := to_signed(0, data_width)
        ; operator       : in      alu_funct_t
        ; result_is_zero : out     std_logic := '1'
        ; result         : buffer  signed (data_width - 1 downto 0) := to_signed(0, data_width)
        );

end alu;

architecture behavioral of alu is
begin

    process (operator, operand_left, operand_right)
    begin
        case operator is
            when alu_add => result <= operand_left +   operand_right;
            when alu_sub => result <= operand_left -   operand_right;
            when alu_and => result <= operand_left and operand_right;
            when alu_or  => result <= operand_left or  operand_right;
            when alu_sll16 => result <= operand_right sll 16;
            when alu_slt =>
                if operand_left < operand_right
                    then result <= to_signed(1, data_width);
                    else result <= to_signed(0, data_width);
                end if;
        end case;
    end process;
	 
	 
	 process(result)
	 begin
		 if result /= 0 then
			result_is_zero <= '0';
		 else
			result_is_zero <= '1';
		 end if;
	 end process;
 
end behavioral;
