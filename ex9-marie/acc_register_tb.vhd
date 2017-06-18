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
            bus_data : inout std_logic_vector (15 downto 0);
            acc_in : in std_logic_vector(8 downto 0);
            acc_out : out std_logic_vector(8 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    constant clk_period :time := 10 ns;

    constant DEBUG : boolean := false;

    signal bus_data : std_logic_vector(15 downto 0) := (others => 'Z');
    signal acc_in : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_out : std_logic_vector (8 downto 0) := (others => 'Z');

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
        wait for clk_period * 3 / 4;
        assert conn_bus(8 downto 0) = "ZZZZZZZZZ" report "1. expected " & msg & ": '" & str("ZZZZZZZZZ") &"' on conn_bus -- got: '" & str(conn_bus) & "'";
        wait for clk_period / 4;

        wait for clk_period * 3 / 4;
        assert conn_bus(8 downto 0) = expected report "2. expected " & msg & ": '" & str(expected) &"' on conn_bus -- got: '" & str(conn_bus) & "'";
        wait for clk_period / 4;

        wait for clk_period;
    end checkData;

BEGIN
    uut: acc_register generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,
        acc_in => acc_in,
        acc_out => acc_out
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

    print(DEBUG, "ACC_TB - START!");
    wait for 100 ns;

    bus_data <= ID & RESET_CMD & NULL_DATA;
    wait for clk_period;
    bus_data <= "ZZZZZZZZZZZZZZZZ";
    wait for clk_period;

    checkData(bus_data, "000000000", "zero after reset");

    bus_data <= ID & SET_CMD & DATA;
    wait for clk_period;
    bus_data <= "ZZZZZZZZZZZZZZZZ";
    wait for clk_period;

    checkData(bus_data, DATA, "setted value");

    print(DEBUG, "ACC_TB - DONE!");

    wait;
    end process;

END;
