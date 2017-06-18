LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.dataType_pkg.all;

entity ram_pc_tb is
end ram_pc_tb;

architecture behavior of ram_pc_tb is
    component ram is
    generic (RAM_DATA : dataType; DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0)
              );
    end component;

    component pc is
    generic (DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0)
        );
    end component;

    signal clk :std_logic := '0';
    constant clk_period :time := 10 ns;

    constant DEBUG : boolean := true;

    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');

    constant RAM_ID : std_logic_vector (2 downto 0) := "001";
    constant PC_ID : std_logic_vector (2 downto 0) := "010";
    constant OxOO : std_logic_vector (8 downto 0) := "111000111";
    constant OxO1 : std_logic_vector (8 downto 0) := "000111000";
    constant OxO2 : std_logic_vector (8 downto 0) := "010101010";
    constant GET_CMD : std_logic_vector (3 downto 0) := "0001";
    constant SET_CMD : std_logic_vector (3 downto 0) := "0010";
    constant NEXT_PC_CMD : std_logic_vector (3 downto 0) := "0011";

    constant NULL_DATA : std_logic_vector (8 downto 0) := "ZZZZZZZZZ";

    procedure checkDataBasedOnPc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= PC_ID & GET_CMD & NULL_DATA;
        wait for clk_period * 2;
        bus_data <= RAM_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;
        assert bus_data(8 downto 0) = expected report "ERROR! expected " & msg & ": '" & str(expected) &"' on conn_bus -- got: '" & str(bus_data) & "'";
        wait for clk_period;
    end checkDataBasedOnPc;

    procedure nextPc(signal bus_data : inout std_logic_vector) is
    begin
        bus_data <= PC_ID & NEXT_PC_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period * 2;
    end nextPc;

BEGIN
    uut: ram generic map (RAM_DATA => (OxOO, OxO1, OxO2, others => "000000000"), DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    uut2: pc generic map (DEBUG => DEBUG)
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

    checkDataBasedOnPc(bus_data, OxOO, "0x00");

    nextPc(bus_data);

    checkDataBasedOnPc(bus_data, OxO1, "0x01");

    nextPc(bus_data);

    checkDataBasedOnPc(bus_data, OxO2, "0x02");

    nextPc(bus_data);



    report "RAM_PC_tb - DONE !";
    wait;
    end process;

END;
