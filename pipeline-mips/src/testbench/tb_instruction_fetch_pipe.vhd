LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_instruction_fetch_pipe IS
END tb_instruction_fetch_pipe;
 
ARCHITECTURE behavior OF tb_instruction_fetch_pipe IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT instruction_fetch_pipe
    PORT
        (instructions_in : IN  std_logic_vector(31 downto 0)
         ;instructions_out : buffer  std_logic_vector(31 downto 0)
         ;program_counter_pluss_one_in : IN  std_logic_vector(7 downto 0)
         ;program_counter_pluss_one_out : buffer  std_logic_vector(7 downto 0)
         ;reset : IN  std_logic
         ;clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal instructions_in : std_logic_vector(31 downto 0) := (others => '0');
   signal program_counter_pluss_one_in : std_logic_vector(7 downto 0) := (others => '0');
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal instructions_out : std_logic_vector(31 downto 0);
   signal program_counter_pluss_one_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: instruction_fetch_pipe PORT MAP 
          (instructions_in => instructions_in
          ,instructions_out => instructions_out
          ,program_counter_pluss_one_in => program_counter_pluss_one_in
          ,program_counter_pluss_one_out => program_counter_pluss_one_out
          ,reset => reset
          ,clk => clk
          );

   -- Clock process definitions
   clk_process  :   process
   
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
      reset                         <= '1';
      instructions_in               <= std_logic_vector(to_unsigned(1, 32));
      program_counter_pluss_one_in  <= std_logic_vector(to_unsigned(2, 8));
      
   
      wait for 100 ns;
      
      check(instructions_out                = std_logic_vector(to_unsigned(0, 32)), "Reset is high, instructions out should be zero");
      check(program_counter_pluss_one_out   = std_logic_vector(to_unsigned(0, 8)), "Reset is high, PC out should be zero");
      
      wait for 3 * clk_period;	

      reset <= '0';

      wait for clk_period * 10;
      report "-- First cycle --";
      
      instructions_in               <= std_logic_vector(to_unsigned(5, 32));
      program_counter_pluss_one_in  <= std_logic_vector(to_unsigned(4, 8));
      
      wait for clk_period;
      report "-- Second cycle --";
      
      instructions_in               <= std_logic_vector(to_unsigned(3, 32));
      program_counter_pluss_one_in  <= std_logic_vector(to_unsigned(6, 8));
      
      report "-- instructions_in = " & integer'image( to_integer(unsigned(instructions_out)) );
      report "-- PC_out = " & integer'image( to_integer(unsigned(program_counter_pluss_one_out)) );
      
      check(instructions_out                = std_logic_vector(to_unsigned(5, 32)), "Race condition with instructions_out");
      check(program_counter_pluss_one_out   = std_logic_vector(to_unsigned(4, 8)), "Race condition with program_counter_pluss_one_out");
      
      wait for clk_period;
      report "-- Second cycle --";
      
      report "== Test Sucess! ==";
      
      
      

      wait;
   end process;

end;
