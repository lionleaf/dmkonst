LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

ENTITY tb_register_file IS
END tb_register_file;
 
ARCHITECTURE behavior OF tb_register_file IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT register_file
    PORT(
         clk : IN  std_logic;
         read_reg_1 : IN  std_logic_vector(4 downto 0);
         read_reg_2 : IN  std_logic_vector(4 downto 0);
         write_reg : IN  std_logic_vector(4 downto 0);
         write_data : IN  std_logic_vector(31 downto 0);
         write_enable : IN  std_logic;
         read_data_1 : OUT  std_logic_vector(31 downto 0);
         read_data_2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal read_reg_1 : std_logic_vector(4 downto 0) := (others => '0');
   signal read_reg_2 : std_logic_vector(4 downto 0) := (others => '0');
   signal write_reg : std_logic_vector(4 downto 0) := (others => '0');
   signal write_data : std_logic_vector(31 downto 0) := (others => '0');
   signal write_enable : std_logic := '0';

 	--Outputs
   signal read_data_1 : std_logic_vector(31 downto 0);
   signal read_data_2 : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: register_file PORT MAP (
          clk => clk,
          read_reg_1 => read_reg_1,
          read_reg_2 => read_reg_2,
          write_reg => write_reg,
          write_data => write_data,
          write_enable => write_enable,
          read_data_1 => read_data_1,
          read_data_2 => read_data_2
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
   procedure check(condition:boolean; error_msg:string) is begin
            assert condition report error_msg severity failure;
        end procedure check;
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
      report "Checking special register 0";
      read_reg_1 <= "00000";
      read_reg_2 <= "00000";
      wait for clk_period;

      check(read_data_1 = X"00000000", "Special register zero not 0 from port 1");
      check(read_data_2 = X"00000000", "Special register zero not 0 from port 2");
  
      wait for clk_period;


      report "Writing to every register";
       write_enable <= '1';

      for i in 1 to 31 loop
          write_reg  <= std_logic_vector(to_unsigned(i,5));
          write_data <= std_logic_vector(to_signed(i,32));
          wait for clk_period;
      end loop;
      
      write_enable <= '0';

      wait for clk_period;

      report "Reading from every register";
      for i in 1 to 31 loop
          read_reg_1 <= std_logic_vector(to_unsigned(i,5));
          read_reg_2 <= std_logic_vector(to_unsigned(i,5));
          wait for clk_period;

          check(read_data_1 = std_logic_vector(to_signed(i,32)), "Register read value wrong");
          check(read_data_2 = std_logic_vector(to_signed(i,32)), "Register read value wrong");
          
      end loop;
      
      report "---------TEST COMPLETED-----------!";
      
      wait;
   end process;

END;
