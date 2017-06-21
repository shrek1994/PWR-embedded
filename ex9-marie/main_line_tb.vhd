LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.txt_util.all;
use work.utills.all;

entity main_line_tb is
end main_line_tb;

   -- type dataType is array (31 downto 0) of std_logic_vector (8 downto 0);

architecture behavior of main_line_tb is

    component main_line is generic(RAM_DATA: data_type; DEBUG : boolean);
    port(
        run       : in  std_logic;
        input_data       : in std_logic_vector(8 downto 0);
        output_data      : out std_logic_vector(8 downto 0)
        );
    end component;
    constant DEBUG: boolean := false;

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

    constant RAM_DATA : data_type := (

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
    );
    signal run : std_logic := '0';
    signal input_data : std_logic_vector(8 downto 0) := (OTHERS => 'Z');
    signal output_data : std_logic_vector(8 downto 0) := (OTHERS => 'Z');
begin

    main: main_line generic map (RAM_DATA => RAM_DATA, DEBUG => DEBUG)
    port map (
        run => run,
        input_data => input_data,
        output_data => output_data
    );

    simul_process : process
    begin
        wait for clk_period;
        input_data <= "000000101";

-- check(1, factorial(1));      -- 0x001
-- check(2, factorial(2));      -- 0x002
-- check(6, factorial(3));      -- 0x006
-- check(24, factorial(4));     -- 0x018
-- check(120, factorial(5));    -- 0x078
-- check(720, factorial(6));    -- 0x2D0 -- out of range

        wait for 1 ms;
    end process;
end;
