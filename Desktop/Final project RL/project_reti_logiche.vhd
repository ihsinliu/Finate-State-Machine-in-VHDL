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
    o_en : out std_logic; --Enable, = 1 when communication with memory is needed.
    o_we : out std_logic; -- Write Enable, = 1 when it's necessary to write on memory.
    o_data : out std_logic_vector (7 downto 0)
    );
    end project_reti_logiche;

architecture Behavior of project_reti_logiche is
    type state_type is (Ready, A, B, C, D, Write, Done); -- A:00, B:01, C:10, D:11
    signal current_state, next_state : state_type;
    signal address_reg, next_address : std_logic_vector(15 downto 0) := "0000000000000001";
    signal output_reg : std_logic_vector(7 downto 0) := "00000000";
    signal next_done, next_en, next_we : std_logic := '0';
    signal in_mask_reg, next_in_mask : std_logic_vector(7 downto 0) := "00000000";
	signal out_mask_reg, next_out_mask : std_logic_vector(7 downto 0) := "00000000";

    begin
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            in_mask_reg <= "00000000";
			out_mask_reg <= "00000000";
			address_reg <= "0000000000000001";
            current_state <= Ready;
        elsif (i_clk'event and i_clk='1') then
            o_done <= next_done;
            o_en <= next_en;
            o_we <= next_we;
            o_data <= output_reg;
            o_address <= next_address;
            current_state <= next_state;
        end if;
    end process;
    
    process (current_state, i_data, i_start, address_reg, output_reg)
    begin
        case current_state is
            when Ready => 
                if (i_start = '1') then
                    next_state <= A;
                end if;
            when A =>
                
            when B =>
            when C =>
            when D =>
            when Write =>
            when Done =>





