LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity ram_tb is
end ram_tb;

architecture behavior of ram_tb is
    component ram is
    generic (RAM_DATA : data_type; DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0)
              );
    end component;

    constant DEBUG : boolean := false;

    signal clk :std_logic := '0';
    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');

    constant NEW_DATA : std_logic_vector (8 downto 0) := "101010101";
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: ram generic map (RAM_DATA => (OxOO_DATA, OxO1_DATA, OxO2_DATA, others => "000000000"), DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    -- Clock process definitions
    clk_process :process
    begin
		clk <= '0';
		wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
    print(DEBUG, "RAM_TB - START !");

    wait for STARTING_TIME;

    checkDataInRam(bus_data, OxOO, OxOO_DATA, "0x00");
    checkDataInRam(bus_data, OxO1, OxO1_DATA, "0x01");
    checkDataInRam(bus_data, OxO2, OxO2_DATA, "0x02");

    setDataInRam(bus_data, OxO3, NEW_DATA);
    checkDataInRam(bus_data, OxO3, NEW_DATA, "new data");

    print(DEBUG, "RAM_TB - DONE !");
    wait;
    end process;

END;
