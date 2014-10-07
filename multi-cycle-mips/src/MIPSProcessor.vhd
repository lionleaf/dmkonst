-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- MIPSProcessor.vhd
-- The MIPS processor component to be used in Exercise 1 and 2.

-- TODO replace the architecture DummyArch with a working Behavioral

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPSProcessor is
	generic (
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 32
	);
	port (
		clk, reset 				: in std_logic;
		processor_enable		: in std_logic;
		imem_data_in			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		imem_address			: out std_logic_vector(ADDR_WIDTH-1 downto 0);
		dmem_data_in			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		dmem_address			: out std_logic_vector(ADDR_WIDTH-1 downto 0);
		dmem_data_out			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		dmem_write_enable		: out std_logic
	);
end MIPSProcessor;

architecture DummyArch of MIPSProcessor is
	signal counterReg : unsigned(31 downto 0);
begin

	DummyProc: process(clk, reset)
	begin
		if reset = '1' then
			counterReg <= (others => '0');
		elsif rising_edge(clk) then
			if processor_enable = '1' then
				counterReg <= counterReg + 1;
			end if;
		end if;
	end process;
	
	dmem_write_enable <= processor_enable;
	imem_address <= (others => '0');
	dmem_address <= std_logic_vector(counterReg(7 downto 0));
	dmem_data_out <= std_logic_vector(counterReg);

end DummyArch;

