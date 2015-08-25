----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:17:53 07/28/2015 
-- Design Name: 
-- Module Name:    Junio2015 - Behavioral 
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

entity Junio2015 is
    Port ( RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           X : in  STD_LOGIC_VECTOR (7 downto 0);
           x_valido : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (7 downto 0);
           ocupado : out  STD_LOGIC);
end Junio2015;

architecture Behavioral of Junio2015 is

--CIRCUITOS AUXILIARES--
	type lut is array (0 downto 5) of signed (7 downto 0);
	signal dec_lut : lut:=(-4,32,72,32,-4);
	signal x2,x3 : signed (15 downto 0);
	signal acu_reg: std_logic_vector(15 downto 0);
	
--DATOS (REGISTRO DESPLAZAMIENTO P/P)--
	signal ld_dato: std_logic;
	signal q,nq: std_logic_vector(15 downto 0);
	signal acu_reg: std_logic_vector(15 downto 0);

--CONTADOR MÓDULO 5--
	signal cnt,n_cnt : unsigned (2 downto 0);
	signal ini_cnt : std_logic;
	
--MEF--
	type states is( reposo,salida,ocupado);
	signal n_state, p_state: states;
	signal s_hab : std_logic;
begin

--CIRCUITOS AUXILIARES--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then x3<=to_unsigned (0,16);
	elsif (CLK'event and CLK='1') then x3<=x2;
	end if;
	end process;
	
	--proceso combinacional--
	x2<= x3+(signed(X)*dec_lut(to_integer(cnt)));
	
--DATOS (RESGISTRO CARGA P/P)--
	acu_reg<=q;
	--proceso secuencial--
	process(CLK,RST)
	begin
	if (RST='1') then q<= to_unsigned(0,16);
	elsif(CLK'event and CLK='1') then q<=nq;
	end if;
	end process;
	
	--proceso combinacional--
	nq<=x3 when ld_dato='1' else q;
	
	S<=acu_reg(14 downto 7);
	
--CONTADOR MODULO 5--
	--proceso secuencial--
	process(CLK,RST)
	begin 
	if(RST='1') then cnt<="000";
	elsif(CLK'event and CLK='1') then cnt<=n_cnt;
	end if;
	end process;
	
	--proceso combinacional--
	n_cnt<=cnt+1 when cnt<5 or ini_cnt='1' else "000";
	
--MEF--
	--proceso secuencial--
	process(CLK,RST)
	begin
	if(RST='1') then p_state<='0';
	elsif (CLK'event and CLK='1') then p_state<=n_state;
	end if;
	end process;
	
	--proceso combinacional--
	process(p_state,cnt,s_hab)
	begin
	x_valido<='0';
	ocupado<='0';
	ld_dato<='0';
	ini_cnt<='0';
	n_state<=p_state;
	case p_state is
		when reposo =>
		if(s_hab='1') then n_state<=ocupado;
		end if;
		when ocupado =>
		ocupado<='1';
		x_valido<='1';
		ini_cnt<='1';
		if(cnt=4) then n_state<=salida;
		end if;
		when salida=>
		ld_dato<='1';
		if(s_hab='0') then n_state<=reposo;
		end if;
	end case;
	end process;
end Behavioral;

