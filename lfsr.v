module lfsr (
	     output [31:0] lfsrVal, // lfsr current value
	     output [7:0]  psrByte, // psuedo random byte
	     input [31:0]  ldVal, //  load value to LFSR
             input 	   ldLFSR, // load the LFSR, up to 32 bits
             input 	   step,    // advance the LFSR 
	     input 	   rst,
	     input 	   clk);

endmodule // lfsr
