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
    subtype addr_t is std_logic_vector(data_width - 1 downto 0);
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
    signal alu_zero   : std_logic;
    signal alu_result : data_t;

    -- pc IOs
    signal update_pc  : std_logic;
    signal next_pc    : addr_t;
    signal current_pc : addr_t;

    -- decode IOs
    signal write_enable     : std_logic;
    signal inst_type_i      : std_logic;
    signal branch           : std_logic;
    signal mem_to_reg       : std_logic;
    signal alu_override     : alu_override_t;
    signal alu_immediate    : std_logic;
    signal reg_write_enable : std_logic;
    signal jump             : std_logic;

begin

    imem_address  <= std_logic_vector(current_pc);
    dmem_address  <= std_logic_vector(alu_result(7 downto 0));
    dmem_data_out <= read_reg_2_data;

--    register_file:
--        entity register_file
--            generic map
--                ( data_width => data_width
--                )
--            port map
--                ( clk => clk
--                , read_reg_1 => rs
--                , read_reg_2 => rt
--                , write_reg => write_reg
--                , write_enable => write_reg_enable
--                , write_data => write_reg_data
--                , read_data_1 => read_reg_1_data
--                , read_data_2 => read_reg_2_data
--                )
--            ;
--
--    alu:
--        entity alu
--            generic map
--                ( data_width => data_width
--                )
--            port map
--                ( operand_left => signed(read_reg_1_data)
--                , operand_right => signed(alu_muxed_input)
--                , result_is_zero => alu_zero
--                , result => alu_result
--                )
--            ;
--
--    pc:
--        entity pc
--            generic map
--                ( addr_width => addr_width
--                )
--            port map
--                ( reset => reset
--                , clk => clk
--                , update_pc => update_pc
--                , next_pc => next_pc
--                , current_pc => current_pc
--                )
--            ;
--
--    control:
--        entity control
--            port map
--                ( reset => reset
--                , clk => clk
--                , processor_enable => processor_enable
--                , opcode => opcode
--                , update_pc => update_pc
--                , write_enable => write_enable
--                )
--            ;
--
--    decode:
--        entity decode
--            port map
--                ( write_enable => write_enable
--                , opcode => opcode
--                , reg_dest => reg_dest
--                , branch => branch
--                , mem_to_reg => mem_to_reg
--                , alu_override => alu_override
--                , mem_write_enable => dmem_write_enable
--                , alu_src => alu_immediate
--                , reg_write_enable => reg_write_enable
--                , jump => jump
--                )
--            ;

end Behavioral;
