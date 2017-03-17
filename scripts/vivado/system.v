`timescale 1 ns / 1 ps

// ChipWhisperer defined
//`default_nettype none 
`define CRYPTO_KEY_WIDTH 128
`define CRYPTO_TEXT_WIDTH 128
`define CRYPTO_CIPHER_WIDTH 128

module system (
	// PicoRV Connections
	input     	 clk,
	input	         resetn,
	output           trap,
	output reg [7:0] out_byte,
	output reg       out_byte_en,

	// ChipWhisperer Connections
    	/****** USB Interface ******/
    	input wire        cw305_usb_clk, /* Clock */
    	inout wire [7:0]  cw305_usb_data,/* Data for write/read */
    	input wire [20:0] cw305_usb_addr,/* Address data */
    	input wire        cw305_usb_rdn, /* !RD, low when addr valid for read */
    	input wire        cw305_usb_wrn, /* !WR, low when data+addr valid for write */
    	input wire        cw305_usb_cen, /* !CE not used */
    	input wire        cw305_usb_trigger, /* High when trigger requested */
    
    	/****** Buttons/LEDs on Board ******/
    	input wire cw305_sw1, /* DIP switch J16 */
    	input wire cw305_sw2, /* DIP switch K16 */
    	input wire cw305_sw3, /* DIP switch K15 */
    	input wire cw305_sw4, /* DIP Switch L14 */
    
    	//input wire resetn, /* Pushbutton SW4, connected to R1 */
    
    	output wire cw305_led1, /* red LED */
    	output wire cw305_led2, /* green LED */
    	output wire cw305_led3,  /* blue LED */
    
    	/****** PLL ******/
    	//input wire clk, //PLL Clock Channel #1
    	//input wire pll_clk2, //PLL Clock Channel #2
    
    	/****** 20-Pin Connector Stuff ******/
    	output wire cw305_tio_trigger,
    	output wire cw305_tio_clkout,
    	input  wire cw305_tio_clkin
);

///////////////////////////////////////////////////////////////////////////////////////////////
// Begin PicoRV
///////////////////////////////////////////////////////////////////////////////////////////////
/*
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;

	picorv32 picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb)
	);

	reg [31:0] memory [0:MEM_SIZE-1];
	initial $readmemh("firmware.hex", memory);

	reg [31:0] m_read_data;
	reg m_read_en;

	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			mem_ready <= 1;
			out_byte_en <= 0;
			mem_rdata <= memory[mem_la_addr >> 2];
			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end
			else
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
			end
		end
	end else begin
		always @(posedge clk) begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready && m_read_en;

			m_read_data <= memory[mem_addr >> 2];
			mem_rdata <= m_read_data;

			out_byte_en <= 0;

			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					m_read_en <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					mem_ready <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
					out_byte_en <= 1;
					out_byte <= mem_wdata;
					mem_ready <= 1;
				end
			endcase
		end
	end endgenerate
*/
/*	reg [31:0] irq;

	always @* begin
		irq = 0;
		irq[4] = &uut.picorv32_core.count_cycle[12:0];
		irq[5] = &uut.picorv32_core.count_cycle[15:0];
	end
*/
	wire        mem_axi_awvalid;
	wire        mem_axi_awready;
	wire [31:0] mem_axi_awaddr;
	wire [ 2:0] mem_axi_awprot;

	wire        mem_axi_wvalid;
	wire        mem_axi_wready;
	wire [31:0] mem_axi_wdata;
	wire [ 3:0] mem_axi_wstrb;

	wire        mem_axi_bvalid;
	wire        mem_axi_bready;

	wire        mem_axi_arvalid;
	wire        mem_axi_arready;
	wire [31:0] mem_axi_araddr;
	wire [ 2:0] mem_axi_arprot;

	wire        mem_axi_rvalid;
	wire        mem_axi_rready;
	wire [31:0] mem_axi_rdata;

	axi4_memory 
	mem (
		.clk             (clk             ),
		.mem_axi_awvalid (mem_axi_awvalid ),
		.mem_axi_awready (mem_axi_awready ),
		.mem_axi_awaddr  (mem_axi_awaddr  ),
		.mem_axi_awprot  (mem_axi_awprot  ),

		.mem_axi_wvalid  (mem_axi_wvalid  ),
		.mem_axi_wready  (mem_axi_wready  ),
		.mem_axi_wdata   (mem_axi_wdata   ),
		.mem_axi_wstrb   (mem_axi_wstrb   ),

		.mem_axi_bvalid  (mem_axi_bvalid  ),
		.mem_axi_bready  (mem_axi_bready  ),

		.mem_axi_arvalid (mem_axi_arvalid ),
		.mem_axi_arready (mem_axi_arready ),
		.mem_axi_araddr  (mem_axi_araddr  ),
		.mem_axi_arprot  (mem_axi_arprot  ),

		.mem_axi_rvalid  (mem_axi_rvalid  ),
		.mem_axi_rready  (mem_axi_rready  ),
		.mem_axi_rdata   (mem_axi_rdata   )

	);

	picorv32_axi #(
		.ENABLE_REGS_DUALPORT(0),
		.COMPRESSED_ISA(1),
		.ENABLE_MUL(1),
		.ENABLE_DIV(1),
		.ENABLE_IRQ(1),
		.ENABLE_TRACE(1)
	) uut (
		.clk            (clk            ),
		.resetn         (resetn         ),
		.trap           (trap           ),
		.mem_axi_awvalid(mem_axi_awvalid),
		.mem_axi_awready(mem_axi_awready),
		.mem_axi_awaddr (mem_axi_awaddr ),
		.mem_axi_awprot (mem_axi_awprot ),
		.mem_axi_wvalid (mem_axi_wvalid ),
		.mem_axi_wready (mem_axi_wready ),
		.mem_axi_wdata  (mem_axi_wdata  ),
		.mem_axi_wstrb  (mem_axi_wstrb  ),
		.mem_axi_bvalid (mem_axi_bvalid ),
		.mem_axi_bready (mem_axi_bready ),
		.mem_axi_arvalid(mem_axi_arvalid),
		.mem_axi_arready(mem_axi_arready),
		.mem_axi_araddr (mem_axi_araddr ),
		.mem_axi_arprot (mem_axi_arprot ),
		.mem_axi_rvalid (mem_axi_rvalid ),
		.mem_axi_rready (mem_axi_rready ),
		.mem_axi_rdata  (mem_axi_rdata  )
	);

/*	reg [1023:0] firmware_file;
	initial begin
		if(!$value$plusargs("firmware=%s", firmware_file))
			firmware_file = "firmware/firmware.hex";
		$readmemh(firmware_file, mem.memory);
	end*/

///// Following firmware read copied from non-AXI picorv instantiation
	// 4096 32bit words = 16kB memory
	initial $readmemh("firmware.hex", mem.memory);
///// End copy from non-AXI picorv instantiation


///////////////////////////////////////////////////////////////////////////////////////////////
//  End PicoRV
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
//  Begin ChipWhisperer
///////////////////////////////////////////////////////////////////////////////////////////////

    	wire cw305_usb_clk_buf;
    
    	/* USB CLK Heartbeat */
    	reg [24:0] cw305_usb_timer_heartbeat;
    	always @(posedge cw305_usb_clk_buf) cw305_usb_timer_heartbeat <= cw305_usb_timer_heartbeat +  25'd1;
    	assign cw305_led1 = cw305_usb_timer_heartbeat[24];
    
    	/* CRYPT CLK Heartbeat */
    	reg [22:0] cw305_crypt_clk_heartbeat;
    	always @(posedge cw305_crypt_clk) cw305_crypt_clk_heartbeat <= cw305_crypt_clk_heartbeat +  23'd1;
    	assign cw305_led2 = cw305_crypt_clk_heartbeat[22];
                   
    	/* Connections between crypto module & registers */
    	wire cw305_crypt_clk;    
    	wire [`CRYPTO_TEXT_WIDTH-1:0] cw305_crypt_key;
    	wire [`CRYPTO_TEXT_WIDTH-1:0] cw305_crypt_textout;
    	wire [`CRYPTO_CIPHER_WIDTH-1:0] cw305_crypt_cipherin;
    	wire cw305_crypt_init;
    	wire cw305_crypt_ready;
    	wire cw305_crypt_start;
    	wire cw305_crypt_done;
    
    	/******* USB Interface ****/
    	wire [1024*8-1:0] cw305_memory_input;
    	wire [1024*8-1:0] cw305_memory_output;
    	// Set up USB with memory registers
    	cw305_usb_module #(
        	.MEMORY_WIDTH(10) // 2^10 = 1024 = 0x400 bytes each for input and output memory
    	)cw305_my_usb(
        	.clk_usb(cw305_usb_clk),
        	.data(cw305_usb_data),
        	.addr(cw305_usb_addr),
        	.rd_en(cw305_usb_rdn),
        	.wr_en(cw305_usb_wrn),
        	.cen(cw305_usb_cen),
        	.trigger(cw305_usb_trigger),
        	.clk_sys(cw305_usb_clk_buf),
        	.memory_input(cw305_memory_input),
        	.memory_output(cw305_memory_output)
    	);  	 
    
    	/******* REGISTERS ********/
    	cw305_registers  #(
    	    .MEMORY_WIDTH(10) // 2^10 = 1024 = 0x400 bytes each for input and output memory
    	) cw305_reg_inst (
        	.mem_clk(cw305_usb_clk_buf),
        	.mem_input(cw305_memory_input),
        	.mem_output(cw305_memory_output),
              
        	.user_led(cw305_led3),
        	.dipsw_1(cw305_sw1),
        	.dipsw_2(cw305_sw2),
                
        	.exttrigger_in(cw305_usb_trigger),
        
        	.pll_clk1(clk),
        	.cw_clkin(cw305_tio_clkin),
        	.cw_clkout(cw305_tio_clkout),
       
        	.crypt_type(8'h02),
        	.crypt_rev(8'h03),
        
        	.cryptoclk(cw305_crypt_clk),
        	.key(cw305_crypt_key),
        	.textin(cw305_crypt_textout),
        	.cipherout(cw305_crypt_cipherin),
               
        	.init(cw305_crypt_init),
        	.ready(cw305_crypt_ready),
        	.start(cw305_crypt_start),
        	.done(cw305_crypt_done)        
    	);
  

    	/* Begin cw305_axi Setup and Connections */
    	wire cw305_axi_busy;
    	assign cw305_crypt_done = ~cw305_axi_busy;
    
    	cw305_axi cw305_axi (
        	.start(cw305_crypt_start),
        	//.key(cw305_crypt_key),
        	.pt(cw305_crypt_textout),
        	.ct(cw305_crypt_cipherin),
        	.busy(cw305_axi_busy),

		.clk             (clk             ),
		.mem_axi_awvalid (mem_axi_awvalid ),
		.mem_axi_awready (mem_axi_awready ),
		.mem_axi_awaddr  (mem_axi_awaddr  ),
		.mem_axi_awprot  (mem_axi_awprot  ),

		.mem_axi_wvalid  (mem_axi_wvalid  ),
		.mem_axi_wready  (mem_axi_wready  ),
		.mem_axi_wdata   (mem_axi_wdata   ),
		.mem_axi_wstrb   (mem_axi_wstrb   ),

		.mem_axi_bvalid  (mem_axi_bvalid  ),
		.mem_axi_bready  (mem_axi_bready  ),

		.mem_axi_arvalid (mem_axi_arvalid ),
		.mem_axi_arready (mem_axi_arready ),
		.mem_axi_araddr  (mem_axi_araddr  ),
		.mem_axi_arprot  (mem_axi_arprot  ),

		.mem_axi_rvalid  (mem_axi_rvalid  ),
		.mem_axi_rready  (mem_axi_rready  ),
		.mem_axi_rdata   (mem_axi_rdata   )
    	);
         
   /******** END CRYPTO MODULE CONNECTIONS ****************/

///////////////////////////////////////////////////////////////////////////////////////////////
//  End ChipWhisperer
///////////////////////////////////////////////////////////////////////////////////////////////
endmodule
