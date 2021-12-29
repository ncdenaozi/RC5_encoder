library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE WORK.RC5_PKG.ALL;

entity RC5_decode is
Port (clr: IN STD_LOGIC; -- asynchronous reset
clk: IN STD_LOGIC; -- Clock signal
start_decryption: IN STD_LOGIC;
key_rdy: IN STD_LOGIC;
skey : IN S_ARRAY;
din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit input
dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0); --64-bit output
dec_done: OUT STD_LOGIC
);
end RC5_decode;

architecture Behavioral of RC5_decode is
--counter
SIGNAL i_cnt: unsigned(3 downto 0):="1100";
--A signal
SIGNAL a_reg: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL a_sub: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL a_rot: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL a: STD_LOGIC_VECTOR(31 downto 0);
--B signal
SIGNAL b_reg: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL b_sub: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL b_rot: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL b: STD_LOGIC_VECTOR(31 downto 0);

TYPE StateType IS (ST_IDLE, ST_PRE_ROUND, ST_ROUND_OP,ST_POST_ROUND,ST_READY);
SIGNAL state : StateType;

begin
process(clr, clk) begin
        if(clr = '0') then
            state<= ST_IDLE;
        elsif (clk'EVENT and clk='1') then
            case state is
                when ST_IDLE =>
                    if(start_decryption='1' and key_rdy='1') then
                            state <= ST_PRE_ROUND;  end if;
                when ST_PRE_ROUND =>
                    state <= ST_ROUND_OP;
                when ST_ROUND_OP =>
                    if (i_cnt="0001") then
                        state <= ST_POST_ROUND;  end if;
                when ST_POST_ROUND=>
                    state<=ST_READY;
                when ST_READY =>
                    state <= ST_IDLE;
                end case;
         end if;
end process;

    b_sub<=std_logic_vector(unsigned(b_reg)-unsigned(skey(to_integer(i_cnt)*2+1)));
    with a_reg(4 downto 0) SELECT
        b_rot <= b_sub(0) & b_sub(31 downto 1)  WHEN "00001",
        b_sub(1 downto 0) & b_sub(31 downto 2) WHEN "00010",
        b_sub(2 downto 0) & b_sub(31 downto 3) WHEN "00011",
        b_sub(3 downto 0) & b_sub(31 downto 4) WHEN "00100",
        b_sub(4 downto 0) & b_sub(31 downto 5) WHEN "00101",
        b_sub(5 downto 0) & b_sub(31 downto 6) WHEN "00110",
        b_sub(6 downto 0) & b_sub(31 downto 7) WHEN "00111",
        b_sub(7 downto 0) & b_sub(31 downto 8) WHEN "01000",
        b_sub(8 downto 0) & b_sub(31 downto 9) WHEN "01001",
        b_sub(9 downto 0) & b_sub(31 downto 10) WHEN "01010",
        b_sub(10 downto 0) & b_sub(31 downto 11) WHEN "01011",
        b_sub(11 downto 0) & b_sub(31 downto 12) WHEN "01100",
        b_sub(12 downto 0) & b_sub(31 downto 13) WHEN "01101",
        b_sub(13 downto 0) & b_sub(31 downto 14) WHEN "01110",
        b_sub(14 downto 0) & b_sub(31 downto 15) WHEN "01111",
        b_sub(15 downto 0) & b_sub(31 downto 16) WHEN "10000",
        b_sub(16 downto 0) & b_sub(31 downto 17) WHEN "10001",
        b_sub(17 downto 0) & b_sub(31 downto 18) WHEN "10010",
        b_sub(18 downto 0) & b_sub(31 downto 19) WHEN "10011",
        b_sub(19 downto 0) & b_sub(31 downto 20) WHEN "10100",
        b_sub(20 downto 0) & b_sub(31 downto 21) WHEN "10101",
        b_sub(21 downto 0) & b_sub(31 downto 22) WHEN "10110",
        b_sub(22 downto 0) & b_sub(31 downto 23) WHEN "10111",
        b_sub(23 downto 0) & b_sub(31 downto 24) WHEN "11000",
        b_sub(24 downto 0) & b_sub(31 downto 25) WHEN "11001",
        b_sub(25 downto 0) & b_sub(31 downto 26) WHEN "11010",
        b_sub(26 downto 0) & b_sub(31 downto 27) WHEN "11011",
        b_sub(27 downto 0) & b_sub(31 downto 28) WHEN "11100",
        b_sub(28 downto 0) & b_sub(31 downto 29) WHEN "11101",
        b_sub(29 downto 0) & b_sub(31 downto 30) WHEN "11110",
        b_sub(30 downto 0) & b_sub(31) when "11111",
        b_sub when others;
    b<=b_rot xor a_reg;
    
    a_sub<=std_logic_vector(unsigned(a_reg)-unsigned(skey(to_integer(i_cnt)*2)));
    with b(4 downto 0) SELECT
        a_rot <= a_sub(0) & a_sub(31 downto 1)  WHEN "00001",
        a_sub(1 downto 0) & a_sub(31 downto 2) WHEN "00010",
        a_sub(2 downto 0) & a_sub(31 downto 3) WHEN "00011",
        a_sub(3 downto 0) & a_sub(31 downto 4) WHEN "00100",
        a_sub(4 downto 0) & a_sub(31 downto 5) WHEN "00101",
        a_sub(5 downto 0) & a_sub(31 downto 6) WHEN "00110",
        a_sub(6 downto 0) & a_sub(31 downto 7) WHEN "00111",
        a_sub(7 downto 0) & a_sub(31 downto 8) WHEN "01000",
        a_sub(8 downto 0) & a_sub(31 downto 9) WHEN "01001",
        a_sub(9 downto 0) & a_sub(31 downto 10) WHEN "01010",
        a_sub(10 downto 0) & a_sub(31 downto 11) WHEN "01011",
        a_sub(11 downto 0) & a_sub(31 downto 12) WHEN "01100",
        a_sub(12 downto 0) & a_sub(31 downto 13) WHEN "01101",
        a_sub(13 downto 0) & a_sub(31 downto 14) WHEN "01110",
        a_sub(14 downto 0) & a_sub(31 downto 15) WHEN "01111",
        a_sub(15 downto 0) & a_sub(31 downto 16) WHEN "10000",
        a_sub(16 downto 0) & a_sub(31 downto 17) WHEN "10001",
        a_sub(17 downto 0) & a_sub(31 downto 18) WHEN "10010",
        a_sub(18 downto 0) & a_sub(31 downto 19) WHEN "10011",
        a_sub(19 downto 0) & a_sub(31 downto 20) WHEN "10100",
        a_sub(20 downto 0) & a_sub(31 downto 21) WHEN "10101",
        a_sub(21 downto 0) & a_sub(31 downto 22) WHEN "10110",
        a_sub(22 downto 0) & a_sub(31 downto 23) WHEN "10111",
        a_sub(23 downto 0) & a_sub(31 downto 24) WHEN "11000",
        a_sub(24 downto 0) & a_sub(31 downto 25) WHEN "11001",
        a_sub(25 downto 0) & a_sub(31 downto 26) WHEN "11010",
        a_sub(26 downto 0) & a_sub(31 downto 27) WHEN "11011",
        a_sub(27 downto 0) & a_sub(31 downto 28) WHEN "11100",
        a_sub(28 downto 0) & a_sub(31 downto 29) WHEN "11101",
        a_sub(29 downto 0) & a_sub(31 downto 30) WHEN "11110",
        a_sub(30 downto 0) & a_sub(31) when "11111",
        a_sub when others; 
    a<= a_rot xor b;
        
    --update A register
    process(clk,clr) begin
        IF (clr='0') THEN a_reg<=din(63 downto 32);
        elsif(clk'event and clk='1') then 
            IF(state=ST_ROUND_OP) THEN a_reg<= a;
            end if;
            IF(state=ST_POST_ROUND) THEN
                a_reg<=std_logic_vector(unsigned(a_reg)-unsigned(skey(0)));
            end if; 
        end if;        
    end process;
    
    --update B register
    process(clk,clr) begin
        IF (clr='0') THEN b_reg<=din(31 downto 0);
        elsif(clk'event and clk='1') then 
            IF(state=ST_ROUND_OP) Then b_reg<= b;
            end if;
            IF(state=ST_POST_ROUND) THEN
                b_reg<=std_logic_vector(unsigned(b_reg)-unsigned(skey(1)));
            end if; 
        end if;        
    end process;
    
    --counter
    process(clk,clr) begin
        IF (clr='0') THEN i_cnt<="1100";
        elsif (clk'EVENT AND clk='1') THEN
            IF(state=ST_ROUND_OP) THEN
                if(i_cnt="0001")THEN i_cnt<="1100";               
                else
                    i_cnt<=i_cnt-1;
                end if;
            end if;
        end if;
    end process;
    
    dout<=a_reg & b_reg;
     With state SELECT
        dec_done<='1' WHEN ST_READY,
                   '0' WHEN OTHERS;
end Behavioral;
