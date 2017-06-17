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
    output      : out std_logic_vector(4 downto 0);

    debug_ram_out   : out std_logic_vector(8 downto 0);
    debug_address   : out std_logic_vector(4 downto 0)
        );
end main_line;

architecture behavior of main_line is

    component ram is generic (RAM_DATA: dataType);
        Port (address   : in  STD_LOGIC_VECTOR (4 downto 0);
            save      : in std_logic;
            ram_in   : in  STD_LOGIC_VECTOR (8 downto 0);
            ram_out  : out STD_LOGIC_VECTOR (8 downto 0)
            );
    end component;

    component pc is
        Port (clk   : in  std_logic;
            set      : in std_logic;
            data_in   : in  STD_LOGIC_VECTOR (4 downto 0);
            data_out  : out STD_LOGIC_VECTOR (4 downto 0)
            );
    end component;

    component acc_register is
        Port (set      : in std_logic;
            data_in   : in  STD_LOGIC_VECTOR (4 downto 0);
            data_out  : out STD_LOGIC_VECTOR (4 downto 0)
            );
    end component;

    component controller is
        port(
            instruction:   in std_logic_vector (8 downto 0);
            operation:     out std_logic_vector (1 downto 0);
            value :        out std_logic_vector(4 downto 0);
            address :      out std_logic_vector(4 downto 0);
            save_to_ram :  out std_logic;
            save_to_pc :   out std_logic;
            save_to_acc :  out std_logic;
            next_pc :      out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    constant clk_period :time := 20 ns;

    signal address : std_logic_vector (4 downto 0) := (others => 'Z');
    signal ram_in  : std_logic_vector(8 downto 0) := (others => 'Z');
    signal ram_out : std_logic_vector(8 downto 0) := (others => 'Z');


    signal operation:     std_logic_vector (1 downto 0) := (others => 'Z');
    signal value :        std_logic_vector(4 downto 0) := (others => 'Z');
    signal save_to_ram :  std_logic := 'Z';
    signal save_to_pc :   std_logic := 'Z';
    signal save_to_acc :  std_logic := 'Z';
    signal next_pc :      std_logic := 'Z';
BEGIN
    random_access_memory: ram generic map (RAM_DATA => RAM_DATA)
    port map (
        address => address,
        save => save_to_ram,
        ram_in => ram_in,
        ram_out => ram_out
    );

    controller_a: controller port map (
            instruction => ram_out,
            operation => operation,
            value => value,
            address => address,
            save_to_ram => save_to_ram,
            save_to_pc => save_to_pc,
            save_to_acc => save_to_acc,
            next_pc => next_pc
    );

    start :process(run)
    begin
        if run = '1' then
            address <= "00000";
        else
            address <= "ZZZZZ";
        end if;
    end process;

    debug_address <= address;
    debug_ram_out <= ram_out;

END;
