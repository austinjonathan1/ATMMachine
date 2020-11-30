`timescale 1 ns / 1 ps

module dac (
    input wire [7:0] sample,
    input wire hush,
    output wire speaker,
    input wire clk
    );
    
    wire [7:0] unsignedsample;
    wire [9:0] deltaadder, sigmaadder, deltab;
    reg [9:0] sigma = 1'b1 << 8;
    
    assign unsignedsample = (hush ? 8'h00 : sample) + 128;
    assign deltab = {sigma[9], sigma[9]} << 8;
    assign sigmaadder = deltaadder + sigma;
    assign deltaadder = unsignedsample + deltab;
    
    always @ (posedge clk) sigma <= sigmaadder;
    assign speaker = sigma[9];
endmodule
