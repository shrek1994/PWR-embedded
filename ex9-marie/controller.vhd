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

    signal send_out : std_logic := '0';
    signal send_out_data : std_logic_vector (8 downto 0);
begin

    nextstate: process(clk)
        variable fetch_state : unsigned (2 downto 0) := "000"; -- TODO change to enum !!!
        variable instruction_bits : std_logic_vector(3 downto 0);
        variable argument_bits : std_logic_vector(4 downto 0);
    begin

    if rising_edge(clk) and receive = '1' then
        instruction_bits := bus_data(8 downto 5);
        argument_bits := bus_data(4 downto 0);
        print(DEBUG, "CTRL: receive command: " & str(instruction_bits) & "-" & str(argument_bits));
    end if;

    if falling_edge(clk) then
        bus_data <= NULL_BUS_DATA;
        send_out <= '0';
        current_state <= next_state;

        case current_state is
            when FETCH =>
                -- get instruction:

                print(DEBUG, "CTRL: fetch_state: " & str(std_logic_vector(fetch_state)));

                if fetch_state = "011" then
                    bus_data <= PC_ID & NEXT_PC_CMD & NULL_DATA;
                    fetch_state := fetch_state + 1;
                    receive <= '1';
                    next_state <= DECODE;
                end if;

                if fetch_state = "010" then
                    bus_data <= RAM_ID & GET_CMD & NULL_DATA;
                    fetch_state := fetch_state + 1;
                end if;

                if fetch_state = "001" then
                    bus_data <= NULL_BUS_DATA;
                    fetch_state := fetch_state + 1;
                end if;

                if fetch_state = "000" then
                    bus_data <= PC_ID & GET_CMD & NULL_DATA;
                    fetch_state := fetch_state + 1;
                end if;

            when DECODE =>
                fetch_state := "000";
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
                    when LOAD =>
                        print(DEBUG, "CTRL: load: " & str(argument_bits));
--                         bus_data <= RAM_ID & GET_CMD & argument_bits;
                        print(DEBUG, "CTRL: load2: " & str(argument_bits));
                            next_state <= STORE;
                    when OUTPUT =>
                            print(DEBUG, "CTRL: sending: " & str(acc_out));
                            send_out <= '1';
                            next_state <= FETCH;
                    when others =>
                        next_state <= HALT;
                end case;
            when STORE =>
                print(DEBUG, "CTRL: STORE: instruction: " & str(current_cmd));
                next_state <= FETCH;
                case current_cmd is
                    when LOAD =>
                        print(DEBUG, "CTRL: load: " & str(argument_bits));
--                         bus_data <= ACC_ID & SET_CMD & NULL_DATA;
                    when OUTPUT =>
                        null;
                    when others =>
                        next_state <= HALT;
                end case;
            when HALT =>
                null;
            when others =>
                null;
        end case;
    end if;

    end process;

    startSendingOut: process(send_out)
        variable data : std_logic_vector(8 downto 0);
    begin
        if send_out = '1' then
            data := acc_out;
            print(DEBUG, "CTRL: starting sending out: " & str(data));
        else
            print(DEBUG, "CTRL: ending sending out: " & str(data));
        end if;
    end process;

    output_data <= acc_out when send_out = '1' else NULL_DATA;

end Flow;

