LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.dataType_pkg.all;
use work.txt_util.all;

entity main_line_tb is
end main_line_tb;

   -- type dataType is array (31 downto 0) of std_logic_vector (8 downto 0);

architecture behavior of main_line_tb is

    component main_line is generic(RAM_DATA: dataType);
    port(
        run       : in  std_logic;
        input       : in std_logic_vector(4 downto 0);
        output      : out std_logic_vector(4 downto 0);
        debug_ram_out   : out std_logic_vector(8 downto 0);
        debug_address   : out std_logic_vector(4 downto 0)
    );
    end component;

    constant OUTPUT_CMD : std_logic_vector(8 downto 0) := "010100000";
    constant HALT_CMD : std_logic_vector(8 downto 0) := "011100000";
    constant EXPECTED_DATA : std_logic_vector(8 downto 0) := "010101010";
    constant RAM_LOAD_DATA : dataType := (
        "000100011", -- load from 0x3
        OUTPUT_CMD,
        HALT_CMD,
        EXPECTED_DATA, -- 0x3
        others => "000000000"
    );
    signal run : std_logic := '0';
    signal input : std_logic_vector(4 downto 0) := (OTHERS => 'Z');
    signal output : std_logic_vector(4 downto 0) := (OTHERS => 'Z');
    signal debug_ram_out : std_logic_vector(8 downto 0) := (OTHERS => 'Z');
    signal debug_address : std_logic_vector(4 downto 0) := (OTHERS => 'Z');
    constant clk_period : Time := 10 ns;
begin

    load_data: main_line generic map (RAM_DATA => RAM_LOAD_DATA)
    port map (
        run => run,
        input => input,
        output => output,

        debug_ram_out => debug_ram_out,
        debug_address => debug_address
    );

    simul_process : process
    begin
        run <= '1';

        wait for clk_period * 10;

        assert output = EXPECTED_DATA report "ERROR! expected: " & str(EXPECTED_DATA) & ", was: " & str(output);

        wait;
    end process;
end;
