library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE WORK.RC5_PKG.ALL;

entity RC5_keygen is
Port ( 
clr: STD_LOGIC;
clk : STD_LOGIC;
key_in : STD_LOGIC;
ukey : STD_LOGIC_VECTOR(127 DOWNTO 0);
skey : OUT S_ARRAY;
key_rdy : OUT STD_LOGIC);
end RC5_keygen;

architecture Behavioral of RC5_keygen is

SIGNAL a_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_tmp1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_tmp2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ab_tmp : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_tmp1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_tmp2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL l_arr : L_ARRAY;
SIGNAL s_arr_tmp: S_ARRAY;
SIGNAL i_cnt : INTEGER RANGE 0 TO 25; 
SIGNAL j_cnt : INTEGER RANGE 0 TO 3; 
SIGNAL k_cnt : INTEGER RANGE 0 TO 77; 

TYPE StateType IS (ST_IDLE, ST_KEY_INIT, ST_KEY_EXP,ST_READY);
SIGNAL state : StateType;

begin

PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN 
        s_arr_tmp(0)<= "10110111111000010101000101100011";
        s_arr_tmp(1)<= "01010110000110001100101100011100";
        s_arr_tmp(2)<= "11110100010100000100010011010101";
        s_arr_tmp(3)<= "10010010100001111011111010001110";
        s_arr_tmp(4)<= "00110000101111110011100001000111";
        s_arr_tmp(5)<= "11001110111101101011001000000000";
        s_arr_tmp(6)<= "01101101001011100010101110111001";
        s_arr_tmp(7)<= "00001011011001011010010101110010";
        s_arr_tmp(8)<= "10101001100111010001111100101011";
        s_arr_tmp(9)<= "01000111110101001001100011100100";
        s_arr_tmp(10)<= "11100110000011000001001010011101";
        s_arr_tmp(11)<= "10000100010000111000110001010110";
        s_arr_tmp(12)<= "00100010011110110000011000001111";
        s_arr_tmp(13)<= "11000000101100100111111111001000";
        s_arr_tmp(14)<= "01011110111010011111100110000001";
        s_arr_tmp(15)<= "11111101001000010111001100111010";
        s_arr_tmp(16)<= "10011011010110001110110011110011";
        s_arr_tmp(17)<= "00111001100100000110011010101100";
        s_arr_tmp(18)<= "11010111110001111110000001100101";
        s_arr_tmp(19)<= "01110101111111110101101000011110";
        s_arr_tmp(20)<= "00010100001101101101001111010111";
        s_arr_tmp(21)<= "10110010011011100100110110010000";
        s_arr_tmp(22)<= "01010000101001011100011101001001";
        s_arr_tmp(23)<= "11101110110111010100000100000010";
        s_arr_tmp(24)<= "10001101000101001011101010111011";
        s_arr_tmp(25)<= "00101011010011000011010001110100";
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_EXP) THEN s_arr_tmp(i_cnt)<=a_tmp2;
        END IF;
    END IF;
END process;

PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN
        l_arr(0)<=(OTHERS=>'0');
        l_arr(1)<=(OTHERS=>'0');
        l_arr(2)<=(OTHERS=>'0');
        l_arr(3)<=(OTHERS=>'0');
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_INIT) THEN
            l_arr(0)<=ukey(31 DOWNTO 0);
            l_arr(1)<=ukey(63 DOWNTO 32);
            l_arr(2)<=ukey(95 DOWNTO 64);
            l_arr(3)<=ukey(127 DOWNTO 96);
        ELSIF(state=ST_KEY_EXP) THEN
            l_arr(j_cnt)<=b_tmp2;
        END IF;
    END IF;
END process;

PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN
        state<=ST_IDLE;
    ELSIF(clk'EVENT AND clk='1') THEN
        CASE state IS
            WHEN ST_IDLE=> 
                IF(key_in='1') THEN state<=ST_KEY_INIT; END IF;
            WHEN ST_KEY_INIT=>
                state<=ST_KEY_EXP;
            WHEN ST_KEY_EXP=>
                IF(k_cnt=77) THEN state<=ST_READY; END IF;
            WHEN ST_READY=>
                state<=ST_IDLE;
        END CASE;
    END IF;
END PROCESS;

PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN
        a_reg<=(OTHERS=>'0' );
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_EXP) THEN a_reg<=a_tmp2;
        END IF;
    END IF;
END PROCESS;

PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN
        b_reg<=(OTHERS=>'0' );
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_EXP) THEN b_reg<=b_tmp2;
        END IF;
    END IF;
END PROCESS;

--i 0 to 25 counter
PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN i_cnt<=0;
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_EXP) THEN
            IF(i_cnt=25) THEN i_cnt<=0;
            ELSE i_cnt<=i_cnt+1;
            END IF;
        END IF;
    END IF;
END PROCESS;

--j 0 to 3 counter
PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN j_cnt<=0;
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_EXP) THEN
            IF(j_cnt=3) THEN j_cnt<=0;
            ELSE j_cnt<=j_cnt+1;
            END IF;
        END IF;
    END IF;
END PROCESS;

--k 0 to 77 counter
PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN k_cnt<=0;
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_EXP) THEN
            IF(k_cnt=77) THEN k_cnt<=0;
            ELSE k_cnt<=k_cnt+1;
            END IF;
        END IF;
    END IF;
END PROCESS;

a_tmp1<=std_logic_vector(unsigned(s_arr_tmp(i_cnt))+unsigned(a_reg)+unsigned(b_reg)); 
a_tmp2<=a_tmp1(28 DOWNTO 0) & a_tmp1(31 DOWNTO 29);

ab_tmp<=std_logic_vector(unsigned(a_tmp2)+unsigned(b_reg));
b_tmp1<=std_logic_vector(unsigned(l_arr(j_cnt))+unsigned(ab_tmp));
WITH ab_tmp(4 DOWNTO 0) SELECT
    b_tmp2 <= b_tmp1(30 downto 0) & b_tmp1(31) WHEN "00001",
        b_tmp1(29 downto 0) & b_tmp1(31 downto 30) WHEN "00010",
        b_tmp1(28 downto 0) & b_tmp1(31 downto 29) WHEN "00011",
        b_tmp1(27 downto 0) & b_tmp1(31 downto 28) WHEN "00100",
        b_tmp1(26 downto 0) & b_tmp1(31 downto 27) WHEN "00101",
        b_tmp1(25 downto 0) & b_tmp1(31 downto 26) WHEN "00110",
        b_tmp1(24 downto 0) & b_tmp1(31 downto 25) WHEN "00111",
        b_tmp1(23 downto 0) & b_tmp1(31 downto 24) WHEN "01000",
        b_tmp1(22 downto 0) & b_tmp1(31 downto 23) WHEN "01001",
        b_tmp1(21 downto 0) & b_tmp1(31 downto 22) WHEN "01010",
        b_tmp1(20 downto 0) & b_tmp1(31 downto 21) WHEN "01011",
        b_tmp1(19 downto 0) & b_tmp1(31 downto 20) WHEN "01100",
        b_tmp1(18 downto 0) & b_tmp1(31 downto 19) WHEN "01101",
        b_tmp1(17 downto 0) & b_tmp1(31 downto 18) WHEN "01110",
        b_tmp1(16 downto 0) & b_tmp1(31 downto 17) WHEN "01111",
        b_tmp1(15 downto 0) & b_tmp1(31 downto 16) WHEN "10000",
        b_tmp1(14 downto 0) & b_tmp1(31 downto 15) WHEN "10001",
        b_tmp1(13 downto 0) & b_tmp1(31 downto 14) WHEN "10010",
        b_tmp1(12 downto 0) & b_tmp1(31 downto 13) WHEN "10011",
        b_tmp1(11 downto 0) & b_tmp1(31 downto 12) WHEN "10100",
        b_tmp1(10 downto 0) & b_tmp1(31 downto 11) WHEN "10101",
        b_tmp1(9 downto 0) & b_tmp1(31 downto 10) WHEN "10110",
        b_tmp1(8 downto 0) & b_tmp1(31 downto 9) WHEN "10111",
        b_tmp1(7 downto 0) & b_tmp1(31 downto 8) WHEN "11000",
        b_tmp1(6 downto 0) & b_tmp1(31 downto 7) WHEN "11001",
        b_tmp1(5 downto 0) & b_tmp1(31 downto 6) WHEN "11010",
        b_tmp1(4 downto 0) & b_tmp1(31 downto 5) WHEN "11011",
        b_tmp1(3 downto 0) & b_tmp1(31 downto 4) WHEN "11100",
        b_tmp1(2 downto 0) & b_tmp1(31 downto 3) WHEN "11101",
        b_tmp1(1 downto 0) & b_tmp1(31 downto 2) WHEN "11110",
        b_tmp1(0) & b_tmp1(31 downto 1) when "11111",
        b_tmp1 when others;
        
  --output logic
  PROCESS(clk,clr) BEGIN
    IF(clr='0') THEN 
        key_rdy<='0';
    ElSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_READY) THEN
            skey<=s_arr_tmp;
            key_rdy<='1';
        End if;
    End if;
  END PROCESS;
 
end Behavioral;
