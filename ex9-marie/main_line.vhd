LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.dataType_pkg.all;

entity main_line is
    generic (RAM_DATA : dataType := ( others => "000000000"));
    Port (
    run       : in  std_logic;
    input       : in std_logic_vector(4 downto 0);
    output      : out std_logic_vector(4 downto 0)
        );
end main_line;

architecture behavior of main_line is

    component ram is generic (RAM_DATA: dataType);
        Port (address   : in  STD_LOGIC_VECTOR (4 downto 0);
            save      : in std_logic;
            ram_in   : in  STD_LOGIC_VECTOR (8 downto 0);
            ram_out  : out STD_LOGIC_VECTOR (8 downto 0));
    end component;

    component pc is
        Port (clk   : in  std_logic;
            set      : in std_logic;
            data_in   : in  STD_LOGIC_VECTOR (4 downto 0);
            data_out  : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    component acc_register is
        Port (set      : in std_logic;
            data_in   : in  STD_LOGIC_VECTOR (4 downto 0);
            data_out  : out STD_LOGIC_VECTOR (4 downto 0) := (others => '0'));
    end component;

    component controller is
        port(
            instruction:    in std_logic_vector (8 downto 0);
            result_to_acc:  in std_logic_vector (4 downto 0);
            driver : inout std_logic_vector(1 downto 0) := "00"
        );
    end component;

    signal clk : std_logic := '0';
    constant clk_period :time := 20 ns;

    signal address   : STD_LOGIC_VECTOR (4 downto 0);
    signal save    : std_logic := '0';
    signal ram_in  : std_logic_vector(8 downto 0) := (others => 'Z');
    signal ram_out : std_logic_vector(8 downto 0) := (others => 'Z');

BEGIN
    random_access_memory: ram generic map (RAM_DATA => RAM_DATA)
    port map (
        address => address,
        save => save,
        ram_in => ram_in,
        ram_out => ram_out
    );

    start :process(run)
    begin
        if run = '1' then

        end if;
    end process;


END;
