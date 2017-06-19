LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
USE work.txt_util.ALL;
USE work.utills.ALL;

entity controller is
  generic (DEBUG : boolean);
  port(
        clk : in std_logic;
        bus_data : inout std_logic_vector (15 downto 0);

        acc_in : out std_logic_vector(8 downto 0);
        acc_out : in std_logic_vector(8 downto 0);

        input_data : in std_logic_vector (8 downto 0);
        output_data : out std_logic_vector (8 downto 0)
  );
end controller;

architecture Flow of controller is
    type state is (FETCH, DECODE, EXECUTE, STORE, HALT);
    signal current_state : state := HALT;
    signal next_state : state := FETCH;

    signal current_cmd : cmd_type := HALT;

    signal receive : std_logic := '0';
begin

    nextstate: process(clk)
        variable number_of_instruction : unsigned (2 downto 0) := "000"; -- TODO change to enum !!!
        variable instruction_bits : std_logic_vector(3 downto 0);
        variable argument_bits : std_logic_vector(4 downto 0);
    begin

    if rising_edge(clk) and receive = '1' then
        instruction_bits := bus_data(8 downto 5);
        argument_bits := bus_data(4 downto 0);
        print(DEBUG, "CTRL: receive data / command: " & str(instruction_bits) & ", " & str(argument_bits));
    end if;

    if falling_edge(clk) then
        bus_data <= NULL_BUS_DATA;
        output_data <= NULL_DATA;
        current_state <= next_state;

        case current_state is
            when FETCH =>
                -- get instruction:
                if number_of_instruction = "011" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= PC_ID & NEXT_PC_CMD & NULL_DATA;
                    number_of_instruction := number_of_instruction + 1;
                    receive <= '1';
                    next_state <= DECODE;
                end if;

                if number_of_instruction = "010" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= RAM_ID & GET_CMD & NULL_DATA;
                    number_of_instruction := number_of_instruction + 1;
                end if;

                if number_of_instruction = "001" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= NULL_BUS_DATA;
                    number_of_instruction := number_of_instruction + 1;
                end if;

                if number_of_instruction = "000" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= PC_ID & GET_CMD & NULL_DATA;
                    number_of_instruction := number_of_instruction + 1;
                end if;

            when DECODE =>
                number_of_instruction := "000";
                receive <= '0';
                print(DEBUG, "CTRL: DECODE: instruction_bits: " & str(instruction_bits));
                case instruction_bits is
                    when "0001" =>
                        current_cmd <= LOAD;
                    when "0010" =>
                        current_cmd <= STORE;
                    when "0011" =>
                        current_cmd <= ADD;
                    when "0100" =>
                        current_cmd <= SUBT;
                    when "0101" =>
                        current_cmd <= INPUT;
                    when "0110" =>
                        current_cmd <= OUTPUT;
                    when "0111" =>
                        current_cmd <= HALT;
                    when "1000" =>
                        current_cmd <= SKIPCOND;
                    when "1001" =>
                        current_cmd <= JUMP;
                    when others =>
                        current_cmd <= HALT;
                end case;
                next_state <= EXECUTE;
            when EXECUTE =>
                print(DEBUG, "CTRL: EXECUTE: instruction: " & str(current_cmd));
                case current_cmd is
                    when OUTPUT =>
                            print(DEBUG, "CTRL: sending: " & str(acc_out));
                            output_data <= acc_out;
                            next_state <= FETCH;
                    when others =>
                        next_state <= HALT;
                end case;
            when STORE =>
                next_state <= FETCH;

            when HALT =>
                null;
            when others =>
                null;
        end case;
    end if;

    end process;

end Flow;

