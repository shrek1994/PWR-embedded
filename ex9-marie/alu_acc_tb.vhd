LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity alu_acc_tb is
end alu_acc_tb;

architecture behavior of alu_acc_tb is
    component acc_register
    generic (DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0);
            acc_in : in std_logic_vector(8 downto 0);
            acc_out : out std_logic_vector(8 downto 0)
        );
    end component;

    component alu is
        generic (DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : in std_logic_vector (15 downto 0);
            acc_in : out std_logic_vector(8 downto 0);
            acc_out : in std_logic_vector(8 downto 0)
            );
    end component;

    signal clk :std_logic := '0';
    constant clk_period :time := 10 ns;

    constant DEBUG : boolean := false;

    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');
    signal acc_in : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_out : std_logic_vector (8 downto 0) := (others => 'Z');

    constant ACC_ID : std_logic_vector (2 downto 0) := "011";
    constant ALU_ID : std_logic_vector (2 downto 0) := "101";
    constant GET_CMD : std_logic_vector (3 downto 0) := "0001";
    constant SET_CMD : std_logic_vector (3 downto 0) := "0010";
    constant ADD_CMD : std_logic_vector (3 downto 0):= "0100";
    constant SUBT_CMD : std_logic_vector (3 downto 0):= "0101";

    constant NULL_DATA : std_logic_vector (8 downto 0) := "ZZZZZZZZZ";
    constant NOTHING : std_logic_vector (15 downto 0) := "ZZZZZZZZZZZZZZZZ";

    procedure setAcc(signal bus_data : inout std_logic_vector; value : in std_logic_vector) is
    begin
        bus_data <= ACC_ID & SET_CMD & value;
        wait for clk_period;
        bus_data <= NOTHING;
        wait for clk_period;
        wait for clk_period;
    end setAcc;

    procedure checkDataInAcc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= ACC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= NOTHING;
        wait for clk_period;
        wait for clk_period / 2;
		assert bus_data(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 2;
    end checkDataInAcc;

    procedure operation(signal bus_data : inout std_logic_vector; oper : std_logic_vector; right : in std_logic_vector) is
    begin
        bus_data <= ALU_ID & oper & right;
        wait for clk_period;
        bus_data <= NOTHING;
    end operation;

    procedure adding(signal bus_data : inout std_logic_vector; right : in std_logic_vector) is
    begin
        operation(bus_data, ADD_CMD, right);
    end adding;

    procedure subtracting(signal bus_data : inout std_logic_vector; right : in std_logic_vector) is
    begin
        operation(bus_data, SUBT_CMD, right);
    end subtracting;

BEGIN
    uut: acc_register generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,
        acc_in => acc_in,
        acc_out => acc_out
    );

    uut2: alu generic map (DEBUG => DEBUG)
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
        print(DEBUG, "ALU_ACC_TB - START !");
        wait for 100 ns;

        setAcc(bus_data, "000101001");
        adding(bus_data, "001010000");
        checkDataInAcc(bus_data, "001111001", "correct adding");


        setAcc(bus_data,         "001111111");
        subtracting(bus_data,    "001010000");
        checkDataInAcc(bus_data, "000101111", "correct subtracting");

        print(DEBUG, "ALU_ACC_TB - DONE !");
    wait;
    end process;

END;
