LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.dataType_pkg.all;

entity ram_tb is
end ram_tb;

architecture behavior of ram_tb is
    component ram is
    generic (RAM_DATA : dataType);
        Port (address   : in  STD_LOGIC_VECTOR (4 downto 0);
              save      : in  std_logic;
              ram_in   : in  STD_LOGIC_VECTOR (8 downto 0);
              ram_out  : out STD_LOGIC_VECTOR (8 downto 0));
    end component;

    signal clk :std_logic := '0';
    constant clk_period :time := 20 ns;

    signal address : std_logic_vector (4 downto 0) := (others => 'Z');
    signal save    : std_logic := '0';
    signal data_in  : std_logic_vector(8 downto 0) := (others => 'Z');
    signal data_out : std_logic_vector(8 downto 0) := (others => 'Z');

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: ram generic map (RAM_DATA => ("111000111", others => "000000000"))
    PORT MAP (
        address => address,
        save => save,
        ram_in => data_in,
        ram_out => data_out
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '1';
		wait for clk_period / 2;
		clk <= '0';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin

    wait for 100 ns;

    wait for clk_period;

    --read data
    address <= "00000";
    save <= '0';
    wait for clk_period;
    assert data_out = "111000111" report "expected: " & "111000111" & ", got: " & str(data_out);


    -- save data
    address <= "00011";
    save <= '1';
    data_in <= "101010101";

    wait for clk_period;

    --read data
    save <= '0';
    address <= "00011";

    wait for clk_period;
    assert data_out = "101010101" report "expected: " & "101010101" & ", got: " & str(data_out);


    wait;
    end process;

END;
