----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o. 
-- Engineer: Andrzej Okulicz 
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name: 	 Test_3	

-- Description: 
-- Test diod oraz switchy
-- LEDs and Switches Test
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Test_3 is
port(
		clk_50MHz 	:in	std_logic;
		reset			:in	std_logic;
		
		-- switch SW7, SW6, SW5, SW4
		SW				:in	std_logic_vector(3 downto 0);
		-- ledy
		LED			:out	std_logic_vector(7 downto 0);
		USER1			:out	std_logic;
		USER2			:out	std_logic
	);	
end Test_3;


architecture Behavioral of Test_3 is

signal clk_1Hz		: std_logic; -- zegar 1[Hz]

begin

-------------------------------------------------------------------
-- generacja zegara 1Hz
-- !Hz clock
-------------------------------------------------------------------
process(clk_50MHz,reset)
variable counter      : integer range 0 to 50000000;
variable counter_7seg : integer range 0 to 50000;
begin
	if(reset='0')then
		counter := 0;
		clk_1Hz  <= '0';
	-- rising edge
	elsif(clk_50MHz'event and clk_50MHz='1')then
	   -- inkrementacja licznika
		counter := counter + 1;
		if(counter=50000000)then
			counter := 0;
			clk_1Hz <= not clk_1Hz;   -- 1Hz
		end if;
	end if;
end process;

------------------------------------------------------------------------
-- LEDy oraz Switche
-- Ledy migaja z czestotliwoscia 1Hz
-- 	- SW7 wcisniety - miga na przemian co drug dioda
-- 	- SW6 wcisniety - migaja na przemian po dwie diody
-- 	- SW5 wcisniety - miga na przemian polowa diod
--		- SW4 wcisniety - wszystkie diody migaja
--
-- Diody USER1 i USER2 na MMfpgaXX migaja caly czas na przemian
--
-- LEDs and Switches
-- Leds are on every 1Hz
-- 	- SW7 on - every second diode is flasching
-- 	- SW6 on - every two diodes are flasching
-- 	- SW5 on - half of diodes is flasching
--  - SW4 on - all diodes are flasching
--
-- LEDs USER1 i USER2 on MMfpgaXX are flasching every time one by one
------------------------------------------------------------------------
process(clk_50MHz,reset)
begin
	if(reset='0')then
		LED <= "11111111";       -- all LEDs off
	-- rising edge
	elsif(clk_50MHz'event and clk_50MHz='1')then

		if(clk_1Hz='1')then
			USER1 <= '0';
			USER2 <= '1';
		else
			USER1 <= '1';
			USER2 <= '0';
		end if;

		if(SW(3)='0')then        -- SW7 wcisniety (on)
			if(clk_1Hz='1')then
				LED <= "10101010";
			else
				LED <= "01010101";
			end if;
		elsif(SW(2)='0')then     -- SW6 wcisniety (on)
			if(clk_1Hz='1')then
				LED <= "11001100";
			else
				LED <= "00110011";
			end if;
		elsif(SW(1)='0')then     -- SW5 wcisniety (on)
			if(clk_1Hz='1')then
				LED <= "11110000";
			else
				LED <= "00001111";
			end if;
		elsif(SW(0)='0')then     -- SW4 wcisniety (on)
			if(clk_1Hz='1')then
				LED <= "00000000";
			else
				LED <= "11111111";
			end if;		
		else                     -- zaden przycisk nie wcisniety (no switch on)
			LED <= "00000000";    -- wszystkie diody zapalone (every LED on)
		end if;
		
	end if;
end process;

end Behavioral;

