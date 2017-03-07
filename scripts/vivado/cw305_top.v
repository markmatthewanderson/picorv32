/* 
ChipWhisperer Artix Target - Example of connections between example registers
and rest of system.

Copyright (c) 2016, NewAE Technology Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted without restriction. Note that modules within
the project may have additional restrictions, please carefully inspect
additional licenses.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of NewAE Technology Inc.
*/

`timescale 1ns / 1ps
`default_nettype none 

`include "board.v"

module cw305_top(
    
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
    
    input wire resetn, /* Pushbutton SW4, connected to R1 */
    
    output wire cw305_led1, /* red LED */
    output wire cw305_led2, /* green LED */
    output wire cw305_led3,  /* blue LED */
    
    /****** PLL ******/
    input wire clk, //PLL Clock Channel #1
    //input wire pll_clk2, //PLL Clock Channel #2
    
    /****** 20-Pin Connector Stuff ******/
    output wire cw305_tio_trigger,
    output wire cw305_tio_clkout,
    input  wire cw305_tio_clkin
    );
    
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
    assign crypt_done = ~cw305_axi_busy;
    
    cw305_axi cw305_axi (
        .clk(cw305_crypt_clk),
        .start(cw305_crypt_start),
        //.key(cw305_crypt_key),
        //.pt(cw305_crypt_textout),
        .ct(cw305_crypt_cipherin),
        .busy(cw305_cw305_axi_busy)
    );
         
   /******** END CRYPTO MODULE CONNECTIONS ****************/
    
endmodule
