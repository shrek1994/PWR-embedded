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
    type state is (FETCH, FETCH_2, FETCH_3, FETCH_4, FETCH_5, DECODE, EXECUTE, EXECUTE_2, STORE, HALT);
    signal current_state : state := HALT;
    signal next_state : state := FETCH;

    signal current_cmd : cmd_type := HALT;

    signal receive : std_logic := '0';

    signal send_out : std_logic := '0';
    signal send_out_data : std_logic_vector (8 downto 0);

    signal send_bus : std_logic := '0';
    signal send_bus_data : std_logic_vector (15 downto 0);

    signal instruction_bits : std_logic_vector(3 downto 0);
    signal argument_bits : std_logic_vector(4 downto 0);
begin

    clock : process (clk)
    begin
        if rising_edge(clk) and receive = '1' then
            instruction_bits <= bus_data(8 downto 5);
            argument_bits <= bus_data(4 downto 0);
            print(DEBUG, "CTRL: receive command: " & str(instruction_bits) & "-" & str(argument_bits));
        end if;

        if falling_edge(clk) then
            if current_state /= next_state then
                print(DEBUG, "CTRL: changing state");
            end if;
        current_state <= next_state;
        end if;
    end process;

    nextstate: process(current_state)
        variable fetch_state : unsigned (2 downto 0) := "000"; -- TODO change to enum !!!
    begin
        send_bus <= '0';
        send_out <= '0';

        case current_state is
            when FETCH =>
                print(DEBUG, "CTRL: ------------------------------ Loading new command ------------------------------");
                send_bus_data <= PC_ID & GET_CMD & NULL_DATA;
                send_bus <= '1';
                next_state <= FETCH_2;
            when FETCH_2 =>
                next_state <= FETCH_3;
            when FETCH_3 =>
                send_bus_data <= RAM_ID & GET_CMD & NULL_DATA;
                send_bus <= '1';
                next_state <= FETCH_4;
            when FETCH_4 =>
                send_bus_data <= PC_ID & NEXT_PC_CMD & NULL_DATA;
                send_bus <= '1';
                receive <= '1';
                next_state <= FETCH_5;
            when FETCH_5 =>
                next_state <= DECODE;
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
                print(DEBUG, "CTRL: ------------------------- EXECUTE ------------------------ instruction: " & str(current_cmd));
                case current_cmd is
                    when LOAD =>
                        print(DEBUG, "CTRL: load: " & str(argument_bits));

                        send_bus_data <= RAM_ID & GET_CMD & "ZZZZ" & argument_bits;
                        send_bus <= '1';
                        next_state <= EXECUTE_2;

                    when STORE =>
                        print(DEBUG, "CTRL: store: " & str(argument_bits));

                        send_bus_data <= ACC_ID & GET_CMD & NULL_DATA;
                        send_bus <= '1';

                        next_state <= EXECUTE_2;
                    when OUTPUT =>
                            print(DEBUG, "CTRL: sending: " & str(acc_out));
                            send_out <= '1';
                            next_state <= FETCH;
                    when others =>
                        next_state <= HALT;
                end case;
            when EXECUTE_2 =>
                print(DEBUG, "CTRL: EXECUTE_2: instruction: " & str(current_cmd));
                case current_cmd is
                    when LOAD =>
                        next_state <= STORE;
                    when STORE =>
                        print(DEBUG, "CTRL: store into: " & str(argument_bits));

                        send_bus_data <= RAM_ID & SET_CMD & "ZZZZ" & argument_bits;
                        send_bus <= '1';

                        next_state <= STORE;
                    when others =>
                        next_state <= HALT;
                end case;
            when STORE =>
                print(DEBUG, "CTRL: STORE: instruction: " & str(current_cmd));
                next_state <= FETCH;
                case current_cmd is
                    when LOAD =>
                        send_bus_data <= ACC_ID & SET_CMD & NULL_DATA;
                        send_bus <= '1';
                        next_state <= FETCH;
                    when STORE =>
                        send_bus_data <= RAM_ID & SET_CMD & NULL_DATA;
                        send_bus <= '1';
                        next_state <= FETCH;
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

    startSendingBus: process(send_bus)
        variable data : std_logic_vector(15 downto 0);
    begin
        if send_bus = '1' then
            data := send_bus_data;
            print(DEBUG, "CTRL: starting sending bus: " & str(data));
        else
            print(DEBUG, "CTRL: ending sending bus: " & str(data));
        end if;
    end process;

    output_data <= acc_out when send_out = '1' else NULL_DATA;
    bus_data <= send_bus_data when send_bus = '1' else NULL_BUS_DATA;

end Flow;

