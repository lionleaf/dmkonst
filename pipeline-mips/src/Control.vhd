library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;

entity Control is

	generic
        ( ADDR_WIDTH : integer := 8
		; DATA_WIDTH : integer := 32
        );
    port
        ( clk, reset       : in   std_logic
        ; processor_enable : in   std_logic
        ; opcode           : in   std_logic_vector(5 downto 0)
        ; update_pc        : out  std_logic
        ; write_enable     : out  std_logic
        );

end control;

architecture Behavioral of Control is

    type state_t is (disabled, fetch, execute, stall);  --type of state machine.
    signal state: state_t;

begin
    
    process(clk)
    begin
        
    end process;
    
    
    process (clk)
    begin
        if rising_edge(clk) then
            case state is
                when disabled =>
                    state <= fetch;
                when fetch =>
                    state <= execute;
                when execute =>
                    if opcode = "100011" or opcode = "101011" then
                        state <= stall;
                    else 
                        state <= fetch;
                    end if;
                when stall =>
                    state <= fetch;
            end case;
            
            if reset = '1' then
                state <= disabled;
            end if;
            
            if processor_enable = '0' then
                state <= disabled;
            end if;
        end if;
    end process;


    process (state, opcode)
    begin
        case state IS
            when disabled =>
                update_pc <= '0';
                write_enable <= '0';
            when fetch =>
                update_pc <= '0';
                write_enable <= '0';
            when execute =>
                if opcode = "100011" or opcode = "101011" then
                    update_pc <= '0';
                else 
                    update_pc <= '1';
                end if;
                
                write_enable <= '1';
            when stall =>
                update_pc <= '1';
                write_enable <= '1';
        end case;
    end process;

end Behavioral;
