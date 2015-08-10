----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:08:57 08/07/2015 
-- Design Name: 
-- Module Name:    Junio2014 - Behavioral 
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

entity Junio2014 is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (9 downto 0);
           D_VALID : in  STD_LOGIC;
           ON_OFF : in  STD_LOGIC;
           PWM : out  STD_LOGIC;
           PER_N : out  STD_LOGIC);
end Junio2014;

architecture Behavioral of Junio2014 is

--registro desplazamiento--
	signal q,nq : std_logic_vector(9 downto 0);
	signal ld_dato: std_logic;
--contador modulo 999--
	signal cnt,n_cnt: unsigned(9 downto 0);
	signal ini_cnt: std_logic;
--MEF--
	type states is (reposo,activa,perN,espera,captura);
	signal n_state,p_state: states;
	signal wt: std_logic;

begin

--REGISTRO DESPLAZAMIENTO P/P--
	--proceso secuencial--
	process(CLK,RST)
	begin 
	if(RST='1') then q<="0000000000";
	elsif(CLK'event and CLK='1') then q<=nq;
	end if;
	end process;
	--proceso combinacional--
	nq<=D when ld_dato='1' else q;
	
	PWM<= nq(9 downto 1);
	
--CONTADOR MODULO 999--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then cnt<="0000000000";
	elsif (CLK'event and CLK='1') then cnt<=n_cnt;
	end if;
	end process;
	--proceso combinacional--
	n_cnt<= cnt+1 when cnt<999 or ini_cnt='1' else "0000000000";
	
--MEF--
	--proceso secuencial--
	process (CLK,RST)
	begin 
	if(RST='1') then p_state<=reposo;
	elsif(CLK'event and CLK='1') then p_state<=n_state;
	end if;
	end process;
	--proceso combinacional--
	process(ON_OFF,n_cnt,wt)
	begin 
	n_state<=p_state;
		case p_state is
			when reposo =>
			ld_dato<='0';
			PER_N<='0';
			ini_cnt<='0';
			D_VALID<='0';
			if(ON_OFF='1') then n_state<=activa;
			end if;
			when activa =>
			ini_cnt<='1';
			ld_dato<='0';
			PER_N<='0';
			D_VALID<='0';
			if(n_cnt=998) then n_state<=perN;
			end if;
			when perN =>
			PER_N<='1';
			ini_cnt<='0';
			ld_dato<='0';
			D_valid<='0';
			if(wt='1') then n_state<=espera;
			end if;
			when espera =>
			ld_dato<='0';
			PER_N<='0';
			ini_cnt<='1';
			D_VALID<='0';
			if(n_cnt=998) then n_state<=captura;
			end if;
			when captura =>
			ld_dato<='1';
			D_VALID<='1';
			PER_N<='0';
			ini_cnt<='0';
			if(ON_OFF='0') then n_state<=reposo;
			end if;
		end case;
	end process;
	
end Behavioral;

