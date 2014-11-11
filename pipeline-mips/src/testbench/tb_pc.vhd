library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.test_utils.all;
use work.defs.all;
  
entity tb_pc is
end tb_pc;
 
architecture behavior of tb_pc is 
   --Inputs
   signal reset 					: std_logic := '0';
   signal clk 						: std_logic := '0';
   signal processor_enable 	: std_logic := '0';
   signal branch_en 				: std_logic := '0';
   signal branch_addr 			: addr_t 	:= (others => '0');

 	--Outputs
   signal PC 						: addr_t;
   signal incremented_PC 		: addr_t;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: 
		entity work.PC port map (
          reset 					=> reset,
          clk 						=> clk,
          processor_enable 	=> processor_enable,
          branch_en 				=> branch_en,
          branch_addr 			=> branch_addr,
          PC 						=> PC,
          incremented_PC 		=> incremented_PC
        );

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
	
	----------Check Reset-----------
	procedure check_reset
		is begin
		
		report "== Testing Reset ==";
		
		reset 				<= '1';
		
		branch_en 			<= '0';
		processor_enable 	<= '0';
		
		wait for clk_period;
		check(PC = (PC'range => '1'), "PC should be zeros when reset is enabled.");
		
		branch_en 			<= '0';
		processor_enable 	<= '1';
		
		wait for clk_period;
		check(PC = (PC'range => '1'), "PC should be zeros when reset is enabled.");
		
		branch_en 			<= '1';
		processor_enable 	<= '0';
		
		wait for clk_period;
		check(PC = (PC'range => '1'), "PC should be zeros when reset is enabled.");
		
		branch_en 			<= '1';
		processor_enable 	<= '1';
		
		wait for clk_period;
		check(PC = (PC'range => '1'), "PC should be zeros when reset is enabled.");
	
	end procedure check_reset;
	

	
	----------Processor Enable-----------
	procedure check_program_counter
		is begin
		
		report "== Testing Processor enable ==";
		
		reset 				<= '0';
		processor_enable 	<= '1';
		branch_en			<= '0';
		wait for clk_period;
		
		branch_addr 		<= X"00";
		processor_enable 	<= '0';
		
		wait for clk_period;
		check(PC = X"00",  integer'image(to_integer(signed(pc))) & ": PC should  not change value while the processor is disabled.");
		
		wait for clk_period;
		processor_enable 	<= '1';
		check(processor_enable = '0', std_logic'image(processor_enable) & ": processor_enable should be low until next cycle after enabling.");
		
		check(PC = X"00", integer'image(to_integer(signed(pc))) & ": PC should  not change value while the processor is disabled.");
		
		wait for clk_period;
		check(PC = X"01", integer'image(to_integer(signed(pc))) & ": PC should  not change the first cycle after the processor is enabled.");
		check(processor_enable = '1', std_logic'image(processor_enable) & ": processor_enable should be high one cycle after enabling.");
		
		wait for clk_period; 
		check(PC = X"02", integer'image(to_integer(signed(pc))) & ": PC should have value 0x02 after two clock cycle while the processor is enabled.");
		
		wait for clk_period; 
		check(PC = X"03", integer'image(to_integer(signed(pc))) & ": PC should have value 0x03 after three clock cycle while the processor is enabled.");
		
		wait for clk_period; 
		check(PC = X"04", integer'image(to_integer(signed(pc))) & ": PC should have value 0x04 after three clock cycle while the processor is enabled.");
		
		wait for clk_period; 
		check(PC = X"05", integer'image(to_integer(signed(pc))) & ": PC should have value 0x05 after three clock cycle while the processor is enabled.");
		
	end procedure check_program_counter;
	
	procedure check_branch
		is begin
		
		report "== Testing branch ==";
		
		branch_addr 		<= X"10";
		processor_enable 	<= '1';
		reset 				<= '0';
		branch_en 			<= '0';
		
		wait for clk_period;
		branch_en <= '1';
		
		wait for clk_period;
		check(PC = X"10", integer'image(to_integer(signed(pc))) & ": PC should change to branch address when branch is enabled");
		branch_en <= '0';
		
		wait for clk_period;
		check(PC = X"11", integer'image(to_integer(signed(pc))) & ": PC should start to increment when branch_en is low");
		
		wait for clk_period;
		check(PC = X"12", integer'image(to_integer(signed(pc))) & ": PC should continue to increment.");
		
		
	end procedure check_branch;
   
	begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
	
      wait for clk_period*10;
			check_reset;
			check_program_counter;
			check_branch;
      
			report "== Test Success ==";
		
      wait;
   end process;

end;
