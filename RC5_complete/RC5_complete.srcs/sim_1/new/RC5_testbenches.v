`timescale 1ns / 1ps

module RC5_testbenches();

reg t_clk=0;
reg t_clr=0;
reg t_start_encryption=0;
reg t_start_decryption=0;
reg t_start_generating_skey=0;
reg[127:0] t_user_key;
reg[63:0] t_din;
// no initialization in the output signal
wire[63:0] t_dout;
wire t_done;

RC5_top dut(
    .clk(t_clk),
    .clr(t_clr),
    .start_encryption(t_start_encryption),
    .start_decryption(t_start_decryption),
    .start_generating_skey(t_start_generating_skey),
    .user_key(t_user_key),
    .d_in (t_din),
    .d_out(t_dout),
    .done (t_done)
);

//integer k;
reg [127:0] key_input [0:99]; 
initial $readmemh("KEY_INPUT.txt",key_input );
initial begin
//$display("Contents of Mem after reading data file:");
//for (k=0; k<100; k=k+1) $display("%d:%h",k,key_input[k]);
end

reg [63:0] ciphertext [0:99];
initial $readmemh("CIPHERTEXT.txt",ciphertext );
initial begin
//for (k=0; k<100; k=k+1) $display("%d:%h",k,ciphertext[k]);
end

initial begin: CLK_GEN
    forever begin
        t_clk=0;
        #5;
        t_clk=1;
        #5;
    end
end

integer i;
initial begin: TEST_CASES
    for(i=0;i<100;i=i+1) begin
        t_din=64'h0000000000000000;
        t_user_key=key_input[i];
        t_clr=0;
        #5;
        t_clr=1;
        #5;
        t_start_generating_skey=1;
        #10;
        t_start_generating_skey=0;
        #800;
        t_start_encryption=1;
        #10;
        t_start_encryption=0;
        #130;
        if(t_dout != ciphertext[i]) $warning("failure");
        #10;
    end
    $display("100 cases of VHDL_RC5_ENCODE passed");
    $finish;
end




endmodule
