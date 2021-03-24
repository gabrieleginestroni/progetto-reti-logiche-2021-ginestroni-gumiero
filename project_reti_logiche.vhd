----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2021 10:20:46 PM
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath_addr is
	port (
		in_dim1 : in std_logic_vector (7 downto 0); --uscita del dim1
		in_dim2 : in std_logic_vector (7 downto 0); --uscita del dim2
		in_reg_counter : in std_logic_vector (15 downto 0); --uscita reg_counter
		in_reg_dim : in std_logic_vector (15 downto 0); --uscita reg_dim
		in_reg_counter_sel : in std_logic; --ingresso mux counter_sel
		in_reg_addr : in std_logic_vector (15 downto 0); --uscita del reg_addr
		in_addr_sel : in std_logic; --selettore mux a monte del reg_addr
		in_o_addr_sel : in std_logic;
		in_fsm_o_addr : in std_logic_vector (15 downto 0);
		in_fsm_sel : in std_logic;
		--in_fsm_done : in std_logic;
		--in_fsm_done_sel : in std_logic;
		
		out_reg_counter : out std_logic_vector (15 downto 0); --ingresso reg_counter
		out_end_loop : out std_logic;
		out_reg_dim : out std_logic_vector (15 downto 0); --uscita moltiplicatore, ingresso reg_dim
		out_reg_addr : out std_logic_vector (15 downto 0);
		o_addr : out std_logic_vector (15 downto 0);
		out_done : out std_logic
		--o_temp : out std_logic
		);
		

end datapath_addr;

architecture Behavioral of datapath_addr is
	signal new_o_addr : std_logic_vector (15 downto 0); --segnale uscita sommatore
	signal diff_temp : UNSIGNED (15 downto 0); --uscita sottrattore
	signal offset : std_logic_vector (15 downto 0);
	signal o_addr_temp : std_logic_vector (15 downto 0) := (others => '0');
	signal tmp_done : std_logic := '0';
begin
	
	out_reg_dim <= std_logic_vector(UNSIGNED(in_dim1) * UNSIGNED(in_dim2));
	
	out_reg_counter <= in_reg_dim when in_reg_counter_sel = '0' else
		std_logic_vector(diff_temp);
		
	diff_temp <= (UNSIGNED(in_reg_counter)-1);
	
	out_end_loop <= '1' when in_reg_counter = "0000000000000000" else
		'0';
	--------------------------------------------------------------------------------
	
	new_o_addr <= std_logic_vector(UNSIGNED(in_reg_addr) + 1);
	
	out_reg_addr <= new_o_addr when in_addr_sel = '0' else
		"0000000000000001";
	
	offset <= std_logic_vector(UNSIGNED(in_reg_dim) + UNSIGNED(new_o_addr));
	
	o_addr_temp <= new_o_addr when in_o_addr_sel = '0' else 
		offset;
	
	o_addr <= o_addr_temp when in_fsm_sel = '1' else 
		in_fsm_o_addr;
		
	tmp_done <= '1' when o_addr_temp = std_logic_vector(1+(UNSIGNED(in_reg_dim)+UNSIGNED(in_reg_dim))) else '0';
	out_done <= tmp_done;
end Behavioral;

---------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath1 is
	port ( 
		in1 : in std_logic_vector (7 downto 0);		--uscita del reg1
		in_min : in std_logic_vector (7 downto 0);	--uscita di reg_min
		in_max : in std_logic_vector (7 downto 0);	--uscita di reg_max
		in_max_min_sel : in std_logic;	--selettore multiplexer
		out_max : out std_logic_vector (7 downto 0);	--ingresso di reg_max
		out_min : out std_logic_vector (7 downto 0);	--ingresso di reg_min
		out_delta : out std_logic_vector (7 downto 0)	--ingresso di reg_delta
		);
end datapath1;

architecture Behavioral of datapath1 is
	signal new_max : UNSIGNED(7 downto 0);
	signal new_min : UNSIGNED(7 downto 0);
begin
	new_max <= UNSIGNED(in1) when UNSIGNED(in1) > UNSIGNED(in_max) else
		UNSIGNED(in_max);
	new_min <= UNSIGNED(in1) when UNSIGNED(in1) < UNSIGNED(in_min) else
		UNSIGNED(in_min);
		
	out_max <= std_logic_vector (new_max) when in_max_min_sel = '1' else
				"00000000";
	out_min <= std_logic_vector (new_min) when in_max_min_sel = '1' else
				"11111111";
	out_delta <= std_logic_vector(UNSIGNED(in_max) - UNSIGNED(in_min)); 
end Behavioral;

---------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath3 is
	port ( 
		in1 : in std_logic_vector (7 downto 0);		--uscita del reg1
		in_reg_min : in std_logic_vector (7 downto 0);	--uscita di reg_min
		in_reg_delta : in std_logic_vector (7 downto 0);		--uscita del reg_delta
		in_reg_shift : in std_logic_vector (7 downto 0);	--uscita di reg_shift

		out_reg_shift : out std_logic_vector (7 downto 0);	--ingresso di reg_shift
		o_data : out std_logic_vector (7 downto 0)	--o_data
	);
end datapath3;

architecture Behavioral of datapath3 is
	signal tmp_pixel : UNSIGNED(7 downto 0);
	signal overflow : UNSIGNED(7 downto 0);
begin
	
	out_reg_shift <= "00001000" when in_reg_delta = "00000000" else --shift = 8 se delta = 0
				"00000111" when in_reg_delta = "00000001" or in_reg_delta = "00000010" else --shift = 7 se delta = 1 o delta = 2
				"00000110" when in_reg_delta > "00000010" and in_reg_delta < "00000111" else --shift = 6 se 2 < delta < 7
				"00000101" when in_reg_delta > "00000110" and in_reg_delta < "00001111" else --shift = 5 se 6 < delta < 15
				"00000100" when in_reg_delta > "00001110" and in_reg_delta < "00011111" else --shift = 4 se 14 < delta < 31
				"00000011" when in_reg_delta > "00011110" and in_reg_delta < "00111111" else --shift = 3 se 30 < delta < 63
				"00000010" when in_reg_delta > "00111110" and in_reg_delta < "01111111" else --shift = 2 se 62 < delta < 127
				"00000001" when in_reg_delta > "01111110" and in_reg_delta < "11111111" else --shift = 1 se 126 < delta < 255
				"00000000"; --shift = 0 se delta >=255

	tmp_pixel <= (UNSIGNED(in1) - UNSIGNED(in_reg_min));
	overflow <= "00000000" when in_reg_shift = "00000000" else
				"10000000" when in_reg_shift = "00000001" else
				"11000000" when in_reg_shift = "00000010" else
				"11100000" when in_reg_shift = "00000011" else
				"11110000" when in_reg_shift = "00000100" else
				"11111000" when in_reg_shift = "00000101" else
				"11111100" when in_reg_shift = "00000110" else
				"11111110" when in_reg_shift = "00000111" else
				"11111111"; --when in_reg_shift = "00001000" else
	o_data <= std_logic_vector (shift_left(tmp_pixel, TO_INTEGER(UNSIGNED(in_reg_shift)))) when (tmp_pixel and overflow) = "00000000" else
				"11111111";
end Behavioral;
-----------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_start : in std_logic;
		i_data : in std_logic_vector(7 downto 0);
		o_address : out std_logic_vector(15 downto 0);
		o_done : out std_logic;
		o_en : out std_logic;
		o_we : out std_logic;
		o_data : out std_logic_vector (7 downto 0)
	);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
--------------------------------------------------FSM states----------------------------------------------------------------------------------
type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S1_bis, S2_bis, S4_bis, S5_bis, S12_bis, S13_bis, S14_bis, S15_bis, S16_bis);
--------------------------------------------------signals declaration---------------------------------------------------------------------------
--------------------------------------------------fsm signals--------------------------------------------------------------------------
signal next_state, current_state: state_type;
---------------------------------------------------datahpath signals-------------------------------------------------------------
signal tmp_done, end_loop : std_logic ;
--------------------------------------------------registers' signals------------------------------------
	signal reg1_load, reg_delta_load, reg_max_load, reg_min_load, reg_shift_load : std_logic := '0';
	signal reg_dim1_load, reg_dim2_load, reg_dim_load, reg_addr_load, reg_counter_load : std_logic := '0';
	signal reg1_out, reg_max_out, reg_delta_out, reg_min_out, reg_dim1_out, reg_dim2_out, reg_shift_out : std_logic_vector (7 downto 0);
	signal reg_max_in, reg_delta_in, reg_min_in, reg_shift_in : std_logic_vector (7 downto 0);
	signal reg_dim_out, reg_counter_out, reg_addr_out : std_logic_vector (15 downto 0);
	signal reg_dim_in, reg_counter_in, reg_addr_in : std_logic_vector (15 downto 0);
-----------------------------------------------------multiplexer selection signals--------------------------------------------------------------
	signal max_min_sel, reg_counter_sel, addr_sel, o_addr_sel, fsm_sel : std_logic;
------------------------------------------------------fsm out signals---------------------------------------------------------------------------
	signal fsm_o_addr : std_logic_vector (15 downto 0);
---------------------------------------------------end of signal declaration---------------------------------------------------------------------
--------------------------------------------------component declaration--------------------------------------------------------------------------
	component datapath1 is 
	
		port ( 
		in1 : in std_logic_vector (7 downto 0);		--uscita del reg1
		in_min : in std_logic_vector (7 downto 0);	--uscita di reg_min
		in_max : in std_logic_vector (7 downto 0);	--uscita di reg_max
		in_max_min_sel : in std_logic;	--selettore multiplexer
		out_max : out std_logic_vector (7 downto 0);	--ingresso di reg_max
		out_min : out std_logic_vector (7 downto 0);	--ingresso di reg_min
		out_delta : out std_logic_vector (7 downto 0)	--ingresso di reg_delta
		);
	end component;
		
	component datapath_addr is 
		
		port (
		in_dim1 : in std_logic_vector (7 downto 0); --uscita del dim1
		in_dim2 : in std_logic_vector (7 downto 0); --uscita del dim2
		in_reg_counter : in std_logic_vector (15 downto 0); --uscita reg_counter
		in_reg_dim : in std_logic_vector (15 downto 0); --uscita reg_dim
		in_reg_counter_sel : in std_logic; --ingresso mux counter_sel
		in_reg_addr : in std_logic_vector (15 downto 0); --uscita del reg_addr
		in_addr_sel : in std_logic; --selettore mux a monte del reg_addr
		in_o_addr_sel : in std_logic;
		in_fsm_o_addr : in std_logic_vector (15 downto 0);
		in_fsm_sel : in std_logic;
		
		out_reg_counter : out std_logic_vector (15 downto 0); --ingresso reg_counter
		out_end_loop : out std_logic;
		out_reg_dim : out std_logic_vector (15 downto 0); --uscita moltiplicatore, ingresso reg_dim
		out_reg_addr : out std_logic_vector (15 downto 0);
		o_addr : out std_logic_vector (15 downto 0);
		out_done : out std_logic
		);	 
	end component;
	
	component datapath3 is
		
		port ( 
		in1 : in std_logic_vector (7 downto 0);	--uscita del reg1
		in_reg_min : in std_logic_vector (7 downto 0);	--uscita di reg_min
		in_reg_delta : in std_logic_vector (7 downto 0);	--uscita del reg_delta
		in_reg_shift : in std_logic_vector (7 downto 0);	--uscita di reg_shift

		out_reg_shift : out std_logic_vector (7 downto 0);	--ingresso di reg_shift
		o_data : out std_logic_vector (7 downto 0)	--o_data
		);
	 end component;
	
--------------------------------------------------end of component declaration------------------------------------------------------------------

begin
-----------------------------------------------------------dataflow-----------------------------------------------------------------------------
	
	p1: datapath1
		port map(reg1_out, reg_min_out, reg_max_out, max_min_sel, reg_max_in, reg_min_in, reg_delta_in);
	p2: datapath_addr
		port map(reg_dim1_out, reg_dim2_out, reg_counter_out, reg_dim_out, reg_counter_sel, reg_addr_out, addr_sel, o_addr_sel, fsm_o_addr, fsm_sel,
				reg_counter_in, end_loop, reg_dim_in, reg_addr_in, o_address, tmp_done);

	p3: datapath3
		port map(reg1_out, reg_min_out, reg_delta_out, reg_shift_out, reg_shift_in, o_data);

	-------------------------------------------------------------------end dataflow----------------------------------------
	registri: process(i_clk,i_rst)
	begin
		if i_rst = '1' then
			reg1_out <= (others => '0');
			reg_max_out <= (others => '0');
			reg_delta_out<= (others => '0');
			reg_min_out <= (others => '0');
			reg_dim1_out <= (others => '0');
			reg_dim2_out <= (others => '0');
			reg_shift_out <= (others => '0');
			reg_dim_out <= (others => '0');
			reg_counter_out <= (others => '0');
			reg_addr_out <= (others => '0');
		elsif i_clk = '1' and i_clk'event then
			if reg1_load = '1' then
				reg1_out <= i_data;
			end if;
			if reg_delta_load = '1' then
				reg_delta_out <= reg_delta_in;
			end if;
			if reg_max_load = '1' then
				reg_max_out <= reg_max_in;
			end if;
			if reg_min_load = '1' then
				reg_min_out <= reg_min_in;
			end if;
			if reg_shift_load = '1' then
				reg_shift_out <= reg_shift_in;
			end if;
			if reg_dim1_load = '1' then
				reg_dim1_out <= i_data;
			end if;
			if reg_dim2_load = '1' then
				reg_dim2_out <= i_data;
			end if;
			if reg_dim_load = '1' then
				reg_dim_out <= reg_dim_in;
			end if;
			if reg_addr_load = '1' then
				reg_addr_out <= reg_addr_in;
			end if;
			if reg_counter_load = '1' then
				reg_counter_out <= reg_counter_in;
			end if;
		 end if;
	end process;
	
	state_reg: process(i_clk, i_rst)
	begin
		if i_rst='1' then
			current_state <= S0;
		elsif i_clk = '1' and i_clk'event then
			current_state <= next_state;
		end if;
	end process;
	
	next_stato: process(current_state, i_start, end_loop, tmp_done)
	begin
		next_state <= current_state;
		case current_state is
		when S0 =>
			if i_start='1' then
				next_state <= S1;
			end if;
		when S1 =>
			next_state <= S1_bis;
		when S1_bis => 
			next_state <= S2;
		when S2 =>
			next_state <= S2_bis;
		when S2_bis => 
			next_state <= S3;
		when S3 =>
			next_state <= S4;
		when S4 =>
			next_state <= S4_bis;
		when S4_bis =>
			next_state <= S5;
		when S5 =>
			next_state <= S5_bis;
		when S5_bis => 
			next_state <= S6;
		when S6 =>
			if end_loop = '1' then
				next_state <=S8;
			else 
				next_state <= S7;
			end if;
		when S7 =>
			next_state <= S6;
		when S8 =>
			next_state <= S9;
		when S9 =>
			next_state <= S10;
		when S10 =>
			next_state <= S11;
		when S11 =>
			next_state <= S12;
		when S12 =>
			next_state <= S12_bis;
		when S12_bis =>
			next_state <= S13;
		when S13 =>
			next_state <= S13_bis;
		when S13_bis =>
			next_state <= S14;
		when S14 =>
			if tmp_done = '1' then
				next_state <= S16;
			else	
				next_state <= S14_bis;
			end if;
		when S14_bis =>
			if tmp_done = '1' then
				next_state <= S16;
			else
				next_state <= S15;
			end if;
		when S15 =>
			next_state <= S15_bis;
		when S15_bis =>
			next_state <= S13;
		when S16 =>
			next_state <= S16_bis;
		when S16_bis =>
			if i_start = '0' then
				next_state <= S0;
			end if;
		end case;
	end process;
	
	fsm_out: process(current_state, tmp_done)
	begin
		reg_dim1_load <= '0';
		o_en <= '1';
		o_we <= '0';
		reg_dim2_load <= '0';
		fsm_sel <= '1';
		reg_dim_load <= '0';
		addr_sel <= '0';
		reg_addr_load <= '0';
		reg_counter_load <= '0';
		reg1_load <= '0';
		reg_counter_sel <= '0';
		max_min_sel <= '0';
		reg_max_load <= '0';
		reg_min_load <= '0';
		reg_delta_load <= '0';
		reg_shift_load <= '0';
		o_addr_sel <= '0';
		fsm_o_addr <= "0000000000000000";
		o_done <= '0';

		case current_state is
			when S0 =>
				o_en <= '0';
			when S1 =>
				fsm_sel <= '0';
				reg_dim1_load <= '1';
				fsm_o_addr <= ( others => '0');
			when S1_bis => 
				fsm_sel <= '0';
				reg_dim1_load <= '1';
				fsm_o_addr <= ( others => '0');
			when S2 =>
				fsm_sel <= '0';
				reg_dim2_load <= '1';
				fsm_o_addr <= ( 15 downto 1 => '0', others => '1');
			when S2_bis =>
				fsm_sel <= '0';
				reg_dim2_load <= '1';
				fsm_o_addr <= ( 15 downto 1 => '0', others => '1');
			when S3 =>
				reg_dim_load <= '1';
			when S4 =>
				addr_sel <= '1';
				reg_addr_load <= '1'; 
				reg_counter_load <= '1';
			when S4_bis =>
				addr_sel <= '1';
				reg_addr_load <= '1';
				reg_counter_load <= '1';
			when S5 =>
				reg1_load <= '1';
				reg_max_load <= '1';
				reg_min_load <= '1';
				reg_counter_sel <= '1';
			when S5_bis =>
				reg1_load <= '1';
				reg_max_load <= '1';
				reg_min_load <= '1';
				reg_counter_sel <= '1';
			when S6 =>
				reg_counter_sel <= '1';
				reg_max_load <= '1';
				reg_min_load <= '1';
				reg_addr_load <= '1';
				max_min_sel <= '1';
			when S7 =>
				reg_counter_sel <= '1';
				reg_max_load <= '1';
				reg_min_load <= '1';
				max_min_sel <= '1';
				reg_counter_load <= '1';
				reg1_load <= '1';
			when S8 =>
				o_en <= '0';
			when S9 =>
				reg_delta_load <= '1';
			when S10 =>
				reg_shift_load <= '1';
			when S11 =>
				reg_shift_load <= '0';
			when S12 =>
				addr_sel <= '1';
				reg_addr_load <= '1';
			when S12_bis =>
				addr_sel <= '1';
				reg_addr_load <= '1';
			when S13 =>
				reg1_load <= '1';
			when S13_bis =>
				reg1_load <= '1';
			when S14 =>
				o_we <= '1';
				o_addr_sel <= '1';
				o_done <= tmp_done;
			when S14_bis =>
				o_we <= '1';
				o_addr_sel <= '1';
				o_done <= tmp_done;
			when S15 =>
				reg_addr_load <= '1';
			when S15_bis =>
			when S16 =>
				o_done <= '1';
				o_en <= '0';
			when S16_bis =>
				o_done <= '1';
				o_en <= '0';
		end case;
	end process;
end Behavioral;