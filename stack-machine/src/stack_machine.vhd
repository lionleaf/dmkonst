library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity stack_machine is
  
  generic (
    size : natural := 1024);

  port (
    clk : in std_logic;
    rst : in std_logic;

    instruction      : in  instruction_t;
    empty            : in  std_logic;
    read_instruction : out std_logic;

    stack_top : out operand_t);

end entity stack_machine;

architecture behavioural of stack_machine is

-- Stack signals
  signal stack_in : operand_t;
  signal top      : operand_t;

-- Control signals
  signal push               : std_logic;
  signal pop                : std_logic;
  signal operand            : operand_t;
  signal stack_input_select : stack_input_select_t;
  signal operand_a_wen      : std_logic;
  signal operand_b_wen      : std_logic;
  signal alu_operation      : alu_operation_t;

-- Operand registers
  signal operand_a_reg : signed(7 downto 0);
  signal operand_b_reg : signed(7 downto 0);
  signal result        : signed(7 downto 0);

begin  -- architecture behavioural

  stack_top <= stack_in when push = '1' else
               top;

  with stack_input_select select
    stack_in <=
    operand                  when STACK_INPUT_OPERAND,
    std_logic_vector(result) when others;

  with alu_operation select
    result <=
    operand_a_reg + operand_b_reg when ALU_ADD,
    operand_a_reg - operand_b_reg when others;

  operand_regs : process (clk, rst) is
  begin  -- process operand_regs
    if rst = '1' then                   -- asynchronous reset
      operand_a_reg <= (others => '0');
      operand_b_reg <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if operand_a_wen = '1' then
        operand_a_reg <= signed(top);
      end if;
      if operand_b_wen = '1' then
        operand_b_reg <= signed(top);
      end if;
    end if;
  end process operand_regs;

  control : entity work.control
    port map (
      clk                => clk,
      rst                => rst,
      instruction        => instruction,
      empty              => empty,
      read_instruction   => read_instruction,
      push               => push,
      pop                => pop,
      stack_input_select => stack_input_select,
      operand            => operand,
      operand_a_wen      => operand_a_wen,
      operand_b_wen      => operand_b_wen,
      alu_operation      => alu_operation);

  stack : entity work.stack
    generic map (
      size => size)
    port map (
      clk      => clk,
      rst      => rst,
      value_in => stack_in,
      push     => push,
      pop      => pop,
      top      => top);

end architecture behavioural;

