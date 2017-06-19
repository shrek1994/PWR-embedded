LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
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

    constant RAM_ID : std_logic_vector (2 downto 0) := "001";
    constant PC_ID  : std_logic_vector (2 downto 0) := "010";
    constant ACC_ID : std_logic_vector (2 downto 0) := "011";
    constant OWN_ID : std_logic_vector (2 downto 0) := "100";
    constant ALU_ID : std_logic_vector (2 downto 0) := "101";

    constant GET_CMD    : std_logic_vector (3 downto 0) := "0001";
    constant SET_CMD    : std_logic_vector (3 downto 0) := "0010";
    constant NEXT_PC_CMD: std_logic_vector (3 downto 0) := "0011";
    constant ADD_CMD    : std_logic_vector (3 downto 0) := "0100";
    constant SUBT_CMD   : std_logic_vector (3 downto 0) := "0101";

    constant NULL_DATA : std_logic_vector (8 downto 0) := "ZZZZZZZZZ";

begin

    nextstate: process(clk)
        variable number_of_instruction : unsigned (2 downto 0) := "000";
    begin
        if falling_edge(clk) then
            current_state <= next_state;

        case current_state is
            when FETCH => -- get instruction

                if number_of_instruction = "100" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= "ZZZZZZZZZZZZZZZZ";
                    next_state <= DECODE;
                end if;


                if number_of_instruction = "011" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= "ZZZZZZZZZZZZZZZZ";
                    number_of_instruction := number_of_instruction + 1;
                end if;

                if number_of_instruction = "010" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= RAM_ID & GET_CMD & NULL_DATA;
                    number_of_instruction := number_of_instruction + 1;
                end if;

                if number_of_instruction = "001" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= "ZZZZZZZZZZZZZZZZ";
                    number_of_instruction := number_of_instruction + 1;
                end if;

                if number_of_instruction = "000" then
                    print(DEBUG, "CTRL: number_of_instruction: " & str(std_logic_vector(number_of_instruction)));
                    bus_data <= PC_ID & GET_CMD & NULL_DATA;
                    number_of_instruction := number_of_instruction + 1;
                end if;

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
                next_state <= EXECUTE;
            when EXECUTE =>
                case current_cmd is
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

