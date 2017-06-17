LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- include also the local library for 'str' call
USE work.txt_util.ALL;


entity controller_tb IS
END controller_tb;

ARCHITECTURE behavior OF controller_tb IS
    COMPONENT controller
        port(
            instruction:    in std_logic_vector (8 downto 0);
            operation:  out std_logic_vector (1 downto 0);
            value :     out std_logic_vector(4 downto 0);
            address :     out std_logic_vector(4 downto 0);
            save_to_ram : out std_logic;
            save_to_pc : out std_logic;
            save_to_acc : out std_logic;
            next_pc    : out std_logic
        );
    END COMPONENT;


   --Inputs
   signal instruction : std_logic_vector (8 downto 0) := "000000000";

 	--Outputs
   signal operation : std_logic_vector(1 downto 0);
   signal value : std_logic_vector(4 downto 0);
   signal address : std_logic_vector(4 downto 0);
   signal save_to_ram : std_logic;
   signal save_to_pc : std_logic;
   signal save_to_acc : std_logic;
   signal next_pc : std_logic;

   -- Clock period definitions
   signal clk : std_logic;
   constant clk_period : time := 10 ns;

   constant NOTHING : std_logic_vector(1 downto 0) := "00";
   constant ADD : std_logic_vector(1 downto 0) := "01";
   constant SUBT : std_logic_vector(1 downto 0) := "10";

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: controller PORT MAP (
          instruction => instruction,
          operation => operation,
          value => value,
          address => address,
          save_to_ram => save_to_ram,
          save_to_pc => save_to_pc,
          save_to_acc => save_to_acc,
          next_pc => next_pc
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
        wait for 100 ns;

        instruction <= "000100001"; -- load 00001
        wait for 1 ns;




        wait;
   end process;

END;


