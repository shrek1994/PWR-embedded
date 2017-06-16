library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity pc is
    Port (clk   : in  std_logic;
          set      : in std_logic;
          data_in   : in  STD_LOGIC_VECTOR (4 downto 0);
          data_out  : out STD_LOGIC_VECTOR (4 downto 0) := (others => '0'));
end pc;

architecture Behavioral of pc is
begin

nextAddress: process(clk, set)
    variable i : unsigned (4 downto 0) := (others => '0');
begin
    if set = '1' then
        i := unsigned(data_in);
    else
        if (clk'event AND clk='1') then
            i := i + 1;
        end if;
        data_out <= STD_LOGIC_VECTOR(i);
    end if;
end process;


end Behavioral;
