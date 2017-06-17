
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE work.txt_util.ALL;

entity controller is
  port(
	instruction:   in std_logic_vector (8 downto 0);
	operation:     out std_logic_vector (1 downto 0) := "ZZ";
	value :        out std_logic_vector(4 downto 0) := "ZZZZZ";
	address :      out std_logic_vector(4 downto 0) := "ZZZZZ";
	save_to_ram :  out std_logic := '0';
	save_to_pc :   out std_logic := '0';
	save_to_acc :  out std_logic := '0';
	next_pc :      out std_logic := '0'
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

    signal clk : std_logic := '1';
    constant clk_period : time := 10 ns;

    signal instruction_bits : std_logic_vector(3 downto 0);
    signal argument : std_logic_vector(4 downto 0);

    constant debug : boolean := true;
begin

--     clock : process
--     begin
--         clk <= '0';
--         wait for clk_period / 2;
--         clk <= '1';
--         current_state <= next_state;
--         wait for clk_period / 2;
--         --reset:
--
--     end process;

    nextstate: process(instruction, current_state, clk)
    begin
        print(debug, "CTRL: inst:" & str(instruction));
        if clk = '1' and instruction /= "ZZZZZZZZZ" then
        case current_state is
            when FETCH =>
                print(debug, "CTRL: FETCH");
                instruction_bits <= instruction(8 downto 5);
                argument <= instruction(4 downto 0);
                current_state <= DECODE;
            when DECODE =>
                print(debug, "CTRL: DECODE: instruction_bits: " & str(instruction_bits));
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

