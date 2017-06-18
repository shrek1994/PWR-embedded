LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity acc_register_tb is
end acc_register_tb;

architecture behavior of acc_register_tb is
    component acc_register is
    generic (DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    constant clk_period :time := 10 ns;

    constant DEBUG : boolean := false;

    signal bus_data : std_logic_vector(15 downto 0) := (others => 'Z');

    constant ID : std_logic_vector (2 downto 0) := "011";
    constant RESET_CMD : std_logic_vector (3 downto 0) := "1111";
    constant GET_CMD : std_logic_vector (3 downto 0):= "0001";
    constant SET_CMD : std_logic_vector (3 downto 0):= "0010";
    constant NULL_DATA : std_logic_vector (8 downto 0) := "ZZZZZZZZZ";
    constant DATA : std_logic_vector (8 downto 0) := "110011001";

    procedure checkData(signal conn_bus : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        conn_bus <= ID & GET_CMD & NULL_DATA;
        wait for clk_period * 2;

        conn_bus <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;
        wait for clk_period * 3 / 4;
		assert conn_bus(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"' on conn_bus -- got: '" & str(conn_bus) & "'";
        wait for clk_period / 4;
    end checkData;

BEGIN
    uut: acc_register generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    stim_proc: process
    begin

    wait for 100 ns;

    bus_data <= ID & RESET_CMD & NULL_DATA;
    wait for clk_period * 2;

    checkData(bus_data, "000000000", "zero after reset");

    bus_data <= ID & SET_CMD & DATA;
    wait for clk_period * 2;

    checkData(bus_data, DATA, "setted value");

    report "ACC_tb - DONE!";

    wait;
    end process;

END;
