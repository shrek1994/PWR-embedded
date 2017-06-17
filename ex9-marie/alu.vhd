library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity alu is
    Port (operation              : in STD_LOGIC_VECTOR (1 downto 0);
          data_from_controller   : in STD_LOGIC_VECTOR (8 downto 0);
          data_from_accumulator  : in STD_LOGIC_VECTOR (8 downto 0);
          result                 : out STD_LOGIC_VECTOR (8 downto 0));
end alu;

architecture Behavioral of alu is
begin

nextOperation: process(operation)
begin
    case operation is
        when "01" =>
            -- add
            result <= STD_LOGIC_VECTOR(unsigned(data_from_accumulator) + unsigned(data_from_controller));
        when "10" =>
            -- subt
            result <= STD_LOGIC_VECTOR(unsigned(data_from_accumulator) - unsigned(data_from_controller));
        when others =>
            result <= "ZZZZZZZZZ";
    end case;
end process;


end Behavioral;
