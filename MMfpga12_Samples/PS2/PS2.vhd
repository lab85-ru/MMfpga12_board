----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o. 	www.propox.com
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name: 	 PS2	
--
-- Description: 
-- PS/2 Test - symbols (A - Z) are reading form keyboard and display in LCD second line. 
--            
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity PS2 is
port(
		clk_50MHz 	:in	std_logic;
		reset			:in	std_logic;
		
		-- klawiatura 
		KBDATA	   :in	std_logic;
		KBCLOCK	   :in	std_logic;
		
		-- LCD 
		LCD_RS		:out	std_logic;
		LCD_E			:out	std_logic;
		LCD_D			:out	std_logic_vector(3 downto 0) 
	);	
end PS2;


architecture Behavioral of PS2 is

signal clk_1Hz : std_logic; -- zegar 1[Hz]
signal clk_LCD : std_logic; -- zegar sterujacy LCD 1[kHz]

signal init_state : integer range 0 to 100;
signal data_state : integer range 0 to 100;
signal home_state : integer range 0 to 100;

signal stan       : integer range 0 to 2;

type tablica_znakow is array (15 downto 0) of std_logic_vector(7 downto 0);
signal data    : tablica_znakow;                      -- dane z PS2
signal LCD     : tablica_znakow;                      -- dane do LCD
signal firma   : tablica_znakow;                      -- nazwa firmy

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
	-- rising edge
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
-- reading data from keyboard 
-------------------------------------------------------------------
process(KBCLOCK,reset)
variable licznik : integer range 0 to 8;
variable pozycja : integer range 0 to 15;
variable start   : integer range 0 to 1;
variable stop    : integer range 0 to 3;
begin
	if(reset='0')then
		licznik := 0;
		pozycja := 0;
		start := 0;
		stop := 0;
		stan <= 0;
		
		data(0) <= (others => '0');
		data(1) <= (others => '0');
		data(2) <= (others => '0');
		data(3) <= (others => '0');
		data(4) <= (others => '0');
		data(5) <= (others => '0');
		data(6) <= (others => '0');
		data(7) <= (others => '0');
		data(8) <= (others => '0');
		data(9) <= (others => '0');
		data(10) <= (others => '0');
		data(11) <= (others => '0');
		data(12) <= (others => '0');
		data(13) <= (others => '0');
		data(14) <= (others => '0');
		data(15) <= (others => '0');

	-- rising edge
	elsif(KBCLOCK'event and KBCLOCK='0')then
		
		if(KBDATA='0')then
			start := 1;
			stan <= 1;
		end if;
		if(start=1 and stan=1)then
			if(stop=0)then
		 	 data(pozycja)(licznik) <= KBDATA;
			end if; 
			licznik := licznik + 1;
			if(licznik=8)then
				licznik:=0;
				stan <= 2;
			end if;
		end if;
		if(stan=2)then
			if(stop=0)then
				pozycja := pozycja + 1;
				if(pozycja=16)then
					pozycja := 0;
				end if;
			end if;
			stop := stop + 1;
			if(stop=3)then
				stop := 0;
			end if;
			
			start:=0;
			stan<=0;
		end if;
		
	end if;
end process;

-------------------------------------------------------------------
-- exposition 
-------------------------------------------------------------------
process(clk_50MHz,reset)
variable pozycja : integer range 0 to 16;
begin
	if(reset='0')then
		pozycja := 0;
		
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

		LCD(0)  <= "10100000"; 
		LCD(1)  <= "10100000"; 
		LCD(2)  <= "10100000"; 
		LCD(3)  <= "10100000"; 
		LCD(4)  <= "10100000"; 
		LCD(5)  <= "10100000"; 
		LCD(6)  <= "10100000"; 
		LCD(7)  <= "10100000"; 
		LCD(8)  <= "10100000"; 
		LCD(9)  <= "10100000"; 
		LCD(10) <= "10100000"; 
		LCD(11) <= "10100000"; 
		LCD(12) <= "10100000"; 
		LCD(13) <= "10100000"; 
		LCD(14) <= "10100000"; 
		LCD(15) <= "10100000"; 
		
	-- rising edge
	elsif(clk_50MHz'event and clk_50MHz='1')then
	
		case data(pozycja) is
			when X"1C" => LCD(pozycja) <= "01000001"; --A 
			when X"32" => LCD(pozycja) <= "01000010"; --B
			when X"21" => LCD(pozycja) <= "01000011"; --C
			when X"23" => LCD(pozycja) <= "01000100"; --D
			when X"24" => LCD(pozycja) <= "01000101"; --E
			when X"2B" => LCD(pozycja) <= "01000110"; --F
			when X"34" => LCD(pozycja) <= "01000111"; --G
			when X"33" => LCD(pozycja) <= "01001000"; --H
			when X"43" => LCD(pozycja) <= "01001001"; --I
			when X"3B" => LCD(pozycja) <= "01001010"; --J
			when X"42" => LCD(pozycja) <= "01001011"; --K
			when X"4B" => LCD(pozycja) <= "01001100"; --L 
			when X"3A" => LCD(pozycja) <= "01001101"; --M
			when X"31" => LCD(pozycja) <= "01001110"; --N
			when X"44" => LCD(pozycja) <= "01001111"; --O
			when X"4D" => LCD(pozycja) <= "01010000"; --P
			when X"15" => LCD(pozycja) <= "01010001"; --Q
			when X"2D" => LCD(pozycja) <= "01010010"; --R
			when X"1B" => LCD(pozycja) <= "01010011"; --S
			when X"2C" => LCD(pozycja) <= "01010100"; --T
			when X"3C" => LCD(pozycja) <= "01010101"; --U
			when X"2A" => LCD(pozycja) <= "01010110"; --V
			when X"1D" => LCD(pozycja) <= "01010111"; --W
			when X"22" => LCD(pozycja) <= "01011000"; --X
			when X"35" => LCD(pozycja) <= "01011001"; --Y
			when X"1A" => LCD(pozycja) <= "01011010"; --Z
			when OTHERS => 
		end case;
		
		pozycja := pozycja + 1;
			
		if(pozycja=16)then
			pozycja := 0;
		end if;
		
	end if;
end process;



-------------------------------------------------------------------
-- LCD
-------------------------------------------------------------------
process(clk_LCD,reset)
variable first_line  : integer range 0 to 1;
variable delay_count : integer range 0 to 100;
variable i           : integer range 0 to 16;
begin
	if(reset='0')then
		LCD_RS <= '0';
		LCD_E  <= '0';
		LCD_D  <= (others => '0');
		
		first_line := 0;
		delay_count := 0;
		init_state <= 0;
		data_state <= 0;
		home_state <= 0;
		
		i := 0;
			
	-- rising edge
	elsif(clk_LCD'event and clk_LCD='1')then

----------------------- Inicjalizacja ----------------------------
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
			if(first_line=0)then
				LCD_D <= firma(i)(7 downto 4);
			else
				LCD_D <= LCD(i)(7 downto 4);
			end if;
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
			if(first_line=0)then
				LCD_D <= firma(i)(3 downto 0);
			else
				LCD_D <= LCD(i)(3 downto 0);
			end if;
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
				home_state <= 1;
			end if;
		end if;
		
		-- Resturn to start of second line --
		-- 4 MSB
		if(home_state=1)then
			LCD_D <= "1100";
			LCD_E <= '1';
			LCD_RS <= '0';
			home_state <= 2;
		end if;
		-- Delay
		if(home_state=2)then
			LCD_E <= '0';
			home_state <= 3;
		end if;
		-- 4 LSB
		if(home_state=3)then
			LCD_D <= "0000";
			LCD_E <= '1';
			home_state <= 4;
		end if;
		-- Delay
		if(home_state=4)then
			LCD_E <= '0';
			home_state <= 0;
			data_state <= 1;
			first_line := 1;
		end if;
		
------------------------------------------------------------------
------------------------------------------------------------------
		
	end if;
end process; 



end Behavioral;

