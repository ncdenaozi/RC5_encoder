library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE WORK.RC5_PKG.ALL;

entity RC5_VHDL is
 Port (clr: IN STD_LOGIC; -- asynchronous reset
clk: IN STD_LOGIC; -- Clock signal
start_encryption: IN STD_LOGIC;
key_rdy: IN STD_LOGIC;
skey : IN S_ARRAY;
din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit input
dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0); --64-bit output
enc_done: OUT STD_LOGIC
);
end RC5_VHDL;

architecture Behavioral of RC5_VHDL is
--counter
SIGNAL i_cnt: unsigned(3 downto 0):="0001";
--A signal
SIGNAL a_reg: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL a_xor: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL a_rot: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL a: STD_LOGIC_VECTOR(31 downto 0);
--B signal
SIGNAL b_reg: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL b_xor: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL b_rot: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL b: STD_LOGIC_VECTOR(31 downto 0);

TYPE StateType IS (ST_IDLE, ST_PRE_ROUND, ST_ROUND_OP,ST_READY);
SIGNAL state : StateType;

begin
    process(clr, clk) begin
        if(clr = '0') then
            state<= ST_IDLE;
        elsif (clk'EVENT and clk='1') then
            case state is
                when ST_IDLE =>
                    if(start_encryption='1' and key_rdy='1') then
                            state <= ST_PRE_ROUND;  end if;
                when ST_PRE_ROUND =>
                    state <= ST_ROUND_OP;
                when ST_ROUND_OP =>
                    if (i_cnt="1100") then
                        state <= ST_READY;  end if;
                when ST_READY =>
                    state <= ST_IDLE;
                end case;
         end if;
end process;
    
    a_xor<=a_reg xor b_reg;
    with b_reg(4 downto 0) SELECT
        a_rot <= a_xor(30 downto 0) & a_xor(31) WHEN "00001",
        a_xor(29 downto 0) & a_xor(31 downto 30) WHEN "00010",
        a_xor(28 downto 0) & a_xor(31 downto 29) WHEN "00011",
        a_xor(27 downto 0) & a_xor(31 downto 28) WHEN "00100",
        a_xor(26 downto 0) & a_xor(31 downto 27) WHEN "00101",
        a_xor(25 downto 0) & a_xor(31 downto 26) WHEN "00110",
        a_xor(24 downto 0) & a_xor(31 downto 25) WHEN "00111",
        a_xor(23 downto 0) & a_xor(31 downto 24) WHEN "01000",
        a_xor(22 downto 0) & a_xor(31 downto 23) WHEN "01001",
        a_xor(21 downto 0) & a_xor(31 downto 22) WHEN "01010",
        a_xor(20 downto 0) & a_xor(31 downto 21) WHEN "01011",
        a_xor(19 downto 0) & a_xor(31 downto 20) WHEN "01100",
        a_xor(18 downto 0) & a_xor(31 downto 19) WHEN "01101",
        a_xor(17 downto 0) & a_xor(31 downto 18) WHEN "01110",
        a_xor(16 downto 0) & a_xor(31 downto 17) WHEN "01111",
        a_xor(15 downto 0) & a_xor(31 downto 16) WHEN "10000",
        a_xor(14 downto 0) & a_xor(31 downto 15) WHEN "10001",
        a_xor(13 downto 0) & a_xor(31 downto 14) WHEN "10010",
        a_xor(12 downto 0) & a_xor(31 downto 13) WHEN "10011",
        a_xor(11 downto 0) & a_xor(31 downto 12) WHEN "10100",
        a_xor(10 downto 0) & a_xor(31 downto 11) WHEN "10101",
        a_xor(9 downto 0) & a_xor(31 downto 10) WHEN "10110",
        a_xor(8 downto 0) & a_xor(31 downto 9) WHEN "10111",
        a_xor(7 downto 0) & a_xor(31 downto 8) WHEN "11000",
        a_xor(6 downto 0) & a_xor(31 downto 7) WHEN "11001",
        a_xor(5 downto 0) & a_xor(31 downto 6) WHEN "11010",
        a_xor(4 downto 0) & a_xor(31 downto 5) WHEN "11011",
        a_xor(3 downto 0) & a_xor(31 downto 4) WHEN "11100",
        a_xor(2 downto 0) & a_xor(31 downto 3) WHEN "11101",
        a_xor(1 downto 0) & a_xor(31 downto 2) WHEN "11110",
        a_xor(0) & a_xor(31 downto 1) when "11111",
        a_xor when others;
    --Add
    a<=std_logic_vector(unsigned(a_rot)+unsigned(skey(to_integer(i_cnt)*2)));
    
    b_xor <=b_reg xor a;    
    with a(4 downto 0) SELECT
        b_rot <= b_xor(30 downto 0) & b_xor(31) WHEN "00001",
        b_xor(29 downto 0) & b_xor(31 downto 30) WHEN "00010",
        b_xor(28 downto 0) & b_xor(31 downto 29) WHEN "00011",
        b_xor(27 downto 0) & b_xor(31 downto 28) WHEN "00100",
        b_xor(26 downto 0) & b_xor(31 downto 27) WHEN "00101",
        b_xor(25 downto 0) & b_xor(31 downto 26) WHEN "00110",
        b_xor(24 downto 0) & b_xor(31 downto 25) WHEN "00111",
        b_xor(23 downto 0) & b_xor(31 downto 24) WHEN "01000",
        b_xor(22 downto 0) & b_xor(31 downto 23) WHEN "01001",
        b_xor(21 downto 0) & b_xor(31 downto 22) WHEN "01010",
        b_xor(20 downto 0) & b_xor(31 downto 21) WHEN "01011",
        b_xor(19 downto 0) & b_xor(31 downto 20) WHEN "01100",
        b_xor(18 downto 0) & b_xor(31 downto 19) WHEN "01101",
        b_xor(17 downto 0) & b_xor(31 downto 18) WHEN "01110",
        b_xor(16 downto 0) & b_xor(31 downto 17) WHEN "01111",
        b_xor(15 downto 0) & b_xor(31 downto 16) WHEN "10000",
        b_xor(14 downto 0) & b_xor(31 downto 15) WHEN "10001",
        b_xor(13 downto 0) & b_xor(31 downto 14) WHEN "10010",
        b_xor(12 downto 0) & b_xor(31 downto 13) WHEN "10011",
        b_xor(11 downto 0) & b_xor(31 downto 12) WHEN "10100",
        b_xor(10 downto 0) & b_xor(31 downto 11) WHEN "10101",
        b_xor(9 downto 0) & b_xor(31 downto 10) WHEN "10110",
        b_xor(8 downto 0) & b_xor(31 downto 9) WHEN "10111",
        b_xor(7 downto 0) & b_xor(31 downto 8) WHEN "11000",
        b_xor(6 downto 0) & b_xor(31 downto 7) WHEN "11001",
        b_xor(5 downto 0) & b_xor(31 downto 6) WHEN "11010",
        b_xor(4 downto 0) & b_xor(31 downto 5) WHEN "11011",
        b_xor(3 downto 0) & b_xor(31 downto 4) WHEN "11100",
        b_xor(2 downto 0) & b_xor(31 downto 3) WHEN "11101",
        b_xor(1 downto 0) & b_xor(31 downto 2) WHEN "11110",
        b_xor(0) & b_xor(31 downto 1) when "11111",
        b_xor when others;
    b<=std_logic_vector(unsigned(b_rot)+unsigned(skey(to_integer(i_cnt)*2+1)));
    
    
    --update A register
    process(clk,clr) begin
        IF (clr='0') THEN 
            a_reg<=din(63 downto 32);
        elsif(clk'event and clk='1') then
            IF(state=ST_PRE_ROUND) THEN
                a_reg<=std_logic_vector(unsigned(a_reg)+unsigned(skey(0)));
            end if; 
            IF(state=ST_ROUND_OP) THEN a_reg<= a;
            END IF;
        end if;        
    end process;
    
    --update B register
    process(clk,clr) begin
        IF (clr='0') THEN b_reg<=din(31 downto 0);
        elsif(clk'event and clk='1') then 
            IF(state=ST_PRE_ROUND) THEN
                b_reg<=std_logic_vector(unsigned(b_reg)+unsigned(skey(1)));
            end if; 
            IF(state=ST_ROUND_OP) THEN b_reg<= b;
            END IF;
        end if;        
    end process;
    
    --counter
    process(clk,clr) begin
        IF (clr='0') THEN i_cnt<="0001";
        elsif (clk'EVENT AND clk='1') THEN
            IF(state=ST_ROUND_OP) THEN 
            if(i_cnt="1100")THEN i_cnt<="0001";               
            else
                i_cnt<=i_cnt+1;
            end if;
            end if;
        end if;
    end process;
    
    dout<=a_reg & b_reg;
    With state SELECT
        enc_done<='1' WHEN ST_READY,
                   '0' WHEN OTHERS;
    
end Behavioral;
