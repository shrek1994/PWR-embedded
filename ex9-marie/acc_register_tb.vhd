LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

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

    constant DATA : std_logic_vector (8 downto 0) := "110011001";

    procedure checkDataInAcc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= ACC_ID & GET_CMD & NULL_DATA;
        wait for clk_period * 2;

        bus_data <= NULL_BUS_DATA;
        wait for clk_period * 3 / 4;
        assert bus_data(8 downto 0) = NULL_DATA report "BEFORE_SENDING: expected " & msg & ": '" & str(NULL_DATA) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;

        wait for clk_period * 3 / 4;
        assert bus_data(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;
    end checkDataInAcc;

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
    wait for STARTING_TIME;

    resetAcc(bus_data);
    checkDataInAcc(bus_data, "000000000", "zero after reset");

    setDataInAcc(bus_data, DATA);
    checkDataInAcc(bus_data, DATA, "setted value");

    print(DEBUG, "ACC_TB - DONE!");

    wait;
    end process;

END;
