library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;
--use ieee.numeric_std.all;


entity hazard_detection is
    port ( mem_read_ex : in  std_logic
         ; reg_rt_ex   : in   reg_t
         ; reg_rs_id   : in   reg_t
         ; reg_rt_id   : in   reg_t
         ; insert_stall: out  std_logic
        );
end hazard_detection;

architecture behavioral of hazard_detection is

begin

  process (mem_read_ex, reg_rt_ex, reg_rs_id, reg_rt_id) 
  begin 
    insert_stall <= '0';
    if mem_read_ex = '1' then
      if reg_rt_ex = reg_rs_id or reg_rt_ex = reg_rt_id then
        insert_stall <= '1';
      end if;
    end if;
  end process;

end behavioral;

