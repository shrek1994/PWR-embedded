LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity factorial_tb is
end factorial_tb;

architecture behavior of factorial_tb is
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


    constant OxO1_BEGIN_FACTORIAL : std_logic_vector (4 downto 0) := "00001";
    constant OxO8_BEGIN_MUL : std_logic_vector (4 downto 0) := "01000";
    constant Ox12_END_MUL : std_logic_vector (4 downto 0) := "10010";
    constant Ox14_END_FACTORIAL : std_logic_vector (4 downto 0) := "10100";

    constant VALUE : std_logic_vector (8 downto 0) := "000000000";
    constant Ox1A_VALUE : std_logic_vector (4 downto 0) := "11010";

    constant I : std_logic_vector (8 downto 0) := "000000000";
    constant Ox1B_I : std_logic_vector (4 downto 0) := "11011";

    constant TEMP : std_logic_vector (8 downto 0) := "000000000";
    constant Ox1C_TEMP : std_logic_vector (4 downto 0) := "11100";

    constant RESULT : std_logic_vector (8 downto 0) := "000000001";
    constant Ox1D_RESULT : std_logic_vector (4 downto 0) := "11101";

    constant ZERO : std_logic_vector (8 downto 0) := "000000000";
    constant Ox1E_ZERO : std_logic_vector (4 downto 0) := "11110";

    constant ONE : std_logic_vector (8 downto 0) := "000000001";
    constant Ox1F_ONE : std_logic_vector (4 downto 0) := "11111";

BEGIN
    uut: ram generic map (RAM_DATA => (

        INPUT & NULL_ARGUMENT,
        SUBT & Ox1F_ONE, ---> begin factorial
        STORE & Ox1A_VALUE,
        SKIPCOND & IF_ACC_MORE_THAN_ZERO,
        JUMP & Ox14_END_FACTORIAL ,

        -- 5 (0x05)
        LOAD & Ox1D_RESULT,
        STORE & Ox1C_TEMP,
        LOAD & Ox1E_ZERO,
        STORE & Ox1B_I, ---> 0x08_begin_mul
        SUBT & Ox1A_VALUE,

        -- 10 (0x0A)
        SKIPCOND & IF_ACC_LESS_THAN_ZERO,
        JUMP & Ox12_END_MUL,
        LOAD & Ox1D_RESULT,
        ADD & Ox1C_TEMP,
        STORE & Ox1D_RESULT,

        -- 15 (0x0F)
        LOAD & Ox1B_I,
        ADD & Ox1F_ONE,
        JUMP & OxO8_BEGIN_MUL,
        LOAD & Ox1A_VALUE, ---> end mul
        JUMP & OxO1_BEGIN_FACTORIAL,

        -- 20 (0x14)
        LOAD & Ox1D_RESULT, ---> end factorial
        OUTPUT & NULL_ARGUMENT,
        HALT & NULL_ARGUMENT,
        NULL_COMMAND,
        NULL_COMMAND,

        -- 25 (0x19)
        NULL_COMMAND,
        VALUE,
        I,
        TEMP,
        RESULT,

        -- 30 (0x1E)
        ZERO,
        ONE
    ),
    DEBUG => DEBUG)
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

    resutl: process (output_data)
    begin
        if output_data /= "UUUUUUUUU" and output_data /= "ZZZZZZZZZ" then
            print(DEBUG, "RESULT: 0b" & str(output_data) & ", 0x" & hstr(output_data));
        end if;
    end process;

    stim_proc: process
    begin
    wait for 10 ns;
    input_data <= "000000011";

    wait;
    end process;

END;
