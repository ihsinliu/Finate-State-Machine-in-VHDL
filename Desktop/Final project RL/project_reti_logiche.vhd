LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
use std.textio.all;


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
    type state_type is (Ready,Request_num_words, Get_num_words, Request_data, Wait_data, Set_mask, A, B, C, D, Write_output, Wait_writing, Done); -- A:00, B:01, C:10, D:11
    signal state_reg, next_state : state_type := Ready;
    signal FSA_state_reg, next_FSA_state : state_type := A;
    signal address_reg, next_address, next_o_address : std_logic_vector(15 downto 0) := "0000000000000000";
    signal output_reg, next_output : std_logic_vector(15 downto 0) := "0000000000000000";
    signal next_o_done, next_o_en, next_o_we : std_logic := '0';
    signal next_o_data : std_logic_vector(7 downto 0) := "00000000";
    signal data, next_data : std_logic_vector(7 downto 0) := "00000000";
    signal in_mask_reg, next_in_mask : std_logic_vector(7 downto 0) := "00000000";
	signal out_mask_reg, next_out_mask : std_logic_vector(15 downto 0) := "0000000000000000";
    signal num_words, next_num_words : Integer range 0 to 255 := 0;
    signal FSA_input_digit, next_FSA_input_digit : Integer := 0;
    signal output_write_address, next_output_write_address :  std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(1000, 16));


    function get_digit (signal a : std_logic_vector(7 downto 0); index : Integer) return Integer is
    begin
        if a(index) = '0' then
            return 0;
        else 
            return 1;
        end if;
    end function;
    begin

    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            state_reg <= Ready;
            FSA_state_reg <= A;
            in_mask_reg <= "00000000";
			address_reg <= "0000000000000000";
            output_reg <= "0000000000000000";
            output_write_address <= std_logic_vector(to_unsigned(1000, 16));
        elsif (i_clk'event and i_clk='1') then
            state_reg <= next_state;
            FSA_state_reg <= next_FSA_state;
            o_done <= next_o_done;
            o_en <= next_o_en;
            o_we <= next_o_we;
            o_data <= next_o_data;
            o_address <= next_o_address;
            output_reg <= next_output;
            address_reg <= next_address;
            data <= next_data;
            num_words <= next_num_words;
            in_mask_reg <= next_in_mask;
            out_mask_reg <= next_out_mask;
            FSA_input_digit <= next_FSA_input_digit;
            output_write_address <= next_output_write_address;
        end if;
    end process;
    
    process (state_reg, FSA_state_reg, i_data, i_start, address_reg, output_reg, in_mask_reg, out_mask_reg, num_words, data, FSA_input_digit, output_write_address)
    begin
        next_o_done <= '0';
        next_o_en <= '0';
        next_o_we <= '0';
        next_o_data <= "00000000";
        next_o_address <= "0000000000000000";
        next_in_mask <= in_mask_reg;
        next_out_mask <= out_mask_reg;
        next_address <= address_reg;
        next_num_words <= num_words;
        next_data <= data;
        next_FSA_input_digit <= FSA_input_digit;
        next_FSA_state <= FSA_state_reg;
        next_output_write_address <= output_write_address;
        next_output <= output_reg;
        case state_reg is
            when Ready => 
                if (i_start = '1') then
                    next_state <= Request_num_words;
                    next_o_en <= '1';
                    next_o_we <= '0';
                    next_o_address <= std_logic_vector(to_unsigned(0, 16));
                else
                    next_state <= Ready;
                end if;

            when Request_num_words =>
                next_state <= Get_num_words;

            when Get_num_words =>
                next_num_words <= to_integer(unsigned(i_data));
                next_state <= Request_data;

            when Request_data =>
                if (num_words = 0) then
                    next_o_done <= '1';
                    next_state <= Done;
                else
                    next_o_en <= '1';
                    next_o_we <= '0';
                    next_o_address <= address_reg + 1;
                    next_address <= address_reg + 1;
                    next_num_words <= num_words - 1;
                    next_state <= Wait_data;
                end if;    

            when Wait_data =>
                next_state <= Set_mask;

            when Set_mask => 
                next_state <= FSA_state_reg;
                next_data <= i_data;
                if (in_mask_reg = "00000000") then
                    next_in_mask <= "10000000";
                    next_out_mask <= "1100000000000000";
                    next_FSA_input_digit <= get_digit(i_data, 7);
                elsif (in_mask_reg = "10000000") then
                    next_in_mask <= "01000000";
                    next_out_mask <= "0011000000000000";
                    next_FSA_input_digit <= get_digit(data, 6);
                elsif (in_mask_reg = "01000000") then
                    next_in_mask <= "00100000";
                    next_out_mask <= "0000110000000000";
                    next_FSA_input_digit <= get_digit(data, 5);
                elsif (in_mask_reg = "00100000") then
                    next_in_mask <= "00010000";
                    next_out_mask <= "0000001100000000";
                    next_FSA_input_digit <= get_digit(data, 4);
                elsif (in_mask_reg = "00010000") then
                    next_in_mask <= "00001000";
                    next_out_mask <= "0000000011000000";
                    next_FSA_input_digit <= get_digit(data, 3);
                elsif (in_mask_reg = "00001000") then
                    next_in_mask <= "00000100";
                    next_out_mask <= "0000000000110000";
                    next_FSA_input_digit <= get_digit(data, 2);
                elsif (in_mask_reg = "00000100") then
                    next_in_mask <= "00000010";
                    next_out_mask <= "0000000000001100";
                    next_FSA_input_digit <= get_digit(data, 1);
                elsif (in_mask_reg = "00000010") then
                    next_in_mask <= "00000001";
                    next_out_mask <= "0000000000000011";
                    next_FSA_input_digit <= get_digit(data, 0);
                else
                    next_state <= Write_output;
                end if;

            when A =>
                if (FSA_input_digit = 0) then
                    next_FSA_state <= A;
                    next_output <= ("0000000000000000" and out_mask_reg) or output_reg;
                else 
                    next_FSA_state <= C;
                    next_output <= ("1111111111111111" and out_mask_reg) or output_reg;
                end if;
                next_state <= Set_mask;

            when B =>
                if (FSA_input_digit = 0) then
                    next_FSA_state <= A;
                    next_output <= ("1111111111111111" and out_mask_reg) or output_reg;
                else
                    next_FSA_state <= C;
                    next_output <= ("0000000000000000" and out_mask_reg) or output_reg;
                end if;
                next_state <= Set_mask;

            when C =>
                if (FSA_input_digit = 0) then
                    next_FSA_state <= B;
                    next_output <= ("0101010101010101" and out_mask_reg) or output_reg;
                else
                    next_FSA_state <= D;
                    next_output <= ("1010101010101010" and out_mask_reg) or output_reg;
                end if;
                next_state <= Set_mask;

            when D =>
                if (FSA_input_digit = 0) then
                    next_FSA_state <= B;
                    next_output <= ("1010101010101010" and out_mask_reg) or output_reg;
                else
                    next_FSA_state <= D;
                    next_output <= ("0101010101010101" and out_mask_reg) or output_reg;
                end if;
                next_state <= Set_mask;

            when Write_output =>
                next_o_en <= '1';
                next_o_we <= '1';
                next_o_address <= output_write_address;
                next_output_write_address <= output_write_address + 1;
                next_o_data <= output_reg(15 downto 8); -- write 1st part of the result
                next_state <= Wait_writing;

            when Wait_writing =>
                next_o_en <= '1';
                next_o_we <= '1';
                next_o_data <= output_reg(7 downto 0); -- write 2nd part of the result
                next_o_address <= output_write_address;
                next_output_write_address <= output_write_address + 1;
                next_in_mask <= "00000000";
                next_output <= "0000000000000000";
                next_state <= Request_data;

            when Done =>
                if (i_start = '0') then
                    next_state <= Ready;
                    next_o_done <= '0';
                    next_address <= "0000000000000000";
                    next_in_mask <= "00000000";
                    next_output <= "0000000000000000";
                    next_FSA_state <= A;
                    next_output_write_address <= std_logic_vector(to_unsigned(1000, 16));
                else
                    next_state <= Done;
                end if;
        end case;
    end process;
end Behavior;