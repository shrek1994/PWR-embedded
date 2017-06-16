LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity pc_tb is
end pc_tb;

architecture behavior of pc_tb is
    component pc is
        Port (clk   : in  std_logic;
            set      : in std_logic;
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
    uut: pc PORT MAP (
        clk => clk,
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
    begin

    wait for 100 ns;

    -- reset
    set <= '1';
    data_in <= "00001";
    wait for clk_period;
    set <= '0';

    -- should be 10 + initial value:
    wait for clk_period * 10;
    assert data_out = "01011" report "ERROR! expected: " &  "01011" & ", was: " & str(data_out);


    wait;
    end process;

END;
