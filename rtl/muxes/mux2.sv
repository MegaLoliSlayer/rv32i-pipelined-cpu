//2 to 1 multiplexer
//#() defines a parameter called WIDTH 
//by default works on 32 bit signals 
//change WIDTH to make it 1 bit or 8 bit etc.
//example usage: mux2 #(.WIDTH(8)) my_8bit_mux (...);
//INPUT: WIDTH bit a; WIDTH bit b; 1 bit select signal
//OUTPUT: WIDTH bit y  
module mux2 #(parameter WIDTH = 32)(
	input logic [WIDTH-1:0] a,
	input logic [WIDTH-1:0] b,
	input logic sel,
	output logic [WIDTH-1:0] y
);

//sel = 0 -> choose a
//sel = 1 -> choose b
assign y = sel ? b : a;

endmodule
