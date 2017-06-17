LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is
    component alu is
        Port (operation              : in STD_LOGIC_VECTOR (1 downto 0);
            data_from_controller   : in STD_LOGIC_VECTOR (8 downto 0);
            data_from_accumulator  : in STD_LOGIC_VECTOR (8 downto 0);
            result                 : out STD_LOGIC_VECTOR (8 downto 0));
    end component;


    signal operation : std_logic_vector (1 downto 0) := (others => '0');
    signal data_from_controller    : STD_LOGIC_VECTOR (8 downto 0) := (others => '0');
    signal data_from_accumulator  : std_logic_vector(8 downto 0) := (others => '0');
    signal result : std_logic_vector(8 downto 0) := (others => '0');

    constant ADD : std_logic_vector(1 downto 0) := "01";
    constant SUB : std_logic_vector(1 downto 0) := "10";
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: alu PORT MAP (
        operation => operation,
        data_from_controller => data_from_controller,
        data_from_accumulator => data_from_accumulator,
        result => result
    );

    -- Stimulus process
    stim_proc: process
    begin

    wait for 100 ns;

    operation <= ADD;
    data_from_accumulator <= "010101010";
    data_from_controller  <= "101010100";
    wait for 1 ns;
    assert result = "111111110" report "ERROR! expected:" & "111111110" & ", was: " & str(result);


    operation <= SUB;
    data_from_accumulator <= "000111110";
    data_from_controller  <= "000010110";
    wait for 1 ns;
    assert result = "000101000" report "ERROR! expected:" & "000101000" & ", was: " & str(result);

    wait;
    end process;

END;
