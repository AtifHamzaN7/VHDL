----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:32:16 11/19/2024 
-- Design Name: 
-- Module Name:    MasterJoystick - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MasterJoystick is
	port ( 	rst : in std_logic;
				clk : in std_logic;
				en : in std_logic;
				led1 : in std_logic;
				led2 : in std_logic;
				miso : in std_logic;
				ss   : out std_logic;
				sclk : out std_logic;
				mosi : out std_logic;
				x : out std_logic_vector (9 downto 0);
				y : out std_logic_vector (9 downto 0);
				Buttonstick: out std_logic;
				Button1: out std_logic;
				Button2: out std_logic;
				busy : out std_logic);

end MasterJoystick;

architecture Behavioral of MasterJoystick is

-- Déclaration des états
  type t_etat is (repos, wait_echange, echange_oct);
  signal etat : t_etat := repos;

  -- Signaux internes
  signal en_er : std_logic;         -- Activation du composant er_1octet
  signal er_busy : std_logic;              -- Signal busy du composant er_1octet
  signal er_dout : std_logic_vector(7 downto 0); -- Données reçues de er_1octet
  signal er_din : std_logic_vector(7 downto 0); -- Donnée à envoyer
  signal cpt_echange : natural; --Compteur pour divers attente
  signal echange : natural; --echange pour indiquer quel octet on envoie
  
  -- Instanciation du composant er_1octet
  COMPONENT er_1octet
    PORT(
      rst : IN std_logic;
      clk : IN std_logic;
      en : IN std_logic;
      din : IN std_logic_vector(7 downto 0);
      miso : IN std_logic;          
      sclk : OUT std_logic;
      mosi : OUT std_logic;
      dout : OUT std_logic_vector(7 downto 0);
      busy : OUT std_logic
    );
  END COMPONENT;

begin

  -- Instantiation de er_1octet
  er_inst : er_1octet
    port map (
      rst => rst,
      clk => clk,
      en => en_er,
      din => er_din, 
      miso => miso,
      sclk => sclk,
      mosi => mosi,
      dout => er_dout,
      busy => er_busy
    );

  process(clk, rst)
  begin
    if rst = '0' then
	 --ss au repos est à 1, le slave n'est pas séléctionner
      ss <= '1';
      busy <= '0';
		echange <= 1;
		--temps de préparation indiqué en fichier pmdjoystick de 15.
		cpt_echange <= 15;
		er_din <= (others => '0');
		etat <= repos;
    elsif rising_edge(clk) then
      case etat is
        -- État repos : en attente d'un ordre de transmission
        when repos =>
          if en = '1' then
			 --peu importe l'échange, er_din est toujours de cette forme
			 --on le met donc dès le passe de repos vers wait_echange
				er_din <= "100000" & led2 & led1;
            busy <= '1'; --Indique qu'on est occupé
            ss <= '0';             -- Sélectionne l'esclave
            cpt_echange <= 15;     -- Temps d'attente initial pour l'esclave
				echange <= 1;
            etat <= wait_echange;
          end if;

        -- État wait_echange : Attend que l'esclave soit prêt
        when wait_echange =>
          if cpt_echange > 0 then
            cpt_echange <= cpt_echange - 1;
          elsif cpt_echange = 0 then
            en_er <= '1';         -- Active er_1octet
            etat <= echange_oct;
          end if;
        -- État echange : Effectue l'échange d'octets
        when echange_oct =>
          en_er <= '0';
          if ( er_busy = '0' and en_er = '0' )  then  -- Attendre que er_1octet termine
            -- Lecture des données reçues selon l'état d'échange
            case echange is
				when 1 =>
				--envoie des 8 bits de poids faible
				  x(7 downto 0) <= er_dout;
				  echange <= echange + 1; --On incrémente échange pour passer au prochain octet
				  cpt_echange <= 10; --Délai de 3 cycles entre chaque octet
				  etat <= wait_echange;
            when 2 =>
				--envoie des 2 bits de poids fort
				  x(9 downto 8) <= er_dout(1 downto 0);
				  echange <= echange + 1; --On incrémente échange pour passer au prochain octet
				  cpt_echange <= 10; --Délai de 3 cycles entre chaque octet
				  etat <= wait_echange;
				when 3 =>	
					--envoie des 8 bits de poids faible
				  y(7 downto 0) <= er_dout;
				  echange <= echange + 1; --On incrémente échange pour passer au prochain octet
				  cpt_echange <= 10; --Délai de 3 cycles entre chaque octet
				  etat <= wait_echange;
				when 4 =>
				--envoie des 2 bits de poids fort
				  y(9 downto 8)<= er_dout(1 downto 0); 
				  echange <= echange + 1; --On incrémente échange pour passer au prochain octet
				  cpt_echange <= 10; --Délai de 3 cycles entre chaque octet
				  etat <= wait_echange;
				when 5 => 				         
				  Buttonstick <= er_dout(0);
				  Button1 <= er_dout(1);
				  Button2 <= er_dout(2);
				  busy <= '0';
				  ss <= '1';          -- Fin de la transmission             
              etat <= repos; 
				when others =>
					null;
			end case;
			end if;
      end case;
    end if;
  end process;

end behavioral;



