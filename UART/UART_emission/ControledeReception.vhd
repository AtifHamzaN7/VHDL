----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:57:41 01/08/2025 
-- Design Name: 
-- Module Name:    ControledeReception - Behavioral 
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

entity ControledeReception is
    Port ( tmpclk : in  STD_LOGIC;
           tmprxd : in  STD_LOGIC;
           read : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           FErr : out  STD_LOGIC;
           OErr : out  STD_LOGIC;
           DRdy : out  STD_LOGIC;
           data : out  STD_LOGIC_VECTOR (7 downto 0));
end ControledeReception;

architecture Behavioral of ControledeReception is
	type t_etat IS (repos, etatdata, verif);
	signal etat : t_etat := repos;

begin
	process(clk,reset)
		variable cpt : natural; -- Compteur de bits
		variable parite : std_logic;	-- Variable pour stocker la parité

  begin
  if reset = '0' then
      Ferr <= '0';
      OErr <= '0';
      DRdy <= '0';
      data <= (others => '0');
		
    elsif rising_edge(clk) then
	 case etat is
        when repos =>
          Ferr <= '0';
          OErr <= '0';
          DRdy <= '0';
          if tmpclk = '1' and tmprxd = '0' then
            cpt := 9; -- 8 bits de data + bit de parité + bit de stop ( comptage de 0)
				parite := '0';
            etat <= etatdata;
          end if;
			 
			 when etatdata =>
          if tmpclk = '1' then
            if cpt > 1 then
              data(cpt - 2) <= tmprxd; --on récupère le bit
				  parite := parite xor tmprxd; --Mise à jour du bit parite
				  cpt := cpt - 1;--On décremente le cpt
				elsif (cpt = 1 and tmprxd /= parite) then -- bit de parité erroné
					Ferr <= '1';
					cpt := cpt - 1;
					etat <= repos;
            elsif (cpt = 0 and tmprxd = '0') then -- bit de stop erroné
              Ferr <= '1';
              etat <= repos;
            else -- bon bit de parité et bon bit de start
              DRdy <= '1';
              etat <= verif;
            end if;
          end if;
			 
			 when verif =>
				 DRdy <= '0';
				 if (read = '0') then
					OErr <= '1';
				 end if;
				etat <= repos;
			end case;
		end if;
	end process;

end Behavioral;

