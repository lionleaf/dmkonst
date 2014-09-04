library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;
use work.testutil.all;
-------------------------------------------------------------------------------

entity stack_tb is

end entity stack_tb;

-------------------------------------------------------------------------------

architecture behavioural of stack_tb is

  -- component generics
  constant size : natural := 1024;

  -- component ports
  signal rst      : std_logic := '0';
  signal value_in : operand_t := (others => '0');
  signal push     : std_logic := '0';
  signal pop      : std_logic := '0';
  signal top      : operand_t;

  -- clock
  constant clk_period : time := 20 ns;
  signal clk : std_logic := '1';

begin  -- architecture behavioural

  -- component instantiation
  DUT: entity work.stack
    generic map (
      size => size)
    port map (
      clk      => clk,
      rst      => rst,
      value_in => value_in,
      push     => push,
      pop      => pop,
      top      => top);

  -- clock generation
  clk <= not clk after clk_period/2;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait for clk_period/4;
    rst <= '1';
    wait for clk_period;
    rst <= '0';
    wait for clk_period;
    check(top = x"00", "Top value should be zero after reset");
    report "Test 1 passed" severity note;

    value_in <= x"EF";
    push <= '1';
    check(top = x"00",
          "Top value should not be updated immediately after push");
    report "Test 2 passed" severity note;
    wait for clk_period;
    push <= '0';
    check(top = x"EF", "Top value should be reflected one cycle after push");
    report "Test 3 passed" severity note;

    pop <= '1';
    check(top = x"EF", "Top value should not be updated immediately after pop");
    report "Test 4 passed" severity note;

    wait for clk_period;
    pop <= '0';
    check(top = x"00", "Top value should be reflected on cycle after pop");
    report "Test 5 passed" severity note;

    value_in <= x"ED";
    push <= '1';
    wait for clk_period;

    value_in <= x"23";
    wait for clk_period;
    check(top = x"23", "push number 2 in a row should work");
    report "Test 6 passed" severity note;

    value_in <= x"67";
    wait for clk_period;
    check(top = x"67", "push number 3 in a row should work");
    report "Test 7 passed" severity note;

    value_in <= x"F4";
    wait for clk_period;
    check(top = x"F4", "push number 4 in a row should work");
    report "Test 8 passed" severity note;
    
    value_in <= x"AA";
    wait for clk_period;
    check(top = x"AA", "push number 5 in a row should work");
    report "Test 9 passed" severity note;

    push <= '0';
    pop <= '1';
    wait for clk_period;
    check(top = x"F4", "pop number 1 in a row should work");
    report "Test 10 passed" severity note;

    wait for clk_period;
    check(top = x"67", "pop number 2 in a row should work");
    report "Test 11 passed" severity note;

    wait for clk_period;
    check(top = x"23", "pop number 3 in a row should work");
    report "Test 12 passed" severity note;

    wait for clk_period;
    check(top = x"ED", "pop number 4 in a row should work");
    report "Test 13 passed" severity note;

    wait for clk_period;
    check(top = x"00", "pop number 5 in a row should work");
    report "Test 14 passed" severity note;

    wait until clk = '1';
    assert false report "TEST SUCCESS" severity failure;
  end process WaveGen_Proc;

  

end architecture behavioural;

-------------------------------------------------------------------------------

configuration stack_tb_behavioural_cfg of stack_tb is
  for behavioural
  end for;
end stack_tb_behavioural_cfg;

-------------------------------------------------------------------------------
