
-- VHDL Instantiation Created from source file sraminterface.vhd -- 15:07:32 08/14/2007
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT sraminterface
	PORT(
		clk_50MHz : IN std_logic;
		reset : IN std_logic;
		doRead : IN std_logic;
		doWrite : IN std_logic;
		readAddr : IN std_logic_vector(18 downto 0);
		writeAddr : IN std_logic_vector(18 downto 0);
		writeData : IN std_logic_vector(15 downto 0);    
		Data : INOUT std_logic_vector(15 downto 0);      
		readData : OUT std_logic_vector(15 downto 0);
		canRead : OUT std_logic;
		canWrite : OUT std_logic;
		flash_ce : OUT std_logic;
		flash_oe : OUT std_logic;
		flash_we : OUT std_logic;
		Addr : OUT std_logic_vector(18 downto 0)
		);
	END COMPONENT;

	Inst_sraminterface: sraminterface PORT MAP(
		clk_50MHz => ,
		reset => ,
		doRead => ,
		doWrite => ,
		readAddr => ,
		writeAddr => ,
		readData => ,
		writeData => ,
		canRead => ,
		canWrite => ,
		flash_ce => ,
		flash_oe => ,
		flash_we => ,
		Addr => ,
		Data => 
	);


