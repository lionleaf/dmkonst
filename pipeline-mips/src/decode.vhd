library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity decode is
    Port
        ( instruction : in   inst_t
        ; branch_en   : out  std_logic
        ; mem_to_reg  : out  std_logic
        ; mem_wen     : out  std_logic
        ; reg_wen     : out  std_logic
        ; inst_type_I : out  std_logic
        ; alu_funct   : out  alu_funct_t
        ; alu_shamt   : out  alu_shamt_t
        );
        
    

end decode;

architecture Behavioral of decode is
  alias opcode is instruction(31 downto 26);
begin

  process (instruction)
    begin
      --default values
     branch_en   <= '0';
     mem_to_reg  <= '0';
     mem_wen     <= '0';
     reg_wen     <= '0';
     inst_type_I <= '0';
     alu_funct   <= (others => '0');
     alu_shamt   <= (others => '0');
 
      case opcode is

          when "000000" => -- ALU operation (and, or, add, sub, slt, sll)
              reg_wen <= '1';

          when "000100" => -- beq branch if equal
              branch_en <= '1';
              inst_type_I <= '1';
              alu_funct <= alu_sub;

--            when "000010" => -- jump
--                reg_dest <= '1';
--                pc_control <= jump;
          when "100011" => -- lw load word
              mem_to_reg <= '1';
              alu_funct <= alu_sub;
              inst_type_I <= '1';
              reg_wen     <= '1';

          when "101011" => -- sw store word
              alu_funct <= alu_sub;
              inst_type_I <= '1';
              mem_wen <= '1';

          when "001111" => -- lui load upper imm
              alu_funct <= alu_sll;
              alu_shamt <= std_logic_vector(to_unsigned(16, 6));
              inst_type_I <= '1';
              reg_wen     <= '1';

          when others => --Error, should not happen
      end case;
  end process;

end Behavioral;

