library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity forwarding_unit is

    port
        ( rs : in  reg_t
        ; rt : in  reg_t
        ; forwarded_rd_ex_mem : in  reg_t
        ; forwarded_rd_mem_wb : in  reg_t

        ; data_1_forward_ex_mem_en : out std_logic
        ; data_2_forward_ex_mem_en : out std_logic
        ; data_1_forward_mem_wb_en : out std_logic
        ; data_2_forward_mem_wb_en : out std_logic
        );

end forwarding_unit;

architecture Behavioral of forwarding_unit is

begin

    forwarding_logic:
        process ( rs
                , rt
                , forwarded_rd_ex_mem
                , forwarded_rd_mem_wb
                )
        begin

            data_1_forward_ex_mem_en <= '0';
            data_2_forward_ex_mem_en <= '0';
            data_1_forward_mem_wb_en <= '0';
            data_2_forward_mem_wb_en <= '0';

            -- Register 0 will not change when written to.
            if rs /= X"0" then
                if rs = forwarded_rd_mem_wb then
                    data_1_forward_mem_wb_en <= '1';
                end if;
                if rs = forwarded_rd_ex_mem then
                    data_1_forward_ex_mem_en <= '1';
                end if;
            end if;

            -- Register 0 will not change when written to.
            if rt /= X"0" then
                if rt = forwarded_rd_mem_wb then
                    data_2_forward_mem_wb_en <= '1';
                end if;
                if rt = forwarded_rd_ex_mem then
                    data_2_forward_ex_mem_en <= '1';
                end if;
            end if;

        end process;

end Behavioral;
