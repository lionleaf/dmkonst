  library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;
 
entity tb_control is end;
 
architecture behavior of tb_control is 

    -- component declaration for the unit under test (uut)
    component control
    port
        ( clk              : in   std_logic
        ; reset            : in   std_logic
        ; processor_enable : in   std_logic
        ; opcode           : in   std_logic_vector(5 downto 0)
        ; update_pc        : buffer  std_logic
        ; write_enable     : buffer  std_logic
        );
    end component;


    --inputs
    signal clk              : std_logic := '0';
    signal reset            : std_logic := '0';
    signal processor_enable : std_logic := '0';
    signal opcode           : std_logic_vector(5 downto 0) := (others => '0');

    --outputs
    signal update_pc    : std_logic;
    signal write_enable : std_logic;

    -- clock period definitions
    constant clk_period : time := 10 ns;

begin
 
    -- instantiate the unit under test (uut)
    uut: control
        port map
            ( clk => clk
            , reset => reset
            , processor_enable => processor_enable
            , opcode => opcode
            , update_pc => update_pc
            , write_enable => write_enable
            );

    -- clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
        procedure check(condition:boolean; error_msg:string) is begin
            assert condition report error_msg severity failure;
        end procedure check;

        procedure perform_reset is begin
            -- hold reset state for 100 ns
            reset <= '1';
            wait for 100 ns;
            reset <= '0';
        end procedure;


        procedure check_disabled
                ( opcode_in   : std_logic_vector(5 downto 0)
                ; opcode_desc : string
                )
        is begin
            perform_reset;
            processor_enable <= '0';
            opcode <= opcode_in;

            wait for clk_period;
            report "opcode: "& opcode_desc;
            for i in 1 to 10 loop
                check(update_pc = '0', "update_pc is high" & integer'image(i) & " cycles after reset");
                wait for clk_period;
            end loop;

        end procedure check_disabled;
        
    procedure check_state_change
                ( opcode_in : std_logic_vector(5 downto 0)
                  ; opcode_name : string
                )
    is begin
      opcode <= opcode_in;
      report "Checking opcode " & opcode_name;
      
      if opcode_in = "100011" or opcode_in = "101011" then
          -- For these two opcodes it is necessary with an extra state
          -- called stall.
          check(write_enable = '1', "write_enable is low.");
          check(update_pc = '0', "update_pc is high");
          wait for clk_period; -- Stall
          check(update_pc = '0', "update_pc is high");
          wait for clk_period; 
          check(write_enable = '0', "write_enable is high.");
          check(update_pc = '1', "update_pc is low");
             
      else
          check(write_enable = '1', "write_enable is low.");
          check(update_pc = '0', "update_pc is high");
          wait for clk_period;
          check(write_enable = '0', "write_enable is high.");
          check(update_pc = '1', "update_pc is low");
      end if;
      
      wait for clk_period; 
    
    end check_state_change;
    
    procedure wait_for_execute
    is begin
      opcode <= "000000";
             
      for i in 1 to 5 loop
          wait for clk_period;
      end loop;
        
      if update_pc = '1' then
          wait for clk_period;
      end if;
      
    end wait_for_execute;
    
    procedure check_control
        is begin
             processor_enable <= '1';
             perform_reset;
             wait_for_execute;
             
             check_state_change("000100", "000100: beq branch if equal.  ");
             check_state_change("000010", "000010: jump.  ");
             check_state_change("100011", "100011: lw load word.  ");
             check_state_change("101011", "101011: sw store word.  ");
             check_state_change("001111", "001111: lui load upper imm.  ");
             check_state_change("101011", "101011: sw store word.  ");
             check_state_change("000000", "000000: ALU operation (and, or, add, sub, slt, sll).  ");
                
        end procedure check_control;
     begin

        report "== Checking disabled processor ==";
        check_disabled("000000", "000000: add, sub, and, or, slt, sll");
        check_disabled("000010", "000010: jump");
        check_disabled("100011", "100011: load");
        check_disabled("101011", "101011: store");
        check_disabled("001111", "001111: load immediate");

        report "=== Testbench one passed successfully! ===";
        
        report "== Checking changes in the state machine. ==";
        check_control;
        report "=== Testbench two passed successfully! ===";
        report "=== Tests Sucess! ===";
        wait;

   end process;
end;
