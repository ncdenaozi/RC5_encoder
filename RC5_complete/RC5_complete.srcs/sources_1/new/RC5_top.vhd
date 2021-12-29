library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE WORK.RC5_PKG.ALL;

entity RC5_top is
  Port (
clr, clk : IN STD_LOGIC;
start_encryption : IN STD_LOGIC; -- Encryption
start_decryption : IN STD_LOGIC; -- Decryption
start_generating_skey : IN STD_LOGIC; -- Indicate the input is user key
user_key : IN  STD_LOGIC_VECTOR(127 downto 0);
d_in : IN STD_LOGIC_VECTOR(63 downto 0);
d_out : OUT STD_LOGIC_VECTOR(63 downto 0);
done : OUT STD_LOGIC -- Indicate the output data is ready 
);
end RC5_top;

architecture Behavioral of RC5_top is
COMPONENT rc5_keygen is 
PORT(
clr, clk : IN STD_LOGIC;
key_in : IN STD_LOGIC;
ukey : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
skey : OUT S_ARRAY;
key_rdy : OUT STD_LOGIC);
END COMPONENT;

COMPONENT RC5_VHDL is
PORT(
clr: IN STD_LOGIC; -- asynchronous reset
clk: IN STD_LOGIC; -- Clock signal
start_encryption: IN STD_LOGIC;
key_rdy: IN STD_LOGIC;
skey : IN S_ARRAY;
din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit input
dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0); --64-bit output
enc_done: OUT STD_LOGIC);
END COMPONENT;

COMPONENT RC5_decode is
PORT(
clr: IN STD_LOGIC; -- asynchronous reset
clk: IN STD_LOGIC; -- Clock signal
start_decryption: IN STD_LOGIC;
key_rdy: IN STD_LOGIC;
skey : IN S_ARRAY;
din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit input
dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0); --64-bit output
dec_done: OUT STD_LOGIC);
END COMPONENT;


signal skey: S_ARRAY;
signal dout_enc: std_logic_vector(63 downto 0);
signal dout_dec: std_logic_vector(63 downto 0);
signal key_rdy: std_logic;
signal dec_rdy: std_logic;
signal enc_rdy: std_logic;

begin
U1: rc5_keygen PORT MAP(clr=>clr, clk=>clk, key_in=>start_generating_skey, ukey=>user_key, skey=>skey,key_rdy=>key_rdy);
U2: RC5_VHDL PORT MAP(clr=>clr, clk=>clk, start_encryption=>start_encryption, din=>d_in, key_rdy=>key_rdy, skey=>skey, dout=>dout_enc, enc_done=>enc_rdy);
U3: RC5_decode PORT MAP(clr=>clr, clk=>clk,start_decryption=>start_decryption, din=>d_in,key_rdy=>key_rdy, skey=>skey,dout=>dout_dec,dec_done=>dec_rdy);

WITH enc_rdy SELECT
    d_out<=dout_enc WHEN '1',
           dout_dec WHEN OTHERS;
--WITH dec_rdy SELECT
--    d_out<=dout_dec WHEN '1',
--            dout_enc WHEN OTHERS;  
WITH enc_rdy SELECT
    done<=enc_rdy WHEN '1',
          dec_rdy WHEN OTHERS;
--WITH dec_rdy SELECT
--    done<=dec_rdy WHEN '1',
--           '0'     WHEN OTHERS;

end Behavioral;
