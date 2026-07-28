----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o.  	www.propox.com
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name: 	 RS232_PS2	
--
-- Description: 
-- Keyboard and RS232 Test - symbols (A-Z) are reading from keyboard and display   
--                           on RS232 terminal.                   
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity RS232_PS2 is
port(
		clk_50MHz 	:in	std_logic;
		reset			:in	std_logic;
		
		-- klawiatura 
		KBDATA	   :in	std_logic;
		KBCLOCK	   :in	std_logic;
		
		--RS232
		RS232_1_TXD :out  std_logic;
		RS232_1_RXD :in   std_logic
		);	
end RS232_PS2;


architecture Behavioral of RS232_PS2 is

signal clk_10kHz : std_logic; -- zegar 10[kHz]

signal stan       : integer range 0 to 2;

signal stan_rs    : integer range 0 to 5;
signal data_rs    : std_logic_vector(7 downto 0);
signal rs232      : std_logic_vector(7 downto 0);

begin

-------------------------------------------------------------------
-- 10kHz and 1kHz
-------------------------------------------------------------------
process(clk_50MHz,reset)
variable counter      : integer range 0 to 5000;
begin
	if(reset='0')then
		counter := 0;
		clk_10kHz  <= '0';
	-- reakcja na zbocze narastajace zegara
	elsif(clk_50MHz'event and clk_50MHz='1')then
	   -- inkrementacja licznikow
		counter := counter + 1;
		if(counter=5000)then
			counter := 0;
			clk_10kHz <= not clk_10kHz;   -- 1Hz
		end if;
	end if;
end process; 



-------------------------------------------------------------------
-- Reading data from keyboard 
-------------------------------------------------------------------
process(KBCLOCK,reset)
variable licznik : integer range 0 to 8;
variable start   : integer range 0 to 1;
variable stop    : integer range 0 to 3;
begin
	if(reset='0')then
		licznik := 0;
		start := 0;
		stop := 0;
		stan <= 0;
				
		rs232 <= (others => '0');
		
	-- rising edge
	elsif(KBCLOCK'event and KBCLOCK='0')then
		
		
		if(KBDATA='0')then
			start := 1;
			stan <= 1;	
		end if;
		
		if(start=1 and stan=1)then
			if(stop=0)then
			 rs232(licznik) <= KBDATA;
			end if; 
			licznik := licznik + 1;
			if(licznik=8)then
				licznik:=0;
				stan <= 2;
			end if;
		end if;
		
		 
		if(stan=2)then
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
-- Coding data to RS232 terminal  
-------------------------------------------------------------------
process(clk_50MHz,reset)
begin
	if(reset='0')then

		
		data_rs <= (others => '0');

	-- rising edge
	elsif(clk_50MHz'event and clk_50MHz='1')then
				
		-- HyperTerminal
		case rs232 is
			when X"1C" => data_rs <= X"41"; --A			  
			when X"32" => data_rs <= X"42"; --B            
			when X"21" => data_rs <= X"43"; --C            
			when X"23" => data_rs <= X"44"; --D            
			when X"24" => data_rs <= X"45"; --E             
			when X"2B" => data_rs <= X"46"; --F             
			when X"34" => data_rs <= X"47"; --G            
			when X"33" => data_rs <= X"48"; --H            
			when X"43" => data_rs <= X"49"; --I          
			when X"3B" => data_rs <= X"4A"; --J            
			when X"42" => data_rs <= X"4B"; --K            
			when X"4B" => data_rs <= X"4C"; --L            			
			when X"3A" => data_rs <= X"4D"; --M            
			when X"31" => data_rs <= X"4E"; --N            
			when X"44" => data_rs <= X"4F"; --O		              
			when X"4D" => data_rs <= X"50"; --P			              
			when X"15" => data_rs <= X"51"; --Q			              
			when X"2D" => data_rs <= X"52"; --R			              
			when X"1B" => data_rs <= X"53"; --S			              
			when X"2C" => data_rs <= X"54"; --T			              
			when X"3C" => data_rs <= X"55"; --U		              
			when X"2A" => data_rs <= X"56"; --V			              
			when X"1D" => data_rs <= X"57"; --W			              
			when X"22" => data_rs <= X"58"; --X			              
			when X"35" => data_rs <= X"59"; --Y			              
			when X"1A" => data_rs <= X"5A"; --Z
			when X"29" => data_rs <= X"5F"; --space
			when OTHERS =>			
		end case;
				
	end if;
end process;


-------------------------------------------------------------------
-- writing to RS232
-- 	  4800 bit/s
--    8 bit data
--    parity no
--    bit stop = 1 
-------------------------------------------------------------------
process(clk_10kHz,reset)
variable licznik    : integer range 0 to 8; 
variable licznik_rs : integer range 0 to 4; 
begin
	if(reset='0')then
		licznik := 0;
		licznik_rs := 0;
		stan_rs <= 0;
		RS232_1_TXD <= '1';
						
	-- rising edge
	elsif(clk_10kHz'event and clk_10kHz='0')then
		
		
		if(KBDATA='0' and stan_rs=0)then
		   if(licznik_rs=0)then
				stan_rs <= 1;
			end if;
			licznik_rs := licznik_rs + 1;
		end if;
		
		
		if(stan_rs=1)then		
			stan_rs <= 2;
			RS232_1_TXD <= '1';
		end if;
		
		if(stan_rs=2)then
			stan_rs <= 3;
			RS232_1_TXD <= '0';
		end if;
		
		if(stan_rs=3)then
		 	RS232_1_TXD <= data_rs(licznik);
			licznik := licznik + 1;
			if(licznik=8)then
				licznik:=0;
				stan_rs <= 4;
			end if;
		end if;
		
		if(stan_rs=4)then
			RS232_1_TXD <= '1';
			stan_rs <= 0;
			if(licznik_rs=4)then
				licznik_rs := 0;
			end if;
		end if;
				
	end if;
end process;

end Behavioral;

