library ieee;
use ieee.std_logic_1164.all;

package defs is
--    data_t is deprecated
    subtype data_t is std_logic_vector(31 downto 0);
    subtype word_t is std_logic_vector(31 downto 0);
    subtype inst_t is std_logic_vector(31 downto 0);
    subtype addr_t is std_logic_vector(7 downto 0);
    subtype reg_t is std_logic_vector(4 downto 0);
    
    subtype alu_funct_t is std_logic_vector(5 downto 0);
    subtype alu_shamt_t is std_logic_vector(5 downto 0);

   constant alu_add : alu_funct_t := "100000";
   constant alu_sub : alu_funct_t := "100010";
   constant alu_slt : alu_funct_t := "101010";
   constant alu_and : alu_funct_t := "100100";
   constant alu_or  : alu_funct_t := "100101";
   constant alu_sll : alu_funct_t := "000000";

end package defs;
