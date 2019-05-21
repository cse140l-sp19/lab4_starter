//
// asciiHex2Bin
// convert 0-9a-f to a 4 bit binary value
//

module asciiHex2Bin (
		  output reg [3:0] val,
		  input [7:0]  inVal);

   always @(*) begin
      casex (inVal)
	8'h61 : val = 4'ha;
	8'h62 : val = 4'hb;
	8'h63 : val = 4'hc;
	8'h64 : val = 4'hd;
	8'h65 : val = 4'he;
	8'h66 : val = 4'hf;
	default  : val = inVal[3:0];
      endcase // casex (inVal)
   end // always @ (*)
endmodule
