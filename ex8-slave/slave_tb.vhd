LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE IEEE.std_logic_unsigned.ALL;
USE work.txt_util.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY slave_tb IS
END slave_tb;

ARCHITECTURE behavior OF slave_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT slave
	 generic ( identifier : std_logic_vector (7 downto 0) );
    PORT(
         conn_bus : INOUT  std_logic_vector(7 downto 0);
         clk : IN  std_logic;
			state : out STD_LOGIC_VECTOR (5 downto 0);
			vq : out std_logic_vector (7 downto 0);
			vcurrent_cmd : out std_logic_vector(3 downto 0)
        );
    END COMPONENT;


   --Inputs
   signal clk : std_logic := '0';

	--BiDirs
   signal conn_bus : std_logic_vector(7 downto 0) := (others => 'Z');


	-- outputs from UUT for debugging
	signal state : std_logic_vector(5 downto 0);
	signal vq : std_logic_vector (7 downto 0);
	signal current_cmd : std_logic_vector (3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant ADDRESS_SLAVE_1 : std_logic_vector (7 downto 0) := "00000001";
   constant ADDRESS_SLAVE_2 : std_logic_vector (7 downto 0) := "00000010";
   constant ADDRESS_SLAVE_3 : std_logic_vector (7 downto 0) := "00000011";
   constant ADD_CMD         : std_logic_vector (7 downto 0) := "00010000";
   constant ID_CMD          : std_logic_vector (7 downto 0) := "00100000";
   constant CRC_CMD         : std_logic_vector (7 downto 0) := "00110000";
   constant DATA_REQ_CMD    : std_logic_vector (7 downto 0) := "01000000";
   constant SUB_CMD         : std_logic_vector (7 downto 0) := "01010000";
   constant RESET_CMD       : std_logic_vector (7 downto 0) := "11110000";
   constant NULL_ARG        : std_logic_vector (7 downto 0) := "00000000";
   constant RECEIVE_ARG_HALF_PERIOD_LATER_ADD : std_logic_vector (7 downto 0) := "10010000";
   constant DATA_REQ_AFTER_TWO_PERIODS_CMD : std_logic_vector (7 downto 0) := "01110000";

    procedure performCmd(signal conn_bus : inout std_logic_vector ; address : in std_logic_vector; cmd : in std_logic_vector; arg : in std_logic_vector) is
    begin
        conn_bus <= address;
        wait for clk_period;
        conn_bus <= cmd;
        wait for clk_period;
        conn_bus <= arg;
        wait for clk_period;
    end performCmd;

    procedure checkResults(signal conn_bus : inout std_logic_vector ; address : in std_logic_vector; expected : in std_logic_vector; msg : string) is
    begin
        conn_bus <= address;
		wait for clk_period;
		conn_bus <= DATA_REQ_CMD;
		wait for clk_period;

		conn_bus <= "ZZZZZZZZ";
		wait for clk_period;
		assert conn_bus = expected report "expected " & msg & ": '" & str(expected) &"' on conn_bus -- got: '" & str(conn_bus) & "'";
		wait for clk_period*2;
    end checkResults;


BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut1: slave
	GENERIC MAP (identifier => ADDRESS_SLAVE_1)
	PORT MAP (
          conn_bus => conn_bus,
          clk => clk,
			 state => state,
			 vq => vq,
			 vcurrent_cmd => current_cmd
        );

    uut2: slave
	GENERIC MAP (identifier => ADDRESS_SLAVE_2)
	PORT MAP (
          conn_bus => conn_bus,
          clk => clk,
			 state => state,
			 vq => vq,
			 vcurrent_cmd => current_cmd
        );

    uut3: slave
	GENERIC MAP (identifier => ADDRESS_SLAVE_3)
	PORT MAP (
          conn_bus => conn_bus,
          clk => clk,
			 state => state,
			 vq => vq,
			 vcurrent_cmd => current_cmd
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;



   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

        performCmd(conn_bus, ADDRESS_SLAVE_1, ID_CMD, NULL_ARG);
        checkResults(conn_bus, ADDRESS_SLAVE_1 , ADDRESS_SLAVE_1, "address");

        performCmd(conn_bus, ADDRESS_SLAVE_1, RESET_CMD, NULL_ARG);
        checkResults(conn_bus, ADDRESS_SLAVE_1 , "00000000", "reset");

        performCmd(conn_bus, ADDRESS_SLAVE_1, ADD_CMD, "00001111");
        checkResults(conn_bus, ADDRESS_SLAVE_1 , "00001111", "the same value as input of one argument adding");

        performCmd(conn_bus, ADDRESS_SLAVE_1, RESET_CMD, NULL_ARG);
        performCmd(conn_bus, ADDRESS_SLAVE_1, ADD_CMD, "00001111");
        performCmd(conn_bus, ADDRESS_SLAVE_1, ADD_CMD, "00000001");
        checkResults(conn_bus, ADDRESS_SLAVE_1 , "00010000", "sum of two values");

        performCmd(conn_bus, ADDRESS_SLAVE_1, RESET_CMD, NULL_ARG);
        performCmd(conn_bus, ADDRESS_SLAVE_1, CRC_CMD, "00001111");
        checkResults(conn_bus, ADDRESS_SLAVE_1 , "00101101", "crc of one value"); -- !

        performCmd(conn_bus, ADDRESS_SLAVE_1, RESET_CMD, NULL_ARG);
        performCmd(conn_bus, ADDRESS_SLAVE_1, CRC_CMD, "00001111");
        performCmd(conn_bus, ADDRESS_SLAVE_1, CRC_CMD, "00001111");
        checkResults(conn_bus, ADDRESS_SLAVE_1 , "11101110", "crc of two values"); -- !

        performCmd(conn_bus, ADDRESS_SLAVE_1, RESET_CMD, NULL_ARG);
        performCmd(conn_bus, ADDRESS_SLAVE_1, ADD_CMD, "00001111");
        performCmd(conn_bus, ADDRESS_SLAVE_1, SUB_CMD, "00001001");
        checkResults(conn_bus, ADDRESS_SLAVE_1 , "00000110", "correct one sub");

        performCmd(conn_bus, ADDRESS_SLAVE_1, RESET_CMD, NULL_ARG);
        performCmd(conn_bus, ADDRESS_SLAVE_1, ADD_CMD, "01111111");
        performCmd(conn_bus, ADDRESS_SLAVE_1, SUB_CMD, "00001000");
        performCmd(conn_bus, ADDRESS_SLAVE_1, SUB_CMD, "00001000");
        checkResults(conn_bus, ADDRESS_SLAVE_1 , "01101111", "correct two sub");

        -- send after 2 period:
        performCmd(conn_bus, ADDRESS_SLAVE_2, ADD_CMD, "01010101");
        performCmd(conn_bus, ADDRESS_SLAVE_3, ADD_CMD, "00101010");

        -- req for result later
        conn_bus <= ADDRESS_SLAVE_2;
		wait for clk_period;
		conn_bus <= DATA_REQ_AFTER_TWO_PERIODS_CMD;
		wait for clk_period;

		-- performCmd with arg from slave 2
        performCmd(conn_bus, ADDRESS_SLAVE_3, RECEIVE_ARG_HALF_PERIOD_LATER_ADD, "ZZZZZZZZ");
        wait for clk_period;

        checkResults(conn_bus, ADDRESS_SLAVE_3 , "01111111", "should correct send data to next slave and sum it");

      wait;
   end process;

END;
