library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity pc is
    generic (DEBUG : boolean := false; VERBOSE : boolean := false);
    Port (
        clk : in std_logic;
        bus_data : inout std_logic_vector (15 downto 0)
        );
end pc;

architecture Behavioral of pc is

    constant OWN_ID : std_logic_vector (2 downto 0) := PC_ID;

    signal sending : std_logic := '0';
    signal sending_on_falling_clk : std_logic := '0';

    type state_type is (IDLE, CMD, RUN);
    signal current_state : state_type := IDLE;
    signal next_state : state_type := IDLE;

    type cmd_type is (NOTHING, SET, GET, NEXT_PC, RESET);
    signal current_cmd : cmd_type := NOTHING;
    signal sending_data : std_logic_vector (15 downto 0) := (others => '0');

    function to_string(state: state_type) return string is
    begin
        case state is
            when IDLE => return "IDLE";
            when CMD => return "CMD";
            when RUN => return "RUN";
        end case;
    end to_string;

    function decode_cmd(cmd : std_logic_vector(3 downto 0)) return cmd_type is
    begin
        case cmd is
            when "0001" => return GET;
            when "0010" => return SET;
            when "0011" => return NEXT_PC;
            when "1111" => return RESET;
            when others => return NOTHING;
        end case;
    end decode_cmd;

    function to_string(cmd: cmd_type) return string is
    begin
        case cmd is
            when GET => return "GET";
            when SET => return "SET";
            when NEXT_PC => return "NEXT_PC";
            when RESET => return "RESET";
            when NOTHING => return "NOTHING";
        end case;
        return "";
    end to_string;
begin

stateadvance: process(clk)
    variable sleep : unsigned (1 downto 0) := "10";
begin
    if rising_edge(clk) and sending = '0'
    then
        if current_state /= next_state then
            print(VERBOSE, "PC: changing state to: " &  to_string(next_state));
        end if;
        current_state <= next_state;
        sleep := "11";
    end if;
    if sending = '1' and sleep = "00"then
        current_state <= next_state;
    end if;
    sleep := sleep - 1;
end process;

nextAddress: process(current_state, bus_data)
    variable init : boolean := true;
    variable current_cmd : cmd_type;
    variable id : std_logic_vector (2 downto 0);
    variable command : std_logic_vector (3 downto 0);
    variable data : std_logic_vector (4 downto 0);
    variable counter : unsigned(4 downto 0) := (others => '0');
    variable sent : unsigned(1 downto 0) := "00";
begin
    sending_on_falling_clk <= '0';

    case current_state is
        when IDLE =>
            sending <= '0';
            id := bus_data(15 downto 13);
            command := bus_data(12 downto 9);
            data := bus_data(4 downto 0);
            if id = OWN_ID and sending /= '1'
            then
                current_cmd := decode_cmd(command);
                print(DEBUG, "PC: receive command: " & to_string(current_cmd) & " with data: " & str(data));
                next_state <= CMD;
            else
                next_state <= IDLE;
            end if;
        sending <= '0';
    when CMD =>
        case current_cmd is
            when GET =>
                print(VERBOSE, "PC: GET");
                sent := "10";
                next_state <= RUN;
            when SET =>
                print(VERBOSE, "PC: SET");
                next_state <= RUN;
            when NEXT_PC =>
                print(VERBOSE, "PC: NEXT_PC");
                next_state <= RUN;
            when RESET =>
                print(VERBOSE, "PC: RESET");
                next_state <= RUN;
            when others =>
                next_state <= IDLE;
        end case;
    when RUN =>
        case current_cmd is
            when GET =>
                sending <= '1';
                sending_data <= "ZZZZZZZZZZZ" & std_logic_vector(counter);
                print(VERBOSE, "PC: set sending data:" & str(sending_data));
                next_state <= IDLE;
            when SET =>
                counter := unsigned(data);
                print(VERBOSE, "PC: set:" & str(data));
                next_state <= IDLE;
            when NEXT_PC =>
                if next_state = RUN then
                    counter := counter + 1;
                print(VERBOSE, "PC: next:" & str(std_logic_vector(counter)));
                end if;
                next_state <= IDLE;
            when RESET =>
                counter := "00000";
                print(VERBOSE, "PC: reset:" & str(std_logic_vector(counter)));
                next_state <= IDLE;
            when others =>
                next_state <= IDLE;
        end case;
    when others =>
        next_state <= IDLE;
    end case;

end process;

startSending: process(sending)
    variable data : std_logic_vector(15 downto 0);
begin
    if sending = '1' then
        data := sending_data;
        print(DEBUG, "PC: starting sending: " & str(data));
    else
        print(DEBUG, "PC: ending sending: " & str(data));
    end if;
end process;

bus_data <= sending_data when sending = '1' else NULL_BUS_DATA;


end Behavioral;
