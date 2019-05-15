----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:12:05 09/26/2011 
-- Design Name: 
-- Module Name:    example2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memoryDump is
	port (
	-- clock 50MHz
	mclk : in std_logic;
	rst : in std_logic;
	button : in std_logic;
	-- memory to be dumpped	
	dout : in std_logic_vector(31 downto 0);
	addr : out std_logic_vector(7 downto 0);
	-- display 7 seg
	an: out std_logic_vector(3 downto 0);
	segment: out std_logic_vector(6 downto 0);
	-- vga
	HSYNC : out std_logic;
	VSYNC : out std_logic;
	OutRed : out std_logic_vector(2 downto 0);
	OutGreen : out std_logic_vector(2 downto 0);
	OutBlue : out std_logic_vector(1 downto 0));
	
end memoryDump;

architecture Behavioral of memoryDump is

-- clocks
signal  clk25MHz: std_logic := '0';
signal  clkKHz: std_logic := '0';

signal  addr_tmp : std_logic_vector(7 downto 0) := x"00";

-- vga
signal  hcount : std_logic_vector(10 downto 0);
signal  vcount : std_logic_vector(10 downto 0);
signal  blank : std_logic;
signal  vga_number : std_logic_vector(6 downto 0);
signal  vga_out: std_logic_vector (3 downto 0) := x"0";

-- button
signal  reg: std_logic_vector(7 downto 0) := "00000000";

-- diplay
signal  refresh : std_logic_vector (1 downto 0) := "00"; 
signal  digit, digit0, digit1, digit2, digit3 : std_logic_vector(7 downto 0):= "00000000";
signal  div: integer := 0;
signal  delta : integer := 0;

begin

vga_crtl: entity work.vga_controller_640_60
port map (
   rst => rst,
   pixel_clk => clk25MHz,
   HS => HSYNC,
   VS => VSYNC,
   hcount => hcount,
   vcount => vcount,
   blank => blank);

clock0: process (mclk)
begin
	if mclk'event and mclk='1' then
		clk25MHz <= not clk25MHz;
	end if;
end process;

clock1: process (mclk)
begin
	if mclk'event and mclk='1' then
		div <= div + 1;
		if div = 50000 then
			clkKHz <= not clkKHz;
			div <= 0;
		end if;
	end if;
end process;

get_input: process (clkKHz, rst)
begin
		if rst = '1' then
			-- reset value is 150 decimal
			addr_tmp <= x"96";
			digit0 <= x"00";
			digit1 <= x"05";
			digit2 <= x"01";
			digit3 <= x"00";
		elsif clkKHz'event and clkKHz='1' then		
			if reg = "11111110" then
			
				addr_tmp <= addr_tmp + 1;

				digit0 <= digit0 + 1;
				if digit0 = 9 then
					digit0 <= x"00";
					digit1 <= digit1 + 1;
					if digit1 = 9 then
						digit1 <= x"00";
						digit2 <= digit2 + 1;
						if digit2 = 9 then
							digit2 <= x"00";
							digit3 <= digit3 + 1;
							if digit3 = 9 then
								digit3 <= x"00";
							end if;
						end if;
					end if;
				end if;
			
			end if;
		
			if button = '1' then
				reg(0) <= '1';
			else
				reg(0) <= '0';
			end if;
	
			for i in 0 to 6 loop 
				reg(i+1) <= reg(i);
			end loop;	
	end if;
end process;

display_refresh: process(clkKHz)
begin
	if clkKHz='1' and clkKHz'event then
		refresh <= refresh + 1;
	end if;
end process;

vga_ctrl: process(clk25MHz)

-- vcount - lines
-- hcount - columns
-- Hexadecimal Memory Dump
--
--    === A ===
--    =       =
--    B       F
--    =       =
--    === G ===    ------>  DELTA
--    =       =
--    C       E
--    =       =
--    === D ===

begin
	if clk25MHz='1' and clk25MHz'event then	
		if blank = '0' then
			-- digit 1
			if hcount < (20 + delta) then
				OutRed <= "000";
				OutGreen <= "000";
				OutBlue <= "00";
			elsif vcount < 10 and hcount <= (60 + delta) and vga_number(0) = '1' then -- A
				OutRed <= "111";
				OutGreen <= "000";
				OutBlue <= "00";
			elsif (vcount >= 10 and vcount < 50) and hcount <= (30 + delta) and vga_number(1) = '1' then -- B
				OutRed <= "111";
				OutGreen <= "000";
				OutBlue <= "00";
			elsif (vcount >= 60 and vcount < 100) and hcount <= (30 + delta) and vga_number(2) = '1' then -- C
				OutRed <= "111";
				OutGreen <= "000";
				OutBlue <= "00";
			elsif (vcount >= 100 and vcount <= 110) and hcount <= (60 + delta) and vga_number(3) = '1' then -- D
				OutRed <= "111";
				OutGreen <= "000";
				OutBlue <= "00";
			elsif (vcount >= 60 and vcount <= 100) and (hcount >= (50  + delta) and hcount <= (60 + delta)) and vga_number(4) = '1' then -- E
				OutRed <= "111";
				OutGreen <= "000";
				OutBlue <= "00";
			elsif (vcount >= 10 and vcount < 50) and (hcount >= (50 + delta) and hcount <= (60 + delta)) and vga_number(5) = '1' then -- F
				OutRed <= "111";
				OutGreen <= "000";
				OutBlue <= "00";
			elsif (vcount >= 50 and vcount < 60) and (hcount >= (20 + delta) and hcount <= (60 + delta)) and vga_number(6) = '1' then -- G
				OutRed <= "111";
				OutGreen <= "000";
				OutBlue <= "00";
			else
				OutRed <= "000";
				OutGreen <= "000";
				OutBlue <= "00";
			end if;
		else
			OutRed <= "000";
			OutGreen <= "000";
			OutBlue <= "00";
		end if;
		
		if hcount < 60 then
			delta <= 0;
			vga_out <= dout(31 downto 28);
		elsif hcount = 60 then
			delta <= 50;
			vga_out <= dout(27 downto 24);
		elsif hcount = 110 then
			delta <= delta + 50;	
			vga_out <= dout(23 downto 20);
		elsif hcount = 160 then
			delta <= delta + 50;
			vga_out <= dout(19 downto 16);
		elsif hcount = 210 then
			delta <= delta + 50;
			vga_out <= dout(15 downto 12);
		elsif hcount = 260 then
			delta <= delta + 50;
			vga_out <= dout(11 downto 8);
		elsif hcount = 310 then
			delta <= delta + 50;
			vga_out <= dout(7 downto 4);
		elsif hcount = 360 then
			delta <= delta + 50;
			vga_out <= dout(3 downto 0);
		end if;
		
	end if;
end process;
	
vga_number <= "0111111" when vga_out = x"0" else
	 "0110000" when vga_out = x"1" else
	 "1101101" when vga_out = x"2" else 
	 "1111001" when vga_out = x"3" else 
	 "1110010" when vga_out = x"4" else 
	 "1011011" when vga_out = x"5" else 
	 "1011111" when vga_out = x"6" else 
	 "0110001" when vga_out = x"7" else 
	 "1111111" when vga_out = x"8" else 
	 "1111011" when vga_out = x"9" else
	 "1110111" when vga_out = x"a" else
	 "1011110" when vga_out = x"b" else
	 "0001111" when vga_out = x"c" else
	 "1111100" when vga_out = x"d" else
	 "1101111" when vga_out = x"e" else
	 "1000111" when vga_out = x"f" else
	 "0111111";

an(3) <= '0' when refresh = "11" else '1';
an(2) <= '0' when refresh = "10" else '1';
an(1) <= '0' when refresh = "01" else '1';
an(0) <= '0' when refresh = "00" else '1';

digit <= digit0 when refresh = "00" else -- 0
			digit1 when refresh = "01" else -- 1
			digit2 when refresh = "10" else -- 2
			digit3;                         -- 3

segment <= "1000000" when digit = x"00" else
	 "1111001" when digit = x"01" else
	 "0100100" when digit = x"02" else 
	 "0110000" when digit = x"03" else 
	 "0011001" when digit = x"04" else 
	 "0010010" when digit = x"05" else 
	 "0000010" when digit = x"06" else 
	 "1111000" when digit = x"07" else 
	 "0000000" when digit = x"08" else 
	 "0010000" when digit = x"09" else
	 "1000000";
	 
addr <= addr_tmp;

end Behavioral;