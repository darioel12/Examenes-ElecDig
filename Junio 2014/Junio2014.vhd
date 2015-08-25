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

--registro carga paralelo I--
	signal q,nq : std_logic_vector(9 downto 0);
	signal ld_dato: std_logic;
--registro carga paralelo II--
	signal q2,nq2 : std_logic_vector(9 downto 0);
	signal ld_dato2: std_logic;
--contador descendente modulo 999--
	signal cnt,n_cnt: unsigned(9 downto 0);
	signal ini_cnt: std_logic;
--MEF--
	type states is (reposo,pwm_0,pwm_1);
	signal n_state,p_state: states;

begin

--REGISTRO CARGA PARALELO-- 
	--proceso secuencial--
	process(CLK,RST)
	begin 
	if(RST='1') then q<=to_unsigned(0,10);
	elsif(CLK'event and CLK='1') then q<=nq;
	end if;
	end process;
	--proceso combinacional--
	nq<=D when D_VALID='1' else q;
	
--	PWM<= nq(9 downto 1);

--REGISTRO CARGA P/P(II)--
	--proceso secuencial--
	process(CLK,RST)
	begin 
	if(RST='1') then q2<=to_unsigned(0,10);
	elsif(CLK'event and CLK='1') then q2<=nq2;
	end if;
	end process;
	--proceso combinacional--
	nq2<=pq when ld_dato2='1' else q2;
	
--CONTADOR DESCENDENTE MODULO 999 (10 BITS) --
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then cnt<=to_unsigned(998,10);
	elsif (CLK'event and CLK='1') then cnt<=n_cnt;
	end if;
	end process;
	--proceso combinacional--
	n_cnt<= cnt-1 when cnt>=0 or ini_cnt='1' else to_unsigned(998,10);
	
	PWM<='1' when (cnt<q2) and ON_OFF<='1' else '0';
	
--MEF--
	--proceso secuencial--
	process (CLK,RST)
	begin 
	if(RST='1') then p_state<=reposo;
	elsif(CLK'event and CLK='1') then p_state<=n_state;
	end if;
	end process;
	--proceso combinacional--
	process(ON_OFF,cnt)
	begin 
	n_state<=p_state;
	PER_N<='0';
	ini_cnt<='0';
	D_VALID<='0';
	ld_dato2<='0';
	PWM<='0';
	PER_N<='0';
		case p_state is
			when reposo =>
			if(ON_OFF='1') then n_state<=pwm_0;
			end if;
			when pwm_0 =>
			ini_cnt<='1';
			D_VALID<='1';
			ld_dato<='1';
			PER_N<='1';
			if(cnt=to_unsigned(q2)) then n_state<=pwm_1;
			end if;
			when pwm_1 =>
			PWM<='1';
			if(ON_OFF='0' and cnt=to_unsigned(998,10)) then n_state<=reposo;
			elsif(ON_OFF='1' and cnt=to_unsigned(998,10)) then n_state<=pwm_0;
			end if;
		end case;
	end process;
	
end Behavioral;

