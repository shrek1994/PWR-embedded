library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity acc_register is
    Port (set      : in std_logic;
          data_in   : in  STD_LOGIC_VECTOR (4 downto 0);
          data_out  : out STD_LOGIC_VECTOR (4 downto 0) := (others => '0'));
end acc_register;

architecture Behavioral of acc_register is
begin

nextAddress: process(set)
    variable i : unsigned (4 downto 0) := (others => '0');
begin
    if set = '1' then
        i := unsigned(data_in);
    end if;
    data_out <= STD_LOGIC_VECTOR(i);
end process;


end Behavioral;
