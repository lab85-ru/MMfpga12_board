----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o.	www.propox.com 
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name: 	 Test_1	
--
-- Description: 
-- Test wyswietlacza 7-segmentowego, wyswietlacz pokazuje co 1s napis PROPOX
-- 7-segment display test - display PROPOX every 1s
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Test_1 is
port(
		clk_50MHz 	:in	std_logic; -- 50MHz
		reset			:in	std_logic; -- reset (active low), dip-switch 8
		
		-- wywietlacz 7-segmentowy
        -- 7-segment display 
		LED7_AN_O	:out	std_logic_vector(5 downto 0);
		LED7_SEG_O	:out	std_logic_vector(7 downto 0)
	 );	
end Test_1;


architecture Behavioral of Test_1 is

signal clk_1Hz		: std_logic; -- zegar 1[Hz]
signal clk_led7   : std_logic; -- zegar przemiatajacy wyswietlacze 7-segmentowe 1[kHz]

begin

-------------------------------------------------------------------
-- 1Hz oraz zegara dla wyswietlacza 7-segmentowego
-- 1Hz and clock for 7seg
-------------------------------------------------------------------
process(clk_50MHz,reset)
variable counter      : integer range 0 to 50000000;
variable counter_7seg : integer range 0 to 50000;
begin
	if(reset='0')then
		counter := 0;
		counter_7seg := 0;
		clk_1Hz  <= '0';
		clk_led7 <= '0';
	-- rising edge
	elsif(clk_50MHz'event and clk_50MHz='1')then
	   -- inkrementacja licznikow
		counter := counter + 1;
		counter_7seg := counter_7seg + 1;
		if(counter=50000000)then
			counter := 0;
			clk_1Hz <= not clk_1Hz;   -- 1Hz
		end if;
		if(counter_7seg=50000)then
			counter_7seg := 0;
			clk_led7 <= not clk_led7; -- 1kHz
		end if;		
	end if;
end process;

------------------------------------------------------------------
-- wyswietlacz 7-segmentowy
-- 7seg diplay
------------------------------------------------------------------
process(clk_led7,reset)
variable state : integer range 0 to 5;  
begin
	if(reset='0')then
		state := 0;
		LED7_AN_O <= "000000";     
		LED7_SEG_O <= "11111111";
	-- reakcja na zbocze narastajace zegara
	elsif(clk_led7'event and clk_led7='1')then
		-- przemiatanie wyswietlaczy z f=1kHz
		if(clk_1Hz='1')then		
			if(state=0)then
				LED7_AN_O <= "011111";    -- wyswietlacz pierwszy z lewej (first left)
				LED7_SEG_O <= "00110001"; -- P
				state := 1;
			elsif(state=1)then
				LED7_AN_O <= "101111";
				LED7_SEG_O <= "00010001"; -- R
				state := 2;
			elsif(state=2)then
				LED7_AN_O <= "110111";
				LED7_SEG_O <= "00000011"; -- O
				state := 3;
			elsif(state=3)then
				LED7_AN_O <= "111011";
				LED7_SEG_O <= "00110001"; -- P
				state := 4;
			elsif(state=4)then
				LED7_AN_O <= "111101";
				LED7_SEG_O <= "00000011"; -- O
				state := 5;
			elsif(state=5)then
				LED7_AN_O <= "111110";    -- wyswietlacz pierwszy z prawej (first right)
				LED7_SEG_O <= "10010001"; -- X
				state := 0;
			end if;	
		else		
			state := 0;
			LED7_AN_O <= "000000";
			LED7_SEG_O <= "11111111"; 
		end if;
	end if;
end process;

end Behavioral;

