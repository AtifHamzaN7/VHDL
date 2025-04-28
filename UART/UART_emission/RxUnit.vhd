library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    read             : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic);
end RxUnit;

architecture RxUnit_arch of RxUnit is

	COMPONENT Compteur16
	PORT(
		enable : IN std_logic;
		reset : IN std_logic;
		rxd : IN std_logic;
		tmprxd : OUT std_logic;          
		tmpclk : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT ControledeReception
	PORT(
		tmpclk : IN std_logic;
		tmprxd : IN std_logic;
		read : IN std_logic;
		reset : IN std_logic;
		clk : IN std_logic;          
		FErr : OUT std_logic;
		OErr : OUT std_logic;
		DRdy : OUT std_logic;
		data : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
signal tmpclkinter : std_logic;
signal tmprxdinter : std_logic;

begin 
Inst_Compteur16: Compteur16 PORT MAP(
		enable => enable,
		reset => reset,
		rxd => rxd,
		tmpclk => tmpclkinter,
		tmprxd => tmprxdinter
	);

Inst_ControledeReception: ControledeReception PORT MAP(
		tmpclk => tmpclkinter,
		tmprxd => tmprxdinter,
		read => read,
		reset => reset,
		clk => clk,
		FErr => Ferr,
		OErr => OErr,
		DRdy => DRdy,
		data => data
	);


end RxUnit_arch;
