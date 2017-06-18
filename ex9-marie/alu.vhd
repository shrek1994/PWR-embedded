library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity alu is
    generic (DEBUG : boolean := false);
    Port (
        clk : in std_logic;
        bus_data : in std_logic_vector (15 downto 0);
        acc_in : in std_logic_vector(8 downto 0);
        acc_out : out std_logic_vector(8 downto 0)
        );
end alu;

architecture Behavioral of alu is
    constant OWN_ID : std_logic_vector (2 downto 0) := "101";
    constant ACC_ID : std_logic_vector (2 downto 0) := "101";

    signal calculated : std_logic := '0';
    signal result : std_logic_vector(8 downto 0) := (others => '0');

    type state_type is (IDLE, RUN, SEND);
    signal current_state : state_type := IDLE;
    signal next_state : state_type := IDLE;

    type cmd_type is (NOTHING, ADD, SUBT);
    signal current_cmd : cmd_type := NOTHING;
    signal sending_data : std_logic_vector (15 downto 0) := (others => '0');

    function to_string(state: state_type) return string is
    begin
        case state is
            when IDLE => return "IDLE";
            when RUN  => return "RUN";
            when SEND => return "SEND";
        end case;
    end to_string;

    function decode_cmd(cmd : std_logic_vector(3 downto 0)) return cmd_type is
    begin
        case cmd is
            when "0100" => return ADD;
            when "0101" => return SUBT;
            when others => return NOTHING;
        end case;
    end decode_cmd;
begin

stateadvance: process(clk)
begin
    if current_state /= next_state then
        print(DEBUG, "PC: changing state to: " &  to_string(next_state));
    end if;

    if rising_edge(clk)
    then
        current_state <= next_state;
    end if;
    if falling_edge(clk) and next_state = SEND then
        current_state <= next_state;
    end if;

end process;

nextAddress: process(current_state, bus_data)
    variable current_cmd : cmd_type;
    variable id : std_logic_vector (2 downto 0);
    variable command : std_logic_vector (3 downto 0);
    variable data : std_logic_vector (8 downto 0);
begin
    case current_state is
        when IDLE =>
            calculated <= '0';
            id := bus_data(15 downto 13);
            command := bus_data(12 downto 9);
            data := bus_data(8 downto 0);
            if id = OWN_ID
            then
                print(DEBUG, "ALU: receive command: " & str(command));
                next_state <= RUN;
                current_cmd := decode_cmd(command);
            else
                next_state <= IDLE;
            end if;
    when RUN =>
        case current_cmd is
            when ADD =>
                result <= std_logic_vector(unsigned(acc_in) + unsigned(data));
                print(DEBUG, "ALU: adding: " & str(acc_in) & "+" & str(data) & "=" & str(result));
                next_state <= SEND;
            when SUBT =>
                result <= std_logic_vector(unsigned(acc_in) - unsigned(data));
                print(DEBUG, "ALU: adding: " & str(acc_in) & "-" & str(data) & "=" & str(result));
                next_state <= SEND;
            when others =>
                next_state <= IDLE;
        end case;
    when SEND =>
        case current_cmd is
            when ADD =>
                calculated <= '1';
            when SUBT =>
                calculated <= '1';
            when others =>
                null;
        end case;
        next_state <= IDLE;
    when others =>
        next_state <= IDLE;
    end case;
end process;

acc_out <= result when calculated = '1' else "ZZZZZZZZZ";

end Behavioral;
