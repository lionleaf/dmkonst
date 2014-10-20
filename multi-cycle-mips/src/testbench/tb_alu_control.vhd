--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:08:01 10/20/2014
-- Design Name:   
-- Module Name:   /opt/dmlab/home/andrels/dmkonst/multi-cycle-mips/src/testbench/tb_alu_control.vhd
-- Project Name:  multicyclemips
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu_control
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.defs.all;
 
ENTITY tb_alu_control IS
END tb_alu_control;
 
ARCHITECTURE behavior OF tb_alu_control IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu_control
    PORT(
         instruction_funct : IN  std_logic_vector(5 downto 0);
         funct_override : IN  alu_override_t;
         alu_function : OUT  alu_funct_t
        );
    END COMPONENT;
    

   --Inputs
   signal instruction_funct : std_logic_vector(5 downto 0) := (others => '0');
   signal funct_override : alu_override_t;

 	--Outputs
   signal alu_function : alu_funct_t;
  
   signal clock : std_logic;
   
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu_control PORT MAP (
          instruction_funct => instruction_funct,
          funct_override => funct_override,
          alu_function => alu_function
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process is
      
      procedure check(condition:boolean; error_msg:string) is begin
            assert condition report error_msg severity failure;
        end procedure check;
        
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      wait for clock_period*10;

      report "-----BEGIN TEST-------";

      -- insert stimulus here 
      report "Check funct without override";
      funct_override <= override_disabled;

      
      report "Check add";
      instruction_funct <= "100000";
      wait for clock_period;
      check(alu_function = alu_add, "ALU add without override did not work");
      
      report "Check sub";
      instruction_funct <= "100010";
      wait for clock_period;
      check(alu_function = alu_sub, "ALU sub without override did not work");
      
      report "Check slt";
      instruction_funct <= "101010";
      wait for clock_period;
      check(alu_function = alu_slt, "ALU slt without override did not work");
      
      report "Check and";
      instruction_funct <= "100100";
      wait for clock_period;
      check(alu_function = alu_and, "ALU and without override did not work");
      
      report "Check sub";
      instruction_funct <= "100101";
      wait for clock_period;
      check(alu_function = alu_or, "ALU or without override did not work");
      
      
      report "Check add override";
      funct_override <= override_add;
      instruction_funct <= "101010";
      wait for clock_period;
      check(alu_function = alu_add, "ALU add override did not work");
      
      report "Check sub override";
      funct_override <= override_sub;
      instruction_funct <= "101010";
      wait for clock_period;
      check(alu_function = alu_sub, "ALU sub override did not work");
      
      
      report "Check sll16 override";
      funct_override <= override_sll16;
      instruction_funct <= "101010";
      wait for clock_period;
      check(alu_function = alu_sll16, "ALU sll16 override did not work");
      
  

      report "-----TEST COMPLETE-------";

      wait;
   end process;

END;
