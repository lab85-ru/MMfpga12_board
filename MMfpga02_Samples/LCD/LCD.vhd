----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o. 	www.propox.com 
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name:    LCD	
--
-- Description: 
-- LCD Test
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity LCD is
port(
		clk_50MHz 	:in	std_logic; -- 50MHz
		reset			:in	std_logic; -- reset(active low), dip-switch 8
		
		-- LCD 
		LCD_RS		:out	std_logic;
		LCD_E			:out	std_logic;
		LCD_D			:out	std_logic_vector(3 downto 0)
	 );	
end LCD;

	
architecture Behavioral of LCD is

signal clk_1Hz		: std_logic; -- 1[Hz]
signal clk_LCD    : std_logic; -- LCD 1[kHz]

signal init_state : integer range 0 to 100;
signal data_state : integer range 0 to 100;

type napis is array (15 downto 0) of std_logic_vector(7 downto 0);
signal firma : napis;
	
begin							 
-------------------------------------------------------------------
-- 1Hz and 1kHz
-------------------------------------------------------------------
process(clk_50MHz,reset)
variable counter      : integer range 0 to 50000000;
variable counter_LCD  : integer range 0 to 50000;
begin
	if(reset='0')then
		counter := 0;
		counter_LCD := 0;
		clk_1Hz  <= '0';
		clk_LCD  <= '0';
	-- rising edge of clock
	elsif(clk_50MHz'event and clk_50MHz='1')then
	   -- inkrementacja licznikow
		counter := counter + 1;
		counter_LCD := counter_LCD + 1;
		if(counter=50000000)then
			counter := 0;
			clk_1Hz <= not clk_1Hz;   -- 1Hz
		end if;
		if(counter_LCD=50000)then
			counter_LCD := 0;
			clk_LCD <= not clk_LCD;   -- 1kHz
		end if;		
	end if;
end process;

-------------------------------------------------------------------
-- LCD
-------------------------------------------------------------------
process(clk_LCD,reset)
variable delay_count : integer range 0 to 100;
variable i           : integer range 0 to 16;
begin
	if(reset='0')then
		LCD_RS <= '0';
		LCD_E  <= '0';
		LCD_D  <= (others => '0');
		
		delay_count := 0;
		init_state <= 0;
		data_state <= 0;
		
		i := 0;
		
		firma(0)  <= "01010000"; --P
		firma(1)  <= "01010010"; --R
		firma(2)  <= "01001111"; --O
		firma(3)  <= "01010000"; --P
		firma(4)  <= "01001111"; --O
		firma(5)  <= "01011000"; --X
		firma(6)  <= "00100000"; --space
		firma(7)  <= "01010011"; --S
		firma(8)  <= "01110000"; --p
		firma(9)  <= "00100000"; --space
		firma(10) <= "01111010"; --z
		firma(11) <= "00100000"; --space
		firma(12) <= "01101111"; --o
		firma(13) <= "00101110"; --.
		firma(14) <= "01101111"; --o
		firma(15) <= "00101110"; --.
		
	-- rising edge of clock
	elsif(clk_LCD'event and clk_LCD='1')then

----------------------- Inicialization ---------------------------
------------------------------------------------------------------		
		-- Power On
		if(init_state=0)then
			delay_count := delay_count + 1;
			if(delay_count=20)then
				delay_count := 0;
				init_state <= 1;
			end if;
		end if;
		
		------------------------------------------
		-- First 0x03
		if(init_state=1)then
			LCD_D <= "0011";
			LCD_E <= '1';
			init_state <= 2;
		end if;
		-- Delay
		if(init_state=2)then
			LCD_E <= '0';
			delay_count := delay_count + 1;
			if(delay_count=10)then
				delay_count := 0;
				init_state <= 3;
			end if;
		end if;
		-- Second 0x03
		if(init_state=3)then
			LCD_D <= "0011";
			LCD_E <= '1';
			init_state <= 4;
		end if;
		-- Delay
		if(init_state=4)then
			LCD_E <= '0';
			delay_count := delay_count + 1;
			if(delay_count=10)then
				delay_count := 0;
				init_state <= 5;
			end if;
		end if;
		-- Third 0x03
		if(init_state=5)then
			LCD_D <= "0011";
			LCD_E <= '1';
			init_state <= 6;
		end if;
		-- Delay
		if(init_state=6)then
			LCD_E <= '0';
			delay_count := delay_count + 1;
			if(delay_count=10)then
				delay_count := 0;
				init_state <= 7;
			end if;
		end if;
		-------------------------------------------------
		
		-- Four Bit Mode --
		if(init_state=7)then
			LCD_D <= "0010";
			LCD_E <= '1';
			init_state <= 8;
		end if;
		-- Delay
		if(init_state=8)then
			LCD_E <= '0';
			init_state <= 9;
		end if;
		
		
		-- Set Interface Length --
		-- 4 MSB
		if(init_state=9)then
			LCD_D <= "0010";
			LCD_E <= '1';
			init_state <= 10;
		end if;
		-- Delay
		if(init_state=10)then
			LCD_E <= '0';
			init_state <= 11;
		end if;
		-- 4 LSB
		if(init_state=11)then
			LCD_D <= "1000";
			LCD_E <= '1';
			init_state <= 12;
		end if;
		-- Delay
		if(init_state=12)then
			LCD_E <= '0';
			init_state <= 13;
		end if;
		
		-- Turn Off Display --
		-- 4 MSB
		if(init_state=13)then
			LCD_D <= "0000";
			LCD_E <= '1';
			init_state <= 14;
		end if;
		-- Delay
		if(init_state=14)then
			LCD_E <= '0';
			init_state <= 15;
		end if;
		-- 4 LSB
		if(init_state=15)then
			LCD_D <= "1000";
			LCD_E <= '1';
			init_state <= 16;
		end if;
		-- Delay
		if(init_state=16)then
			LCD_E <= '0';
			init_state <= 17;
		end if;
		
		-- Clear Display --
		-- 4 MSB
		if(init_state=17)then
			LCD_D <= "0000";
			LCD_E <= '1';
			init_state <= 18;
		end if;
		-- Delay
		if(init_state=18)then
			LCD_E <= '0';
			init_state <= 19;
		end if;
		-- 4 LSB
		if(init_state=19)then
			LCD_D <= "0001";
			LCD_E <= '1';
			init_state <= 20;
		end if;
		-- Delay
		if(init_state=20)then
			LCD_E <= '0';
			init_state <= 21;
		end if;

		-- Set Cursor Move Direction --
		-- 4 MSB
		if(init_state=21)then
			LCD_D <= "0000";
			LCD_E <= '1';
			init_state <= 22;
		end if;
		-- Delay
		if(init_state=22)then
			LCD_E <= '0';
			init_state <= 23;
		end if;
		-- 4 LSB
		if(init_state=23)then
			LCD_D <= "0110";
			LCD_E <= '1';
			init_state <= 24;
		end if;
		-- Delay
		if(init_state=24)then
			LCD_E <= '0';
			init_state <= 25;
		end if;
		
		-- Enable Display/Cursor --
		-- 4 MSB
		if(init_state=25)then
			LCD_D <= "0000";
			LCD_E <= '1';
			init_state <= 26;
		end if;
		-- Delay
		if(init_state=26)then
			LCD_E <= '0';
			init_state <= 27;
		end if;
		-- 4 LSB
		if(init_state=27)then
			LCD_D <= "1111";
			LCD_E <= '1';
			init_state <= 28;
		end if;
		-- Delay
		if(init_state=28)then
			LCD_E <= '0';
			init_state <= 29;
			data_state <= 1;
		end if;


------------------------------------------------------------------
------------------------------------------------------------------
		-- Data --
		-- 4 MSB
		if(data_state=1)then
			LCD_D <= firma(i)(7 downto 4);
			LCD_E <= '1';
			LCD_RS <= '1';
			data_state <= 2;
		end if;
		-- Delay
		if(data_state=2)then
			LCD_E <= '0';
			data_state <= 3;
		end if;
		-- 4 LSB
		if(data_state=3)then
			LCD_D <= firma(i)(3 downto 0);
			LCD_E <= '1';
			data_state <= 4;
		end if;
		-- Delay
		if(data_state=4)then
			LCD_E <= '0';
			data_state <= 1;
			
			i := i + 1;
			if(i=16)then
				data_state <= 5;
			end if;
		end if;
------------------------------------------------------------------
------------------------------------------------------------------
		
	end if;
end process;

end Behavioral;

