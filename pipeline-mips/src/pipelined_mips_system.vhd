library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity pipelined_processor is
    generic
        ( addr_width : integer := 8
        ; data_width : integer := 32
        );
    port
        ( clk, reset        : in  std_logic
        ; processor_enable  : in  std_logic
        ; imem_data_in      : in  std_logic_vector(data_width-1 downto 0)
        ; imem_address      : buffer std_logic_vector(addr_width-1 downto 0)
        ; dmem_data_in      : in  std_logic_vector(data_width-1 downto 0)
        ; dmem_address      : buffer std_logic_vector(addr_width-1 downto 0)
        ; dmem_data_out     : buffer std_logic_vector(data_width-1 downto 0)
        ; dmem_write_enable : buffer std_logic
        );
end pipelined_processor;

architecture Behavioral of pipelined_processor is

    function to_std_logic(p: boolean)
    return std_logic
    is begin
        if p then
            return '1';
        else
            return '0';
        end if;
    end;

    subtype reg_number is std_logic_vector(4 downto 0);

    subtype opcode_t is std_logic_vector(5 downto 0);

    alias instruction : std_logic_vector(31 downto 0)
                      is imem_data_in;


    -- decomposition of instruction
    alias rs        : reg_number    is instruction(25 downto 21);
    alias rt        : reg_number    is instruction(20 downto 16);
    alias rd        : reg_number    is instruction(15 downto 11);
    alias opcode    : opcode_t      is instruction(31 downto 26);

    -- register file IOs
    signal write_reg : reg_number;
    signal write_reg_enable : std_logic;
    signal write_reg_data  : data_t;
    signal read_reg_1_data : data_t;
    signal read_reg_2_data : data_t;

    -- alu IOs
    signal alu_function    : alu_funct_t;
    signal alu_zero        : boolean;
    signal alu_result      : signed(data_width - 1 downto 0);
    signal alu_muxed_input : data_t;

    -- decode IOs
    signal write_enable     : std_logic;
    signal reg_dest         : std_logic;
    signal pc_control       : pc_control_t;
    signal mem_to_reg       : std_logic;
    signal alu_override     : alu_override_t;
    signal alu_immediate    : std_logic;
    
    
    -- control IOs
    signal update_pc        : std_logic;

    -- internal signals
    signal imm_data_extended : data_t;
    
    -- fetch
    signal incremented_PC_fetch     : addr_t;
    signal incremented_PC_fetch_in  : addr_t;
    signal pc_source                : std_logic;
    signal branch_address           : addr_t;
    
    -- decode
    signal incremented_PC_decode    : addr_t;
    signal instructions_decode_in   : std_logic_vector(31 downto 0);
    signal read_reg_1_data_decode   : data_t;
    signal read_reg_2_data_decode   : data_t;
    
    signal data_1_execute           : data_t;
    signal data_2_execute           : data_t;
    
    -- Execution
    
    signal instruction_execution_in         : std_logic_vector(31 downto 0);
    
    alias rt_execution_in                   : reg_number    is instruction_execution_in(20 downto 16);
    alias rd_execution_in                   : reg_number    is instruction_execution_in(15 downto 11);
    
    signal reg_dst_execution                : reg_number;
    
    signal alu_zero_execute_out             : boolean := true;
    
    signal alu_result_execute_out           : signed (data_width - 1 downto 0) := to_signed(0, data_width);
    signal branch_address_execute           : addr_t;
    
    signal register_destination_execution   : addr_t;
    
    signal register_destination             : std_logic;
    
    -- Memory
    
    signal register_destination_memory      :   reg_number;
    signal alu_zero_memory_out              :   boolean := true;
    signal branch                           :   std_logic;
    
    -- Write back
    signal alu_result_write_back_in         :   signed (data_width - 1 downto 0) := to_signed(0, data_width);
    
begin

    dmem_address  <= std_logic_vector(alu_result(7 downto 0));
    dmem_data_out <= read_reg_2_data;
    
    -- Instruction Fetch
         
    pc:
        entity work.pc
            generic map
                ( addr_width => addr_width
                )
            port map
                ( reset                 => reset
                , clk                   => clk
                , pc_source             => pc_source
                , branch_addr           => branch_address
                , PC                    => imem_address
                , incremented_PC        => incremented_PC_fetch  
                )
            ;
    
    instruction_fetch_pipe:
            entity work.instruction_fetch_pipe
                port map
                    ( reset                         => reset
                    , clk                           => clk
                    , instructions_in               => imem_data_in 
                    , instructions_out              => instructions_decode_in
                    , program_counter_pluss_one_in  => incremented_PC_fetch 
                    , program_counter_pluss_one_out => incremented_PC_decode
                    )
                ;
               
    -- Instruction Decode

    register_file:
        entity work.register_file
            generic map
                ( data_width => data_width
                )
            port map
                ( clk           => clk
                , read_reg_1    => rs
                , read_reg_2    => rt
                , write_reg     => write_reg
                , write_enable  => write_reg_enable
                , write_data    => write_reg_data
                , read_data_1   => read_reg_1_data_decode
                , read_data_2   => read_reg_2_data_decode
                )
            ;
      
    instruction_decode_pipe:
        entity work.instruction_decode_pipe
            port map
                ( clk                   => clk
                , reset                 => reset
                , incremented_PC_in     => incremented_PC_decode
                , incremented_PC_out    => incremented_PC_fetch_in
                , data_1_in             => read_reg_1_data_decode
                , data_1_out            => data_1_execute
                , data_2_in             => read_reg_2_data_decode
                , data_2_out            => data_2_execute
                , instructions_in       => instructions_decode_in
                , instructions_out      => instruction_execution_in
                )
            ;
                  
    -- Execution

    alu:
        entity work.alu
            generic map
                ( data_width => data_width
                )
            port map
                ( operator          => alu_function
                , operand_left      => signed(data_1_execute)
                , operand_right     => signed(alu_muxed_input)
                , result_is_zero    => alu_zero_execute_out
                , result            => alu_result_execute_out
                )
            ;
            
    alu_muxed_input <= imm_data_extended
                       when alu_immediate = '1'
                       else data_2_execute;	
                       
    branch_address_select: 
        entity work.branch_address_select
            port map
                ( left_oprand   => instruction_execution_in     
                , right_oprand  => incremented_PC_fetch_in
                , result        => branch_address_execute
                )
            ;

    execution_pipe:
        entity work.execution_pipe
            port map
                ( clk                   => clk
                , reset                     => reset
                , sum_in                    => branch_address_execute
                , sum_out                   => branch_address
                , zero_in                   => alu_zero_execute_out
                , zero_out                  => alu_zero_memory_out
                , alu_result_in             => alu_result_execute_out
                , unsigned(alu_result_out)  => dmem_address
                , data_2_in                 => instruction_execution_in
                , data_2_out                => dmem_data_out
                , instructions_in           => register_destination_execution
                , instructions_out          => register_destination_memory
            );
            
    register_destination_execution  <= rd_execution_in 
                                    when register_destination = '1'
                                    else rt_execution_in;
    -- Memory
    
    pc_source <= to_std_logic(alu_zero_memory_out) and branch;
    
    
    -- Write back
    
    write_back_pipe:
        entity work.write_back_pipe
            port map
            (     reset            => reset
                , clk              => clk
                , read_data_in     => data_2_execute
                , read_data_out    => write_reg_data
                , unsigned(alu_result_in)    => dmem_address
                , alu_result_out   => alu_result_write_back_in
                , instructions_in  => register_destination_memory
                , instructions_out => write_reg_data
            );
    
    -- Others

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
                , pc_control => pc_control
                , mem_to_reg => mem_to_reg
                , alu_override => alu_override
                , mem_write_enable => dmem_write_enable
                , alu_src => alu_immediate
                , reg_write_enable => write_reg_enable
                )
            ;

    alu_control:
        entity work.alu_control
            port map
                ( instruction_funct => instruction(5 downto 0)
                , funct_override  => alu_override
                , alu_function  => alu_function
                )
            ;

    imm_data_extended <= std_logic_vector(resize(signed(instruction(15 downto 0)), DATA_WIDTH));
    
    
    write_reg <= instruction(15 downto 11)
                 when reg_dest = '1'
                 else instruction(20 downto 16);


    write_reg_data <= dmem_data_in
                      when mem_to_reg = '1'
                      else std_logic_vector(alu_result);

    
    

end Behavioral;