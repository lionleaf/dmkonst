library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;
use work.testutil.all;
-------------------------------------------------------------------------------

entity stack_machine_tb is

end entity stack_machine_tb;

-------------------------------------------------------------------------------

architecture behavioural of stack_machine_tb is

  -- component generics
  constant size : natural := 1024;

  -- component ports
  signal rst              : std_logic     := '0';
  signal instruction      : instruction_t := (others => '0');
  signal empty            : std_logic     := '1';
  signal read_instruction : std_logic;
  signal stack_top        : operand_t;

  -- clock
  constant clk_period : time      := 20 ns;
  signal clk          : std_logic := '1';

  -- test instructions
begin  -- architecture behavioural

  -- component instantiation
  DUT : entity work.stack_machine
    generic map (
      size => size)
    port map (
      clk              => clk,
      rst              => rst,
      instruction      => instruction,
      empty            => empty,
      read_instruction => read_instruction,
      stack_top        => stack_top);

  -- clock generation
  clk <= not clk after clk_period / 2;

  -- waveform generation
  WaveGen_Proc : process

    procedure check (
      condition : in boolean;
      error_msg : in string) is
    begin  -- procedure check
      assert condition report error_msg severity failure;
    end procedure check;

    procedure check_stable_idle (
      constant expected_stack_top : in operand_t) is
    begin  -- procedure check_stable_idle
      assert empty = '1'
        report "[TEST BUG]: Empty should be high for idle check"
        severity failure;
      for i in 0 to 20 loop
        check(read_instruction = '0',
              "instructions should not be requested when empty is high");
        check(stack_top = expected_stack_top,
              "The stack top value should be kept stable");
        wait for clk_period;
      end loop;  -- i
    end procedure check_stable_idle;


    procedure run_instruction (
      constant instr_in : in instruction_t;
      constant is_final_instruction : in boolean) is
    begin  -- procedure run_instruction
      --wait until read_instruction = '1';
      instruction <= instr_in;
      if is_final_instruction then
        empty <= '1';
      end if;
      --wait until rising_edge(idle);
      wait until falling_edge(read_instruction);
      if not is_final_instruction then
        wait until rising_edge(read_instruction);               
      end if;
    end procedure run_instruction;

    procedure check_instruction_result (
      constant instruction_name : in string;
      constant expected_result  : in operand_t) is
    begin  -- procedure check_instruction_result
      check(stack_top = expected_result,
            "after " & instruction_name & "has completed, " &
            "stack_top should be updated");
    end procedure check_instruction_result;

    procedure run_and_check_instruction (
      constant instr_in : instruction_t;
      constant expected_result : in operand_t;
      constant is_final_instruction : in boolean) is

      variable instruction_name : string(1 to 4);
    begin  -- procedure run_and_check_instruction
      case instr_in(9 downto 8) is
        when "00" => instruction_name := "push";
        when "01"  => instruction_name := "add ";
        when "10"  => instruction_name := "sub ";
        when others =>
          assert false
            report "[TEST BUG]: Unknown operation tested"
            severity failure;
      end case;

      run_instruction(instr_in,is_final_instruction);
      if is_final_instruction then
        wait for clk_period * 20;
      end if;
      check_instruction_result(instruction_name, expected_result);
    end procedure run_and_check_instruction;
    
    procedure run_and_check_instruction (
      constant instr_in : instruction_t;
      constant expected_result : in operand_t) is
    begin  -- procedure run_and_check_instruction
      run_and_check_instruction(instr_in, expected_result, false);
    end procedure run_and_check_instruction;

  begin
    -- insert signal assignments here
    rst <= '1';
    wait for clk_period;
    rst <= '0';

    check(read_instruction = '0',
          "instructions should not be requested when empty is high");
    check(stack_top = x"00",
          "The stack top should be zero when nothing has been calculated");

    wait for clk_period;
    check_stable_idle(x"00");

    empty <= '0';
	 wait until rising_edge(read_instruction);
    run_and_check_instruction(make_instruction(OP_PUSH, x"01"), x"01");
    run_and_check_instruction(make_instruction(OP_PUSH, x"02"), x"02");
    run_and_check_instruction(make_instruction(OP_ADD), x"03");

    run_and_check_instruction(make_instruction(OP_PUSH, x"FE"), x"FE");
    run_and_check_instruction(make_instruction(OP_SUB), x"05");

    run_and_check_instruction(make_instruction(OP_PUSH, x"FF"), x"FF");
    run_and_check_instruction(make_instruction(OP_ADD), x"04");
    run_and_check_instruction(make_instruction(OP_PUSH, x"03"), x"03");
    run_and_check_instruction(make_instruction(OP_SUB), x"01", true);

    wait for clk_period / 2;
    check_stable_idle(x"01");

    assert false report "TEST SUCCESS" severity failure;
    wait until clk = '1';
  end process WaveGen_Proc;

end architecture behavioural;

-------------------------------------------------------------------------------

configuration stack_machine_tb_behavioural_cfg of stack_machine_tb is
  for behavioural
  end for;
end stack_machine_tb_behavioural_cfg;

-------------------------------------------------------------------------------
