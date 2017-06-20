LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity main_line is
    generic (RAM_DATA : data_type := ( others => "000000000"); DEBUG : boolean);
    Port (
        run       : in  std_logic;
        input_data       : in std_logic_vector(8 downto 0);
        output_data      : out std_logic_vector(8 downto 0)
        );
end main_line;

architecture behavior of main_line is
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

            ram_debug : inout data_type
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

    signal clk : std_logic := '0';
    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');
    signal acc_in : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_out : std_logic_vector (8 downto 0) := (others => 'Z');

    signal ram_debug : data_type;

    constant LOAD     : std_logic_vector (3 downto 0) := "0001";
    constant STORE    : std_logic_vector (3 downto 0) := "0010";
    constant ADD      : std_logic_vector (3 downto 0) := "0011";
    constant SUBT     : std_logic_vector (3 downto 0) := "0100";

    constant INPUT    : std_logic_vector (3 downto 0) := "0101";
    constant OUTPUT   : std_logic_vector (3 downto 0) := "0110";
    constant HALT     : std_logic_vector (3 downto 0) := "0111";
    constant SKIPCOND : std_logic_vector (3 downto 0) := "1000";
    constant JUMP     : std_logic_vector (3 downto 0) := "1001";
BEGIN
    random_access_memory: ram generic map (
    RAM_DATA => (

    HALT & NULL_ARGUMENT,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,

    -- 5 (0x05)
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,

    -- 10 (0x0A)
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,

    -- 15 (0x0F)
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,

    -- 20 (0x14)
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,

    -- 25 (0x19)
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,
    NULL_COMMAND,

    -- 30 (0x1E)
    NULL_COMMAND,
    NULL_COMMAND

    ), DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,

        ram_debug => ram_debug
    );

    position_counter: pc generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    accumulator: acc_register generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,
        acc_in => acc_in,
        acc_out => acc_out
    );
    ctrl: controller generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,

        acc_in => acc_in,
        acc_out => acc_out,

        input_data => input_data,
        output_data => output_data
    );

    uut: alu generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,

        acc_in => acc_in,
        acc_out => acc_out
    );

    start :process(run)
    begin
        if run = '1' then
            null;
        end if;
    end process;

END;
