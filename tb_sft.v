
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
// software testbench for simulation
//
`define MAXMSG 256

module tb_sft(
	      output reg   tb_sim_rst,      // soft reset
	      output reg   clk12m,          // 12 mhz clock
	      input [7:0]  la_tx_data,      // uart data from (alarm time and status)
	      input 	   la_tx_data_rdy,  // 

	      output reg [7:0] tb_rx_data,  // uart data to the DUT
	      output reg   tb_rx_data_rdy,  //

	      input [4:0]  leds

	      );

   //
   // convert ascii to binary
   //
   function [4:0] ascii2bin (input [7:0] t);
      reg [7:0] 	   bin8;    // 8 bit binary
      reg [4:0] 	   result;
      
      begin
 
	 if ((t >= 8'h30) && (t <= 8'h3f)) begin
	    bin8 = t - 8'h30;
	    ascii2bin = {1'b0, bin8[3:0]};
	 end
	 else
	 if ((t >= 8'h50) && (t <= 8'h5f)) begin
	    bin8 = t - 8'h50;
	    ascii2bin = {1'b1, bin8[3:0]};
	 end
	 else if ((t>= 8'h61) && (t <= 8'h66)) begin
	    // a-f
	    bin8 = t - 8'h61;
	    ascii2bin = {1'b0, bin8[3:0] + 4'ha};
	 end
	 else if ((t>= 8'h41) && (t <= 8'h46)) begin
	    // A-F
	    bin8 = t - 8'h41;
	    ascii2bin = {1'b1, bin8[3:0] + 4'ha};
	 end
	 else
	   begin
	      ascii2bin = 5'b0000;
	   end
      end
   endfunction // ascii2bin



   //
   // print the "LEDS" to the screen
   //
   task displayLattice(input [4:0] leds);
      begin
	 #1;
	 $display("    [%c]", leds[2] ? "*":".");
	 $display(" [%c][%c][%c] ", leds[1] ? "*":".", leds[4] ? "*" : ".", leds[3] ? "*" : ".");
	 $display("    [%c]", leds[0] ? "*":".");
//	 $display($time,,, ": %d  %d  %c  -> %d %d", a, b, op ? "-" : "+", leds[4], leds[3:0]);
	 $display;
      end	 
   endtask


   //
   // sendByte
   // send a byte to the DUT
   //
   task sendByte(input [7:0] byt);
     begin
		@(posedge clk12m);
		tb_rx_data_rdy <= 1;
		tb_rx_data     <= byt;
		@(posedge clk12m);
		tb_rx_data_rdy <= 0;
     end
   endtask


   //
   // waitN
   // wait for N cycles
   //
   task waitN(input integer N);
      begin
	 repeat (N) begin
	    @(posedge clk12m);
	 end
      end
   endtask // waitN
   
   

   //
   // print out a snipped of JSON for one test
   //
   task jsonTest(input integer firstOne, input integer tNum, input reg[`MAXMSG * 8-1:0] oStr, input integer score);
      begin
	 $display("%c { \"name\" : \"test%d\",", (firstOne == 1'b1) ? " ": ",", tNum);
	 $display("%-s", oStr);
	 $display("\"score\" : %d}", score);
      end
   endtask

   initial begin

      // uncomment these two lines if using icarus verilog and gtkwave
      $dumpfile("lab4.vcd");
      $dumpvars(0, top_sft);
      tb_sim_rst <= 0;
      clk12m <= 0;
      tb_rx_data = 8'b0;
      tb_rx_data_rdy = 1'b0;
      #40
      tb_sim_rst <= 1;
      #40
      #40
      #40
      #40
      tb_sim_rst <= 0;
   end

   always @(*) begin
      #40;
      clk12m <= ~clk12m;
   end

   always @(*)
     if (la_tx_data_rdy) begin
	if (la_tx_data != 8'h0d)
	  if (la_tx_data == 8'h0a)
	    $display;
	  else
	    $write("%c", la_tx_data);
     end
   //
   // display digits coming back from the dut
   //  display the segment displays
   //
   //      $display("%s %s  %s %s",
   //	       segment2ascii(segment4d),
   //	       segment2ascii(segment3d),
   //	       segment2ascii(segment2d),
   //	       segment2ascii(segment1d));
   
   //  display the alarm display
   //
   //   always @(posedge ut_tx_data_rdy) begin
   //	   #1;
   //	   $display("%s", ut_tx_data);
   //   end

 
   
   // ------------------------
   //
   // stimulus
   //
   //
   initial begin
      #400;
      #400;
      @(posedge clk12m);
//      $display("{\"vtests\" : [");
      tb_rx_data = 8'b0;
      tb_rx_data_rdy = 1'b0;
      //
      waitN(100);
      sendByte("L");
      sendByte("1");
      sendByte("2");
      sendByte("3");
      sendByte("4");
      sendByte("5");
      sendByte("6");
      sendByte("7");
      sendByte("8");
      sendByte(8'h0d);
      waitN(3);
      sendByte("E");
      waitN(3);
      sendByte("a");
      sendByte("b");
      sendByte("c");
      sendByte("d");
      sendByte("!");
      sendByte(8'h0d);
      waitN(10);
      sendByte("L");
      sendByte("1");
      sendByte("2");
      sendByte("3");
      sendByte("4");
      sendByte("5");
      sendByte("6");
      sendByte("7");
      sendByte("8");
      sendByte(8'h0d);
      waitN(10);
      sendByte("D");
      waitN(1);
      sendByte("f"); sendByte("0");
      sendByte("c"); sendByte("0");
      sendByte("2"); sendByte("7");
      sendByte("6"); sendByte("c");
      sendByte("b"); sendByte("0");
      sendByte(8'h0d);
      waitN(100);
      //
      //      $display("]}");
      $finish;

   end


endmodule // tb_sft
