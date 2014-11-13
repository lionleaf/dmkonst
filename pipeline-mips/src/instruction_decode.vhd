library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity instruction_decode is
	port
		(	clk             : std_logic
    ; processor_enable: std_logic
		;	write_data      : in word_t
		;	instruction     : in inst_t := (others => '0')
		;	write_register	: in reg_t
		;	write_reg_enable: in std_logic
		;	data_1			    : out word_t
		;	data_2			    : out word_t
    
    -- Hazard handling
		;	insert_stall    : in std_logic
    
    --Control outputs
    ; branch_en   : out  std_logic
    ; mem_to_reg  : out  std_logic
    ; mem_wen     : out  std_logic
    ; mem_read    : out  std_logic
    ; reg_wen     : out  std_logic
    ; inst_type_I : out  std_logic
    ; imm_to_alu : out  std_logic
    ; alu_funct   : out  alu_funct_t
    ; alu_shamt   : out  alu_shamt_t

        -- To forwarding-unit
        ; rs_out : out reg_t
        ; rt_out : out reg_t
    )
	;
end instruction_decode;

architecture Behavioral of instruction_decode is

    -- decomposition of instruction
    alias rs        : reg_t   is instruction(25 downto 21);
    alias rt        : reg_t    is instruction(20 downto 16);
    
    
    --Internal signals so that we can mux result with insert_stall
    --We only force some signals to 0 when stalling,
    --as many of them will have no effect when these are 0
    signal decode_enable_i : std_logic;

begin

   -- Output the register numbers used. This is used by the forwarding-unit.
  rs_out <= rs;
  rt_out <= rt;


  decode_enable_i <= '1' when processor_enable = '1' and insert_stall = '0'
              else '0';

   decode:
    entity work.decode
        port map
            ( enable => decode_enable_i
            , instruction => instruction
            , branch_en   => branch_en
            , mem_to_reg  => mem_to_reg   
            , mem_wen     => mem_wen  --Internal signal for stalling purposes
            , mem_read    => mem_read --Internal signal for stalling purposes
            , reg_wen     => reg_wen  --Internal signal for stalling purposes
            , imm_to_alu  => imm_to_alu
            , inst_type_I => inst_type_I
            , alu_funct   => alu_funct
            , alu_shamt   => alu_shamt
            )
        ;

    register_file:
        entity work.register_file
            port map
                ( clk           => clk
                , read_reg_1    => rs
                , read_reg_2    => rt
                , write_reg     => write_register
                , write_enable  => write_reg_enable
                , write_data    => write_data
                , read_data_1   => data_1
                , read_data_2   => data_2
                )
            ;

end Behavioral;

