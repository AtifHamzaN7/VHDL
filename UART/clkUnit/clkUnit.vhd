library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is


	COMPONENT diviseurClk
	generic(facteur : natural);
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
	END COMPONENT;

begin

Inst_diviseurClk: diviseurClk 
GENERIC MAP(16) 
PORT MAP(
		clk => clk,
		reset => reset,
		nclk => enableTX
	);

enableRX <= clk and reset;
end behavorial;
