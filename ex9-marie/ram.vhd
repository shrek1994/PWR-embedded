library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ram is
    Port (address   : in  STD_LOGIC_VECTOR (4 downto 0);
          save      : in std_logic;
          data_in   : in  STD_LOGIC_VECTOR (8 downto 0);
          data_out  : out STD_LOGIC_VECTOR (8 downto 0));
end ram;

architecture Behavioral of ram is
    type dataType is array (31 downto 0) of std_logic_vector (8 downto 0);
    signal data : dataType;
begin

nextAddress: process(address, save)
begin
    if save = '1' then
        data(to_integer(unsigned(address))) <= data_in;
        data_out <= "000000000"; -- "ZZZZZZZZZ";
    else
        data_out <= data(to_integer(unsigned(address)));
    end if;
end process;

--  data_out <= data(unsigned(address)) when save = '0' else "ZZZZZZZZZ";

end Behavioral;
