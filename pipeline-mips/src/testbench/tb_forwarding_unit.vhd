library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;
use work.test_utils.all;
 
entity tb_forwarding_unit is
end tb_forwarding_unit;
 
architecture behavior of tb_forwarding_unit is 
 
    -- Component declaration for the unit under test (uut)
    component forwarding_unit
    port
        ( rs : in  reg_t
        ; rt : in  reg_t
        ; forwarded_rd_ex_mem : in  reg_t
        ; forwarded_rd_mem_wb : in  reg_t
        ; data_1_forward_ex_mem_en : out  std_logic
        ; data_2_forward_ex_mem_en : out  std_logic
        ; data_1_forward_mem_wb_en : out  std_logic
        ; data_2_forward_mem_wb_en : out  std_logic
        );
    end component;
    

    -- Inputs
    signal rs : reg_t := (others => '0');
    signal rt : reg_t := (others => '0');
    signal forwarded_rd_ex_mem : reg_t := (others => '0');
    signal forwarded_rd_mem_wb : reg_t := (others => '0');

    -- Outputs
    signal data_1_forward_ex_mem_en : std_logic;
    signal data_2_forward_ex_mem_en : std_logic;
    signal data_1_forward_mem_wb_en : std_logic;
    signal data_2_forward_mem_wb_en : std_logic;

    -- Clock period:
    constant clock_period : time := 10 ns; 

begin
 
    -- Instantiate the unit under test (uut)
    uut: forwarding_unit
        port map
         ( rs => rs
         , rt => rt
         , forwarded_rd_ex_mem => forwarded_rd_ex_mem
         , forwarded_rd_mem_wb => forwarded_rd_mem_wb
         , data_1_forward_ex_mem_en => data_1_forward_ex_mem_en
         , data_2_forward_ex_mem_en => data_2_forward_ex_mem_en
         , data_1_forward_mem_wb_en => data_1_forward_mem_wb_en
         , data_2_forward_mem_wb_en => data_2_forward_mem_wb_en
         );
 

    -- Stimulus process:
    stim_proc: process

    procedure check_forwarding
        ( rs_i: reg_t
        ; rt_i: reg_t
        ; rd_ex_mem_i: reg_t
        ; rd_mem_wb_i: reg_t
        ; data_1_forward_ex_mem_en_i: std_logic
        ; data_2_forward_ex_mem_en_i: std_logic
        ; data_1_forward_mem_wb_en_i: std_logic
        ; data_2_forward_mem_wb_en_i: std_logic
        )
    is begin

-- Dosen't work.
--        report "Testing rs:" & str(rs_i) & " rt:" & str(rt_i)
--             & " rd_ex_mem:" & str(rd_ex_mem_i) & " rd_mem_wb:" & str(rd_mem_wb_i);

        rs <= rs_i;
        rt <= rt_i;
        forwarded_rd_ex_mem <= rd_ex_mem_i;
        forwarded_rd_mem_wb <= rd_mem_wb_i;

        -- This actually has to happen much faster than one cycle.
        wait for clock_period;

        check(data_1_forward_ex_mem_en = data_1_forward_ex_mem_en_i, "Not correct: data1_forward_ex_mem_en");
        check(data_2_forward_ex_mem_en = data_2_forward_ex_mem_en_i, "Not correct: data2_forward_ex_mem_en");
        check(data_1_forward_mem_wb_en = data_1_forward_mem_wb_en_i, "Not correct: data1_forward_mem_wb_en");
        check(data_2_forward_mem_wb_en = data_2_forward_mem_wb_en_i, "Not correct: data2_forward_mem_wb_en");

    end check_forwarding;

    begin

        check_forwarding("00000", "00000", "00000", "00000", '0', '0', '0', '0');
        check_forwarding("00000", "00000", "00000", "00001", '0', '0', '0', '0');
        check_forwarding("00000", "00000", "00001", "00000", '0', '0', '0', '0');
        check_forwarding("00000", "00000", "00001", "00001", '0', '0', '0', '0');
        
        check_forwarding("00000", "00001", "00000", "00000", '0', '0', '0', '0');
        check_forwarding("00000", "00001", "00000", "00001", '0', '0', '0', '1');
        check_forwarding("00000", "00001", "00001", "00000", '0', '1', '0', '0');
        check_forwarding("00000", "00001", "00001", "00001", '0', '1', '0', '1');
        
        check_forwarding("00001", "00000", "00000", "00000", '0', '0', '0', '0');
        check_forwarding("00001", "00000", "00000", "00001", '0', '0', '1', '0');
        check_forwarding("00001", "00000", "00001", "00000", '1', '0', '0', '0');
        check_forwarding("00001", "00000", "00001", "00001", '1', '0', '1', '0');

        check_forwarding("00001", "00001", "00000", "00000", '0', '0', '0', '0');
        check_forwarding("00001", "00001", "00000", "00001", '0', '0', '1', '1');
        check_forwarding("00001", "00001", "00001", "00000", '1', '1', '0', '0');
        check_forwarding("00001", "00001", "00001", "00001", '1', '1', '1', '1');



        -- End of testbench.
        wait;
    end process;

end;
