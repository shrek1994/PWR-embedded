LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.dataType_pkg.all;

entity ram_pc_acc_tb is
end ram_pc_acc_tb;

architecture behavior of ram_pc_acc_tb is
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

    component acc_register is
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
    constant ACC_ID : std_logic_vector (2 downto 0) := "011";

    constant OxOO_DATA : std_logic_vector (8 downto 0) := "111000111";
    constant OxO1_DATA : std_logic_vector (8 downto 0) := "000111000";
    constant OxO2_DATA : std_logic_vector (8 downto 0) := "010101010";

    constant OxOO : std_logic_vector (8 downto 0) := "ZZZZ" & "00000";
    constant OxO1 : std_logic_vector (8 downto 0) := "ZZZZ" & "00001";
    constant OxO2 : std_logic_vector (8 downto 0) := "ZZZZ" & "00010";
    constant OxO3 : std_logic_vector (8 downto 0) := "ZZZZ" & "00011";


    constant GET_CMD : std_logic_vector (3 downto 0) := "0001";
    constant SET_CMD : std_logic_vector (3 downto 0) := "0010";
    constant NEXT_PC_CMD : std_logic_vector (3 downto 0) := "0011";

    constant NULL_DATA : std_logic_vector (8 downto 0) := "ZZZZZZZZZ";

    procedure loadFromRamToAcc(signal bus_data : inout std_logic_vector; address : in std_logic_vector) is
    begin
        bus_data <= RAM_ID & GET_CMD & address;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;

        bus_data <= ACC_ID & SET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;
        wait for clk_period;
    end loadFromRamToAcc;

    procedure checkDataInAcc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= ACC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;
		assert bus_data(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period * 2;
    end checkDataInAcc;

    procedure checkDataInRam(signal conn_bus : inout std_logic_vector; address : in std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        conn_bus <= RAM_ID & GET_CMD & address;
        wait for clk_period;

        conn_bus <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;

		assert conn_bus(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"' on conn_bus -- got: '" & str(conn_bus) & "'";
        wait for clk_period * 2;
    end checkDataInRam;

BEGIN
    uut: ram generic map (RAM_DATA => (OxOO_DATA, OxO1_DATA, OxO2_DATA, others => "000000000"), DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    uut2: pc generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    uut3: acc_register generic map (DEBUG => DEBUG)
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

    -- load from ram to acc

    loadFromRamToAcc(bus_data, OxO1);
    checkDataInAcc(bus_data, OxO1_DATA, "data from 0x01");

    -- store from acc to ram

    loadFromRamToAcc(bus_data, OxO2);

  --  bus_data <= ACC_ID & GET_CMD & NULL_DATA;
    wait for clk_period;
    -- bus_data <= RAM_ID & SET_CMD & OxO3;
    wait for clk_period;
   -- bus_data <= RAM_ID & SET_CMD & NULL_DATA;

    --checkDataInRam(bus_data, OxO3, OxO2_DATA, "data from acc");

    report "RAM_PC_ACC_tb - DONE !";
    wait;
    end process;

END;
