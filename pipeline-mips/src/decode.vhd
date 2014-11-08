library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;

entity decode is
    Port
        ( opcode           : in   std_logic_vector(5 downto 0)
        ; write_enable     : in   std_logic
        ; reg_dest         : buffer  std_logic
        ; pc_control       : buffer  pc_control_t
        ; mem_to_reg       : buffer  std_logic
        ; alu_override     : buffer  alu_override_t
        ; mem_write_enable : buffer  std_logic
        ; alu_src          : buffer  std_logic
        ; reg_write_enable : buffer  std_logic
        );
end decode;

architecture Behavioral of decode is
begin

    process (opcode, write_enable)
    begin
        --default values
        reg_dest          <= '0';
        pc_control        <= step;
        mem_to_reg        <= '0';
        mem_write_enable  <= '0';
        alu_src           <= '0';
        alu_override      <= override_disabled;
        reg_write_enable  <= '0';
   
   
        case opcode is

            when "000000" => -- ALU operation (and, or, add, sub, slt, sll)
                reg_dest <= '1';
                reg_write_enable <= '1';

            when "000100" => -- beq branch if equal
                reg_dest <= '1';
                pc_control <= branch;
                alu_override <= override_sub;

            when "000010" => -- jump
                reg_dest <= '1';
                pc_control <= jump;
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

        if write_enable = '0' then
            mem_write_enable <= '0';
            reg_write_enable <= '0';
        end if;

end process;

end Behavioral;

