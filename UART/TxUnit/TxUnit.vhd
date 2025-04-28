library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic; -- Horloge et signal de réinitialisation
    enable : in std_logic;		-- Signal d'activation de la transmission
    ld : in std_logic;	-- Signal de chargement 
    txd : out std_logic;	 -- Sortie de transmission de données
    regE : out std_logic;	--le registre d’´emission
    bufE : out std_logic;	
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is
	type t_etat is (repos, etat1, etat2, etat3, etat4); --Les états de l'automate
	signal etat : t_etat := repos; -- Signal pour stocker l'état actuel (initialisé à 'repos')
	
	signal regEnable : std_logic;	
	signal bufEnable : std_logic;
	
	signal regT : std_logic_vector(7 downto 0); -- Registre transmission
	signal bufT : std_logic_vector(7 downto 0); --Buffer transmission
	

begin

	regE <= regEnable;
	bufE <= bufEnable;

	process(clk, reset)
		variable parite : std_logic;	-- Variable pour stocker la parité
		variable cpt_bit : integer; -- Compteur pour les bits à transmettre
	begin
    if reset = '0' then
		regEnable <= '1'; --Au départ, le registre est libre
		bufEnable <= '1'; --Au départ, le buffer est libre
		txd <= '1'; --txd libre
		etat <= repos; -- L'état passe à 'repos'
		
	 elsif rising_edge(clk) then
      case etat is
			when repos => 
			if ld = '1' then
				bufT <= data;		-- Charge les données dans le tampon
				bufEnable <= '0';	--buffer plein
				etat <= etat1; -- Passe à l'état 'etat1'
			end if;
			
			when etat1 => 
			regT <= bufT; -- Copie les données du buffer dans le registre
			regEnable <= '0'; --Registre plein
			bufEnable <= '1'; --Buffer vide
			etat <= etat2;	-- Passe à l'état 'etat2'
			
			when etat2 =>
			if ( ld = '1' and bufEnable = '1') then
			 bufT <= data; --Vérifier si une seconde data doit être envoyé pendant l'émission de la première.
			 bufEnable <= '0';
			end if;		
			
			if enable = '1' then
			txd <= '0';		--ENvoi du bit de start
			cpt_bit := 7;	--Initialisation du compteur des bits
			parite := '0'; --Initialisation du bit parité
			etat <= etat3; -- Passe à l'état 'etat3'
			end if;
					
			when etat3 => 
				if ( ld = '1' and bufEnable = '1') then
				 bufT <= data; --Vérifier si une seconde data doit être envoyé pendant l'émission de la première.
				 bufEnable <= '0';
				end if;	
				
				if enable = '1' then
					if cpt_bit >= 0 then 
						txd <= regT(cpt_bit); --Envoi du bit
						parite := parite xor regT(cpt_bit); --Mise à jour du bit parite
						cpt_bit := cpt_bit - 1;		--Decrementer le compteur bit			
					else
						regEnable <= '1'; --Fin de transmission de l'octet, le registre est désormais libre.
						txd <= parite; --Envoie du bit parite
						etat <= etat4;	-- Passe à l'état 'etat4'
					end if;
				end if;
								
			when etat4 => 
					if ( ld = '1' and bufEnable = '1') then
						 bufT <= data; --Vérifier si une seconde data doit être envoyé pendant l'émission de la première.
						 bufEnable <= '0';
					end if;					
					if enable = '1' then
						if bufEnable = '1' then
							txd <= '1'; --Envoi du bit de stop
							etat <= repos; -- Passe à l'état repos
						else
							txd <= '1'; --txd libre
							etat <= etat1; -- Passe à l'état 'etat1'
						end if;	
					end if;
			end case;
		end if;
	end process;						
end behavorial;
