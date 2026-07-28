----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o.	www.porpox.com 
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name: 	 VGA_RAM	
--
-- Description: 
-- Display Company wallpaper on VGA
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

signal data_r        : std_logic_vector(2 downto 0);
signal data_g        : std_logic_vector(2 downto 0);
signal data_b        : std_logic_vector(2 downto 0);

signal addr_ram      : std_logic_vector(16 downto 0); 
signal data          : std_logic_VECTOR(0 downto 0);


component tapeta
	port (
		addr	: IN 	std_logic_VECTOR(16 downto 0);
		clk	: IN 	std_logic;
		dout	: OUT std_logic_VECTOR(0 downto 0)
		  );
end component;


begin

propox : tapeta
			port map (
					addr 	=> addr_ram,
					clk 	=> CLK_50MHz,
					dout 	=> data
						);

-- dane
-- data
RED   <= data_r when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";
GREEN <= data_g when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";
BLUE  <= data_b when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";
			
 
video_clk <= licznik_clk;


-- 25[MHz]
process (CLK_50MHz,reset)
begin
	if (reset = '0') then
		licznik_clk <= '0';
	elsif rising_edge(CLK_50MHz)then
		licznik_clk <= not licznik_clk;
	end if;
end process;


-- odczyt pamieci
-- memory reading
process (CLK_50MHz,reset)
begin
	if (reset = '0') then
		addr_ram <= (others => '0');
	elsif rising_edge(CLK_50MHz) then
			
		if( ((Hcnt < 577)  and (Hcnt >= 65)) and ((Vcnt < 369)  and (Vcnt >= 113)) )then
			data_r   <= data & data & data;
			data_g   <= data & data & data;
			data_b   <= data & data & data;
			addr_ram <= (Vcnt(7 downto 0)-113) & (Hcnt(8 downto 0)-65);
		else
			data_r   <= "000";
			data_g   <= "000";
			data_b   <= "000";		
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