----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:59:42 05/08/2019 
-- Design Name: 
-- Module Name:    datapath - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           selUAL : in  STD_LOGIC_VECTOR (2 downto 0);
			  selMux : in  STD_LOGIC;
           cargaN : in  STD_LOGIC;
			  cargaZ : in  STD_LOGIC;
           cargaAC : in  STD_LOGIC;
           cargaPC : in  STD_LOGIC;
           cargaRI : in  STD_LOGIC;
           cargaREM : in  STD_LOGIC;
           cargaRDM : in  STD_LOGIC;
           decoder : out  STD_LOGIC_VECTOR (7 downto 0);
           outRDM : out  STD_LOGIC_VECTOR (7 downto 0);
           outREM : out  STD_LOGIC_VECTOR (7 downto 0);
           outNZ : out  STD_LOGIC_VECTOR (1 downto 0) -- N => bit (1)
																		-- Z => bit (0)
				);
end datapath;

architecture Behavioral of datapath is

signal AC : std_logic_vector (7 downto 0);
signal regRDM : std_logic_vector (7 downto 0);
signal regREM : std_logic_vector (7 downto 0);
signal PC : std_logic_vector (7 downto 0);
signal opcode : std_logic_vector (7 downto 0);




begin


---------------multiplexador do REM--------------
	process(clk,reset,selMux,regREM)
	begin
		if reset = '1' then
			regREM <= (others => '0');
		elsif rising_edge(clk) then
			if cargaREM = '1' then
				case selMux is
					when '1' => regREM <= PC;
					when '0' => regREM <= regRDM;
					when others => regREM <= regREM;
				end case;
			end if;
		end if;
		outREM <= regREM;
	end process;
	
-------------------UAL---------------------------
	process(clk,reset,selUAL)
	begin
		if reset = '1' then
			AC <= (others => '0');
		elsif rising_edge(clk) then
			if cargaAC = '1' then
				case selUAL is
					when "000" => AC <= AC + regRDM; 	-- X+Y
					when "001" => AC <= AC and regRDM;	-- X and Y
					when "010" => AC <= AC or regRDM;	-- X or Y
					when "011" => AC <= not AC;			-- not X
					when "100" => AC <= regRDM;			-- Y
					when "101" => AC <= AC - regRDM;		-- X-Y
					when others => AC <= AC;
				end case;
			end if;
			
			if cargaZ = '1' then
				if AC = "00000000" then
					outNZ(0) <= '1';
				else
					outNZ(0) <= '0';
				end if;
			end if;
			
			if cargaN = '1' then
				if AC(7) = '1' then
					outNZ(1) <= '1';
				else
					outNZ(1) <= '0';
				end if;
			end if;
		end if;
	end process;

------------------Decoder-------------------------
	process(clk,regRDM)
	begin
		if rising_edge(clk) then
			if cargaRI = '1' then
				opcode <= regRDM;
				case opcode(7 downto 4) is
					when "0000" => decoder <= "0000" & "0000";		--NOP
					when "0001" =>	decoder <= "0001" & "0000";		--STA
					when "0010" =>	decoder <= "0010" & "0000";		--LDA
					when "0011" =>	decoder <= "0011" & "0000";		--ADD
					when "0100" =>	decoder <= "0100" & "0000";		--OR
					when "0101" =>	decoder <= "0101" & "0000";		--AND
					when "0110" =>	decoder <= "0110" & "0000";		--NOT
					when "0111" => decoder <= "0111" & "0000";
					when "1000" =>	decoder <= "1000" & "0000";		--JMP
					when "1001" =>	decoder <= "1001" & "0000";		--JN
					when "1010" =>	decoder <= "1010" & "0000";		--JZ
					when "1111" =>	decoder <= "1111" & "0000";		--HLT
					when others =>	opcode <= opcode;		--dont care									
				end case;
			end if;
		end if;
	end process;

end Behavioral;

