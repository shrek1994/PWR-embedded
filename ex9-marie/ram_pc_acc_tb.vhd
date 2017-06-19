LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.utills.all;

entity ram_pc_acc_tb is
end ram_pc_acc_tb;

architecture behavior of ram_pc_acc_tb is
    component ram is
    generic (RAM_DATA : data_type; DEBUG : boolean);
        Port (
            clk : in std_logic;
            bus_data : inout std_logic_vector (15 downto 0)
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

    signal clk :std_logic := '0';

    constant DEBUG : boolean := false;

    signal bus_data : std_logic_vector (15 downto 0) := (others => 'Z');
    signal acc_in : std_logic_vector (8 downto 0) := (others => 'Z');
    signal acc_out : std_logic_vector (8 downto 0) := (others => 'Z');

BEGIN
    uut: ram generic map (RAM_DATA => (OxOO_DATA, OxO1_DATA, OxO2_DATA, others => "000000000"), DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    uut2: pc generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data
    );

    uut3: acc_register generic map (DEBUG => DEBUG)
    PORT MAP (
        clk => clk,
        bus_data => bus_data,
        acc_in => acc_in,
        acc_out => acc_out
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

    print(DEBUG, "RAM_PC_ACC_TB - START !");
    wait for STARTING_TIME;

    -- load from ram to acc

    loadDataFromRamToAcc(bus_data, OxO1);
    checkDataInAcc(bus_data, OxO1_DATA, "data from 0x01");

    -- store from acc to ram

    loadDataFromRamToAcc(bus_data, OxO2);
    storeDataFromAccToRam(bus_data, OxO3);
    checkDataInRam(bus_data, OxO3, OxO2_DATA, "data from acc");

    print(DEBUG, "RAM_PC_ACC_TB - DONE !");
    wait;
    end process;

END;
