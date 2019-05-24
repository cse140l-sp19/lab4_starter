// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------

//
// uncomment this define if you want to target hardware
// otherwise, this file will be configured for the simulator
//
`define HW

//
// Revision History : 0.0
//

   
`ifdef HW

module inpin(
  input clk,
  input pin,
  output rd);

  SB_IO #(.PIN_TYPE(6'b0000_00)) _io (
        .PACKAGE_PIN(pin),
        .INPUT_CLK(clk),
        .D_IN_0(rd));
endmodule

`endif


// -----------------------------------
//
// reset generator
//    
// when esc key is detected, generates a reset signal for 16 cycles
//
//
//
module resetGen (
		output reg  rst,             // global reset		 
		input 	    bu_rx_data_rdy,  // data from uart rdy
		input [7:0] bu_rx_data,      // data from uart
		input 	    tb_sim_rst,      // simulation reset
		input 	    clk
		);
   
   
   reg [5-1:0] 		     reset_count;
   wire 		     escKey = bu_rx_data_rdy & (bu_rx_data == 8'h1b);
   
   wire [5-1:0] reset_count_next;
   defparam uu0.N = 5;
   
   N_bit_counter uu0(
		     .result (reset_count_next[5-1:0])       , // Output
		     .r1 (reset_count[5-1:0])                  , // input
		     .up (1'b1)
		     );
   
   always @(posedge clk) begin
      rst <= ~reset_count[4];
      reset_count <= (tb_sim_rst | escKey)? 5'b00000 :
	             (reset_count[4])? reset_count: reset_count_next;
   end // always @ (posedge clk_in)
endmodule // resetGen


// -----------------------------------
//
// top level for lab4
//
module latticehx1k(
		   output 	sd,       // serial data IR control - not used
 	     
		   input 	clk_in,   // input from onboard clock gen
		   input wire 	from_pc,  // serial data from the host
		   output wire 	to_ir,    // serial data to IR - not used
		   output wire 	o_serial_data, // serial data to host
		   output [4:0] led       // onboard leds
				
		   // for software only
				
`ifdef HW
`else
		   ,input tb_sim_rst      // test bench reset
		   ,input [7:0] tb_rx_data // pretend data coming from the uart
		   ,input tb_rx_data_rdy   //
				
		   ,output [7:0] la_tx_data // shortcut, data from the fake tx uart
		   ,output la_tx_data_rdy
`endif
		   
		   );


   wire 			clk;
   wire 			rst;
 			
`ifdef HW
   wire tb_sim_rst = 1'b0;
   
   //
   // we are not using the IR interface for this lab
   //
   assign to_ir = 1'b0;
   assign sd = 1'b0;

   wire PLLOUTGLOBAL;
   latticehx1k_pll latticehx1k_pll_inst(.REFERENCECLK(clk_in),
                                     .PLLOUTCORE(clk),
                                     .PLLOUTGLOBAL(PLLOUTGLOBAL),
                                     .RESET(1'b1));
									 
`else // !`ifdef HW
   fake_pll uut (
                         .REFERENCECLK(clk_in),
                         .PLLOUTCORE(clk),
		         .PLLOUTGLOBAL(),
                         .RESETB(1'b1),
                         .BYPASS(1'b0)
                        );
   
`endif

   wire [7:0] 	    bu_rx_data;         // data from uart to dev
   wire  	    bu_rx_data_rdy;     // data from uart to dev is valid
   wire             bu_tx_busy;         // Uart is busy transmitting
   
   wire [7:0] 	    L4_tx_data;         // data from lab4 to host
   wire 	    L4_tx_data_rdy;     // data from lab4 to host ready 
   
   

   


   wire [7:0] 	    utb_txdata;         // data from uarttxbuf to buart
   wire 	    utb_txdata_rdy;     // "          "       rdy signal
   wire 	    L4_PrintBuf;        // print the stored data to the uart


`ifdef HW

   wire 	    uart_RXD;           // retimed serial input data
   
   inpin _rcxd(.clk(clk), .pin(from_pc), .rd(uart_RXD));

   // with 12 MHz clock, 115600 baud, 8, N, 1

   
   uartTxBuf ufifo (
		    .utb_txdata(utb_txdata),
		    .utb_txdata_rdy(utb_txdata_rdy),
		    .txdata(L4_tx_data),
		    .txDataValid(L4_tx_data_rdy),
		    .txBusy(bu_tx_busy),
		    .rxdata(bu_rx_data),
		    .rxDataValid(bu_rx_data_rdy),
                    .printBuf(L4_PrintBuf),
		    .reset(rst),
		    .clk(clk)
		    );
   
   

   buart buart (
		.clk (clk),
		.resetq(~rst),
		.rx(uart_RXD),
		.tx(o_serial_data),
		.rd(1'b1),                // read strobe
		.wr(utb_txdata_rdy),	  // write strobe 
		.valid(bu_rx_data_rdy),   // rx has valid data
		.busy(bu_tx_busy),
		.tx_data(utb_txdata),
		.rx_data(bu_rx_data));

`else // !`ifdef HW

   uartTxBuf ufifo (
		    .utb_txdata(utb_txdata),
		    .utb_txdata_rdy(utb_txdata_rdy),
		    .txdata(L4_tx_data),
		    .txDataValid(L4_tx_data_rdy),
		    .txBusy(bu_tx_busy),
		    .rxdata(bu_rx_data),
		    .rxDataValid(bu_rx_data_rdy),
                    .printBuf(L4_PrintBuf),
		    .reset(rst),
		    .clk(clk)
		    );
   


   fake_buart buart (
		.clk (clk),
		.resetq(tb_sim_rst),
		.rx(from_pc),
		.tx(o_serial_data),
		.rd(1'b1),                // read strobe
		.wr(utb_txdata_rdy),                // write strobe 
		.valid(bu_rx_data_rdy),   // rx has valid data
                .busy(bu_tx_busy),        // uart is busy transmitting
		.tx_data(utb_txdata),
		.rx_data(bu_rx_data),
  	        .fa_data(la_tx_data),
		.fa_valid(la_tx_data_rdy),
		.to_dev_data(tb_rx_data),
		.to_dev_data_valid(tb_rx_data_rdy));
`endif


   //
   // reset generation
   //
   resetGen resetGen(
		     .rst(rst),
		     .bu_rx_data_rdy(bu_rx_data_rdy),
		     .bu_rx_data(bu_rx_data),
		     .tb_sim_rst(tb_sim_rst),
		     .clk(clk)
		     );
   

   wire [4:0] 	    L4_led;
   assign led[4:0] = L4_led[4:0];
   
   //
   // instantiate assignment 4 DUT
   //
   Lab4_140L Lab_UT(
		    .rst   (rst),                            
		    .clk   (clk),
		    .bu_rx_data_rdy (bu_rx_data_rdy),
		    .bu_rx_data (bu_rx_data),
		    .L4_tx_data_rdy (L4_tx_data_rdy),
		    .L4_tx_data (L4_tx_data),
		    .L4_led   (L4_led[4:0]),
                    .L4_PrintBuf (L4_PrintBuf)
		    );
			

endmodule // latticehx1k

`ifdef HW
//
// PLL
//
module latticehx1k_pll(REFERENCECLK,
                       PLLOUTCORE,
                       PLLOUTGLOBAL,
                       RESET);

input wire REFERENCECLK;
input wire RESET;    /* To initialize the simulation properly, the RESET signal (Active Low) must be asserted at the beginning of the simulation */ 
output wire PLLOUTCORE;
output wire PLLOUTGLOBAL;

SB_PLL40_CORE latticehx1k_pll_inst(.REFERENCECLK(REFERENCECLK),
                                   .PLLOUTCORE(PLLOUTCORE),
                                   .PLLOUTGLOBAL(PLLOUTGLOBAL),
                                   .EXTFEEDBACK(),
                                   .DYNAMICDELAY(),
                                   .RESETB(RESET),
                                   .BYPASS(1'b0),
                                   .LATCHINPUTVALUE(),
                                   .LOCK(),
                                   .SDI(),
                                   .SDO(),
                                   .SCLK()); 

//\\ Fin=12 Mhz, Fout=12 Mhz;
defparam latticehx1k_pll_inst.DIVR = 4'b0000;
defparam latticehx1k_pll_inst.DIVF = 7'b0111111;
defparam latticehx1k_pll_inst.DIVQ = 4'b0110;
defparam latticehx1k_pll_inst.FILTER_RANGE = 3'b001;
defparam latticehx1k_pll_inst.FEEDBACK_PATH = "SIMPLE";
defparam latticehx1k_pll_inst.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
defparam latticehx1k_pll_inst.FDA_FEEDBACK = 4'b0000;
defparam latticehx1k_pll_inst.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
defparam latticehx1k_pll_inst.FDA_RELATIVE = 4'b0000;
defparam latticehx1k_pll_inst.SHIFTREG_DIV_MODE = 2'b00;
defparam latticehx1k_pll_inst.PLLOUT_SELECT = "GENCLK";
defparam latticehx1k_pll_inst.ENABLE_ICEGATE = 1'b0;

endmodule

`endif

//
// N_bit_counter used by resetgen
//
module N_bit_counter (
result      , // Output
r1          ,  // input
up
);

parameter N = 4;
parameter N_1 = N - 1;
// Input Port Declarations       
input    [N_1:0]   r1         ;
input              up         ; 

// Output Port Declarations
output   [N_1:0]  result      ;

// Port Wires
wire     [N_1:0]    r1        ;
wire     [N_1:0]    result    ;


// Internal variables
wire     [N_1:0]      ci       ;

assign result[0] = ~r1[0];
genvar i;
generate
    for (i = 1; i < N; i=i+1) 
    begin : counter_gen_label	
        assign ci[i] = (up)? &r1[i-1:0] : ~|r1[i-1:0];
        xor (result[i], r1[i], ci[i]);
    end
endgenerate

endmodule // End Of Module adder


