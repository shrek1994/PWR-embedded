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

    constant OxOO_COMMAND : std_logic_vector (8 downto 0) := OUTPUT & NULL_ARGUMENT;
    constant OxO1_COMMAND : std_logic_vector (8 downto 0) := LOAD & Ox1F(4 downto 0);
    constant OxO2_COMMAND : std_logic_vector (8 downto 0) := "010101010";

    constant Ox1F_DATA : std_logic_vector (8 downto 0) := "000111000";

BEGIN
    uut: ram generic map (RAM_DATA => (OxOO_COMMAND,
                                       OxO1_COMMAND,
                                       OxO2_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       -- 5
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
                                       NULL_COMMAND,
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
                                       NULL_COMMAND,
                                       -- 30
                                       NULL_COMMAND,
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


    -- 0x00 first output - everything clear - so output is "000000000"
    wait for 95 ns;
    assert output_data = "000000000" report "expected " & ": '" & str("000000000") &"', got: '" & str(output_data) & "'";
    wait for 5 ns;

    -- 100 ns

    print(DEBUG, "CTLR_TB - DONE !");
    wait;
    end process;

END;
