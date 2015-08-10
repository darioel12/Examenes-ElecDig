----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:40:51 08/10/2015 
-- Design Name: 
-- Module Name:    Septiembre2013 - Behavioral 
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

entity Septiembre2013 is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           D_VALID : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (7 downto 0);
           SERIAL_OUT : out  STD_LOGIC);
end Septiembre2013;

architecture Behavioral of Septiembre2013 is
--registro desplazamiento--
signal nq,pq : std_logic_vector(7 downto 0);
signal ld_dato: std_logic;
--contador módulo 444500--
signal cnt,n_cnt: unsigned(15 downto 0);
signal ini_cnt: std_logic;
--contador modulo 4--
signal cnt_4,n_cnt_4: unsigned(2 downto 0);
--mef--
type states is (reposo,start,b7,b6,b5,b4,b3,b2,b1,b0);
signal n_state,p_state : states;

begin

--REGISTRO DESPLAZAMIENTO--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then pq<="00000000";
	elsif (CLK'event and CLK='1') then pq<=nq;
	end if;
	end process;
	--proceso combinacional--
	nq<=D when ld_dato='1' else pq;
	
--CONTADOR MODULO 44450--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then cnt<=0;
	elsif (CLK'event and CLK='1') then cnt<=n_cnt;
	end if;
	end process;
	--proceso combinacional--
	n_cnt<=cnt+1 when cnt<44450 or ini_cnt='1' else 0;
	
--CONTADOR MODULO 4--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then cnt_4<=0;
	elsif (CLK'event and CLK='1') then cnt_4<=n_cnt_4;
	end if;
	end process;
	--proceso combinacional--
	n_cnt_4<=cnt_4+1 when cnt<4 or cnt=44449 else 0;
	
--MEF--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then p_state<=reposo;
	elsif (CLK'event and CLK='1') then p_state<=n_state;
	end if;
	end process;
	--proceso combinacional--
	process(n_cnt_4,D_VALID,p_state)
	begin
	case p_state is
		when reposo =>
		SERIAL_OUT<='0';
		ini_cnt<='0';
		if(D_VALID='1') then n_state<=start;
		end if;
		
		when start =>
		SERIAL_OUT<='0';
		ini_cnt<='1';
		if(n_cnt_4=3) then n_state<=b7;
		end if;
		
		when b7 =>
		SERIAL_OUT<=nq(7);
		ini_cnt<='1';
		if(n_cnt_4=1) then n_state<=b6;
		end if;
		
		when b6 =>
		SERIAL_OUT<=nq(6);
		ini_cnt<='1';
		if(n_cnt_4=1) then n_state<=b5;
		end if;
		
		when b5 =>
		SERIAL_OUT<=nq(5);
		ini_cnt<='1';
		if(n_cnt_4=1) then n_state<=b4;
		end if;
		
		when b4 =>
		SERIAL_OUT<=nq(4);
		ini_cnt<='1';
		if(n_cnt_4=1) then n_state<=b3;
		end if;
		
		when b3 =>
		SERIAL_OUT<=nq(3);
		ini_cnt<='1';
		if(n_cnt_4=1) then n_state<=b2;
		end if;
		
		when b2 =>
		SERIAL_OUT<=nq(2);
		ini_cnt<='1';
		if(n_cnt_4=1) then n_state<=b1;
		end if;
		
		when b1 =>
		SERIAL_OUT<=nq(1);
		ini_cnt<='1';
		if(n_cnt_4=1) then n_state<=b0;
		end if;
		
		when b0 =>
		SERIAL_OUT<=nq(0);
		ini_cnt<='1';
		if(D_VALID='0') then n_state<=reposo;
		end if;
		
	end case;
	end process;

	

end Behavioral;

