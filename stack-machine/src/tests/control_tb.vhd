library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.testutil.all;
-------------------------------------------------------------------------------

entity control_tb is

end entity control_tb;

-------------------------------------------------------------------------------

architecture behavioural of control_tb is

  -- component ports
  signal rst : std_logic := '0';

  signal instruction      : instruction_t := (others => '0');
  signal empty            : std_logic     := '1';
  signal read_instruction : std_logic;

  signal push               : std_logic;
  signal pop                : std_logic;
  signal stack_input_select : stack_input_select_t;
  signal operand            : operand_t;

  signal operand_a_wen : std_logic;
  signal operand_b_wen : std_logic;
  signal alu_operation : alu_operation_t;

  -- clock
  constant clk_period : time      := 20 ns;
  signal clk          : std_logic := '1';

  --signal i : integer := 0;

begin  -- architecture behavioural

  -- component instantiation
  DUT : entity work.control
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

  -- clock generation
  clk <= not clk after clk_period / 2;

  -- waveform generation
  WaveGen_Proc : process

    procedure check_idle_output is
    begin  -- procedure check_idle_output
      check(push = '0', "The processor should not push anything when idle");
      check(pop = '0', "The processor should not pop anything when idle");
      check(read_instruction = '0',
            "The processor should not read instructions when empty is high");
    end procedure check_idle_output;

    procedure check_stable_idle is
    begin  -- procedure check_stable_idle
      check(empty = '1', "[TEST BUG]: Empty should be 1 for idle to be stable");
      stable_reset_check : for i in 0 to 20 loop
        check_idle_output;
        wait for clk_period;
      end loop stable_reset_check;
    end procedure check_stable_idle;

    procedure check_fetch_output is
    begin  -- procedure check_fetch_output
      check(push = '0', "The processor should not push when fetching");
      check(pop = '0', "The processor should not pop when fetching");
      check(read_instruction = '1',
            "The processor should request instruction when fetching");
    end procedure check_fetch_output;

    procedure check_decode_output is
    begin  -- procedure check_decode_output
      check(push = '0', "The processor should not push when decoding");
      check(pop = '0', "The processor should not pop when decoding");
      check(read_instruction = '0',
            "The processor should not request instructions when decoding");
    end procedure check_decode_output;

    procedure check_push_operand_output is
    begin  -- procedure check_push_operand_output
      check(push = '1', "in push_operand, push should be set high");
      check(stack_input_select = STACK_INPUT_OPERAND,
            "in push_operand, the stack input should be operand");
      check(pop = '0', "when pushing operand, control should not pop");
    end procedure check_push_operand_output;

    procedure check_pop_b_output is
    begin  -- procedure check_pop_b_output
      check(read_instruction = '0',
            "The processor should not read instruction when popping B");
      check(push = '0', "The processor should not push when popping B");
      check(pop = '1', "control should assert pop when popping B");
      check(operand_b_wen = '1',
            "Control should enable writes to B when popping B");
    end procedure check_pop_b_output;

    procedure check_pop_a_output is
    begin  -- procedure check_pop_a_output
      check(read_instruction = '0',
            "The processor should not read instruction when popping A");
      check(push = '0', "The processor should not push when popping A");
      check(pop = '1', "control should assert pop when popping A");
      check(operand_b_wen = '0',
            "Control should not enable writes to B when popping A");
      check(operand_a_wen = '1',
            "Control should enable writes to A when popping A");
 
    end procedure check_pop_a_output;

    procedure check_compute_output is
    begin  -- procedure check_compute_output
      check(push = '0', "The processor should not push when computing");
      check(pop = '0', "The processor should not pop when computing");
      check(read_instruction = '0',
            "The processor should not read instructions when computing");
      check(operand_b_wen = '0',
            "The processor should not modify operand B when computing");
      check(operand_a_wen = '0',
            "The processor should not modify operand A when computing");
    end procedure check_compute_output;

    procedure check_push_result_output is
    begin  -- procedure check_push_result_output
      check(push = '1', "in push_result, push should be set high");
      check(stack_input_select = STACK_INPUT_RESULT,
            "in push_result, the stack input should be result");
      check(pop = '0', "when pushing operand, control should not pop");
    end procedure check_push_result_output;

  begin
    -- insert signal assignments here
    wait for clk_period/4;
    rst <= '1';
    wait for clk_period;
    rst <= '0';

-- TEST stable behaviour after reset
    check_stable_idle;
    report "Test 1 passed" severity note;

-- TEST push control flow
    empty <= '0';
    wait for clk_period;
    check_fetch_output;
    report "Test 2 passed" severity note;

    instruction <= make_instruction(OP_PUSH, x"bb");
    empty       <= '1';
    wait for clk_period;
    check_decode_output;
    report "Test 3 passed" severity note;

    wait for clk_period;
    check_push_operand_output;
    check(operand = x"bb", "Pushed operand should be the same as immediate");
    report "Test 4 passed" severity note;

    wait for clk_period;
    check_stable_idle;
    report "Test 5 passed" severity note;

-- TEST add control flow
    empty <= '0';
    wait for clk_period;
    check_fetch_output;
    report "Test 6 passed" severity note;

    instruction <= make_instruction(OP_ADD);
    wait for clk_period;
    check_decode_output;
    report "Test 7 passed" severity note;

    wait for clk_period;
    check_pop_b_output;
    report "Test 8 passed" severity note;

    wait for clk_period;
    check_pop_a_output;
    report "Test 9 passed" severity note;

    wait for clk_period;
    check_compute_output;
    check(alu_operation = ALU_ADD,
          "ALU operation should be set to add when adding");
    report "Test 10 passed" severity note;

    wait for clk_period;
    check_push_result_output;
    check(alu_operation = ALU_ADD,
          "ALU operation should be set to add when pushing result");
    report "Test 11 passed" severity note;

    wait for clk_period;
    check_idle_output;
    report "Test 12 passed" severity note;

-- TEST computation continues while empty is low
    wait for clk_period;
    check_fetch_output;
    report "Test 13 passed" severity note;

-- TEST subtraction control flow    
    instruction <= make_instruction(OP_SUB);
    empty <= '1';
    wait for clk_period;
    check_decode_output;
    report "Test 14 passed" severity note;

    wait for clk_period;
    check_pop_b_output;
    report "Test 15 passed" severity note;

    wait for clk_period;
    check_pop_a_output;
    report "Test 16 passed" severity note;

    wait for clk_period;
    check_compute_output;
    check(alu_operation = ALU_SUB,
          "ALU operation should be set to sub when subtracting");
    report "Test 17 passed" severity note;

    wait for clk_period;
    check_push_result_output;
    check(alu_operation = ALU_SUB,
          "ALU operation should be set to sub when subtracting");
    report "Test 18 passed" severity note;
    
    wait for clk_period;
    check_stable_idle;
    report "Test 19 passed" severity note;

    assert false report "TEST SUCCESS" severity failure;
    wait until clk = '1';
  end process WaveGen_Proc;

end architecture behavioural;

-------------------------------------------------------------------------------

configuration control_tb_behavioural_cfg of control_tb is
  for behavioural
  end for;
end control_tb_behavioural_cfg;

-------------------------------------------------------------------------------
