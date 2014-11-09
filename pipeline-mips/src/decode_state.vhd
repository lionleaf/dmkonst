library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity decode_stage is

    port
        ( clk               : in     std_logic

        ; fetch_decode_pipe : in fetch_decode_pipe_t
        ; inst              : in inst_t
        ; reg_wen           : in std_logic
        ; reg_dst           : in reg_n_t
        ; reg_w_data        : in word_t

        ; decode_execute_pipe : buffer decode_execute_pipe_t
        ; reg_val_rs          : buffer word_t
        ; reg_val_rt          : buffer word_t
        );

end decode_stage;

architecture rtl of decode_stage is

    alias opcode : opcode_t is inst(31 downto 26);
    alias reg_rs  : reg_n_t is inst(25 downto 21);
    alias reg_rt  : reg_n_t is inst(20 downto 16);
    alias reg_rd  : reg_n_t is inst(15 downto 11);
    alias imm_val_raw   : std_logic_vector(15 downto 0) is inst(15 downto 0);
    alias alu_funct_raw : std_logic_vector(5 downto 0) is inst(5 downto 0);

    constant OP_BEQ : opcode_t := "000100";
    constant OP_SW  : opcode_t := "101011";
    constant OP_LW  : opcode_t := "100011";
    constant OP_LUI : opcode_t := "001111";

begin

    decode_execute_pipe.reg_rt <= reg_rt;
    decode_execute_pipe.reg_rd <= reg_rd;
    decode_execute_pipe.branch_en  <= to_std_logic(opcode = OP_BEQ);
    decode_execute_pipe.mem_wen    <= to_std_logic(opcode = OP_SW);
    decode_execute_pipe.mem_to_reg <= to_std_logic(opcode = OP_LW);
    decode_execute_pipe.inst_type_I <= to_std_logic(opcode = OP_LUI);
    decode_execute_pipe.alu_funct <= to_alu_funct_t(alu_funct_raw);
    decode_execute_pipe.imm_val <= std_logic_vector(resize(unsigned(imm_val_raw), word_t'length));
    decode_execute_pipe.pc_succ <= fetch_decode_pipe.pc_succ;

    register_file:
        entity work.register_file
            port map
                ( clk           => clk
                , read_reg_1    => reg_rs
                , read_reg_2    => reg_rt
                , write_reg     => reg_dst
                , write_enable  => reg_wen
                , write_data    => reg_w_data
                -- Output
                , read_data_1   => reg_val_rs
                , read_data_2   => reg_val_rt
                )
            ;

end rtl;
