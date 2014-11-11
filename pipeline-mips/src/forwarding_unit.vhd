library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity forwarding_unit is

    port
        ( reg_rs_ex : in  reg_t
        ; reg_rt_ex : in  reg_t
        ; reg_rd_mem  : in  reg_t
        ; reg_rd_wb   : in  reg_t
        ; reg_wen_mem       : in  std_logic
        ; reg_wen_wb        : in  std_logic

        ; data_1_forward_mem_en : out std_logic
        ; data_2_forward_mem_en : out std_logic
        ; data_1_forward_wb_en : out std_logic
        ; data_2_forward_wb_en : out std_logic
        );

end forwarding_unit;

architecture Behavioral of forwarding_unit is

--Internal signals, as the values are being read.
signal data_1_forward_mem_en_i : std_logic;
signal data_2_forward_mem_en_i : std_logic;

begin

--Connect internal signals and output
  data_1_forward_mem_en <= data_1_forward_mem_en_i;
  data_2_forward_mem_en <= data_2_forward_mem_en_i;

    forwarding_logic:
        process ( reg_rs_ex
                , reg_rt_ex
                , reg_rd_mem
                , reg_rd_wb
                , reg_wen_mem
                , reg_wen_wb
                , data_1_forward_mem_en_i
                , data_2_forward_mem_en_i
                )
        begin

            data_1_forward_mem_en_i <= '0';
            data_2_forward_mem_en_i <= '0';
            data_1_forward_wb_en <= '0';
            data_2_forward_wb_en <= '0';

            -----------------------------
            --EX hazard detection
            --
            --Equations are taken from page 308
            --in "Computer Organization and Design"
            --by Patterson and Hennesy
            -----------------------------
            if reg_wen_mem = '1'
            and reg_rd_mem /= "00000"
            and reg_rd_mem = reg_rs_ex 
            then 
              data_1_forward_mem_en_i <= '1';
            end if;
            
            if reg_wen_mem = '1'
            and reg_rd_mem /= "00000"
            and reg_rd_mem = reg_rt_ex 
            then 
              data_2_forward_mem_en_i <= '1';
            end if;
            
            -----------------------------
            --MEM hazard detection
            --
            --Equations are taken from page 311
            --in "Computer Organization and Design"
            --by Patterson and Hennesy
            -----------------------------

            if reg_wen_wb = '1'
            and reg_rd_wb /= "00000"
            and reg_rd_wb = reg_rs_ex
            and data_1_forward_mem_en_i = '0' --If both tries to forwad, mem is more recent.
            then
              data_1_forward_wb_en <= '1';
            end if;
            
            if reg_wen_wb = '1'
            and reg_rd_wb /= "00000"
            and reg_rd_wb = reg_rs_ex
            and data_2_forward_mem_en_i = '0' --If both tries to forwad, mem is more recent.
            then
              data_1_forward_wb_en <= '1';
            end if;

        end process;

end Behavioral;
