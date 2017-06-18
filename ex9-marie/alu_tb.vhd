LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is
    component alu is
        generic (DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : in std_logic_vector (15 downto 0);
            acc_in : out std_logic_vector(8 downto 0);
            acc_out : in std_logic_vector(8 downto 0)
            );
    end component;

    signal clk : std_logic := '0';
    constant clk_period :time := 10 ns;
    constant DEBUG : boolean := false;

    signal bus_data : std_logic_vector(15 downto 0) := (others => 'Z');
    signal acc_in :  std_logic_vector(8 downto 0) := (others => 'Z');
    signal acc_out : std_logic_vector(8 downto 0) := (others => 'Z');

    constant ALU_ID : std_logic_vector (2 downto 0) := "101";
    constant ADD_CMD : std_logic_vector (3 downto 0):= "0100";
    constant SUBT_CMD : std_logic_vector (3 downto 0):= "0101";
    constant NULL_DATA : std_logic_vector (8 downto 0) := "ZZZZZZZZZ";
    constant NOTHING : std_logic_vector (15 downto 0) := "ZZZZZZZZZZZZZZZZ";

    procedure operation(signal bus_data : inout std_logic_vector; signal acc_out : inout std_logic_vector; left : std_logic_vector; oper : std_logic_vector; right : in std_logic_vector) is
    begin
        acc_out <= left;
        bus_data <= ALU_ID & oper & right;
        wait for clk_period;
        bus_data <= NOTHING;
    end operation;

    procedure adding(signal bus_data : inout std_logic_vector; signal acc_out : inout std_logic_vector;
                     left : in std_logic_vector; right : in std_logic_vector) is
    begin
        operation(bus_data, acc_out, left, ADD_CMD, right);
    end adding;

    procedure subtracting(signal bus_data : inout std_logic_vector; signal acc_out : inout std_logic_vector;
                          left : in std_logic_vector; right : in std_logic_vector) is
    begin
        operation(bus_data, acc_out, left, SUBT_CMD, right);
    end subtracting;

    procedure checkResult(signal acc_out : inout std_logic_vector; expected : std_logic_vector; msg : string) is
    begin
        wait for clk_period / 2;
        assert acc_out = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(acc_out) & "'";
        wait for clk_period / 2;
    end checkResult;

BEGIN
    uut: alu generic map (DEBUG => DEBUG)
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

    print(DEBUG, "ALU_TB - START !");
    wait for 100 ns;

    adding(bus_data, acc_out, "000110011", "001000100");
    checkResult(acc_in, "001110111", "correct adding");

    acc_out <= acc_in;

    subtracting(bus_data, acc_out, "011111111", "001010100");
    checkResult(acc_in, "010101011", "correct subtracting");

    print(DEBUG, "ALU_TB - DONE !");
    wait;
    end process;

END;
