`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Stanford University
// Engineer: Mark Matthew Anderson
// 
// Create Date: 03/07/16     
// Module Name: cw305_axi
// Project Name: cw305_axi
// Target Devices: Artix-7 on NewAE CW305
//////////////////////////////////////////////////////////////////////////////////


module cw305_axi(
    //input wire clk,         //CESEL clock
    //input wire start,       //start signal to CESEL
    //input wire [127:0] key, //crypto key
    //input wire [127:0] pt,  //plaintext input to CESEL
    //output reg [127:0] ct,  //ciphertext output from CESEL
    //output reg busy         //busy signal from CESEL
);
/*
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
*/
	input clk, resetn,
	output trap,

	// AXI4-lite master memory interface

	output        mem_axi_awvalid,
	input         mem_axi_awready,
	output [31:0] mem_axi_awaddr,
	output [ 2:0] mem_axi_awprot,

	output        mem_axi_wvalid,
	input         mem_axi_wready,
	output [31:0] mem_axi_wdata,
	output [ 3:0] mem_axi_wstrb,

	input         mem_axi_bvalid,
	output        mem_axi_bready,

	output        mem_axi_arvalid,
	input         mem_axi_arready,
	output [31:0] mem_axi_araddr,
	output [ 2:0] mem_axi_arprot,

	input         mem_axi_rvalid,
	output        mem_axi_rready,
	input  [31:0] mem_axi_rdata
endmodule
