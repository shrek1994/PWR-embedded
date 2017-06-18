
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE work.txt_util.ALL;

entity controller is
  generic (DEBUG : boolean);
  port(
        clk : in std_logic;
        bus_data : inout std_logic_vector (15 downto 0);

        input_data : in std_logic_vector (8 downto 0);
        output_data : out std_logic_vector (8 downto 0)
  );
end controller;

architecture Flow of controller is
    type state is (FETCH, DECODE, EXECUTE, STORE, HALT);
    signal current_state : state := HALT;
    signal next_state : state := FETCH;

    type cmd_type is (LOAD, STORE, ADD, SUBT, INPUT, OUTPUT, HALT, SKIPCOND, JUMP);
    attribute enum_encoding: string;
    attribute enum_encoding of cmd_type: type is
				"0001 0010 0011 0100 0101 0110 0111 1000 1001";
    signal current_cmd : cmd_type := HALT;

    signal instruction_bits : std_logic_vector(3 downto 0);
    signal argument : std_logic_vector(4 downto 0);
begin



    nextstate: process(current_state, clk)
    begin
        case current_state is
            when FETCH =>
                print(DEBUG, "CTRL: FETCH");
                instruction_bits <= instruction(8 downto 5);
                argument <= instruction(4 downto 0);
                current_state <= DECODE;
            when DECODE =>
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
                    when others =>
                        current_cmd <= HALT;
                end case;
                current_state <= EXECUTE;
            when EXECUTE =>
                case current_cmd is
                    when LOAD =>
                        address <= argument;
                        save_to_ram <= '1';
                    when others =>
                        null;
                end case;
            when STORE =>
                null;
            when HALT =>
                null;
            when others =>
                null;
        end case;
        end if;
    end process;

end Flow;

