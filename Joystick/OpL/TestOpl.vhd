--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:16:41 11/16/2024
-- Design Name:   
-- Module Name:   /home/haf6850/Xilinx/MasterOPL/TestOpl.vhd
-- Project Name:  MasterOPL
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MasterOpl
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
 
ENTITY TestOpl IS
END TestOpl;
 
ARCHITECTURE behavior OF TestOpl IS 
 
    -- Déclaration du composant MasterOpl
  component MasterOpl
    port (
      rst : in std_logic;
      clk : in std_logic;
      en : in std_logic;
      v1 : in std_logic_vector(7 downto 0);
      v2 : in std_logic_vector(7 downto 0);
      miso : in std_logic;
      ss : out std_logic;
      sclk : out std_logic;
      mosi : out std_logic;
      val_xor : out std_logic_vector(7 downto 0);
      val_and : out std_logic_vector(7 downto 0);
      val_or : out std_logic_vector(7 downto 0);
      busy : out std_logic
    );
  end component;

  -- Déclaration du composant SlaveOpl
  component SlaveOpl
    port (
      sclk : in std_logic;
      mosi : in std_logic;
      miso : out std_logic;
      ss : in std_logic
    );
  end component;

  -- Les inputs
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal en : std_logic := '0';
  signal v1 : std_logic_vector(7 downto 0) := (others => 'U');
  signal v2 : std_logic_vector(7 downto 0) := (others => 'U');
  signal miso : std_logic;
	-- Les Outputs
  signal ss : std_logic;
  signal sclk : std_logic;
  signal mosi : std_logic;
  signal val_xor : std_logic_vector(7 downto 0);
  signal val_and : std_logic_vector(7 downto 0);
  signal val_or : std_logic_vector(7 downto 0);
  signal busy : std_logic;

  -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  -- Instanciation de MasterOpl
  uut_master : MasterOpl
    port map (
      rst => rst,
      clk => clk,
      en => en,
      v1 => v1,
      v2 => v2,
      miso => miso,
      ss => ss,
      sclk => sclk,
      mosi => mosi,
      val_xor => val_xor,
      val_and => val_and,
      val_or => val_or,
      busy => busy
    );

  -- Instanciation de SlaveOpl
  uut_slave : SlaveOpl
    port map (
      sclk => sclk,
      mosi => mosi,
      miso => miso,
      ss => ss
    );

  -- Processus de génération de l'horloge
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Stimulus principal
  stim_proc : process
  begin
    -- Initialisation du reset
    wait for 100 ns;  
    rst <= '1';
	 en <= '1';
    -- Premier test : Vérifier les valeurs initiales transmises par le SlaveOpl
	 v1 <= "10101010";
    v2 <= "11001100";
	 wait until busy = '0'; -- Attente que l'opération se termine
	 -- Vérification des valeurs initiales
    assert (val_xor = "00110011") report "Erreur: XOR initial incorrect" severity error;
    assert (val_and = "10100000") report "Erreur: AND initial incorrect" severity error;
    assert (val_or = "11001100") report "Erreur: OR initial incorrect" severity error;	 
	 wait for 1050 ns;
	-- Deuxième test : Vérifier les valeurs initiales transmises par le SlaveOpl
	 v1 <= "00000000";
    v2 <= "11111111";
	 wait until busy = '0';
    -- Vérification des résultats du premier test
    assert (val_xor = "01100110") report "Erreur: XOR incorrect dans le deuxième test" severity error;
    assert (val_and = "10001000") report "Erreur: AND incorrect dans le deuxième test" severity error;
    assert (val_or = "11101110") report "Erreur: OR incorrect dans le deuxième test" severity error;
	 wait for 1050 ns;

	 wait until busy = '0';
    -- Vérification des valeurs du deuxième test
    assert (val_xor = "11111111") report "Erreur: XOR initial incorrect" severity error;
    assert (val_and = "00000000") report "Erreur: AND initial incorrect" severity error;
    assert (val_or = "11111111") report "Erreur: OR initial incorrect" severity error;
	  	
    -- Fin du test
    wait;
  end process;

end behavior;
