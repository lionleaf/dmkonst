library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity control is
  
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- Communication
    instruction      : in  instruction_t;
    empty            : in  std_logic;
    read_instruction : out std_logic;

    -- Stack control
    push               : out std_logic;
    pop                : out std_logic;
    stack_input_select : out stack_input_select_t;
    operand            : out operand_t;

    -- ALU control
    operand_a_wen : out std_logic;
    operand_b_wen : out std_logic;
    alu_operation : out alu_operation_t);


end entity control;

architecture behavioural of control is

  type state_type is (
    idle,
    push_result,
    compute,
    pop_a, 
    pop_b,
    decode,
    push_operand,
    fetch);
  
  signal current_state : state_type;
  signal next_state : state_type;


begin  -- architecture behavioural

  process(clk, rst)
  begin
		if (rst = '1') then -- Asyncon reset 
      current_state <= idle;
		elsif( rising_edge(clk) ) then
			current_state <= next_state;
		end if;
	end process;
  
  process(
    clk,
    rst,
    instruction,
    empty,
    current_state)
  begin
    case current_state is
      when idle => 
        read_instruction <= '0';
        operand_a_wen <= '0';
        operand_b_wen <= '0';
        read_instruction <= '0';
        pop <= '0';
        push <= '0';
        -- alu_operation and stack_input_select is don't care
			
        if(empty = '1') then
          next_state <= idle;
        elsif (empty = '0') then
          next_state <= fetch;            
        end if;
      when fetch =>
        read_instruction <= '1';
        next_state <= decode; 
      when decode =>
        read_instruction <= '0';
    
        if ( instruction(15 downto 8) = (15 downto 8 => '0' )) then -- push 
					next_state <= push_operand;
				else -- Not push 
					next_state <= pop_b;
				end if;
      when push_operand =>
        push <= '1';
        stack_input_select <= STACK_INPUT_OPERAND;
        next_state <= idle;
        operand(7 downto 0) <= instruction(7 downto 0);
        next_state <= idle;
      when pop_b =>
        pop <= '1';
        operand_b_wen <= '1';
        next_state <= pop_a;
      when pop_a =>
        pop <= '1';
        operand_a_wen <= '1';
        next_state <= compute;
        
      when others =>
        next_state <= idle;
    end case;    
  end process;
    

end architecture behavioural;