--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:08:01 01/20/2025
-- Design Name:   
-- Module Name:   /home/haf6850/Xilinx/UARTrendu/RxUnittest.vhd
-- Project Name:  UARTrendu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RxUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY RxUnittest IS
END RxUnittest;
 
ARCHITECTURE behavior OF RxUnittest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RxUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         read : IN  std_logic;
         rxd : IN  std_logic;
         data : OUT  std_logic_vector(7 downto 0);
         Ferr : OUT  std_logic;
         OErr : OUT  std_logic;
         DRdy : OUT  std_logic
        );
    END COMPONENT;
    
	 COMPONENT clkUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		enableTX : OUT std_logic;
		enableRX : OUT std_logic
		);
	END COMPONENT;


   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable : std_logic := '0';
   signal read : std_logic := '0';
   signal rxd : std_logic := '0';

 	--Outputs
   signal data : std_logic_vector(7 downto 0);
   signal Ferr : std_logic;
   signal OErr : std_logic;
   signal DRdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	signal enableTx, enableRX : std_logic;
	signal cpt : integer := 8;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => enable,
          read => read,
          rxd => rxd,
          data => data,
          Ferr => Ferr,
          OErr => OErr,
          DRdy => DRdy
        );
	Inst_clkUnit: clkUnit PORT MAP(
		clk => clk,
		reset => reset,
		enableTX => enableTX,
		enableRX => enableRX
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
	-- La data à envoyer
	variable octet : std_logic_vector(7 downto 0);
	--Pour le calcul de parite
	variable parite : std_logic;
	
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      reset <= '1';

      --test pour la lettre U ( 01010101) 
		rxd <= '1';
		wait until enableTX = '1';
		rxd <= '0'; --bit start
		wait until enableTX = '0';
		octet := "01010101";
		parite := '0';
		while cpt > 0 loop -- envoie de l'octet
			wait until enableTX = '1';
			rxd <= octet(cpt - 1);
			wait until enableTX = '0';
			parite := parite xor octet(cpt - 1);
			cpt <= cpt - 1 ;
		end loop;
		wait until enableTX = '1';
		rxd <= parite; -- bit parite
		wait until enableTX = '0';
		wait until enableTX = '1';
		rxd <= '1'; --bit stop
		wait until enableTX = '0';

      wait;
   end process;

END;
