`timescale 1ns/1ps

//Testbench module
module tb_and_gate;

//internal test signals
logic a;
logic b;
logic y;

//Instantiate the design undeer test
//connect and_gate port a -> testbench signal a(testbench controlling a)
//connect and_gate port b -> testbench signal b(testbench controlling b)
//connect and_gate port y -> testbench signal y(testbench watching y)
and_gate dut(
	.a(a),
	.b(b),
	.y(y)
	);

//Initial block
initial begin 
	//waveform output 
	//save waveform data into waves/and_gate.vcd
	$dumpfile("waves/and_gate.vcd");
	//record all signals undeer tb_and_gate
	$dumpvars(0, tb_and_gate);

	//Test case 1: 0 AND 0
	//set the inputs to 0
	a=0;
	b=0;
	//wait 10 ns so the output has time to update
	#10;
        
	//if y is not 0, display error message and stop simulation
	//using !== instead of != since we want strict check which includes
	//x = known and z = high impedence 
	if (y !== 0) begin
		$display("FAIL: 0 & 0 should be 0");
		$finish;
	end

	//Test case 2: 0 AND 1 = 0
	//set a = 0, b = 1
	a = 0;
	b = 1;
	#10 ;
	if (y !== 0) begin
		$display("FAIL: 0 & 1 should be 0");
		$finish;
	end

	//Test case 3: 1 AND 0 = 0  
	//set a = 1, b = 0 
	a = 1;
	b = 0;
	#10;
	if (y !== 0) begin
		$display("FAIL: 1 & 0 should be 0");
		$finish;
	end

	//Test case 4: 1 AND 1 = 1
	//set a = 1, b = 1
	a = 1;
	b = 1;
	#10;
	if  (y !== 1) begin
		$display("FAIL: 1 & 1 should be 1");
		$finish;
	end
	
	//if the simulation reaches this part, it means no test failed
	//print passed and stop the simulation
	$display("All AND gate tests passed");
	$finish;
end

endmodule
