LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity pc_tb is
end pc_tb;

architecture behavior of pc_tb is
    component pc is
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    constant clk_period :time := 10 ns;

    signal bus_data : std_logic_vector(15 downto 0) := (others => 'Z');

    constant ID : std_logic_vector (2 downto 0) := "010";
    constant RESET_CMD : std_logic_vector (3 downto 0) := "1111";
    constant GET_PC_CMD : std_logic_vector (3 downto 0):= "0001";
    constant SET_PC_CMD : std_logic_vector (3 downto 0):= "0010";
    constant NEXT_PC_CMD : std_logic_vector (3 downto 0):= "0011";
    constant NULL_DATA : std_logic_vector (8 downto 0) := "000000000";

    procedure checkData(signal conn_bus : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        conn_bus <= ID & GET_PC_CMD & NULL_DATA;
        wait for clk_period * 2;

        conn_bus <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;
		assert conn_bus(4 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"' on conn_bus -- got: '" & str(conn_bus) & "'";
        wait for clk_period;
    end checkData;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: pc PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin

    wait for 100 ns;

    bus_data <= ID & RESET_CMD & NULL_DATA;
    wait for clk_period * 2;

    checkData(bus_data, "00000", "zero after reset");

    bus_data <= ID & NEXT_PC_CMD & NULL_DATA;
    wait for clk_period * 2;

    checkData(bus_data, "00001", "one after next pc");

    bus_data <= ID & SET_PC_CMD & "0000" & "00100";
    wait for clk_period * 2;

    checkData(bus_data, "00100", "set value");

    bus_data <= ID & NEXT_PC_CMD & NULL_DATA;
    wait for clk_period * 2;
    checkData(bus_data, "00101", "next after set value");


    report "PC_tb - DONE!";

    wait;
    end process;

END;
