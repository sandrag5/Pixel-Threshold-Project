-- Detects the color of objects, for each color, if it is <threshold it is assigned a 0, if larger, it is not changed
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity test is
port( clk, reset, VGA_VS, VGA_HS, vid_datavalid: in std_logic;
			key: in std_logic_vector(3 downto 0);
			SW: in std_logic_vector(3 downto 0);	
			Ri, Gi, Bi: in std_logic_vector(7 downto 0);
			Rth, Gth, Bth: out std_logic_vector(7 downto 0);
			Ro, Go, Bo: out std_logic_vector(7 downto 0);
			LED: out std_logic_vector(3 downto 0)
			);
end entity test;

architecture logic of test is

signal R_reg, G_reg, B_reg: unsigned (7 downto 0);
signal R_next, G_next, B_next: unsigned (7 downto 0);

--////////////////////////////////////////////////////////////////////////////
signal R_offset_reg, G_offset_reg, B_offset_reg: unsigned (7 downto 0);
signal R_offset_next, G_offset_next, B_offset_next: unsigned (7 downto 0);
signal R_th, G_th, B_th: unsigned (7 downto 0);

--////////////////////////////////////////////////////////////////////////////

-- type cast to unsigned to allow arithmetic operations
signal uR, uG, uB: unsigned (7 downto 0);


begin
	
	process(reset, clk)
	begin
		
		if reset='0' then 
			R_reg<=(others=>'0');
			G_reg<=(others=>'0');
			B_reg<=(others=>'0');
			
		elsif rising_edge(clk) then
			R_reg<=R_next;
			G_reg<=G_next;
			B_reg<=B_next;
		end if;
		
	end process;

	
	-- type cast inputs to unsigned
	uR<=unsigned(Ri);
	uG<=unsigned(Gi);
	uB<=unsigned(Bi);
	
	
	--////////////////////////////////////////////////////////////
	-- your code here, store final results in R_next, G_next, B_next
	--///////////////////////////////////////////////////////////
	
	process (reset, key)
	begin
		if reset = '0' then 
			R_offset_reg <= (others => '0');
			G_offset_reg <= (others => '0');
			B_offset_reg <= (others => '0');

		else
		
			if rising_edge (key(2)) then 
				R_offset_reg <= R_offset_next;
				
			end if;
			
			if rising_edge (key(1)) then 
				G_offset_reg <= G_offset_next;
			end if;
			
			if rising_edge (key(0)) then 
				B_offset_reg <= B_offset_next;
			end if;
		END IF;
	end process;
	
	-- Add or subtract 16 color levels if key is pressed
	
	R_offset_next <= R_offset_reg + 16 when SW(2) ='1' else R_offset_reg - 16;
	G_offset_next <= G_offset_reg + 16 when SW(1) ='1' else G_offset_reg - 16;
	B_offset_next <= B_offset_reg + 16 when SW(0) ='1' else B_offset_reg - 16;
	
	-- To avoid overflow
	
	R_th <= R_offset_next when SW(3) = '1'else (OTHERS=>'1') when uR + R_offset_reg < uR else uR + R_offset_reg;
	G_th <= G_offset_next when SW(3) = '1' else (OTHERS=>'1') when uG + G_offset_reg < uG else uG + G_offset_reg;
	B_th <= B_offset_next when SW(3) = '1' else (OTHERS=>'1') when uB + B_offset_reg < uB else uB + B_offset_reg;

	process(R_th, uR, G_th, uG, B_th, uB)
	begin
		if uR < R_th or uG < G_th or uB < B_th then
			R_next <= (others => '0');
			G_next <= (others => '0');
			B_next <= (others => '0');
		else
			R_next <= uR;
			G_next <= uG;
			B_next <= uB;
		end if;
	end process;
	
	Rth <= std_logic_vector(R_offset_reg);
	Gth <= std_logic_vector(G_offset_reg);
	Bth <= std_logic_vector(B_offset_reg);
	
	--/////////////////////////////////////////////////////////////
	-- the output of this entity
	Ro<= (others => '0') when (VGA_VS = '0' or VGA_HS = '0') else std_logic_vector(R_reg);
	Go<= (others => '0') when (VGA_VS = '0' or VGA_HS = '0') else std_logic_vector(G_reg);
	Bo<= (others => '0') when (VGA_VS = '0' or VGA_HS = '0') else std_logic_vector(B_reg);

	
	
end architecture logic;
