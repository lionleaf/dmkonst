library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity MIPSProcessor is
    generic
        ( addr_width : integer := 8
        ; data_width : integer := 32
        );
    port
        ( clk, reset        : in  std_logic
        ; processor_enable  : in  std_logic
        ; imem_data_in      : in  std_logic_vector(data_width-1 downto 0)
        ; imem_address      : out std_logic_vector(addr_width-1 downto 0)
        ; dmem_data_in      : in  std_logic_vector(data_width-1 downto 0)
        ; dmem_address      : out std_logic_vector(addr_width-1 downto 0)
        ; dmem_data_out     : out std_logic_vector(data_width-1 downto 0)
        ; dmem_write_enable : out std_logic
        );
end MIPSProcessor;

architecture Behavioral of MIPSProcessor is

    subtype reg_number is std_logic_vector(4 downto 0);
    subtype data_t is std_logic_vector(data_width - 1 downto 0);
    subtype addr_t is std_logic_vector(7 downto 0);
    subtype opcode_t is std_logic_vector(5 downto 0);

    alias instruction : std_logic_vector(data_width - 1 downto 0)
                      is imem_data_in;

    -- decomposition of instruction
    alias rs : reg_number is instruction(25 downto 21);
    alias rt : reg_number is instruction(20 downto 16);
    alias rd : reg_number is instruction(15 downto 11);
    alias opcode : opcode_t is instruction(31 downto 26);

    -- register file IOs
    signal write_reg : reg_number;
    signal write_reg_enable : std_logic;
    signal write_reg_data  : data_t;
    signal read_reg_1_data : data_t;
    signal read_reg_2_data : data_t;

    -- alu IOs
    signal alu_op          : op_t;
    signal alu_zero        : boolean;
    signal alu_result      : signed(data_width - 1 downto 0);
    signal alu_muxed_input : data_t;

    -- pc IOs
    signal update_pc  : std_logic;
    signal next_pc    : addr_t;
    signal current_pc : addr_t;

    -- decode IOs
    signal write_enable     : std_logic;
    signal reg_dest         : std_logic;
    signal branch           : std_logic;
    signal mem_to_reg       : std_logic;
    signal alu_override     : alu_override_t;
    signal alu_immediate    : std_logic;
    signal jump             : std_logic;
    
    -- internal signals
    signal incremented_PC : addr_t;
    signal jump_addr : addr_t;
    signal imm_data_extended : data_t;
    signal imm_addr_extended : addr_t;
    signal branch_or_inc_addr : addr_t;
    signal branch_addr : addr_t;

begin

    imem_address  <= std_logic_vector(current_pc);
    dmem_address  <= std_logic_vector(alu_result(7 downto 0));
    dmem_data_out <= read_reg_2_data;

    register_file:
        entity work.register_file
            generic map
                ( data_width => data_width
                )
            port map
                ( clk => clk
                , reset => reset
                , read_reg_1 => rs
                , read_reg_2 => rt
                , write_reg => write_reg
                , write_enable => write_reg_enable
                , write_data => write_reg_data
                , read_data_1 => read_reg_1_data
                , read_data_2 => read_reg_2_data
                )
            ;

    alu:
        entity work.alu
            generic map
                ( data_width => data_width
                )
            port map
                ( operator => alu_op
                , operand_left => signed(read_reg_1_data)
                , operand_right => signed(alu_muxed_input)
                , result_is_zero => alu_zero
                , result => alu_result
                )
            ;

    pc:
        entity work.pc
            generic map
                ( addr_width => addr_width
                )
            port map
                ( reset => reset
                , clk => clk
                , update_pc => update_pc
                , next_pc => next_pc
                , current_pc => current_pc
                )
            ;

    control:
        entity work.control
            port map
                ( reset => reset
                , clk => clk
                , processor_enable => processor_enable
                , opcode => opcode
                , update_pc => update_pc
                , write_enable => write_enable
                )
            ;

    decode:
        entity work.decode
            port map
                ( write_enable => write_enable
                , opcode => opcode
                , reg_dest => reg_dest
                , branch => branch
                , mem_to_reg => mem_to_reg
                , alu_override => alu_override
                , mem_write_enable => dmem_write_enable
                , alu_src => alu_immediate
                , reg_write_enable => write_reg_enable
                , jump => jump
                )
            ;

    incremented_PC <= std_logic_vector(unsigned(current_PC) + 1);

    jump_addr <= incremented_PC(ADDR_WIDTH - 1 downto 26) & instruction(25 downto 0)
                 when ADDR_WIDTH > 26
                 else instruction(ADDR_WIDTH - 1 downto 0);

    branch_addr <= std_logic_vector(signed(incremented_PC) + signed(imm_addr_extended));

    imm_data_extended <= std_logic_vector(resize(signed(instruction(15 downto 0)), DATA_WIDTH));
    imm_addr_extended <= std_logic_vector(resize(signed(instruction(15 downto 0)), ADDR_WIDTH));

    branch_or_inc_addr <= branch_addr
                          when branch = '1' and alu_zero
                          else incremented_PC;

    next_PC <= jump_addr
               when jump = '1'
               else branch_or_inc_addr;

    alu_muxed_input <= imm_data_extended
                       when alu_immediate = '1'
                       else read_reg_2_data;	

    write_reg <= instruction(15 downto 11)
                 when reg_dest = '1'
                 else instruction(20 downto 16);


    write_reg_data <= dmem_data_in
                      when mem_to_reg = '1'
                      else std_logic_vector(alu_result);

    with alu_override
    select alu_op <= op_sub when override_sub,
                     op_add when override_add,
                     op_sll16 when override_sll16,
                     to_op_t(instruction(5 downto 0)) when others;

end Behavioral;
