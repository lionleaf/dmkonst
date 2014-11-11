library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity forwarding_unit is

    port
        ( rs_ex : in  reg_t
        ; rt_ex : in  reg_t
        ; forwarded_rd_mem : in  reg_t
        ; forwarded_rd_wb : in  reg_t

        ; data_1_forward_mem_en : out std_logic
        ; data_2_forward_mem_en : out std_logic
        ; data_1_forward_wb_en : out std_logic
        ; data_2_forward_wb_en : out std_logic
        );

end forwarding_unit;

architecture Behavioral of forwarding_unit is

begin

    forwarding_logic:
        process ( rs_ex
                , rt_ex
                , forwarded_rd_mem
                , forwarded_rd_wb
                )
        begin

            data_1_forward_mem_en <= '0';
            data_2_forward_mem_en <= '0';
            data_1_forward_wb_en <= '0';
            data_2_forward_wb_en <= '0';

            -- Register 0 will not change when written to.
            if rs_ex /= "00000" then
                if rs_ex = forwarded_rd_wb then
                    data_1_forward_wb_en <= '1';
                end if;
                if rs_ex = forwarded_rd_mem then
                    data_1_forward_mem_en <= '1';
                end if;
            end if;

            -- Register 0 will not change when written to.
            if rt_ex /= "00000" then
                if rt_ex = forwarded_rd_wb then
                    data_2_forward_wb_en <= '1';
                end if;
                if rt_ex = forwarded_rd_mem then
                    data_2_forward_mem_en <= '1';
                end if;
            end if;

        end process;

end Behavioral;