library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MasterOpl is
  port ( rst : in std_logic;
         clk : in std_logic;
         en : in std_logic;
         v1 : in std_logic_vector (7 downto 0);
         v2 : in std_logic_vector(7 downto 0);
         miso : in std_logic;
         ss   : out std_logic;
         sclk : out std_logic;
         mosi : out std_logic;
         val_xor : out std_logic_vector (7 downto 0);
         val_and : out std_logic_vector (7 downto 0);
         val_or : out std_logic_vector (7 downto 0);
         busy : out std_logic);
end MasterOpl;

architecture behavior of MasterOpl is
  -- Déclaration des états
  type t_etat is (repos, wait_slave, echange_oct);
  signal etat : t_etat := repos;

  -- Signaux internes
  signal en_er : std_logic;         -- Activation du composant er_1octet
  signal er_busy : std_logic;              -- Signal busy du composant er_1octet
  signal er_dout : std_logic_vector(7 downto 0); -- Données reçues de er_1octet
  signal din : std_logic_vector(7 downto 0); -- Donnée à envoyer
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
      din => din, 
      miso => miso,
      sclk => sclk,
      mosi => mosi,
      dout => er_dout,
      busy => er_busy
    );

  process(clk, rst)
  begin
    if rst = '0' then
		--ss au repos à 1, le slave n'est pas séléctionné
      ss <= '1';
      busy <= '0';
		-- Initialisation des valeurs par des U au départ
      val_xor <= (others => 'U');
      val_and <= (others => 'U');
      val_or <= (others => 'U');
		--Echange intialisé par 1 pour indiquer 
		--qu'on va commencer par le tout premier échange d'octet.
		echange <= 1;
		--Le temps d'attente pour la préparation du slave
		cpt_echange <= 10;
		etat <= repos;
    elsif rising_edge(clk) then
      case etat is
        -- État repos : en attente d'un ordre de transmission
        when repos =>
          if en = '1' then
            busy <= '1'; --Indique qu'on est occupé
            ss <= '0';             -- Sélectionne l'esclave
            cpt_echange <= 10;     -- Temps d'attente initial pour l'esclave
				echange <= 1;
            etat <= wait_slave;
          end if;

        -- État wait_slave : Attend que l'esclave soit prêt
        when wait_slave =>
          if cpt_echange > 0 then
			 --On decremente cpt_echange jusqu'à atteindre 0
            cpt_echange <= cpt_echange - 1;
          elsif cpt_echange = 0 then
            en_er <= '1';         -- Active er_1octet
				-- Affectation de `din` selon l'octet d'échange
            if echange = 1 then
              din <= v1;
            elsif echange = 2 then
              din <= v2;
				else
					din <= (others => 'U');
            end if;
            etat <= echange_oct;
          end if;
        -- État echange : Effectue l'échange d'octets
        when echange_oct =>
          en_er <= '0';
          if ( er_busy = '0' and en_er = '0' and echange < 3 )  then  -- Attendre que er_1octet termine
            -- Lecture des données reçues selon l'état d'échange
            if echange = 1 then				  
				  val_xor <= er_dout;
            elsif echange = 2 then
				  val_and <= er_dout;
				end if;
				  echange <= echange + 1; --On incrémente échange pour passer au prochain octet
				  cpt_echange <= 3; --Délai de 3 cycles entre chaque octet
				  etat <= wait_slave;
				  
          elsif ( er_busy = '0' and en_er = '0' and echange >= 3 ) then 
				  val_or <= er_dout; --Réception de la dernière val_or.
				  busy <= '0';
				  ss <= '1';          -- Fin de la transmission             
              etat <= repos;                     				
          end if;
      end case;
    end if;
  end process;

end behavior;

