//Hardware Block definination
//input ports 1 bit a, b; output port 1 bit y
module and_gate(
	input  logic a,
	input logic b,
	output logic y 
);

  //output port y is continuously driven by a AND b
  assign y = a & b;

endmodule
