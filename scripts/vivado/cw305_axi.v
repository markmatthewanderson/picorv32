`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Stanford University
// Engineer: Mark Matthew Anderson
// 
// Create Date: 02/04/2017 01:28:18 PM
// Module Name: CESEL_test
// Project Name: CESEL_test 
// Target Devices: Artix-7 on NewAE CW305
//////////////////////////////////////////////////////////////////////////////////


module CESEL_test(
    input wire clk,         //CESEL clock
    input wire start,       //start signal to CESEL
    //input wire [127:0] key, //crypto key
    //input wire [127:0] pt,  //plaintext input to CESEL
    output reg [127:0] ct,  //ciphertext output from CESEL
    output reg busy         //busy signal from CESEL
);

always @(posedge clk)
begin
    busy <= 0;
    if(start)
    begin
        busy <= 1;
        ct <= 'h00000000000000000000000000000000;
    end
    else if(busy)
    begin
        ct <= 'hdeadbeefdeadbeefdeadbeefdeadbeef;
        busy <= 0;
    end
end

endmodule
