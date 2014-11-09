-- testbench template 

  library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  entity testbench is
  end testbench;

  architecture behavior of testbench is 

  -- component declaration
          component <component name>
            port
              ( clk, reset        : in     std_logic

              ; fetch_decode_pipe : in fetch_decode_pipe_t
              ; inst              : in inst_t
              ; reg_wen           : in std_logic
              ; reg_dst           : in reg_n_t
              ; reg_w_data        : in word_t

              ; decode_execute_pipe : buffer decode_execute_pipe_t
              ; reg_val_rs          : buffer word_t
              ; reg_val_rt          : buffer word_t
              );
          end component;

  begin

  -- component instantiation
          uut: work.decode_stage port map(
                  <port1> => <signal1>,
                  <port3> => <signal2>
          );


  --  test bench statements
     tb : process
     begin

        wait for 100 ns; -- wait until global set/reset completes

        -- add user defined stimulus here

        wait; -- will wait forever
     end process tb;
  --  end test bench 

  end;
