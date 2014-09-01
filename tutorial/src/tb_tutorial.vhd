--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:47:32 09/01/2014
-- Design Name:   
-- Module Name:   /opt/dmlab/home/kulia/datakonst/tutorial/src/tb_tutorial.vhd
-- Project Name:  tutorial
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: tutorial
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_tutorial IS
END tb_tutorial;
 
ARCHITECTURE behavior OF tb_tutorial IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT tutorial
    PORT(
         A : IN  std_logic;
         B : IN  std_logic;
         C : IN  std_logic;
         X : OUT  std_logic;
         Y : OUT  std_logic;
         Z : OUT  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic := '0';
   signal B : std_logic := '0';
   signal C : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal X : std_logic;
   signal Y : std_logic;
   signal Z : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: tutorial PORT MAP (
          A => A,
          B => B,
          C => C,
          X => X,
          Y => Y,
          Z => Z,
          clk => clk,
          reset => reset
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
   begin		
			report "Hello World!";
			A <= '0'; B <='1'; C <= '0';
			reset <= '1';
         wait for 100 ns; -- wait until global set/reset completes
			reset <= '0';
        -- Add user defined stimulus here
			
			wait for 50*clk_period;
			
			for i in 0 to 10 loop
				report "X = " & std_logic'image(X)
									  & " Y = " & std_logic'image(Y)
									  & " Z = " & std_logic'image(y);
				A <= not B; B <= not C; C <= not A;
				
				wait for 100*clk_period;
			end loop;
	
			
			
        wait; -- will wait forever
   end process;

END;
