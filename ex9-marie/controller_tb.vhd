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

    component alu is
        generic (DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : in std_logic_vector (15 downto 0);
            acc_in : out std_logic_vector(8 downto 0);
            acc_out : in std_logic_vector(8 downto 0)
            );
    end component;

    constant DEBUG : boolean := true;

    signal clk : std_logic := '0';
    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');
    signal input_data : std_logic_vector (8 downto 0) := (others => 'Z');
    signal output_data : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_in : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_out : std_logic_vector (8 downto 0) := (others => 'Z');

    constant LOAD     : std_logic_vector (3 downto 0) := "0001";
    constant STORE    : std_logic_vector (3 downto 0) := "0010";
    constant ADD      : std_logic_vector (3 downto 0) := "0011";
    constant SUBT     : std_logic_vector (3 downto 0) := "0100";

    constant INPUT    : std_logic_vector (3 downto 0) := "0101";
    constant OUTPUT   : std_logic_vector (3 downto 0) := "0110";
    constant HALT     : std_logic_vector (3 downto 0) := "0111";
    constant SKIPCOND : std_logic_vector (3 downto 0) := "1000";
    constant JUMP     : std_logic_vector (3 downto 0) := "1001";

    constant NULL_COMMAND : std_logic_vector (8 downto 0) := "000000000";

    constant Ox1D_DATA : std_logic_vector (8 downto 0) := "000010101";
    constant Ox1E_DATA : std_logic_vector (8 downto 0) := "000001010";
    constant SUM_1D_1E : std_logic_vector (8 downto 0) := "000011111";

    constant Ox1F_DATA : std_logic_vector (8 downto 0) := OUTPUT & NULL_ARGUMENT;

BEGIN
    uut: ram generic map (RAM_DATA => (OUTPUT & NULL_ARGUMENT,
                                       LOAD & Ox1F(4 downto 0),
                                       OUTPUT & NULL_ARGUMENT,
                                       STORE & OxO4(4 downto 0),
                                       NULL_COMMAND, -- should store 0x1f which is output
                                       -- 5
                                       LOAD & Ox1D(4 downto 0),
                                       ADD & Ox1E(4 downto 0),
                                       OUTPUT & NULL_ARGUMENT,
                                       SUBT & Ox1D(4 downto 0),
                                       OUTPUT & NULL_ARGUMENT,
                                       -- 10
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       -- 15
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       -- 20
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       -- 25
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       Ox1D_DATA,
                                       -- 30
                                       Ox1E_DATA,
                                       Ox1F_DATA
                                       ), DEBUG => DEBUG)
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


    print(DEBUG, "------------------------------------ FIRST SECENARIO (EMPTY ACC) ------------------------------------");
    -- 0x00 first output - everything clear - so output is "000000000"
    wait for 75 ns;
    assert output_data = "000000000" report "expected " & ": '" & str("000000000") &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 80 ns
    print(DEBUG, "------------------------------------ SECOND SECENARIO (LOAD FROM RAM) ------------------------------------");

    -- 0x02 output after load 0x1F
    wait for 155 ns;
    assert output_data = Ox1F_DATA report "expected " & ": '" & str(Ox1F_DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 240 ns
    print(DEBUG, "------------------------------------ THIRD SECENARIO (STORE TO RAM) ------------------------------------");

    -- 0x04 output after store 0x1F with output_command

    wait for 155 ns;
    assert output_data = Ox1F_DATA report "expected " & ": '" & str(Ox1F_DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 400 ns
    print(DEBUG, "------------------------------------ FOURTH SECENARIO (ADDING) ------------------------------------");

    -- 0x07 output with sum of 0x1D and 0x1Ed

    wait for 245 ns;
    assert output_data = SUM_1D_1E report "expected " & ": '" & str(SUM_1D_1E) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 650 ns
    print(DEBUG, "------------------------------------ FIFTH SECENARIO (ADDING) ------------------------------------");

    wait for 155 ns;
    assert output_data = Ox1F_DATA report "expected " & ": '" & str(Ox1F_DATA) &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    print(DEBUG, "CTLR_TB - DONE !");
    wait;
    end process;

END;
