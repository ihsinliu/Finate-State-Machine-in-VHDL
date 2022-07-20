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
    type state_type is (Ready,Request_num_words, Get_num_words, Request_data, A, B, C, D, Write, Done); -- A:00, B:01, C:10, D:11
    signal current_state, next_state : state_type;
    signal address_reg, next_address, next_o_address : std_logic_vector(15 downto 0) := "0000000000000001";
    signal output_reg : std_logic_vector(15 downto 0) := "0000000000000000";
    signal next_o_done, next_o_en, next_o_we : std_logic := '0';
    signal next_o_data : std_logic := '00000000';
    signal in_mask_reg, next_in_mask : std_logic_vector(7 downto 0) := "00000000";
	signal out_mask_reg, next_out_mask : std_logic_vector(15 downto 0) := "0000000000000000";
    signal num_words : Integer range 0 to 255 := 0;
    SIGNAL got_num_words, next_got_num_words : BOOLEAN := false;

    begin
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            in_mask_reg <= "00000000";
			out_mask_reg <= "0000000000000000";
			address_reg <= "0000000000000000";
            output_reg <= "0000000000000000";
            num_words <= '0';
            current_state <= Ready;
        elsif (i_clk'event and i_clk='1') then
            o_done <= next_o_done;
            o_en <= next_o_en;
            o_we <= next_o_we;
            o_data <= next_o_data;
            o_address <= next_o_address;
            got_num_words <= next_got_num_words;
            address_reg <= next_address;
            current_state <= next_state;
        end if;
    end process;
    
    process (current_state, i_data, i_start, address_reg, output_reg, in_mask_reg, out_mask_reg)
    begin
        next_o_done <= '0';
        next_o_en <= '0';
        next_o_we <= '0';
        next_o_data <= "00000000";
        next_o_address <= "0000000000000000";
        next_got_num_words <= got_num_words;
        next_in_mask <= in_mask_reg;
        next_out_mask <= out_mask_reg;
        next_address <= address_reg;

        case current_state is
            when Ready => 
                if (i_start = '1') then
                    next_state <= Request_num_words;
                end if;

            when Request_num_words =>
                next_o_en <= '1';
                next_o_we <= '0';
                if (not got_num_words) then
                    next_o_address <= '0000000000000000';
                end if;

            when Get_num_words =>
                if (not got_num_words) then 
                    num_words <= conv_integer(i_data);
                    got_num_words <= true;
                    next_state <= Request_data
                end if;

            when Request_data =>
                if (got_num_words and num_words = 0) then
                    next_o_done = '1';
                    next_state = Done;
                else
                    
                    

            when A =>

            when B =>

            when C =>

            when D =>

            when Write =>

            when Done =>






