library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;
USE work.txt_util.ALL;
use work.pack.all;

-----------------------------------------------------------------------
-- a (working) skeleton template for slave device on 8-bit bus
--    capable of executing commands sent on the bus in the sequence:
--    1) device_address (8 bits)
--		2) cmd_opcode (4 bits) & reserved (4 bits)
--		3) (optional) cmd_args (8 bits)
--
-- currently supported commands:
-- 	* ID 			[0010] - get device address
-- 	* DATA_REQ 	[1111] - send current result in the next clockpulse
-- 	* NOP 		[0000] - don't do anything
-----------------------------------------------------------------------
-- debugging information on current state of statemachine and command
-- executed and input buffer register is given in outputs, vstate,
-- vcurrent_cmd and vq, respectively
-----------------------------------------------------------------------

entity slave is
    generic ( identifier : std_logic_vector (7 downto 0) := "10101010" );
    Port ( conn_bus : inout  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
			  state : out STD_LOGIC_VECTOR (5 downto 0);
			  vq : out std_logic_vector (7 downto 0);
			  vcurrent_cmd : out std_logic_vector(3 downto 0)
			  );
end slave;

architecture Behavioral of slave is

-- statemachine definitions
type state_type is (IDLE, CMD, RUN);
signal current_s : state_type := IDLE;
signal next_s : state_type := IDLE;
-- for debugging entity's state
signal vstate : std_logic_vector(5 downto 0) := (others => '0');

-- command definitions
type cmd_type is (NOP, ADD, ID, CRC, DATA_REQ, SUB, DATA_REQ_AFTER_TWO_PERIODS, RECEIVE_ARG_HALF_PERIOD_LATER_ADD, RESET);
attribute enum_encoding: string;
attribute enum_encoding of cmd_type: type is
				"0000 0001 0010 0011 0100 0101 0111 1001 1111";
signal current_cmd : cmd_type := NOP;

-- input buffer
signal q : std_logic_vector (7 downto 0) := (others => '0');

-- for storing results and indicating it is to be sent to bus
signal result_reg : std_logic_vector (7 downto 0) := (others => '0');
signal sending : std_logic := '0';
signal half_period : std_logic := '0';

constant debug : boolean := false;

begin

stateadvance: process(clk)
begin
    if half_period = '0' then
        if rising_edge(clk)
        then
            q  <= conn_bus;
            current_s <= next_s;
        end if;
    else
        if falling_edge(clk)
        then
            print(debug, "receiving?");
            q  <= conn_bus;
            current_s <= next_s;
        end if;
        half_period <= '0';
    end if;
end process;


nextstate: process(current_s,q)
  variable fourbit : std_logic_vector(3 downto 0) := "0000";
  variable tmp : std_logic_vector(7 downto 0) :=  (others => '0');
  variable sleepTime : unsigned(1 downto 0);
begin

 case current_s is
   when IDLE =>
		vstate <= "000001";		-- set for debugging
		if q = identifier and sending /= '1'
		then
            next_s <= CMD;
		else
			next_s <= IDLE;
		end if;
		sending <= '0';
	when CMD =>
		vstate <= "000010";
		-- command decode
		fourbit := q(7 downto 4);
		case fourbit is
			when "0000" => current_cmd <= NOP;
			when "0001" => current_cmd <= ADD;
			when "0010" => current_cmd <= ID;
			when "0011" => current_cmd <= CRC;
			when "0100" => current_cmd <= DATA_REQ;
			when "0101" => current_cmd <= SUB;
			when "1001" =>
                print(debug, "RECEIVE_ARG_HALF_PERIOD_LATER_ADD");
                current_cmd <= RECEIVE_ARG_HALF_PERIOD_LATER_ADD;
                sleepTime := "01";
			when "0111" =>
                current_cmd <= DATA_REQ_AFTER_TWO_PERIODS;
                sleepTime := "10";

			when "1111" => current_cmd <= RESET;
			when others => current_cmd <= NOP;
		end case;
		next_s <= RUN;
	when RUN =>
		vstate <= "000100";
		-- determine action based on currend_cmd state
		case current_cmd is
			when NOP
				=> result_reg <= result_reg;
                    next_s <= IDLE;
			when ID
				=> result_reg <= identifier;
                    next_s <= IDLE;
			when DATA_REQ
				=> sending <= '1';
                    next_s <= IDLE;
			--
			-- here other commands execution
			--
			when RESET
                => result_reg <= "00000000";
                    next_s <= IDLE;
			when ADD
                =>
                print(debug, "adding: " & str(result_reg) & " + " & str(q) );
                result_reg <= std_logic_vector(unsigned(result_reg) + unsigned(q));
                next_s <= IDLE;
            when CRC
                => result_reg <= nextCRC(q, result_reg);
                    next_s <= IDLE;
            when SUB
                => result_reg <= std_logic_vector(unsigned(result_reg) - unsigned(q));
                    next_s <= IDLE;
            when DATA_REQ_AFTER_TWO_PERIODS =>
                print(debug, "after 2 periods: " & str(std_logic_vector(sleepTime)));
                if sleepTime = "00" then
                        sending <= '1';
                        next_s <= IDLE;
                        print(debug, "sending!");
                end if;
                sleepTime := sleepTime - 1;
            when RECEIVE_ARG_HALF_PERIOD_LATER_ADD =>
                print(debug, "waiting for data");
                current_cmd <= ADD;
                next_s <= RUN;
			when others
				=> result_reg <= result_reg;
                next_s <= IDLE;
		end case;
   when others =>
		vstate <= "111111";
		next_s <= IDLE;
   end case;
end process;


-- tri-state bus
conn_bus <= result_reg when sending = '1' else "ZZZZZZZZ";

-- output debugging signals
state <= vstate;
vq    <= q;
with current_cmd select
 vcurrent_cmd <= "0001" when ADD,
					  "0010" when ID,
					  "0011" when CRC,
					  "0100" when DATA_REQ,
					  "0000" when others;


end Behavioral;

