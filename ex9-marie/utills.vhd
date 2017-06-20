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
    procedure checkDataInPc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string);
    procedure resetPc(signal bus_data : inout std_logic_vector);
    procedure setPc(signal bus_data : inout std_logic_vector; value : in std_logic_vector);
    procedure resetAcc(signal bus_data : inout std_logic_vector);
    procedure setDataInAcc(signal bus_data : inout std_logic_vector; value : std_logic_vector);

    constant STARTING_TIME : time := 100 ns;
    constant CLK_PERIOD : time := 10 ns;

    constant RAM_ID : std_logic_vector (2 downto 0) := "001";
    constant PC_ID  : std_logic_vector (2 downto 0) := "010";
    constant ACC_ID : std_logic_vector (2 downto 0) := "011";
    constant ALU_ID : std_logic_vector (2 downto 0) := "101";

    constant OxOO_DATA : std_logic_vector (8 downto 0) := "111000111";
    constant OxO1_DATA : std_logic_vector (8 downto 0) := "000111000";
    constant OxO2_DATA : std_logic_vector (8 downto 0) := "010101010";

    constant OxOO : std_logic_vector (8 downto 0) := "ZZZZ" & "00000";
    constant OxO1 : std_logic_vector (8 downto 0) := "ZZZZ" & "00001";
    constant OxO2 : std_logic_vector (8 downto 0) := "ZZZZ" & "00010";
    constant OxO3 : std_logic_vector (8 downto 0) := "ZZZZ" & "00011";
    constant OxO4 : std_logic_vector (8 downto 0) := "ZZZZ" & "00100";

    constant OxOE : std_logic_vector (8 downto 0) := "ZZZZ" & "01110";

    constant Ox1A : std_logic_vector (8 downto 0) := "ZZZZ" & "11010";
    constant Ox1B : std_logic_vector (8 downto 0) := "ZZZZ" & "11011";
    constant Ox1C : std_logic_vector (8 downto 0) := "ZZZZ" & "11100";
    constant Ox1D : std_logic_vector (8 downto 0) := "ZZZZ" & "11101";
    constant Ox1E : std_logic_vector (8 downto 0) := "ZZZZ" & "11110";
    constant Ox1F : std_logic_vector (8 downto 0) := "ZZZZ" & "11111";

    constant GET_CMD     : std_logic_vector (3 downto 0) := "0001";
    constant SET_CMD     : std_logic_vector (3 downto 0) := "0010";
    constant NEXT_PC_CMD : std_logic_vector (3 downto 0) := "0011";
    constant ADD_CMD     : std_logic_vector (3 downto 0) := "0100";
    constant SUBT_CMD    : std_logic_vector (3 downto 0) := "0101";
    constant RESET_CMD   : std_logic_vector (3 downto 0) := "1111";


    constant NULL_ARGUMENT : std_logic_vector (4 downto 0) := "ZZZZZ";
    constant NULL_DATA : std_logic_vector (8 downto 0) := "ZZZZZZZZZ";
    constant NULL_BUS_DATA : std_logic_vector (15 downto 0) := "ZZZZZZZZZZZZZZZZ";


    -- from controller
    type cmd_type is (LOAD, STORE, ADD, SUBT, INPUT, OUTPUT, HALT, SKIPCOND, JUMP);
    function str(cmd : cmd_type) return string;

    procedure printRAM(active : boolean; data : data_type);
end package utills;

package body utills is
    procedure printRAM(active : boolean; data : data_type) is
        variable i : unsigned(5 downto 0);
    begin
        i := "000000";
        print(active, "---------------------------------------------- RAM ----------------------------------------------");
        for ram in data'range loop
            print(active, str(std_logic_vector(i)) & ", 0x" & hstr(std_logic_vector(i)) & ": " & str(data(to_integer(i))));
        i :=  i + 1;
        end loop;
        print(active, "-------------------------------------------- END RAM --------------------------------------------");
    end;


    function str(cmd : cmd_type) return string is
    begin
        case cmd is
            when LOAD => return "LOAD";
            when STORE => return "STORE";
            when ADD => return "ADD";
            when SUBT => return "SUBT";
            when INPUT => return "INPUT";
            when OUTPUT => return "OUTPUT";
            when HALT => return "HALT";
            when SKIPCOND => return "SKIPCOND";
            when JUMP => return "JUMP";
        end case;
        return "";
    end;

    procedure checkDataInRam(signal bus_data : inout std_logic_vector; address : in std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= RAM_ID & GET_CMD & address;
        wait for clk_period;

        bus_data <= NULL_BUS_DATA;
        wait for clk_period * 3 / 4;
        assert bus_data(8 downto 0) = NULL_DATA report "BEFORE_SENDING: expected " & msg & ": '" & str(NULL_DATA) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;

        wait for clk_period * 3 /4;
        assert bus_data(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;
    end checkDataInRam;

    procedure setDataInRam(signal conn_bus : inout std_logic_vector ; address : in std_logic_vector; data : in std_logic_vector) is
    begin
        conn_bus <= RAM_ID & SET_CMD & address;
        wait for clk_period;
        conn_bus <= RAM_ID & SET_CMD & data;
        wait for clk_period;
        conn_bus <= NULL_BUS_DATA;
    end setDataInRam;

    procedure checkDataInRamBasedOnAddressFromPc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= PC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period;
        bus_data <= RAM_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period;

        wait for clk_period / 2;
        assert bus_data(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 2;
    end checkDataInRamBasedOnAddressFromPc;

    procedure nextPc(signal bus_data : inout std_logic_vector) is
    begin
        bus_data <= PC_ID & NEXT_PC_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period * 2;
    end nextPc;

    procedure loadDataFromRamToAcc(signal bus_data : inout std_logic_vector; address : in std_logic_vector) is
    begin
        bus_data <= RAM_ID & GET_CMD & address;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period;

        bus_data <= ACC_ID & SET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
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
        bus_data <= NULL_BUS_DATA;
    end storeDataFromAccToRam;

    procedure checkDataInAcc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= ACC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;

        bus_data <= NULL_BUS_DATA;
        wait for clk_period * 3 / 4;
        assert bus_data(8 downto 0) = NULL_DATA report "BEFORE_SENDING: expected " & msg & ": '" & str(NULL_DATA) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;

        wait for clk_period * 3 / 4;
        assert bus_data(8 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;

    end checkDataInAcc;

    procedure checkDataInPc(signal bus_data : inout std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        bus_data <= PC_ID & GET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period;

        wait for clk_period * 3 / 4;
        assert bus_data(4 downto 0) = expected report "expected " & msg & ": '" & str(expected) &"', got: '" & str(bus_data) & "'";
        wait for clk_period / 4;
    end checkDataInPc;

    procedure resetPc(signal bus_data : inout std_logic_vector) is
    begin
        bus_data <= PC_ID & RESET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period * 2;
    end resetPc;

    procedure setPc(signal bus_data : inout std_logic_vector; value : in std_logic_vector) is
    begin
        bus_data <= PC_ID & SET_CMD & "ZZZZ" & value;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period * 2;
    end setPc;

    procedure resetAcc(signal bus_data : inout std_logic_vector) is
    begin
        bus_data <= ACC_ID & RESET_CMD & NULL_DATA;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period * 2;
    end resetAcc;

    procedure setDataInAcc(signal bus_data : inout std_logic_vector; value : std_logic_vector) is
    begin
        bus_data <= ACC_ID & SET_CMD & value;
        wait for clk_period;
        bus_data <= NULL_BUS_DATA;
        wait for clk_period * 2;
    end setDataInAcc;

end utills;
