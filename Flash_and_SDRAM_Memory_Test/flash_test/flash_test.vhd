----------------------------------------------------------------------------------
-- Company: PROPOX Sp. z o.o. 
-- Engineer: Andrzej Okulicz 
-- 
-- Create Date:    13:17:44 07/09/2007 
-- Design Name: 	 flash_test	
--
-- Description:    Test pamieci flash dla MMfpga12 - program cyklicznie zapisuje
--                 i odczytuje wartosc 90h do/z wszystkich komorek pamieci.
--                 Jezeli test wypadl poprawnie to zapalaja sie segmenty wyswietlacza.
--                 Jezeli nie to nic sie nie zapala.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity flash_test is
port(
		clk_50MHz 	: in		std_logic;
		reset			: in		std_logic;
		
		-- wywietlacz 7-segmentowy 
		LED7_AN_O	: out 	std_logic_vector(5 downto 0);
		LED7_SEG_O	: out  	std_logic_vector(7 downto 0);
		
		-- flash memory
		Addr			: out		std_logic_vector(21 downto 0);
		Data			: inout	std_logic_vector(15 downto 0);
		
		flash_ce		: out		std_logic;
		flash_oe		: out		std_logic;
		flash_we		: out		std_logic;
		flash_rp		: out    std_logic;
		flash_wp    : out    std_logic
		);	
end flash_test;


architecture Behavioral of flash_test is

signal clk_10kHz : std_logic; -- zegar 10[kHz]

signal stan : integer range 0 to 9;

signal data_out : std_logic_vector(15 downto 0);


component sraminterface is
    port (
        clk_50MHz		: in STD_LOGIC;								 		-- Clock signal.
        reset			: in STD_LOGIC;										-- Asynchronous reset
        doRead			: in STD_LOGIC;										-- Set this to make a read request.							
        doWrite		: in STD_LOGIC;										-- Set this to make a write request.
        readAddr		: in STD_LOGIC_VECTOR (21 downto 0);			-- Address to read from (user-side).
        writeAddr		: in STD_LOGIC_VECTOR (21 downto 0);			-- Address to write to (user-side).
        readData		: out STD_LOGIC_VECTOR (15 downto 0);			-- Data read (user-side).
        writeData		: in STD_LOGIC_VECTOR (15 downto 0);			-- Data to write (user-side).
        canRead		: out STD_LOGIC;										-- Is '1' when a read request can be handled.							
        canWrite		: out STD_LOGIC;										-- Is '1' when a write request can be handled.
        flash_ce		: out STD_LOGIC;										-- CEn signal to left SRAM bank.
        flash_oe		: out STD_LOGIC;										-- OEn signal to left SRAM bank.
        flash_we		: out STD_LOGIC;										-- WEn signal to left SRAM bank.
        Addr      	: out STD_LOGIC_VECTOR (21 downto 0);			-- Address bus to left SRAM bank.
        Data	      : inout STD_LOGIC_VECTOR (15 downto 0)			-- Data bus to left SRAM bank.
    );
end component;

signal doRead 			: STD_LOGIC;
signal doWrite 		: STD_LOGIC;
signal readAddr      : STD_LOGIC_VECTOR (21 downto 0);
signal writeAddr     : STD_LOGIC_VECTOR (21 downto 0);
signal readData      : STD_LOGIC_VECTOR (15 downto 0);
signal writeData     : STD_LOGIC_VECTOR (15 downto 0);
signal canRead       : STD_LOGIC;
signal canWrite      : STD_LOGIC;


begin

X1: sraminterface port map(
        clk_50MHz		=> clk_50MHz, 											 		
        reset			=> reset,
		  
        doRead			=> doRead,																			
        doWrite		=>	doWrite,									
        readAddr		=>	readAddr,		
        writeAddr		=>	writeAddr,	
        readData		=>	readData,	
        writeData		=>	writeData,		
        canRead		=>	canRead,														
        canWrite		=> canWrite,
		  
        flash_ce		=> flash_ce,												
        flash_oe		=>	flash_oe,									
        flash_we		=>	flash_we,
		  
        Addr	      =>	Addr,		
        Data	      =>	Data	
);
 
flash_rp <= '1';
flash_wp <= '1'; 

LED7_AN_O <= (others => '0');

-------------------------------------------------------------------
-- generacja zegara 10kHz
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
			clk_10kHz <= not clk_10kHz;   -- generacja zegara 1Hz
		end if;
	end if;
end process; 


-------------------------------------------------------------------
-- odczyt numeru seryjnego 
-------------------------------------------------------------------
process(clk_50MHz,reset)
variable licznik : integer range 0 to 4194304 := 0;
begin
	if(reset='0')then
		stan <= 0;				
		data_out   <= (others => '0');
		LED7_SEG_O <= (others => '1');
		writeAddr  <= (others => '1');
		readAddr   <= (others => '1');
	elsif(clk_50MHz'event and clk_50MHz='1')then
		
		-- write
		if(stan=0)then
			writeAddr <= writeAddr + '1';
			writeData <= X"0090";
			stan<=1;
		end if;
		
		if(stan=1 and canWrite='1')then
			doWrite <= '1';
			stan<=2;
		end if;
		
		if(stan=2)then
			stan<=3;
		end if;
		
		if(stan=3)then
			stan<=4;
		end if;
		
		if(stan=4)then
			stan<=5;
		end if;
		
		-- read
		if(stan=5)then
			readAddr <= readAddr + '1';
			stan<=6;
		end if;
		
		if(stan=6 and canRead='1')then
			doRead <= '1';
			stan <= 7;
		end if;
		
		if(stan=7)then
			stan <= 8;
		end if;
		
		if(stan=8 and canRead='1')then
			data_out <= readData;
		end if;
		
		
		if(data_out=X"0090")then
			licznik := licznik + 1;
			stan <= 0;
		end if;
		
		-- wyswietlenie odpowiedzi
		if(licznik=4194304)then
			LED7_SEG_O <= (others => '0');
			licznik := 0;
			stan <= 8;
		end if;
								
	end if;
end process;

end Behavioral;

