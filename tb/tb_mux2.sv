//what time units to use
//1ns = time unit
//1ps = time precision
`timescale 1ns/1ps 

//testbench module
module tb_mux2;

//testbench signals
logic [31:0] a;
logic [31:0] b;
logic sel;
logic [31:0] y;

//instantiate
//set signal bit width to 32
mux2 #(.WIDTH(32)) dut (
	.a(a),
	.b(b),
	.sel(sel),
	.y(y)
);

//create a task called check so we can reuse it many times
task check;
	//creates an 32 bit input argument called test_a to the task
	input [31:0] test_a;
	//creates an 32 bit input argument called test_b to the task
	input [31:0] test_b;
	//creates an 1 bit input argument called test_sel to the task
	input test_sel;
	//creates an 32 bit input argument called expected to the task
	input [31:0] expected;
	
	//starts the body of the task
        begin
		//drives the testbench signal a with the value passed into the
		//task
		a = test_a;
		b = test_b;
		sel = test_sel;
		#10;

		if (y !== expected) begin 
			$display("FAIL: a=%h b=%h sel=%b y=%h expected=%h", a, b, sel, y, expected);
			$finish;
		//end if block
		end
	//end task body
	end
//end check task
endtask

//starts initial block 
initial begin 
	//save the waveform data into this file
	$dumpfile("waves/mux2.vcd");
	//save all the signals in tb_mux2 into the waveform file
	$dumpvars(0, tb_mux2);

	//test 
	check(32'hAAAA_AAAA, 32'h5555_5555, 1'b0, 32'hAAAA_AAAA);
	check(32'hAAAA_AAAA, 32'h5555_5555, 1'b1, 32'h5555_5555);

	check(32'h1234_5678, 32'hDEAD_BEEF, 1'b0, 32'h1234_5678);
	check(32'h1234_5678, 32'hDEAD_BEEF, 1'b1, 32'hDEAD_BEEF);

	//Display passed info and end sim
	$display("ALL mux2 tests passed");
	$finish;
//end initial block
end
//end testbench module
endmodule

