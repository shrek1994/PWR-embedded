library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package dataType_pkg is
    type dataType is array (0 to 31) of std_logic_vector (8 downto 0);
end package dataType_pkg;
