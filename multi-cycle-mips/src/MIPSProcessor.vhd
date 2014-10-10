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
		dmem_write_enable	: out std_logic
	);
end MIPSProcessor;

architecture Behavioral of MIPSProcessor is
	signal instruction : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal write_reg_addr : std_logic_vector(4 downto 0);
	signal write_reg_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal alu_data_a	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal alu_data_b	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal alu_result	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal alu_control : std_logic_vector(3 downto 0);
	signal alu_zero : std_logic;
	signal reg_write_enable : std_logic;
	
	signal mem_to_reg: std_logic;
	signal reg_dest  : std_logic;
begin


instruction <= imem_data_in;
dmem_address <= alu_result(7 downto 0);

mux_reg_dest: process(reg_dest, clk)
begin
	if(reg_dest = '1') then
		write_reg_addr <= instruction(15 downto 11);
	else
		write_reg_addr <= instruction(20 downto 16);
	end if;
end process mux_reg_dest;

mux_mem_to_reg: process(mem_to_reg, clk)
begin
	if(mem_to_reg = '1') then
		write_reg_data <= dmem_data_in;
	else
		write_reg_data <= alu_result;
	end if;
end process mux_mem_to_reg;

Registers: entity work.Registers(Behavioral) 
					generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH) 
					port map (
					readReg1 	=> instruction(25 downto 21),
					readReg2 	=> instruction(20 downto 16),
					writeReg		=> write_reg_addr,
					writeData	=> write_reg_data,
					readData1 	=> alu_data_a,
					readData2 	=> alu_data_b,
					regWrite		=> reg_write_enable
					);
					
ALU: entity work.ALU(Behavioral) 
					generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH) 
					port map (
					data_a 	=> alu_data_a,
					data_b 	=> alu_data_b,
					control	=> alu_control,
					zero 		=> alu_zero,
					result 	=> alu_result
					);
					

end Behavioral;

