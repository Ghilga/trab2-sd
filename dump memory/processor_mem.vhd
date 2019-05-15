----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:15:12 10/04/2011 
-- Design Name: 
-- Module Name:    processor_mem - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity processor_mem is
    Port ( mclk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           button : in  STD_LOGIC;
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           segment : out  STD_LOGIC_VECTOR (6 downto 0);
           HSYNC : out std_logic;
		   VSYNC : out std_logic;
		   OutRed : out std_logic_vector(2 downto 0);
		   OutGreen : out std_logic_vector(2 downto 0);
		   OutBlue : out std_logic_vector(1 downto 0));
end processor_mem;

architecture Behavioral of processor_mem is

signal addra : std_logic_vector(7 downto 0);
signal douta : std_logic_vector(31 downto 0);

begin

-- Exemplo de uso do dump de memória (entity work.memoryDump):

--	* criar memória bram tipo single port rom 
--    com o nome mem256p32bit com 256 posições de 32 bits cada
--  * inicialize a memória com o uso de um arquivo .coe ou escolha
--    a opção 'fill remaining' com um valor para preencher
--	* utilizar os botões btn1 (incrementa memória) 
--    e btn0 (volta para posição 125)

dump_mem: entity work.memoryDump
	port map (
		mclk => mclk,
		rst  => rst,
		button => button,
		dout => douta,
		addr => addra,
		an => an,
		segment => segment,
		HSYNC => HSYNC,
		VSYNC => VSYNC,
		OutRed => OutRed,
		OutGreen => OutGreen,
		OutBlue => OutBlue);

-- dump de uma memória ROM
proc_mem: entity work.mem256p32bit
	port map (
		clka => mclk,
		addra => addra,
		douta => douta);

end Behavioral;

