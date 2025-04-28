library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Nexys4Joystick is
  port (
    -- les 16 switchs
    swt : in std_logic_vector (15 downto 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : in std_logic;
    -- horloge
    mclk : in std_logic;
    -- les 16 leds
    led : out std_logic_vector (15 downto 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : out std_logic_vector (7 downto 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : out std_logic_vector (7 downto 0);
	 --les valeurs ajoutées pour connecter le joystick à la nexys4
	 ss : out std_logic;
	 miso : in std_logic;
	 mosi : out std_logic;
	 sclk : out std_logic
  );
end Nexys4Joystick;

architecture synthesis of Nexys4Joystick is

component MasterJoystick 
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

end component;

component All7Segments 
    Port ( clk : in  std_logic;
           reset : in std_logic;
           e0 : in std_logic_vector (3 downto 0);
           e1 : in std_logic_vector (3 downto 0);
           e2 : in std_logic_vector (3 downto 0);
           e3 : in std_logic_vector (3 downto 0);
           e4 : in std_logic_vector (3 downto 0);
           e5 : in std_logic_vector (3 downto 0);
           e6 : in std_logic_vector (3 downto 0);
           e7 : in std_logic_vector (3 downto 0);
           an : out std_logic_vector (7 downto 0);
           ssg : out std_logic_vector (7 downto 0));
end component;

component diviseurClk 
  -- facteur : ratio entre la fréquence de l'horloge origine et celle
  --           de l'horloge générée
  --  ex : 100 MHz -> 1Hz : 100 000 000
  --  ex : 100 MHz -> 1kHz : 100 000
  generic(facteur : natural);
  port (
    clk, reset : in  std_logic;
    nclk       : out std_logic);
end component;
 
signal reset : std_logic ;
signal en : std_logic;

signal busy : std_logic;
signal nclk: std_logic;

signal x_pos : std_logic_vector (9 downto 0);
signal y_pos : std_logic_vector (9 downto 0);
signal btnStick, btn1, btn2 : std_logic;

begin

  -- connexion du (des) composant(s) avec les ports de la carte
 
 Inst_MasterJoystick: MasterJoystick PORT MAP(
		rst => reset,
		clk => nclk,
		en => en,
		led1 => swt(0),  -- Le switch 0 commande la LED1 du joystick,
		led2 => swt(1),  -- Le switch 1 commande la LED2 du joystick,
		miso => miso,
		ss => ss,
		sclk => sclk,
		mosi => mosi,
		x => x_pos,
		y => y_pos,
		Buttonstick => btnStick,
		Button1 => btn1,
		Button2 => btn2,
		busy => busy
	);
	
	Inst_All7Segments: All7Segments PORT MAP(
		clk => mclk,
		reset => reset,
		e0 => x_pos(3 downto 0), --on affiche les x,y via le all7segments
		e1 => x_pos(7 downto 4),
		e2 => "00" & x_pos(9 downto 8),
		e3 => "0000",
		e4 => y_pos(3 downto 0),
		e5 => y_pos(7 downto 4),
		e6 => "00" & y_pos(9 downto 8),
		e7 => "0000",
		an => an,
		ssg => ssg
	);
	
	Inst_diviseurClk: diviseurClk 
	GENERIC MAP(100) --facteur de 100 pour passer de 100MHZ à 1MHZ
	PORT MAP(
		clk => mclk,
		reset => reset,
		nclk => nclk
	);
    
 -- Allumer les LEDs de la carte Nexys4 avec des boutons du joystick
    led(0) <= btnStick;  -- LED 0 allumée si le bouton central du joystick est pressé
    led(1) <= btn1;      -- LED 1 allumée si le bouton 1 du joystick est pressé
    led(2) <= btn2;      -- LED 2 allumée si le bouton 2 du joystick est pressé
	 
	 -- 13 leds éteintes, 3 sont allumées graçe au bouttons du JoyStick
	led(15 downto 3) <= (others => '0');
	-- pour éviter de toujours appuyer sur le btnC, on donne à reset not btnC
	reset <= not btnC;
	--Le switch 2 contrôle le comportement de en
	en <= swt(2);
  
 end synthesis;
