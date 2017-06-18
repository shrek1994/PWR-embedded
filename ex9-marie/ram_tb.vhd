LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.dataType_pkg.all;

entity ram_tb is
end ram_tb;

architecture behavior of ram_tb is
    component ram is
    generic (RAM_DATA : dataType; DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0)
              );
    end component;

    signal clk :std_logic := '0';
    constant clk_period :time := 10 ns;
    constant DEBUG : boolean := false;

    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');

    constant RAM_ID : std_logic_vector (2 downto 0) := "001";
    constant OxOO : std_logic_vector (8 downto 0) := "111000111";
    constant OxO1 : std_logic_vector (8 downto 0) := "000111000";
    constant OxO2 : std_logic_vector (8 downto 0) := "010101010";
    constant NEW_DATA : std_logic_vector (8 downto 0) := "101010101";
    constant GET_CMD : std_logic_vector (3 downto 0) := "0001";
    constant SET_CMD : std_logic_vector (3 downto 0) := "0010";


    procedure checkData(signal conn_bus : inout std_logic_vector; address : in std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        conn_bus <= RAM_ID & GET_CMD & "ZZZZ" & address;
        wait for clk_period;

        conn_bus <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period * 3 / 4;
        assert conn_bus(8 downto 0) = "ZZZZZZZZZ" report "1. expected " & msg & ": '" & str("ZZZZZZZZZZZZZZZZ") &"' on conn_bus -- got: '" & str(conn_bus) & "'";
        wait for clk_period / 4;

        wait for clk_period * 3 /4;
		assert conn_bus(8 downto 0) = expected report "2. expected " & msg & ": '" & str(expected) &"' on conn_bus -- got: '" & str(conn_bus) & "'";
        wait for clk_period / 4;
    end checkData;

    procedure setData(signal conn_bus : inout std_logic_vector ; address : in std_logic_vector; data : in std_logic_vector) is
    begin
        conn_bus <= RAM_ID & SET_CMD & "ZZZZ" & address;
		wait for clk_period;
        conn_bus <= RAM_ID & SET_CMD & data;
		wait for clk_period;
        conn_bus <= "ZZZZZZZZZZZZZZZZ";
    end setData;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: ram generic map (RAM_DATA => (OxOO, OxO1, OxO2, others => "000000000"), DEBUG => DEBUG)
    PORT MAP (
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
    print(DEBUG, "RAM_TB - START !");

    wait for 100 ns;

    checkData(bus_data, "00000", OxOO, "0x00");
    checkData(bus_data, "00001", OxO1, "0x01");
    checkData(bus_data, "00010", OxO2, "0x02");

    setData(bus_data, "00011", NEW_DATA);
    checkData(bus_data, "00011", NEW_DATA, "new data");

    print(DEBUG, "RAM_TB - DONE !");
    wait;
    end process;

END;
