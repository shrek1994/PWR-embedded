LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity pc_tb is
end pc_tb;

architecture behavior of pc_tb is
    component pc is
    generic (DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0)
        );
    end component;
    constant DEBUG : boolean := false;

    signal clk : std_logic := '0';
    signal bus_data : std_logic_vector(15 downto 0) := (others => 'Z');

BEGIN
    uut: pc generic map (DEBUG => DEBUG)
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

    print(DEBUG, "PC_TB - START!");
    wait for STARTING_TIME;

    resetPc(bus_data);
    checkDataInPc(bus_data, "00000", "zero after reset");

    nextPc(bus_data);
    checkDataInPc(bus_data, "00001", "one after next pc");

    setPc(bus_data, "00100");
    checkDataInPc(bus_data, "00100", "set value");

    nextPc(bus_data);
    checkDataInPc(bus_data, "00101", "next after set value");

    print(DEBUG, "PC_TB - DONE!");

    wait;
    end process;

END;
