LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity ram_pc_tb is
end ram_pc_tb;

architecture behavior of ram_pc_tb is
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

    constant DEBUG : boolean := false;

    signal clk :std_logic := '0';
    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');

    signal ram_debug : data_type := (others => "ZZZZZZZZZ");

BEGIN
    uut: ram generic map (RAM_DATA => (OxOO_DATA, OxO1_DATA, OxO2_DATA, others => "000000000"), DEBUG => DEBUG)
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

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    stim_proc: process
    begin

    print(DEBUG, "RAM_PC_TB - START!");
    wait for STARTING_TIME;

    checkDataInRamBasedOnAddressFromPc(bus_data, OxOO_DATA, "0x00");
    nextPc(bus_data);
    checkDataInRamBasedOnAddressFromPc(bus_data, OxO1_DATA, "0x01");
    nextPc(bus_data);
    checkDataInRamBasedOnAddressFromPc(bus_data, OxO2_DATA, "0x02");

    print(DEBUG, "RAM_PC_TB - DONE!");
    wait;
    end process;

END;
