// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
// -------------------------------------------------------------------- //           
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
//
// fake pll module for running in the simulator
//
module fake_pll(
		input REFERENCECLK,
		output reg PLLOUTCORE,
		output PLLOUTGLOBAL,
		input RESETB,
		input BYPASS
		);

   initial
     PLLOUTCORE <= 1;
   
   always @(*) begin
      #10;
      PLLOUTCORE <= ~PLLOUTCORE;
   end
endmodule // fake_pll

