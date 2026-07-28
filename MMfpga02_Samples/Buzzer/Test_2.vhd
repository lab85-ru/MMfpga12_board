----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o.	www.propox.com 
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name: 	 Test_2	
-- Description: 
-- Test buzzera, buzzer brzeczy z czestotliwoscia 1Hz
-- Buzzer Test - it is active every 1s
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Test_2 is
port(
		clk_50MHz 	:in	std_logic;
		reset			:in	std_logic;
		
		-- buzzer
		BUZZER		:out	std_logic
	);	
end Test_2;


architecture Behavioral of Test_2 is

signal clk_1Hz		: std_logic; -- 1[Hz]

begin

-------------------------------------------------------------------
-- generacja zegara 1Hz
-- 1Hz clock
-------------------------------------------------------------------
process(clk_50MHz,reset)
variable counter      : integer range 0 to 50000000;
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
-- buzzer
------------------------------------------------------------------------
process(clk_50MHz,reset)
begin
	if(reset='0')then
		BUZZER <= '1';
	-- rising edge
	elsif(clk_50MHz'event and clk_50MHz='1')then
		if(clk_1Hz='1')then
			BUZZER <= '0';  -- buzzer wlaczony (on)
		else
			BUZZER <= '1';  -- buzzer wylaczony (off)
		end if;
	end if;
end process;

end Behavioral;

