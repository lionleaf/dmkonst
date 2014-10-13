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
	signal reg_write_enable : std_logic;
	signal reg_data_a	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal reg_data_b	: std_logic_vector(DATA_WIDTH - 1 downto 0);

	signal alu_data_b	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal alu_result	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal alu_op : std_logic_vector(3 downto 0);
	signal alu_zero : std_logic;
	
	signal imm_data_extended : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal imm_addr_extended : std_logic_vector(ADDR_WIDTH - 1 downto 0);

	
	signal mem_to_reg: std_logic;
	signal reg_dest  : std_logic;
	signal alu_src : std_logic;
	signal branch : std_logic;
	signal jump : std_logic;
    signal alu_compare : std_logic;
	
	signal current_PC : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal next_PC : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal incremented_PC : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal jump_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal branch_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal branch_or_inc_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	
	
begin


instruction <= imem_data_in;
dmem_address <= alu_result(7 downto 0);
dmem_data_out <= reg_data_b;
imem_address <= std_logic_vector(current_PC);





increment_PC : process(clk)
begin
	incremented_PC <= std_logic_vector(unsigned(current_PC) + 1);
end process increment_PC;

concat_jump_addr : process(clk)
begin
	if ADDR_WIDTH > 26 then
        jump_addr <= incremented_PC(ADDR_WIDTH - 1 downto 26) & instruction(25 downto 0);
    else
        jump_addr <= instruction(ADDR_WIDTH - 1 downto 0);
    end if;
end process concat_jump_addr;

calc_branch_addr : process(clk)
begin
	branch_addr <= std_logic_vector(signed(incremented_PC) + signed(imm_addr_extended));
end process calc_branch_addr;

extend_immidiate : process(clk)
begin
	imm_data_extended <= std_logic_vector(resize(signed(instruction(15 downto 0)), DATA_WIDTH));
    imm_addr_extended <= std_logic_vector(resize(signed(instruction(15 downto 0)), ADDR_WIDTH));
end process extend_immidiate;


mux_branch : process(clk)
begin
	if branch = '1' and alu_zero = '1' then
		branch_or_inc_addr <= branch_addr;
	else
		branch_or_inc_addr <= incremented_PC;
	end if;
end process mux_branch;

mux_jump : process(clk)
begin
	if jump = '1' then
		next_PC <= jump_addr;
	else
		next_PC <= branch_or_inc_addr;
	end if;
end process mux_jump;

mux_alu_src : process(clk)
begin
	if(alu_src = '1') then
		alu_data_b <= imm_data_extended;
	else
		alu_data_b <= reg_data_b;
	end if;
end process mux_alu_src;	

mux_reg_dest: process(clk)
begin
	if(reg_dest = '1') then
		write_reg_addr <= instruction(15 downto 11);
	else
		write_reg_addr <= instruction(20 downto 16);
	end if;
end process mux_reg_dest;

mux_mem_to_reg: process(clk)
begin
	if(mem_to_reg = '1') then
		write_reg_data <= dmem_data_in;
	else
		write_reg_data <= alu_result;
	end if;
end process mux_mem_to_reg;



alu_control: process(clk)
begin
	if(alu_compare = '1') then
    	alu_op <= "0000";
	else
    	alu_op <= instruction(3 downto 0);
	end if;
end process alu_control;




Registers: entity work.Registers(Behavioral) 
					generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH) 
					port map (
					clk => clk, reset => reset,
					readReg1 	=> instruction(25 downto 21),
					readReg2 	=> instruction(20 downto 16),
					writeReg		=> write_reg_addr,
					writeData	=> write_reg_data,
					readData1 	=> reg_data_a,
					readData2 	=> reg_data_b,
					regWrite		=> reg_write_enable
					);
					
ALU: entity work.ALU(Behavioral) 
					generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH) 
					port map (
					clk => clk, reset => reset,
					data_a 	=> reg_data_a,
					data_b 	=> alu_data_b,
					control	=> alu_op,
					zero 		=> alu_zero,
					result 	=> alu_result
					);
					
PC: entity work.PC(Behavioral) 
					generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH) 
					port map (
					clk => clk, reset => reset,
					current_PC	=> current_PC, 
					next_PC 	=> next_PC
					);

Control: entity work.Control(Behavioral) 
					generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH) 
					port map (
					clk => clk, reset => reset,
					opcode => instruction(31 downto 26),
					reg_dest => reg_dest,
					branch => branch,
					mem_to_reg => mem_to_reg,
					alu_op => alu_compare,
					mem_write_enable => dmem_write_enable,
					alu_src => alu_src,
					reg_write_enable => reg_write_enable,
					jump => jump
					);
					

end Behavioral;

