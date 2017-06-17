
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE work.txt_util.ALL;

entity controller is
  port(
	instruction:    in std_logic_vector (8 downto 0);
	operation:  out std_logic_vector (1 downto 0) := "ZZ";
	value :     out std_logic_vector(4 downto 0) := "ZZZZZ";
	save_to_ram : out std_logic := '0';
	save_to_pc : out std_logic := '0';
	next_pc    : out std_logic := '0'
  );
end controller;

architecture Flow of controller is
    type state is (FETCH, DECODE, EXECUTE, STORE);
    signal current_state : state := FETCH;
    signal next_state : state := FETCH;
begin

-- state_advance: process(clk, reset)
-- begin
-- --
-- --   	IF reset = '1' THEN
-- -- 		stan_teraz <= S0;
-- -- 	ELSIF rising_edge(clk) then
-- -- 	    if pusher = '1' then
-- -- 	    	stan_teraz <= stan_potem;
-- -- 	    elsif pusher = '0' and stan_teraz = S2 then
-- -- 	    	stan_teraz <= S0;
-- -- 	 	end if;
-- --   	END IF;
-- end process;

-- next_stateagds: process(current_state)
-- begin
-- --    case stan_teraz is
-- --      when S0 =>
-- -- 				stan_potem <= S1;
-- -- 				driver <= "00";
-- -- 	  when S1 =>
-- -- 				stan_potem <= S2;
-- -- 				driver <= "10";
-- -- 	  when S2 =>
-- -- 				stan_potem <= S3;
-- -- 				driver <= "11";
-- -- 	  when S3 =>
-- -- 				stan_potem <= S1;
-- -- 				driver <= "01";
-- --
-- --    end case;
-- end process;

end Flow;

