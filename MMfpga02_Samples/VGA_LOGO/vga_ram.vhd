----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o.	www.propox.com 
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name: 	 VGA_RAM	
--
-- Description: 
-- VGA and BlockRam Test
--
---------------------------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity VGA_RAM is

port( 
		CLK_50MHz      : in  std_logic;					        
		reset          : in  std_logic;
		
		SW             : in  std_logic_vector(3 downto 0);
		
		HSYNC,VSYNC  	: out std_logic;					        
		RED 			   : out std_logic_vector(2 downto 0);	  
		GREEN 		   : out std_logic_vector(2 downto 0);	  
		BLUE  		   : out std_logic_vector(2 downto 0)	  
);

end VGA_RAM;

architecture behavior of VGA_RAM is

constant H_max    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(799,10); -- 799 jest max liczba probek
constant V_max    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(524,10); -- 524 jest max liczba linii
signal Hcnt, Vcnt : std_logic_vector(9 downto 0);

signal licznik_clk : std_logic;
signal video_clk   : std_logic;
signal CLK_50Hz     : std_logic;

signal data_r        : std_logic_vector(2 downto 0);
signal data_g        : std_logic_vector(2 downto 0);
signal data_b        : std_logic_vector(2 downto 0);

signal addr_ram      : std_logic_vector(13 downto 0); 
signal data          : std_logic_vector(7 downto 0);

signal pion          : integer range 0 to 479;
signal poziom        : integer range 0 to 639;

component ram
	port (
		addr	: IN 	std_logic_VECTOR(13 downto 0);
		clk	: IN 	std_logic;
		dout	: OUT std_logic_VECTOR(7 downto 0));
end component;


begin

propox : ram
			port map (
					addr 	=> addr_ram,
					clk 	=> CLK_50MHz,
					dout 	=> data
						);

-- dane
RED   <= data_r when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";
GREEN <= data_g when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";
BLUE  <= data_b when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";
			
video_clk <= licznik_clk;


-- 25[MHz]
process (CLK_50MHz,reset)
variable licznik : integer range 0 to 1000000;
begin
	if (reset = '0') then
		licznik := 0;
		licznik_clk <= '0';
		CLK_50Hz <= '0';
	elsif rising_edge(CLK_50MHz)then
		licznik_clk <= not licznik_clk;
		licznik := licznik + 1;
		if(licznik=1000000)then
			licznik := 0;
			CLK_50Hz <= not CLK_50Hz;
		end if;
	end if;
end process;

-- motion direction
process(CLK_50Hz,reset)
begin
	if (reset = '0') then
		pion   <= 209;
		poziom <= 193;
	elsif rising_edge(CLK_50Hz)then
		-- dol
		-- down
		if( SW(3)='0')then
			pion <= pion + 1;
			if(pion=416)then
				pion <= 0;
			end if;
		end if;
		-- gora
		-- up
		if( SW(2)='0')then
			pion <= pion - 1;
			if(pion=0)then
				pion <= 416;
			end if;
		end if;
		-- lewo
		-- left
		if( SW(1)='0')then
			poziom <= poziom + 1;
			if(poziom=639)then
				poziom <= 0;
			end if;
		end if;
		-- prawo
		-- right
		if( SW(0)='0')then
			poziom <= poziom - 1;
			if(poziom=0)then
				poziom <= 639;
			end if;
		end if;		
	end if;
end process;


-- odczyt pamieci
-- memory reading
process (CLK_50MHz,reset)
begin
	if (reset = '0') then
		addr_ram <= (others => '0');
	elsif rising_edge(CLK_50MHz) then
			
		if( ((Hcnt < poziom+255)  and (Hcnt >= poziom)) and ((Vcnt < pion+63)  and (Vcnt >= pion)) )then
			data_r   <= '1' & data(7 downto 6);
			data_g   <= data(5 downto 3);
			data_b   <= data(2 downto 0);
			addr_ram <= (Vcnt(5 downto 0)-pion) & (Hcnt(7 downto 0)-poziom);
		else
			data_r   <= "100";
			data_g   <= "111";
			data_b   <= "111";		
		end if;
		
	end if;	
end process;


-- Generacja odpowiednich przebiegów synchronizacji
-- Synchronization signals
GENERATOR_VIDEO: Process(video_clk,reset)

begin

if (reset = '0') then
	
	Hcnt <= (others => '0');
	Vcnt <= (others => '0');
	
elsif (video_clk'event and video_clk = '1') then

-- Sygnal Hcnt zlicza ilosc pixeli (640 plus dodatkowe pixele na synchronizacje)
-- pixel count
	if (Hcnt >= H_max) then
		Hcnt <= "0000000000";
	else
		Hcnt <= Hcnt + "0000000001";
	end if;

-- Generator poziomego sygnalu synchronizacji
-- horizontal synchronization
	if (Hcnt <= 755) and (Hcnt >= 659) then
		hsync <= '0';
	else
		hsync <= '1';
	end if;

-- Sygnal Vcnt zlicza ilosc pionowych pixeli (480 + dodatkowe wymagane do synchronizacji)
-- line count
	if (Vcnt >= V_max) and (Hcnt >= 699) then
		Vcnt <= "0000000000";
	else 
		if (Hcnt = 699) then
			Vcnt <= Vcnt + "0000000001";
		end if;
	end if;

-- Generator pionowego sygnalu synchronizacji
-- vertical synchronization
	if (Vcnt <= 494) and (Vcnt >= 493) then
		vsync <= '0';
	else
		vsync <= '1';
	end if;
	
end if;
end process GENERATOR_VIDEO;

end behavior;