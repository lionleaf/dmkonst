----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:05:19 10/11/2014 
-- Design Name: 
-- Module Name:    Control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Control is
	generic (
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 32
	);
    Port ( 
		clk, reset      : in   std_logic;
        processor_enable: in   std_logic;
		opcode          : in   std_logic_vector(5 downto 0);
        reg_dest        : out  std_logic;
        branch          : out  std_logic;
        mem_to_reg      : out  std_logic;
        alu_override    : out  alu_override_t;
        mem_write_enable: out  std_logic;
        alu_src         : out  std_logic;
        reg_write_enable: out  std_logic;
        update_pc       : out  std_logic;
        jump            : out  std_logic);
end control;

architecture Behavioral of Control is
    type state_t is (initial_state, first_fetch, fetch, execute, stall, error_s);  --type of state machine.
    signal current_s, next_s: state_t;
begin

process (clk,reset, processor_enable)
begin
 if (reset='1' or processor_enable = '0') then
  current_s <= initial_state;  --default state on reset.
elsif (rising_edge(clk)) then
  current_s <= next_s;   --state change.
end if;
end process;

process (current_s, opcode)
begin
     update_pc <= '0';

    case current_s is
    when initial_state =>
        next_s <= first_fetch;
    when first_fetch =>
        next_s <= execute;
    when fetch =>
        next_s <= execute;
        update_pc <= '1';
    when execute =>
        --If lw or sw stall one cycle
        if opcode = "100011" or opcode = "101011" then
           next_s <= stall;
        else
            next_s <= fetch;
        end if; 
    when stall =>
        if(processor_enable = '1') then
            next_s <= fetch;
        else
            next_s <= stall;
        end if;
    when error_s =>
        --Do not proceed. Light LED
    end case;
 end process;




process (opcode)
begin
--default values
   reg_dest    <= '0';
   branch      <= '0';
   mem_to_reg  <= '0';
   mem_write_enable <= '0';
   alu_src     <= '0';
   alu_override <= override_disabled;
   reg_write_enable <= '0';
   jump        <= '0';
   
   
    case opcode is
        when "000000" => -- ALU operation (and, or, add, sub, slt, sll)
            reg_dest    <= '1';
            reg_write_enable <= '1';
        when "000100" => -- beq branch if equal
            reg_dest    <= '1';
            branch      <= '1';
            alu_override <= override_sub;
            
        when "000010" => -- jump
            reg_dest    <= '1';
            jump        <= '1';
            
        when "100011" => -- lw load word
            mem_to_reg  <= '1';
            alu_override <= override_add;
            alu_src     <= '1';
            reg_write_enable <= '1';
        
        when "101011" => -- sw store word
            alu_override <= override_add;
            alu_src     <= '1';
            mem_write_enable <= '1';
            
        when "001111" => -- lui load upper imm
            alu_override <= override_sll16;
            alu_src     <= '1';
            reg_write_enable <= '1';
            
        when others => --Error, should not happen
    end case;
        
end process;


end Behavioral;

