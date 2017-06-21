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
    signal output : std_logic_vector (8 downto 0) := (others => 'Z');
    signal ram_debug : data_type := (others => "ZZZZZZZZZ");

    signal start : std_logic := '0';

BEGIN
    random_access_memory: ram generic map (RAM_DATA => RAM_DATA, DEBUG => DEBUG)
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
        output_data => output
    );

    uut: alu generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,

        acc_in => acc_in,
        acc_out => acc_out
    );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    in_put: process(input_data)
    begin
        if input_data /= "UUUUUUUUU" and input_data /= "ZZZZZZZZZ" then
            print("INPUT: 0b" & str(input_data) & ", 0x" & hstr(input_data));
        end if;
    end process;

    out_put: process(output)
    begin
        if output /= "UUUUUUUUU" and output /= "ZZZZZZZZZ" then
            print("RESULT: 0b" & str(output) & ", 0x" & hstr(output));
        end if;
    end process;

    output_data <= output;
END;
