library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.dataType_pkg.all;
use work.txt_util.all;


entity ram is
    generic (RAM_DATA : dataType := (others => "000000000"));
    Port (address   : in  STD_LOGIC_VECTOR (4 downto 0);
          save      : in std_logic;
          ram_in   : in  STD_LOGIC_VECTOR (8 downto 0);
          ram_out  : out STD_LOGIC_VECTOR (8 downto 0));
end ram;

architecture Behavioral of ram is
--     signal data : dataType := RAM_DATA;
    constant debug : boolean := true;
begin

nextAddress: process(address, save)
    variable data_ram : dataType;
    variable init : boolean := true;
begin
    if init then
        data_ram := RAM_DATA;
        init := false;
    end if;

    if save = '1' then
        print(debug, "RAM: address: " & str(address) & ", saving: " & str(ram_in));
        data_ram(to_integer(unsigned(address))) := ram_in;
        print(debug, "RAM: saved: " & str(data_ram(to_integer(unsigned(address)))));
        ram_out <= "ZZZZZZZZZ";
    else
        if address = "UUUUU" or address = "ZZZZZ" then
            null;
        else
            ram_out <= data_ram(to_integer(unsigned(address)));
            print(debug, "RAM: address: " & str(address) & ", sending: " & str(data_ram(to_integer(unsigned(address)))));
        end if;
    end if;
end process;


end Behavioral;
