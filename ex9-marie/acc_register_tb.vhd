LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity acc_register_tb is
end acc_register_tb;

architecture behavior of acc_register_tb is
    component acc_register is
        Port (set      : in std_logic;
            data_in   : in  STD_LOGIC_VECTOR (4 downto 0);
            data_out  : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    signal clk : std_logic := '0';
    constant clk_period :time := 20 ns;

    signal set    : std_logic := '0';
    signal data_in  : std_logic_vector(4 downto 0) := (others => 'Z');
    signal data_out : std_logic_vector(4 downto 0) := (others => 'Z');

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: acc_register PORT MAP (
        set => set,
        data_in => data_in,
        data_out => data_out
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
        variable expected : std_logic_vector (4 downto 0) := (others => '0');
    begin

    wait for 100 ns;

    -- set new value
    expected := "01001";
    set <= '1';
    data_in <= expected;
    wait for clk_period;
    set <= '0';
    assert data_out = expected report "ERROR! expected: " & str(expected) & ", was: " & str(data_out);

    -- should be the same value:
    wait for clk_period * 10;

    assert data_out = expected report "ERROR! expected: " & str(expected) & ", was: " & str(data_out);


    wait;
    end process;

END;
