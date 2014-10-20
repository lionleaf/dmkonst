LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.defs.all;

ENTITY tb_pc IS
END tb_pc;
 
ARCHITECTURE behavior OF tb_pc IS 
 
    COMPONENT PC
    PORT(
         reset : IN  std_logic;
         update_pc : IN  std_logic;
         clk : IN  std_logic;
         pc_control : IN pc_control_t;
         alu_zero : IN  boolean;
         immediate : IN  std_logic_vector(15 downto 0);
         PC : BUFFER  addr_t
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal update_pc : std_logic := '0';
   signal clk : std_logic := '0';
   signal pc_control : pc_control_t;
   signal alu_zero : boolean := false;
   signal immediate : std_logic_vector(15 downto 0) := (others => '0');

   -- OUT
   signal PC_sig : addr_t;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PC PORT MAP (
          reset => reset,
          update_pc => update_pc,
          clk => clk,
          pc_control => pc_control,
          alu_zero => alu_zero,
          immediate => immediate,
          PC => PC_sig        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   procedure check(condition:boolean; error_msg:string) is begin
            assert condition report error_msg severity failure;
        end procedure check;
   begin
      update_pc <= '0';   
      reset <= '1';
      
      wait for 100ns;
      
      reset   <= '0';
      pc_control <= step;
      alu_zero   <= false;
      immediate  <= X"1337";
      
      wait for clk_period*10;
      
      check(PC_sig = X"00", "PC is not 0 after reset");
      wait for clk_period;

      
      report "Incrementing PC by one!";
      
      update_pc <= '1';
      wait for clk_period;
      update_pc <= '0';

      check(PC_sig = X"01", "PC is not 1 after first update.");
      wait for clk_period;

      report "Incrementing PC by one!";
      
      update_pc <= '1';
      wait for clk_period;
      update_pc <= '0';

      check(PC_sig = X"02", "PC is not 2 after step.");
      wait for clk_period;

      report "Incrementing PC by one!";
      
      update_pc <= '1';
      wait for clk_period;
      update_pc <= '0';

      check(PC_sig = X"03", "PC is not 3 after step.");
      wait for clk_period;

      report "Jumping to 0x15!";
      
      pc_control <= jump;
      immediate <= X"0015";
      update_pc <= '1';
      wait for clk_period;
      update_pc <= '0';


      check(PC_sig = X"15", "PC is not 0x15 after jump.");
      wait for clk_period;
      
      report "Testing a failed beq!";

      pc_control <= branch;
      update_pc <= '1';
      wait for clk_period;
      update_pc <= '0';

      check(PC_sig = X"16", "PC is not 0x16 after not met beq.");
      wait for clk_period;

      report "Testing a beq!";

      pc_control <= branch;
      alu_zero   <= true;
      immediate  <= X"0010";
      update_pc <= '1';
      wait for clk_period;
      update_pc <= '0';

      check(PC_sig = X"27", "PC is not 0x27 after met beq.");
      wait for clk_period;
     
      report "---------TEST COMPLETED-----------!";
      
      wait;
   end process;

END;
