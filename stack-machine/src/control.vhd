library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity control is

    port
        ( clk : in std_logic
        ; rst : in std_logic

    -- Communication
        ; instruction      : in  instruction_t
        ; empty            : in  std_logic
        ; read_instruction : out std_logic

    -- Stack control
        ; push               : out std_logic
        ; pop                : out std_logic
        ; stack_input_select : out stack_input_select_t
        ; operand            : out operand_t

    -- ALU control
        ; operand_a_wen : out std_logic
        ; operand_b_wen : out std_logic
        ; alu_operation : out alu_operation_t
        );

end entity control;

architecture behavioural of control is

    type state_type is
        ( idle
        , push_result
        , compute
        , pop_a
        , pop_b
        , decode
        , push_operand
        , fetch
        );

    signal current_state : state_type;
    signal next_state : state_type;
    signal opcode : opcode_t;
    
begin

    opcode <= instruction(15 downto 8);
    operand <= instruction(7 downto 0);

    with opcode(1) select alu_operation
        <= alu_add         when '0'
         , alu_sub         when others -- '1'
    ;

    process
        ( clk
        , rst
        )
    begin
        if rst = '1' then 
            current_state <= idle;
		else
            if rising_edge(clk) then
                current_state <= next_state;
            end if;
		end if;
	end process;


    process
        ( clk
        , rst
        , instruction
        , empty
        , current_state
        , opcode
        )
    begin
        stack_input_select <= STACK_INPUT_OPERAND;
        next_state <= idle;
        read_instruction <= '0';
        operand_a_wen <= '0';
        operand_b_wen <= '0';
        read_instruction <= '0';
        pop <= '0';
        push <= '0';

        case current_state is

            when idle =>
                if empty = '0' then
                    next_state <= fetch;
                end if;

            when fetch =>
                read_instruction <= '1';
                next_state <= decode;

            when decode =>
                if opcode(1 downto 0) = "00" then
                    next_state <= push_operand;
				else
					next_state <= pop_b;
				end if;

            when push_operand =>
                push <= '1';
                stack_input_select <= STACK_INPUT_OPERAND;
      
            when pop_b =>
                operand_b_wen <= '1';
                pop <= '1';
                next_state <= pop_a;
      
            when pop_a =>
                operand_a_wen <= '1';
                pop <= '1';
                next_state <= compute;
        
            when compute =>
                next_state <= push_result;

            when push_result =>
                stack_input_select <= STACK_INPUT_RESULT;
                push <= '1';

        end case;    
    end process;

end architecture behavioural;
