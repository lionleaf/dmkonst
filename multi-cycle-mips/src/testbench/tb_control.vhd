--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:43:50 10/14/2014
-- Design Name:   
-- Module Name:   /home/lionleaf/projects/dmkonst/multi-cycle-mips/src/tb_control.vhd
-- Project Name:  multicyclemips
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Control
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_control IS
END tb_control;
 
ARCHITECTURE behavior OF tb_control IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Control
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         processor_enable : IN  std_logic;
         opcode : IN  std_logic_vector(5 downto 0);
         reg_dest : OUT  std_logic;
         branch : OUT  std_logic;
         mem_to_reg : OUT  std_logic;
         alu_override : OUT alu_override_t;
         mem_write_enable : OUT  std_logic;
         alu_src : OUT  std_logic;
         reg_write_enable : OUT  std_logic;
         update_pc : OUT  std_logic;
         jump : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal processor_enable : std_logic := '0';
   signal opcode : std_logic_vector(5 downto 0) := (others => '0');

 	--Outputs
   signal reg_dest : std_logic;
   signal branch : std_logic;
   signal mem_to_reg : std_logic;
   signal alu_override : alu_override_t;
   signal mem_write_enable : std_logic;
   signal alu_src : std_logic;
   signal reg_write_enable : std_logic;
   signal update_pc : std_logic;
   signal jump : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Control PORT MAP (
          clk => clk,
          reset => reset,
          processor_enable => processor_enable,
          opcode => opcode,
          reg_dest => reg_dest,
          branch => branch,
          mem_to_reg => mem_to_reg,
          alu_override => alu_override,
          mem_write_enable => mem_write_enable,
          alu_src => alu_src,
          reg_write_enable => reg_write_enable,
          update_pc => update_pc,
          jump => jump
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
--    processor_enable : IN  std_logic;
--         opcode : IN  std_logic_vector(5 downto 0);
--         reg_dest : OUT  std_logic;
--         branch : OUT  std_logic;
--         mem_to_reg : OUT  std_logic;
--         alu_override : OUT  std_logic;
--         mem_write_enable : OUT  std_logic;
--         alu_src : OUT  std_logic;
--         reg_write_enable : OUT  std_logic;
--         update_pc : OUT  std_logic;
--         jump : OUT  std_logic
   -- Stimulus process
   stim_proc: process
   begin		
        -- hold reset state for 100 ns
        reset <= '1';
        processor_enable <= '0';
        wait for 100 ns;	
        reset <= '0';
        
        wait for 10 * clk_period;
--        Check that processor is disabled.
        
        assert update_pc = '0' report "Update PC is non-zero with disabled processor." severity error;
        assert mem_write_enable = '1' report "Update PC is non-zero with disabled processor." severity failure;

        

		


      wait;
   end process;

END;
