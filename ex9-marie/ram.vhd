library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.dataType_pkg.all;


entity ram is
    generic (RAM_DATA : dataType := ( others => "000000000"));
    Port (address   : in  STD_LOGIC_VECTOR (4 downto 0);
          save      : in std_logic;
          ram_in   : in  STD_LOGIC_VECTOR (8 downto 0);
          ram_out  : out STD_LOGIC_VECTOR (8 downto 0));
end ram;

architecture Behavioral of ram is
    type dataType is array (31 downto 0) of std_logic_vector (8 downto 0);
    signal data : dataType;
begin

nextAddress: process(address, save)
begin
    if save = '1' then
        data(to_integer(unsigned(address))) <= ram_in;
        ram_out <= "ZZZZZZZZZ";
    else
        ram_out <= data(to_integer(unsigned(address)));
    end if;
end process;


end Behavioral;
