library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity acc_register is
    generic (DEBUG : boolean := false);
    Port (
        clk : in std_logic;
        bus_data : inout std_logic_vector (15 downto 0);
        acc_in : in std_logic_vector(8 downto 0);
        acc_out : out std_logic_vector(8 downto 0)
        );
end acc_register;

architecture Behavioral of acc_register is

    constant OWN_ID : std_logic_vector (2 downto 0) := "011";
    signal sending : std_logic := '0';
    signal should_send : std_logic := '0';

    type state_type is (IDLE, CMD, RUN);
    signal current_state : state_type := IDLE;
    signal next_state : state_type := IDLE;

    type cmd_type is (NOTHING, SET, GET, RESET);
    signal current_cmd : cmd_type := NOTHING;
    signal sending_data : std_logic_vector (15 downto 0) := (others => '0');

    signal reg : std_logic_vector (8 downto 0) := (others => '0');

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
            when "1111" => return RESET;
            when others => return NOTHING;
        end case;
    end decode_cmd;
begin

stateadvance: process(clk)
    variable sleep : unsigned (1 downto 0) := "10";
begin
    if rising_edge(clk) and sending = '0'
    then
        if current_state /= next_state then
            print(DEBUG, "ACC: changing state to: " &  to_string(next_state));
        end if;
        current_state <= next_state;
        sleep := "11";
    end if;
    if should_send = '1' and clk = '0'
    then
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
    variable sent : unsigned(1 downto 0) := "00";
begin
    case current_state is
        when IDLE =>
            should_send <= '0';
            id := bus_data(15 downto 13);
            command := bus_data(12 downto 9);
            data := bus_data(8 downto 0);
            if id = OWN_ID and sending /= '1'
            then
                print(DEBUG, "ACC: receive command: " & str(command));
                next_state <= CMD;
                current_cmd := decode_cmd(command);
            else
                next_state <= IDLE;
            end if;
    when CMD =>
        case current_cmd is
            when GET =>
                print(DEBUG, "ACC: GET");
                sent := "10";
                next_state <= RUN;
            when SET =>
                print(DEBUG, "ACC: SET");
                next_state <= RUN;
            when RESET =>
                print(DEBUG, "ACC: RESET");
                next_state <= RUN;
            when others =>
                next_state <= IDLE;
        end case;
    when RUN =>
        case current_cmd is
            when GET =>
                should_send <= '1';
                sending_data <= "ZZZZZZZ" & reg;
                print(DEBUG, "ACC: set sending data:" & str(sending_data));
                next_state <= IDLE;
            when SET =>
                reg <= data;
                print(DEBUG, "ACC: set:" & str(data));
                next_state <= IDLE;
            when RESET =>
                reg <= "000000000";
                print(DEBUG, "ACC: reset:" & str(reg));
                next_state <= IDLE;
            when others =>
                next_state <= IDLE;
        end case;
    when others =>
        next_state <= IDLE;
    end case;

end process;

bus_data <= sending_data when sending = '1' else "ZZZZZZZZZZZZZZZZ";



end Behavioral;
