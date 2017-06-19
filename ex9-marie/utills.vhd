library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

package utills is
    type data_type is array (0 to 31) of std_logic_vector (8 downto 0);

    procedure checkDataInRam(signal bus_data : inout std_logic_vector; address : in std_logic_vector; expected : in std_logic_vector; msg : string);
    procedure setDataInRam(signal conn_bus : inout std_logic_vector ; address : in std_logic_vector; data : in std_logic_vector);
    procedure checkDataInRamBasedOnAddressFromPc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string);
    procedure nextPc(signal bus_data : inout std_logic_vector);
    procedure loadDataFromRamToAcc(signal bus_data : inout std_logic_vector; address : in std_logic_vector);
    procedure storeDataFromAccToRam(signal bus_data : inout std_logic_vector; address : in std_logic_vector);
    procedure checkDataInAcc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string);

    constant CLK_PERIOD : time := 10 ns;

    constant RAM_ID : std_logic_vector (2 downto 0) := "001";
    constant PC_ID  : std_logic_vector (2 downto 0) := "010";
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
    constant RESET_CMD : std_logic_vector (3 downto 0) := "1111";


    constant NULL_DATA : std_logic_vector (8 downto 0) := "ZZZZZZZZZ";


end package utills;

package body utills is

    procedure checkDataInRam(signal bus_data : inout std_logic_vector; address : in std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= RAM_ID & GET_CMD & address;
        wait for clk_period;

        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period * 3 / 4;
        assert bus_data(8 downto 0) = "ZZZZZZZZZ" report "1. expected " & msg & ": '" & str("ZZZZZZZZZZZZZZZZ") &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;

        wait for clk_period * 3 /4;
		assert bus_data(8 downto 0) = expected report "2. expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;
    end checkDataInRam;


    procedure setDataInRam(signal conn_bus : inout std_logic_vector ; address : in std_logic_vector; data : in std_logic_vector) is
    begin
        conn_bus <= RAM_ID & SET_CMD & address;
		wait for clk_period;
        conn_bus <= RAM_ID & SET_CMD & data;
		wait for clk_period;
        conn_bus <= "ZZZZZZZZZZZZZZZZ";
    end setDataInRam;

    procedure checkDataInRamBasedOnAddressFromPc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= PC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;
        bus_data <= RAM_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;

        wait for clk_period / 2;
        assert bus_data(8 downto 0) = expected report "ERROR! expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 2;
    end checkDataInRamBasedOnAddressFromPc;

    procedure nextPc(signal bus_data : inout std_logic_vector) is
    begin
        bus_data <= PC_ID & NEXT_PC_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period * 2;
    end nextPc;

    procedure loadDataFromRamToAcc(signal bus_data : inout std_logic_vector; address : in std_logic_vector) is
    begin
        bus_data <= RAM_ID & GET_CMD & address;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period;

        bus_data <= ACC_ID & SET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
        wait for clk_period *2;
    end loadDataFromRamToAcc;


    procedure storeDataFromAccToRam(signal bus_data : inout std_logic_vector; address : in std_logic_vector) is
    begin
        bus_data <= ACC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= RAM_ID & SET_CMD & address;
        wait for clk_period;
        bus_data <= RAM_ID & SET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= "ZZZZZZZZZZZZZZZZ";
    end storeDataFromAccToRam;

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

end utills;
