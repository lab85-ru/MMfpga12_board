--------------------------------------------------------------------
-- Company : XESS Corp.
-- Engineer : Dave Vanden Bout
-- Creation Date : 06/13/2005
-- Copyright : 2005, XESS Corp
-- Tool Versions : WebPACK 6.3.03i
--
--
-- Additional Comments:
--
-- License:
-- This code can be freely distributed and modified as long as
-- this header is not removed.
-------------------------------------------------------------------- 

library IEEE;
use IEEE.std_logic_1164.all;
use WORK.test_board_core_pckg.all;

entity test_board is
  port(
    ce_n   : out   std_logic;           				-- Flash RAM chip-enable
    reset  : in    std_logic;           				-- active-low pushbutton input
    clk    : in    std_logic;           				-- main clock input from external clock source
    sclk   : out   std_logic;           				-- clock to SDRAM
    cke    : out   std_logic;           				-- SDRAM clock-enable
    cs_n   : out   std_logic;          			 	-- SDRAM chip-select
    ras_n  : out   std_logic;          				-- SDRAM RAS
    cas_n  : out   std_logic;           				-- SDRAM CAS
    we_n   : out   std_logic;           				-- SDRAM write-enable
    ba     : out   std_logic_vector( 1 downto 0);  -- SDRAM bank-address
    sAddr  : out   std_logic_vector(12 downto 0);  -- SDRAM address bus
    sData  : inout std_logic_vector(15 downto 0);  -- data bus to/from SDRAM
    dqmh   : out   std_logic;                      -- SDRAM DQMH
    dqml   : out   std_logic;                      -- SDRAM DQML
    s      : out   std_logic_vector(6 downto 0);   -- 7-segment LED segments
	 en     : out   std_logic_vector(5 downto 0);   -- 7-segment LED enable
	 dp     : out   std_logic;
	 
	 -- switch SW7, SW6, SW5, SW4
	 SW	  : in	std_logic_vector(3 downto 0);
	 -- led's
	 LED	  : out	std_logic_vector(7 downto 0);
	 USER1  : out	std_logic;
	 USER2  : out	std_logic;  
	 -- buzzer
    buzzer : out  std_logic                      
    );
end entity;

architecture arch of test_board is
signal clk_1Hz		: std_logic; -- 1[Hz]
signal clk_led7   : std_logic; -- 1[kHz]
signal var        : std_logic;
begin

  ce_n <= '1';                          -- disable Flash RAM
  en   <= (others=>'0');                -- all displays active
  dp   <= '0';									 -- dp active all time  
  
  
  u0 : test_board_core
    generic map(
      FREQ        => 50_000,           -- 50MHz
      PIPE_EN     => false,             -- enable pipeline operations
      DATA_WIDTH  => sData'length,
      SADDR_WIDTH => sAddr'length,
      NROWS       => 8192,
      NCOLS       => 512,
      BEG_ADDR    => 16#00_0000#,
      END_ADDR    => 16#FF_FFFF#,
      BEG_TEST    => 16#00_0000#,
      END_TEST    => 16#FF_FFFF#
      )
    port map(
      button_n    => reset,
      clk         => clk,
      sclk        => sclk,
      cke         => cke,
      cs_n        => cs_n,
      ras_n       => ras_n,
      cas_n       => cas_n,
      we_n        => we_n,
      ba          => ba,
      sAddr       => sAddr,
      sData       => sData,
      dqmh        => dqmh,
      dqml        => dqml,
      led         => s,
      heartBeat   => buzzer
      );


-------------------------------------------------------------------
-- 1Hz and 1kHz clock generation 
-------------------------------------------------------------------
process(clk,reset)
variable counter      : integer range 0 to 50000000;
variable counter_7seg : integer range 0 to 50000;
begin
	if(reset='0')then
		counter := 0;
		counter_7seg := 0;
		clk_1Hz  <= '0';
		clk_led7 <= '0';
	elsif(clk'event and clk='1')then

	   -- counters increments
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

------------------------------------------------------------------------
-- LEDs and Switchs
-- Ledy flashing one by one with f=1Hz
-- 	- SW7 click - flashing every second dionde
-- 	- SW6 click - flashing two diodes alternately
-- 	- SW5 click - flashing four diodes alternately 
--		- SW4 click - all diodes flashing
--
-- USER1 and USER2 diodes flashing one by one
------------------------------------------------------------------------
process(clk,reset)
begin
	if(reset='0')then
		LED <= "11111111";       -- all leds power-down
	elsif(clk'event and clk='1')then

		if(clk='1')then
			USER1 <= '0';
			USER2 <= '1';
		else
			USER1 <= '1';
			USER2 <= '0';
		end if;

		if(SW(3)='0')then        -- SW7 click
			if(clk_1Hz='1')then
				LED <= "10101010";
			else
				LED <= "01010101";
			end if;
		elsif(SW(2)='0')then     -- SW6 click
			if(clk_1Hz='1')then
				LED <= "11001100";
			else
				LED <= "00110011";
			end if;
		elsif(SW(1)='0')then     -- SW5 click
			if(clk_1Hz='1')then
				LED <= "11110000";
			else
				LED <= "00001111";
			end if;
		elsif(SW(0)='0')then     -- SW4 click
			if(clk_1Hz='1')then
				LED <= "00000000";
			else
				LED <= "11111111";
			end if;		
		else                     
			LED <= "00000000";    -- all leds power-up
		end if;
		
	end if;
end process; 
 
 
end arch;

