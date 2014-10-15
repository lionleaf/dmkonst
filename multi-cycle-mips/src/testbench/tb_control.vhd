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
        procedure check(condition:boolean; error_msg:string) is begin
            assert condition report error_msg severity failure;
        end procedure check;

        subtype opcode_t is std_logic_vector(5 downto 0);

        procedure perform_reset is begin
            -- hold reset state for 100 ns
            reset <= '1';
            wait for 100 ns;
            reset <= '0';
        end procedure;


        procedure check_disabled
                ( opcode_in : std_logic_vector(5 downto 0)
                ; opcode_desc : string
        ) is begin
            perform_reset;
            processor_enable <= '0';
            opcode <= opcode_in;

            wait for clk_period;

            report "Opcode: "& opcode_desc;
            check(update_pc = '0', "update_pc is high");
            check(mem_write_enable = '0', "mem_write_enable is high");
            check(reg_write_enable = '0', "reg_write_enable is high");
        end procedure check_disabled;

   begin
        report "== Checking disabled processor ==";
        check_disabled("000000", "000000: add, sub, and, or, slt, sll");
        check_disabled("000010", "000010: jump");
        check_disabled("100011", "100011: load");
        check_disabled("101011", "101011: store");
        check_disabled("001111", "001111: load immediate");


        report "== Checking enabled processor ==";


        report "Opcode: 000000: add, sub, and, or, slt, sll";
        perform_reset;
        processor_enable <= '1';
        opcode <= "000000";
        wait for clk_period;
        check(reg_dest         = '1', "alu instructions are r-type. reg_dest should be 1");
        check(alu_src          = '0', "alu instructions are r-type. alu_src should be 0");
        check(alu_override     = override_disabled, "alu_override is not orverride_disabled");
        check(branch           = '0', "branch is not 0");
        check(jump             = '0', "jump is not 1");
        check(mem_to_reg       = '0', "mem_to_reg is not 0");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '1', "reg_write_enable is not 1");


        report "Opcode: 000010: jump";
        perform_reset;
        processor_enable <= '1';
        opcode <= "000010";
        wait for clk_period;
        check(jump             = '1', "jump is not 1");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '0', "reg_write_enable is not 0");


        report "Opcode: 100011: load";
        perform_reset;
        processor_enable <= '1';
        opcode <= "100011";
        wait for clk_period;
        check(reg_dest         = '0', "load instructions are i-type. reg_dest should be 0");
        check(alu_src          = '1', "load instructions are i-type. alu_src should be 1");
        check(alu_override     = override_add, "alu_override is not override_add. jump needs to add rs and imm");
        check(branch           = '0', "branch is not 0");
        check(jump             = '0', "jump is not 0");
        check(mem_to_reg       = '1', "mem_to_reg is not 1");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '1', "reg_write_enable is not 1");


        report "Opcode: 101011: store";
        perform_reset;
        processor_enable <= '1';
        opcode <= "101011";
        wait for clk_period;
        check(reg_dest         = '0', "store instructions are i-type. reg_dest should be 0");
        check(alu_src          = '1', "store instructions are i-type. alu_src should be 1");
        check(alu_override     = override_add, "alu_override is not override_add. jump needs to add rs and imm");
        check(branch           = '0', "branch is not 0");
        check(jump             = '0', "jump is not 0");
        check(mem_write_enable = '1', "mem_write_enable is not 1");
        check(reg_write_enable = '0', "reg_write_enable is not 0");


        report "Opcode: 001111: load immediate";
        perform_reset;
        processor_enable <= '1';
        opcode <= "001111";
        wait for clk_period;
        check(reg_dest         = '0', "load imm instructions are i-type. reg_dest should be 0");
        check(alu_src          = '1', "load imm instructions are i-type. alu_src should be 1");
        check(alu_override     = override_sll16, "alu_override is not override_sll16");
        check(branch           = '0', "branch is not 0");
        check(jump             = '0', "jump is not 0");
        check(mem_to_reg       = '0', "mem_to_reg is not 0");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '1', "reg_write_enable is not 1");


        report "=== Testbench passed successfully! ===";
        wait;
   end process;

END;
