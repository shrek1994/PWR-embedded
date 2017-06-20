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
    constant DEBUG: boolean := true;

    constant RAM_DATA : data_type := (

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
        run <= '1';

--         assert output = EXPECTED_DATA report "ERROR! expected: " & str(EXPECTED_DATA) & ", was: " & str(output);

        wait for 1 ms;
    end process;
end;
