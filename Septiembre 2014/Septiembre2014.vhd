----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:18:39 07/28/2015 
-- Design Name: 
-- Module Name:    Septiembre2014 - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Septiembre2014 is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           t_ini : in  STD_LOGIC;
           ACK : in  STD_LOGIC;
           libre : out  STD_LOGIC;
           RPT : out  STD_LOGIC;
           error : out  STD_LOGIC);
end Septiembre2014;

architecture Behavioral of Septiembre2014 is
--circuitos auxiliares--
	signal ACK_1,ACK_2: std_logic;
	
--contador modulo 1000000--
	signal cnt,n_cnt: unsigned(19 downto 0);
	signal ini_cnt: std_logic;
	
--contador modulo 3--
	signal cnt_3,n_cnt_3: unsigned(1 downto 0);
	signal ini_cnt_3: std_logic;
	
--mef--
	type states is (reposo,espera,repite,error);
	signal p_state,n_state: states;
begin

--CIRCUITOS AUXILIARES (2 FF'S)--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then
	ACK_1<='0';
	ACK_2<='0';
	elsif(CLK'event and CLK='1') then
	ACK_1<=ACK;
	ACK_2<=ACK_1;
	end if;
	end process;
	
--CONTADOR MÓDULO 1000000--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then cnt<="00000000000000000000";
	elsif (CLK'event and CLK='1') then cnt<=n_cnt;
	end if;
	end process;
	
	--proceso combinacional--
	n_cnt<=cnt+1 when cnt<1000000 or ini_cnt='1' else "00000000000000000000";
	
--CONTADOR MODULO 3--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then cnt_3<="00";
	elsif(CLK'event and CLK='1') then cnt_3<=n_cnt_3;
	end if;
	end process;
	
	--proceso combinacional--
	n_cnt_3<=cnt_3+1 when cnt_3<3 else "00";


--MEF--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then p_state<=reposo;
	elsif (CLK'event and CLK='1') then p_state<=n_state;
	end if;
	end process;
	
	--proceso combinacional--
	process(p_state,RST,t_ini,ACK_2)
	begin
	case p_state is
		when reposo =>
			libre<='1';
			RPT<='0';
			error<='0';
			ini_cnt<='0';
			ini_cnt_3<='0';
			if(t_ini='1') then n_state<=espera;
			end if;
		when espera=>
			libre<='0';
			RPT<='0';
			error<='0';
			ini_cnt<='1';
			ini_cnt_3<='0';
			if(ACK_2='1') then n_state<=reposo;
			elsif(n_cnt=999999) then n_state<=repite;
			end if;
		when repite=>
			libre<='0';
			RPT<='1';
			ini_cnt_3<='1';
			error<='0';
			ini_cnt<='0';
			if(n_cnt_3=2) then n_state<=error;
			end if;
		when error=>
			libre<='0';
			ini_cnt<='0';
			ini_cnt_3<='0';
			error<='1';
			RPT<='0';
			if(t_ini='0') then n_state<=reposo;
			end if;
		end case;
	end process;
	
	
end Behavioral;