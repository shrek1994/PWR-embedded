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

                acc_in : out std_logic_vector(8 downto 0);
                acc_out : in std_logic_vector(8 downto 0);

                input_data : in std_logic_vector (8 downto 0);
                output_data : out std_logic_vector (8 downto 0)
        );
    end component;

    component ram is
    generic (RAM_DATA : data_type; DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0);

            ram_debug : out data_type
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

    component alu is
        generic (DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : in std_logic_vector (15 downto 0);
            acc_in : out std_logic_vector(8 downto 0);
            acc_out : in std_logic_vector(8 downto 0)
            );
    end component;

    constant DEBUG : boolean := false;

    signal clk : std_logic := '0';
    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');
    signal input_data : std_logic_vector (8 downto 0) := (others => 'Z');
    signal output_data : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_in : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_out : std_logic_vector (8 downto 0) := (others => 'Z');

    signal ram_debug : data_type;

    constant Ox1C_ZERO : std_logic_vector (8 downto 0) := "ZZZZ" & "11100";

    constant Ox1A_POSITIVE_DATA : std_logic_vector (8 downto 0) := "000011111";
    constant Ox1B_NEGATIVE_DATA : std_logic_vector (8 downto 0) := "100011111";
    constant Ox1C_ZERO_DATA : std_logic_vector (8 downto 0) := "000000000";

    constant Ox1D_DATA : std_logic_vector (8 downto 0) := "000010101";
    constant Ox1E_DATA : std_logic_vector (8 downto 0) := "000001010";
    constant SUM_1D_1E : std_logic_vector (8 downto 0) := "000011111";

    constant Ox1F_DATA : std_logic_vector (8 downto 0) := OUTPUT & NULL_ARGUMENT;

    constant DATA : std_logic_vector (8 downto 0) := "111000111";
BEGIN                               -- 0x00
    uut: ram generic map (RAM_DATA => (OUTPUT & NULL_ARGUMENT,
                                       LOAD & Ox1F(4 downto 0),
                                       OUTPUT & NULL_ARGUMENT,
                                       STORE & OxO4(4 downto 0),
                                       NULL_COMMAND, -- should store command frow 0x1f which is output

                                       -- 5 (0x05)
                                       LOAD & Ox1D(4 downto 0),
                                       ADD & Ox1E(4 downto 0),
                                       OUTPUT & NULL_ARGUMENT,
                                       SUBT & Ox1D(4 downto 0),
                                       OUTPUT & NULL_ARGUMENT,

                                       -- 10 (0x0A)
                                       INPUT & NULL_ARGUMENT,
                                       OUTPUT & NULL_ARGUMENT,
                                       JUMP & OxOE(4 downto 0),
                                       HALT & NULL_ARGUMENT,
                                       LOAD & Ox1C_ZERO(4 downto 0), -- 0x0E

                                       -- 15 (0x0F)
                                       OUTPUT & NULL_ARGUMENT,
                                       SKIPCOND & IF_ACC_EQUAL_ZERO,
                                       JUMP & Ox19(4 downto 0), -- jump to halt
                                       LOAD & Ox1B(4 downto 0), -- negative data
                                       SKIPCOND & IF_ACC_LESS_THAN_ZERO,

                                       -- 20 (0x14)
                                       JUMP & Ox19(4 downto 0), -- jump to halt
                                       LOAD & Ox1A(4 downto 0), -- positive data
                                       SKIPCOND & IF_ACC_MORE_THAN_ZERO,
                                       JUMP & Ox19(4 downto 0), -- jump to halt
                                       OUTPUT & NULL_ARGUMENT,

                                       -- 25 (0x19)
                                       HALT & NULL_ARGUMENT,
                                       Ox1A_POSITIVE_DATA,
                                       Ox1B_NEGATIVE_DATA,
                                       Ox1C_ZERO_DATA,
                                       Ox1D_DATA,
                                       -- 30 (0x1E)
                                       Ox1E_DATA,
                                       Ox1F_DATA
                                       ), DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,

        ram_debug => ram_debug
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

        acc_in => acc_in,
        acc_out => acc_out,

        input_data => input_data,
        output_data => output_data
    );

    uut5: alu generic map (DEBUG => DEBUG)
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

    print(DEBUG, "CTLR_TB - START !");
    wait for 5 ns;
    printRAM(DEBUG, ram_debug);


    print(DEBUG, "------------------------------------ FIRST SECENARIO (EMPTY ACC) ------------------------------------");
    -- 0x00 first output - everything clear - so output is "000000000"
    wait for 70 ns;
    assert output_data = "000000000" report "1. expected " & ": '" & str("000000000") &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 80 ns
    print(DEBUG, "------------------------------------ SECOND SECENARIO (LOAD FROM RAM) ------------------------------------");

    -- 0x02 output after load 0x1F
    wait for 155 ns;
    assert output_data = Ox1F_DATA report "2. expected " & ": '" & str(Ox1F_DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 240 ns
    print(DEBUG, "------------------------------------ THIRD SECENARIO (STORE TO RAM) ------------------------------------");

    -- 0x04 output after store 0x1F with output_command

    wait for 155 ns;
    assert output_data = Ox1F_DATA report "3. expected " & ": '" & str(Ox1F_DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 400 ns
    print(DEBUG, "------------------------------------ FOURTH SECENARIO (ADDING) ------------------------------------");

    -- 0x07 output with sum of 0x1D and 0x1Ed

    wait for 245 ns;
    assert output_data = SUM_1D_1E report "4. expected " & ": '" & str(SUM_1D_1E) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 650 ns
    print(DEBUG, "------------------------------------ FIFTH SECENARIO (SUBT) ------------------------------------");

    -- 0x07 output is sum(0x1D, 0x1E) - 0x1D = 0x1E
    wait for 155 ns;
    assert output_data = Ox1E_DATA report "5. expected " & ": '" & str(Ox1E_DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 810 ns
    print(DEBUG, "------------------------------------ SIXTH SECENARIO (INPUT) ------------------------------------");

    -- on output the same value as in input
    input_data <= DATA;
    wait for 70 ns;
    input_data <= NULL_DATA;
    wait for 65 ns;
    assert output_data = DATA report "6. expected " & ": '" & str(DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 950 ns
    print(DEBUG, "------------------------------------ SEVENTH SECENARIO (JUMP AND LOAD ZERO) ------------------------------------");

    -- on output ZERO
    wait for 245 ns;
    assert output_data = Ox1C_ZERO_DATA report "7. expected " & ": '" & str(Ox1C_ZERO_DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;


    -- 1200 ns
    print(DEBUG, "------------------------------------ EIGHTH SECENARIO (ALL 3 SKIPCOND) ------------------------------------");

    -- on output Positive data
    wait for 515 ns;
    assert output_data = Ox1A_POSITIVE_DATA report "7. expected " & ": '" & str(Ox1A_POSITIVE_DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 1720 ns
    print(DEBUG, "CTLR_TB - DONE !");
    wait;
    end process;

END;
