library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RPNC is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           empty : in  STD_LOGIC;
           instr_data : in  STD_LOGIC_VECTOR (15 downto 0);
           stack_top : out  STD_LOGIC_VECTOR (7 downto 0);
           read_en : out  STD_LOGIC);
end RPNC;

architecture DummyBehavior of RPNC is
	signal dummySum : unsigned(7 downto 0);
	signal empty_r : std_logic;
begin

	DummyProcess: process(clk,reset)
	begin
		if reset = '1' then
			dummySum <= (others => '0');
			empty_r <= '1';
		elsif rising_edge(clk) then
			if empty_r = '0' then
				dummySum <= dummySum + unsigned(instr_data(7 downto 0));
			end if;
			empty_r <= empty;
		end if;
	end process;
	
	read_en <= not empty;
	stack_top <= std_logic_vector(dummySum);

end DummyBehavior;

