library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode is
    Port
        ( opcode           : in   std_logic_vector(5 downto 0)
        ; processor_enable : in   std_logic
        ; reg_dest         : out  std_logic
        ; branch           : out  std_logic
        ; mem_to_reg       : out  std_logic
        ; alu_override     : out  alu_override_t
        ; mem_write_enable : out  std_logic
        ; alu_src          : out  std_logic
        ; reg_write_enable : out  std_logic
        ; jump             : out  std_logic
        );
end decode;

architecture Behavioral of decode is
begin

    process (opcode)
    begin
        --default values
        reg_dest          <= '0';
        branch            <= '0';
        mem_to_reg        <= '0';
        mem_write_enable  <= '0';
        alu_src           <= '0';
        alu_override      <= override_disabled;
        reg_write_enable  <= '0';
        jump              <= '0';
   
   
        case opcode is

            when "000000" => -- ALU operation (and, or, add, sub, slt, sll)
                reg_dest <= '1';
                reg_write_enable <= '1';

            when "000100" => -- beq branch if equal
                reg_dest <= '1';
                branch <= '1';
                alu_override <= override_sub;

            when "000010" => -- jump
                reg_dest <= '1';
                jump <= '1';

            when "100011" => -- lw load word
                mem_to_reg <= '1';
                alu_override <= override_add;
                alu_src <= '1';
                reg_write_enable <= '1';

            when "101011" => -- sw store word
                alu_override <= override_add;
                alu_src <= '1';
                mem_write_enable <= '1';

            when "001111" => -- lui load upper imm
                alu_override <= override_sll16;
                alu_src <= '1';
                reg_write_enable <= '1';

            when others => --Error, should not happen
        end case;

end process;

end Behavioral;

