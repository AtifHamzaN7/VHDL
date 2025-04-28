library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity er_1octet is
  port ( rst : in std_logic ;
         clk : in std_logic ;
         en : in std_logic ;
         din : in std_logic_vector (7 downto 0) ;
         miso : in std_logic ;
         sclk : out std_logic ;
         mosi : out std_logic ;
         dout : out std_logic_vector (7 downto 0) ;
         busy : out std_logic);
end er_1octet;

architecture behavioral of er_1octet is

	type t_etat is (repos, reception_bit, envoi_bit);
	signal etat : t_etat;

begin

	process(clk, rst)
		variable cpt_bit : natural;
		variable rg_din : std_logic_vector(7 downto 0);
		
		
	begin
	if (rst = '0') then
	-- sclk est au repos à '1'
	sclk <= '1';
	mosi <= 'U';
	dout <= (others => 'U');
	-- busy est au repos à '0'
	busy <= '0';	
	-- le registre d'envoi
   rg_din := (others => 'U');	
	cpt_bit := 7;
	-- état initialisé à repos	
	etat <= repos;
	
	elsif(rising_edge(clk)) then
	
				case etat is 
					when repos =>
						if(en = '1') then		
							-- Mise à jour des valeurs busy et sclk.
							busy <= '1';
							sclk <= '0';
							rg_din := din;
							cpt_bit := 7;
							-- Envoie du premier bit
							mosi <= rg_din(cpt_bit);	
							-- Etat passe à reception_bit
							etat <= reception_bit;
						end if;
					when reception_bit =>			
							sclk <= '1';
							-- Utilisation du même registre pour la réception aussi.
							rg_din(cpt_bit) := miso;
						if (cpt_bit = 0) then
							--l'octet a été transmis entierement
							busy <= '0';
							-- Réception de l'octet via le rg_din
							dout <= rg_din;
							-- On repasse à repos puisqu'on a finit transmission et réception.
							etat <= repos;
						else 
							etat <= envoi_bit;
						end if;
					
					when envoi_bit =>
						sclk <= '0';
						--Le cpt_bit est decrementé
						cpt_bit := cpt_bit - 1;
						--Envoie du bit via mosi
						mosi <= rg_din(cpt_bit);
						-- On passe à la réception.
						etat <= reception_bit;
				
			end case;
		end if;
	end process;
					
end behavioral;
