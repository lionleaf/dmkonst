library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity id_to_ex_pipe is

    generic
        ( data_width : integer := 32
        );

    Port
        ( clk               : in      std_logic
        ; reset             : in      std_logic
        ; incremented_PC_in : in      addr_t
        ; incremented_PC_out: out     addr_t
        ; data_1_in         : in      word_t
        ; data_1_out        : out     word_t
        ; data_2_in         : in      word_t
        ; data_2_out        : out     word_t
        ; instructions_in   : in      word_t
        ; instructions_out  : out     word_t
        
        --Control signals
        --For execute stage
        ; inst_type_I_in    : in    std_logic
        ; inst_type_I_out   : out   std_logic
        ; imm_to_alu_in     : in    std_logic
        ; imm_to_alu_out    : out   std_logic
        ; alu_funct_in      : in    alu_funct_t
        ; alu_funct_out     : out   alu_funct_t
        ; alu_shamt_in      : in    alu_shamt_t
        ; alu_shamt_out     : out   alu_shamt_t

        --Control signals for memory stage
        ; branch_en_in      : in    std_logic
        ; branch_en_out     : out   std_logic
        ; mem_wen_in        : in    std_logic
        ; mem_wen_out       : out   std_logic

        --Control signals for writeback stage
        ; reg_wen_in        : in    std_logic
        ; reg_wen_out       : out   std_logic
        ; mem_to_reg_in     : in    std_logic
        ; mem_to_reg_out    : out   std_logic
       );
end id_to_ex_pipe;

architecture Behavioral of id_to_ex_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
           incremented_PC_out <= (others => '0');
           instructions_out   <= (others => '0');
           data_1_out         <= (others => '0');
           data_2_out         <= (others => '0');
           inst_type_I_out    <= '0';
           imm_to_alu_out     <= '0';
           alu_funct_out      <= (others => '0');
           alu_shamt_out      <= (others => '0');
           branch_en_out      <= '0';
           mem_wen_out        <= '0';
           reg_wen_out        <= '0';
           mem_to_reg_out     <= '0';
        else 
           incremented_PC_out <= incremented_PC_in;
           instructions_out   <= instructions_in;
           data_1_out         <= data_1_in;
           data_2_out         <= data_2_in;
           inst_type_I_out    <= inst_type_I_in;
           imm_to_alu_out     <= imm_to_alu_in;
           alu_funct_out      <= alu_funct_in;
           alu_shamt_out      <= alu_shamt_in;
           branch_en_out      <= branch_en_in;
           mem_wen_out        <= mem_wen_in;
           reg_wen_out        <= reg_wen_in;
           mem_to_reg_out     <= mem_to_reg_in ;
        end if;
    end if;    
    end process;

end Behavioral;

