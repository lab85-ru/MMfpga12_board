----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o.  www.propox.com
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name:    VGA	
--
-- Description: 
-- Test VGA
--
---------------------------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity VGA is

port( 
		CLK_50MHz      : in  std_logic;					        
		reset          : in  std_logic;

		SW_i				: in  std_logic_vector(6 downto 0);
		SW             : in  std_logic_vector(1 downto 0);
		
		HSYNC,VSYNC  	: out std_logic;					        
		RED 			   : out std_logic_vector(2 downto 0);	  
		GREEN 		   : out std_logic_vector(2 downto 0);	  
		BLUE  		   : out std_logic_vector(2 downto 0)	  
);

end VGA;

architecture behavior of VGA is

constant H_max : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(799,10); -- 799 jest max liczba probek
constant V_max : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(524,10); -- 524 jest max liczba linii

signal video_out              : std_logic_vector(8 downto 0);
signal Hcnt, Vcnt             : std_logic_vector(9 downto 0);

signal licznik_clk : std_logic;
signal video_clk   : std_logic;

signal data_r        : std_logic_vector(2 downto 0);
signal data_g        : std_logic_vector(2 downto 0);
signal data_b        : std_logic_vector(2 downto 0);

signal CLK_2Hz       : std_logic;

begin

--color bars on vga monitor
video_out <=  "111111111" when ((Hcnt < 80)  and (Hcnt >= 0))	else
				  "000111111" when ((Hcnt < 160) and (Hcnt >= 80))  else
				  "111000111" when ((Hcnt < 240) and (Hcnt >= 160)) else
				  "000000111" when ((Hcnt < 320) and (Hcnt >= 240)) else
				  "111111000" when ((Hcnt < 400) and (Hcnt >= 320)) else
				  "000111000" when ((Hcnt < 480) and (Hcnt >= 400)) else
				  "111000000" when ((Hcnt < 560) and (Hcnt >= 480)) else
				  "000000000" when ((Hcnt < 640) and (Hcnt >= 560)) else
				  "000000000"; -- blanking level

-- dane
RED   <= Video_out(8 downto 6) when (SW_i(0)='1' and SW_i(1)='1' and SW_i(2)='1' and SW_i(3)='1' and SW_i(4)='1' and SW_i(5)='1' and SW_i(6)='1') else 
			data_r                when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";
GREEN <= Video_out(5 downto 3) when (SW_i(0)='1' and SW_i(1)='1' and SW_i(2)='1' and SW_i(3)='1' and SW_i(4)='1' and SW_i(5)='1' and SW_i(6)='1') else 
			data_g                when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";

BLUE  <= Video_out(2 downto 0) when (SW_i(0)='1' and SW_i(1)='1' and SW_i(2)='1' and SW_i(3)='1' and SW_i(4)='1' and SW_i(5)='1' and SW_i(6)='1') else 
			data_b                when ((Hcnt < 640)  and (Hcnt >= 0)) else
			"000";

 
video_clk <= licznik_clk;


-- 25[MHz]
process (CLK_50MHz,reset)
variable licznik : integer range 0 to 50000000;
begin
	if (reset = '0') then
	   licznik := 0;
		licznik_clk <= '0';
		CLK_2Hz <= '0';
	elsif rising_edge(CLK_50MHz)then
		licznik := licznik + 1;
		if(licznik=25000000)then
		   licznik := 0;
			CLK_2Hz <= not CLK_2Hz;
		end if;
		licznik_clk <= not licznik_clk;
	end if;
end process;

-- saturation changing
process (CLK_2Hz,reset)
begin
	if (reset = '0') then
		data_r <= "000";
		data_g <= "000";
		data_b <= "000";
	elsif rising_edge(CLK_2Hz) then
	
		-- skala szarosci --
		-- gray scale --
		if( SW_i(0)='0' )then
			if( SW(1)='0' )then			
				data_r <= data_r + 1;
				data_g <= data_g + 1;
				data_b <= data_b + 1;
			elsif( SW(0)='0' )then
				data_r <= data_r - 1;
				data_g <= data_g - 1;
				data_b <= data_b - 1;
			end if;
		-- blekitny --
		elsif( SW_i(1)='0' )then
			if( SW(1)='0' )then			
				data_r <= "000";
				data_g <= data_g + 1;
				data_b <= data_b + 1;
			elsif( SW(0)='0' )then
				data_r <= "000";
				data_g <= data_g - 1;
				data_b <= data_b - 1;
			end if;
		-- purpurowy --
		elsif( SW_i(2)='0' )then
			if( SW(1)='0' )then			
				data_r <= data_r + 1;
				data_g <= "000";
				data_b <= data_b + 1;
			elsif( SW(0)='0' )then
				data_r <= data_r - 1;
				data_g <= "000";
				data_b <= data_b - 1;
			end if;
		-- niebieski --
		-- blue --
		elsif( SW_i(3)='0' )then
			if( SW(1)='0' )then			
				data_r <= "000";
				data_g <= "000";
				data_b <= data_b + 1;
			elsif( SW(0)='0' )then
				data_r <= "000";
				data_g <= "000";
				data_b <= data_b - 1;
			end if;
		-- zolty --
		-- yellow --
		elsif( SW_i(4)='0' )then
			if( SW(1)='0' )then			
				data_r <= data_r + 1;
				data_g <= data_g + 1;
				data_b <= "000";
			elsif( SW(0)='0' )then
				data_r <= data_r - 1;
				data_g <= data_g - 1;
				data_b <= "000";
			end if;
		-- zielony --
		-- green --
		elsif( SW_i(5)='0' )then
			if( SW(1)='0' )then			
				data_r <= "000";
				data_g <= data_g + 1;
				data_b <= "000";
			elsif( SW(0)='0' )then
				data_r <= "000";
				data_g <= data_g - 1;
				data_b <= "000";
			end if;
		-- czerwony --
		-- red --
		elsif( SW_i(6)='0' )then
			if( SW(1)='0' )then			
				data_r <= data_r + 1;
				data_g <= "000";
				data_b <= "000";
			elsif( SW(0)='0' )then
				data_r <= data_r - 1;
				data_g <= "000";
				data_b <= "000";
			end if;
		else
			data_r <= "000";
			data_g <= "000";
			data_b <= "000";			
		end if;
			
	end if;
end process;

-- synchronization
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