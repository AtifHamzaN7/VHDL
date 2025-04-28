----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:19:56 01/08/2025 
-- Design Name: 
-- Module Name:    Compteur16 - Behavioral 
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

entity Compteur16 is
    Port ( enable : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rxd : in  STD_LOGIC;
           tmpclk : out  STD_LOGIC;
           tmprxd : out  STD_LOGIC);
end Compteur16;

architecture behavioral of Compteur16 is

	-- attente: attente de réception de bit start, donc les 8 fronts
   -- compter: compter 16 fronts de enable entre chaque envoie de bit
   -- verif: cet état met à jour tmpclk à '0', lit le bit de données rxd 
	--et passe à l'état compter si des bits restent encore à lire, ou à l'état idle si tous les bits ont été lus.
  type t_etat IS (attente, compter, verif);
  signal etat : t_etat := attente;

begin
	process(enable,reset)
		variable nb_bits : natural; -- nombre de bits restants  lire
		variable  cpt : natural; -- compteur d'attente 
  begin
  if ( reset = '0') then 
	tmpclk <= '0';
	tmprxd <= '1';
	nb_bits := 11;
	cpt := 8;
	etat <= attente;
	elsif rising_edge(enable) then
      case etat is
		when attente =>
			cpt := 8; --Attente de 8 fronts après réception du bit de start
			nb_bits := 11; -- 11 bits : 8 data + parité + stop
			if (rxd = '0') then
				etat <= compter;
			end if;
			
		when compter =>
			if (cpt = 0) then	
			nb_bits := nb_bits - 1;
			tmpclk <= '1';
			tmprxd <= rxd;
			cpt := 15; --Compter 16 fronts
			etat <= verif;
			else
			cpt := cpt - 1;
			end if;
	
		when verif =>
			tmpclk <= '0';
			if (nb_bits = 0) then
				etat <= attente;
			else
				cpt := cpt - 1;
            etat <= compter;
          end if;
      end case;
    end if;
  end process;
end behavioral;

			
			

