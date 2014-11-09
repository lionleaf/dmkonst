library ieee;
use ieee.std_logic_1164.all;

package defs is

    subtype word_t is std_logic_vector(31 downto 0);
    subtype inst_t is std_logic_vector(31 downto 0);
    subtype inst_addr_t is std_logic_vector(7 downto 0);
    subtype reg_n_t is std_logic_vector(4 downto 0);
    subtype opcode_t is std_logic_vector(5 downto 0);

    type alu_funct_t is
        ( alu_add
        , alu_sub
        , alu_and
        , alu_or
        , alu_slt
        , alu_sll16
        );
    
    type pc_control_t is
        ( step
        , jump
        , branch
        );

    type alu_override_t is
        ( override_add
        , override_sub
        , override_sll16
        , override_disabled
        );

    type fetch_decode_pipe_t is record
        pc_succ : inst_addr_t;
    end record;

    type decode_execute_pipe_t is record
        -- Control signals:
        branch_en   : std_logic;
        mem_wen     : std_logic;
        mem_to_reg  : std_logic;
        reg_wen     : std_logic;
        alu_funct   : alu_funct_t;
        inst_type_I : std_logic;

        pc_succ    : inst_addr_t;
        imm_val    : word_t;
        reg_rt     : reg_n_t;
        reg_rd     : reg_n_t;
    end record;

    type execute_memory_pipe_t is record
        -- Control signals:
        branch_en   : std_logic;
        mem_wen     : std_logic;
        mem_to_reg  : std_logic;
        reg_wen     : std_logic;

        -- Data to memory:
        alu_result  : word_t;
        write_data  : word_t;

        -- Writeback details:
        reg_dst     : reg_n_t;

        -- Branch data:
        alu_zero    : std_logic;
        branch_addr : inst_addr_t;
    end record;

    type mem_writeback_pipe_t is record
        -- Control signals:
        reg_wen    : std_logic;
        mem_to_reg : std_logic;
        -- Note: mem_result should not be ff-ed because it already is late one cycle.
        alu_result : word_t;
        -- Writeback details:
        reg_dst    : reg_n_t;
    end record;

    function to_alu_funct_t (opcode: std_logic_vector(5 downto 0)) return alu_funct_t;
    function to_std_logic (p: boolean) return std_logic;

end package defs;

package body defs is

    function to_alu_funct_t (opcode : std_logic_vector(5 downto 0))
        return alu_funct_t is
    begin
        case opcode is
           when "100000" => return alu_add;
           when "100010" => return alu_sub;
           when "101010" => return alu_slt;
           when "100100" => return alu_and; 
           when "100101" => return alu_or;
           when others   => return alu_sub;
        end case;
    end to_alu_funct_t;

    function to_std_logic (p: boolean)
        return std_logic
    is begin
        if p then
            return '1';
        else
            return '0';
        end if;
    end to_std_logic;

 end defs;
