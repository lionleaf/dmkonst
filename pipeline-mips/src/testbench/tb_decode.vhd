library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;
 
entity tb_decode is end;
 
architecture behavior of tb_decode is 
 
    -- component declaration for the unit under test (uut)
    component decode
    port
        ( instruction 		: in   inst_t
        ; processor_enable : in  std_logic
        ; branch_en   		: out  std_logic
        ; mem_to_reg  		: out  std_logic
        ; mem_wen     		: out  std_logic
        ; reg_wen     		: out  std_logic
        ; inst_type_I 		: out  std_logic
        ; alu_funct   		: out  alu_funct_t
        ; alu_shamt   		: out  alu_shamt_t
        );
    end component;

    --inputs
    signal opcode           : std_logic_vector(5 downto 0) := (others => '0');
    signal write_enable     : std_logic := '0';

    --outputs
    signal reg_dest         : std_logic;
    signal pc_control       : pc_control_t;
    signal mem_to_reg       : std_logic;
    signal alu_override     : alu_override_t;
    signal mem_write_enable : std_logic;
    signal alu_src          : std_logic;
    signal reg_write_enable : std_logic;

    -- clock period definitions
    constant clk_period     : time := 10 ns;

begin

    -- instantiate the unit under test (uut)
    uut: decode
        port map
            ( write_enable => write_enable
            , opcode => opcode
            , reg_dest => reg_dest
            , pc_control => pc_control
            , mem_to_reg => mem_to_reg
            , alu_override => alu_override
            , mem_write_enable => mem_write_enable
            , alu_src => alu_src
            , reg_write_enable => reg_write_enable
            );

   -- stimulus process
   stim_proc: process

        procedure check(condition:boolean; error_msg:string) is begin
            assert condition report error_msg severity failure;
        end procedure check;

        procedure check_disabled
            ( opcode_in : std_logic_vector(5 downto 0)
            ; opcode_desc : string
            )
        is begin
            write_enable <= '0';
            opcode <= opcode_in;

            wait for clk_period;

            report "opcode: "& opcode_desc;
            check(mem_write_enable = '0', "mem_write_enable is not 0");
            check(reg_write_enable = '0', "reg_write_enable is not 0");
        end procedure check_disabled;

    begin
        -- let other messages come first
        wait for 1 ps;


        report "== Checking write disabled ==";
        
        check_disabled("000000", "000000: add, sub, and, or, slt, sll");
        check_disabled("000010", "000010: jump");
        check_disabled("000100", "000100: branch");
        check_disabled("100011", "100011: load");
        check_disabled("101011", "101011: store");
        check_disabled("001111", "001111: load immediate");


        report "== Checking write enabled ==";

        report "opcode: 000000: add, sub, and, or, slt, sll";
        write_enable <= '1';
        opcode <= "000000";
        wait for clk_period;
        check(reg_dest         = '1', "alu instructions are r-type. reg_dest should be 1");
        check(alu_src          = '0', "alu instructions are r-type. alu_src should be 0");
        check(alu_override     = override_disabled, "alu_override is not orverride_disabled");
        check(pc_control       = step, "pc control is not step");
        check(mem_to_reg       = '0', "mem_to_reg is not 0");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '1', "reg_write_enable is not 1");


        report "opcode: 000010: jump";
        write_enable <= '1';
        opcode <= "000010";
        wait for clk_period;
        check(pc_control       = jump, "pc control is not jump");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '0', "reg_write_enable is not 0");


        report "opcode: 100011: load";
        write_enable <= '1';
        opcode <= "100011";
        wait for clk_period;
        check(reg_dest         = '0', "load instructions are i-type. reg_dest should be 0");
        check(alu_src          = '1', "load instructions are i-type. alu_src should be 1");
        check(alu_override     = override_add, "alu_override is not override_add. jump needs to add rs and imm");
        check(pc_control       = step, "pc control is not step");
        check(mem_to_reg       = '1', "mem_to_reg is not 1");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '1', "reg_write_enable is not 1");
        
        
        report "opcode: 000100: branch";
        write_enable <= '1';
        opcode <= "000100";
        wait for clk_period;
        check(reg_dest         = '1', "load instructions are i-type. reg_dest should be 0");
        check(alu_src          = '0', "load instructions are i-type. alu_src should be 1");
        check(alu_override     = override_sub, "alu_override is not override_add. jump needs to add rs and imm");
        check(pc_control       = branch, "pc control is not step");
        check(mem_to_reg       = '0', "mem_to_reg is not 1");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '0', "reg_write_enable is not 1");


        report "opcode: 101011: store";
        write_enable <= '1';
        opcode <= "101011";
        wait for clk_period;
        check(reg_dest         = '0', "store instructions are i-type. reg_dest should be 0");
        check(alu_src          = '1', "store instructions are i-type. alu_src should be 1");
        check(alu_override     = override_add, "alu_override is not override_add. jump needs to add rs and imm");
        check(pc_control       = step, "pc control is not step");
        check(mem_write_enable = '1', "mem_write_enable is not 1");
        check(reg_write_enable = '0', "reg_write_enable is not 0");


        report "opcode: 001111: load immediate";
        write_enable <= '1';
        opcode <= "001111";
        wait for clk_period;
        check(reg_dest         = '0', "load imm instructions are i-type. reg_dest should be 0");
        check(alu_src          = '1', "load imm instructions are i-type. alu_src should be 1");
        check(alu_override     = override_sll16, "alu_override is not override_sll16");
        check(pc_control       = step, "pc control is not step");
        check(mem_to_reg       = '0', "mem_to_reg is not 0");
        check(mem_write_enable = '0', "mem_write_enable is not 0");
        check(reg_write_enable = '1', "reg_write_enable is not 1");


        report "=== Testbench passed successfully! ===";

        wait;
   end process;

end;
