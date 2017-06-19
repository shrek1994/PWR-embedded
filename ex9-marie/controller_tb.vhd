LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity controller_tb is
end controller_tb;

architecture behavior of controller_tb is
    component controller is
        generic (DEBUG : boolean);
        port(
                clk : in std_logic;
                bus_data : inout std_logic_vector (15 downto 0);

                input_data : in std_logic_vector (8 downto 0);
                output_data : out std_logic_vector (8 downto 0)
        );
    end component;

    component ram is
    generic (RAM_DATA : data_type; DEBUG : boolean);
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
            bus_data : inout std_logic_vector (15 downto 0);
            acc_in : in std_logic_vector(8 downto 0);
            acc_out : out std_logic_vector(8 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    constant clk_period : time := 10 ns;

    constant DEBUG : boolean := false;

    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');
    signal input_data : std_logic_vector (8 downto 0) := (others => 'Z');
    signal output_data : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_in : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_out : std_logic_vector (8 downto 0) := (others => 'Z');

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
    constant NOTHING : std_logic_vector (15 downto 0) := "ZZZZZZZZZZZZZZZZ";

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

    procedure storeFromAccToRam(signal bus_data : inout std_logic_vector; address : in std_logic_vector) is
    begin
        bus_data <= ACC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= RAM_ID & SET_CMD & address;
        wait for clk_period;
        bus_data <= RAM_ID & SET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
    end storeFromAccToRam;

    procedure checkDataInAcc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= ACC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;
        wait for clk_period / 2;
		assert bus_data(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 2;

    end checkDataInAcc;

    procedure checkDataInRam(signal bus_data : inout std_logic_vector; address : in std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= RAM_ID & GET_CMD & address;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;

        wait for clk_period / 2;
		assert bus_data(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 2;
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
        bus_data => bus_data,
        acc_in => acc_in,
        acc_out => acc_out
    );
    uut4: controller generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,
        input_data => input_data,
        output_data => output_data
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

    print(DEBUG, "CTLR_TB - START !");
    wait for 100 ns;



    print(DEBUG, "CTLR_TB - DONE !");
    wait;
    end process;

END;
