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

`define MEMORY_SIZE 1152 // if changing, also change in axi4_memory.v

module cw305_axi(
	input wire start,        //start signal to CESEL
        //input wire [127:0] key,  //crypto key
	input wire [127:0] pt,   //plaintext input to CESEL
	output wire [127:0] ct,   //ciphertext output from CESEL
	output reg busy,         //busy signal from CESEL
	input             clk,
	input             mem_axi_awvalid,
	output reg        mem_axi_awready = 0,
	input [31:0]      mem_axi_awaddr,
	input [ 2:0]      mem_axi_awprot,

	input            mem_axi_wvalid,
	output reg       mem_axi_wready = 0,
	input [31:0]     mem_axi_wdata,
	input [ 3:0]     mem_axi_wstrb,

	output reg       mem_axi_bvalid = 0,
	input            mem_axi_bready,

	input            mem_axi_arvalid,
	output reg       mem_axi_arready = 0,
	input [31:0]     mem_axi_araddr,
	input [ 2:0]     mem_axi_arprot,

	output reg        mem_axi_rvalid = 0,
	input             mem_axi_rready,
	output reg [31:0] mem_axi_rdata
);
	reg [31:0] ct_reg [0:3];
	assign ct = {ct_reg[3], ct_reg[2], ct_reg[1], ct_reg[0]};

	wire [31:0] pt_reg [0:3];
	assign pt_reg[0] = pt[31:0];
	assign pt_reg[1] = pt[63:32];
	assign pt_reg[2] = pt[95:64];
	assign pt_reg[3] = pt[127:96];

	reg latched_raddr_en = 0;
	reg latched_waddr_en = 0;
	reg latched_wdata_en = 0;

	reg fast_raddr = 0;
	reg fast_waddr = 0;
	reg fast_wdata = 0;

	reg [31:0] latched_raddr;
	reg [31:0] latched_waddr;
	reg [31:0] latched_wdata;
	reg [ 3:0] latched_wstrb;
	reg        latched_rinsn;

	reg [4:0] delay_axi_transaction = 0;

	reg enc_ready = 0; // is encryption ready to start?
	reg enc_done = 0; // is encryption done?

// on input from chipwhisperer over usb, start goes high. signal to picorv that read over AXI is valid and set "busy" output high
// on input from picorv32 over AXI, load the AXI data in to "ct" output and set "busy" output low


// handle usb connection
always @(posedge clk)
begin
    busy <= 0;
    if(start)
    begin
	// set busy signal
        busy <= 1;
	// clear ciphertext output
        ct <= 128'b0;
	// clear encryption done signal
	enc_done <= 0;
	// signal axi read ready
	enc_ready <= 1;
    end
    else if(busy)
    begin
	if(enc_done)
	begin       
		busy <= 0;
	end
	else 
	begin
		// keep signaling busy if !enc_done
		busy <= 1;
	end
    end
end
// end handle usb communication	


// handle AXI communication
	task handle_axi_arvalid; begin 
		if (enc_ready) // do not allow read until enc_ready is high
		begin
			mem_axi_arready <= 1;
			latched_raddr = mem_axi_araddr;
			latched_rinsn = mem_axi_arprot[2];
			latched_raddr_en = 1;
			fast_raddr <= 1;
		end
	end endtask

	task handle_axi_awvalid; begin
		mem_axi_awready <= 1;
		latched_waddr = mem_axi_awaddr;
		latched_waddr_en = 1;
		fast_waddr <= 1;
	end endtask

	task handle_axi_wvalid; begin
		mem_axi_wready <= 1;
		latched_wdata = mem_axi_wdata;
		latched_wstrb = mem_axi_wstrb;
		latched_wdata_en = 1;
		fast_wdata <= 1;
	end endtask

	task handle_axi_rvalid; begin
		if (latched_raddr >= `MEMORY_SIZE) begin
			mem_axi_rdata <= pt_reg[latched_waddr - `MEMORY_SIZE];
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0;
		end
	end endtask

	task handle_axi_bvalid; begin
		if (latched_waddr >= `MEMORY_SIZE) begin
			if (latched_wstrb[0]) ct_reg[latched_waddr - `MEMORY_SIZE][ 7: 0] <= latched_wdata[ 7: 0];
			if (latched_wstrb[1]) ct_reg[latched_waddr - `MEMORY_SIZE][15: 8] <= latched_wdata[15: 8];
			if (latched_wstrb[2]) ct_reg[latched_waddr - `MEMORY_SIZE][23:16] <= latched_wdata[23:16];
			if (latched_wstrb[3]) ct_reg[latched_waddr - `MEMORY_SIZE][31:24] <= latched_wdata[31:24];
			if (latched_waddr == `MEMORY_SIZE && latched_wstrb[3]) enc_done <= 1; // make sure to write to this location last
		end
		mem_axi_bvalid <= 1;
		latched_waddr_en = 0;
		latched_wdata_en = 0;
	end endtask

	always @(posedge clk) begin
		mem_axi_arready <= 0;
		mem_axi_awready <= 0;
		mem_axi_wready <= 0;

		fast_raddr <= 0;
		fast_waddr <= 0;
		fast_wdata <= 0;

		if (mem_axi_rvalid && mem_axi_rready) begin
			mem_axi_rvalid <= 0;
		end

		if (mem_axi_bvalid && mem_axi_bready) begin
			mem_axi_bvalid <= 0;
		end

		if (mem_axi_arvalid && mem_axi_arready && !fast_raddr) begin
			latched_raddr = mem_axi_araddr;
			latched_rinsn = mem_axi_arprot[2];
			latched_raddr_en = 1;
		end

		if (mem_axi_awvalid && mem_axi_awready && !fast_waddr) begin
			latched_waddr = mem_axi_awaddr;
			latched_waddr_en = 1;
		end

		if (mem_axi_wvalid && mem_axi_wready && !fast_wdata) begin
			latched_wdata = mem_axi_wdata;
			latched_wstrb = mem_axi_wstrb;
			latched_wdata_en = 1;
		end

		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && !delay_axi_transaction[0]) handle_axi_arvalid;
		if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && !delay_axi_transaction[1]) handle_axi_awvalid;
		if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && !delay_axi_transaction[2]) handle_axi_wvalid;
		if (!mem_axi_rvalid && latched_raddr_en && !delay_axi_transaction[3]) handle_axi_rvalid;
		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && !delay_axi_transaction[4]) handle_axi_bvalid;
	
	end
// end AXI communication handling
endmodule
