library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.utills.all;
use work.txt_util.all;


entity ram is
    generic (RAM_DATA : data_type := (others => "000000000"); DEBUG : boolean := false; VERBOSE : boolean := false);
    Port (
        clk : in std_logic;
        bus_data : inout std_logic_vector (15 downto 0);

        ram_debug : out data_type
        );
end ram;

architecture Behavioral of ram is
    constant OWN_ID : std_logic_vector (2 downto 0) := "001";
    signal next_state_on_rising_edge : std_logic := '1';
    signal sending : std_logic := '0';
    signal should_send : std_logic := '0';

    type state_type is (IDLE, CMD, RUN);
    signal current_state : state_type := IDLE;
    signal next_state : state_type := IDLE;

    type cmd_type is (NOTHING, SET_DATA, GET_DATA);
    signal current_cmd : cmd_type := NOTHING;
    signal sending_data : std_logic_vector (15 downto 0) := (others => '0');

    signal data_ram : data_type;

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
            when "0001" => return GET_DATA;
            when "0010" => return SET_DATA;
            when others => return NOTHING;
        end case;
    end decode_cmd;

    function to_string(cmd: cmd_type) return string is
    begin
        case cmd is
            when GET_DATA => return "GET_DATA";
            when SET_DATA => return "SET_DATA";
            when NOTHING => return "NOTHING";
        end case;
        return "";
    end to_string;
begin

stateadvance: process(clk)
    variable sleep : unsigned(1 downto 0) := "00";
begin
    if rising_edge(clk) and sending = '0'
    then
        if current_state /= next_state then
            print(VERBOSE, "RAM: changing state to: " &  to_string(next_state));
        end if;
        current_state <= next_state;
        sleep := "11";
    end if;
    if should_send = '1' and clk = '0'
    then
        print(VERBOSE, "RAM: start sending: " &  str(sending_data));
        sending <= '1';
    end if;
    if sending = '1' and sleep = "00" then
        current_state <= next_state;
        sending <= '0';
    end if;
    sleep := sleep - 1;
end process;

nextAddress: process(current_state, bus_data)
    variable init : boolean := true;
    variable current_cmd : cmd_type;
    variable id : std_logic_vector (2 downto 0);
    variable command : std_logic_vector (3 downto 0);
    variable data : std_logic_vector (8 downto 0);
    variable address : std_logic_vector(4 downto 0);
begin
    if init then
        data_ram <= RAM_DATA;
        init := false;
    end if;

    case current_state is
        when IDLE =>
            should_send <= '0';
            id := bus_data(15 downto 13);
            command := bus_data(12 downto 9);
            data := bus_data(8 downto 0);
            if id = OWN_ID and sending /= '1'
            then
                current_cmd := decode_cmd(command);
                print(DEBUG, "RAM: receive command: " & to_string(current_cmd) & ", with data:" & str(data));
                next_state <= CMD;
            else
                next_state <= IDLE;
            end if;
    when CMD =>
        case current_cmd is
            when GET_DATA =>
                address := data(4 downto 0);
                print(VERBOSE, "RAM: GET_DATA, address: " & str(address));
                next_state <= RUN;
            when SET_DATA =>
                if next_state = CMD then
                    address := data(4 downto 0);
                end if;
                data := bus_data(8 downto 0);
                print(DEBUG, "RAM: SET_DATA, address: " & str(address) & ", date: " & str(data));
                data_ram(to_integer(unsigned(address))) <= data;
                next_state <= IDLE;
            when others =>
                next_state <= IDLE;
        end case;
    when RUN =>
        case current_cmd is
            when GET_DATA =>
                sending_data <= "ZZZZZZZ" & data_ram(to_integer(unsigned(address)));
                should_send <= '1';
                print(VERBOSE, "RAM: set sending data:" & str(sending_data));
            when SET_DATA =>
                data_ram(to_integer(unsigned(address))) <= data;
            when others =>
                null;
        end case;
        next_state <= IDLE;
    when others =>
        next_state <= IDLE;
    end case;

end process;

startSending: process(sending)
    variable data : std_logic_vector(15 downto 0);
begin
    if sending = '1' then
        data := sending_data;
        print(DEBUG, "RAM: starting sending: " & str(data));
    else
        print(DEBUG, "RAM: ending sending: " & str(data));
    end if;
end process;

bus_data <= sending_data when sending = '1' else NULL_BUS_DATA;
ram_debug <= data_ram;

end Behavioral;
