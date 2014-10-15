library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;
 
entity tb_decode is end;
 
architecture behavior of tb_decode is 

    -- component declaration for the unit under test (uut)
    component control
    port
        ( clk              : in   std_logic
        ; reset            : in   std_logic
        ; processor_enable : in   std_logic
        ; opcode           : in   std_logic_vector(5 downto 0)
        ; update_pc        : out  std_logic
        );
    end component;


    --inputs
    signal clk              : std_logic := '0';
    signal reset            : std_logic := '0';
    signal processor_enable : std_logic := '0';
    signal opcode           : std_logic_vector(5 downto 0) := (others => '0');

    --outputs
    signal update_pc : std_logic;

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

    begin

        report "== checking disabled processor ==";
        check_disabled("000000", "000000: add, sub, and, or, slt, sll");
        check_disabled("000010", "000010: jump");
        check_disabled("100011", "100011: load");
        check_disabled("101011", "101011: store");
        check_disabled("001111", "001111: load immediate");

        report "=== testbench passed successfully! ===";
        wait;

   end process;
end;
