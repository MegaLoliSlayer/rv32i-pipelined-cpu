`timescale 1ns/1ps

module tb_full_adder;

logic a;
logic b;
logic cin;
logic sum;
logic cout;

full_adder dut(
	.a(a),
	.b(b),
	.cin(cin),
	.sum(sum),
	.cout(cout)
);

task check;
	input logic test_a;
	input logic test_b;
	input logic test_cin;
	input logic expected_sum;
	input logic expected_cout;
        begin
		a = test_a;
		b = test_b;
		cin = test_cin;
		#10;
		if (sum !== expected_sum || cout !== expected_cout) begin
			$display("FAIL: a=%b b=%b cin=%b sum=%b cout=%b expected_sum=%b expected_cout=%b", a, b, cin, sum, cout, expected_sum, expected_cout);
			$finish;
		end
	end
endtask

initial begin
	$dumpfile("waves/full_adder.vcd");
	$dumpvars(0, tb_full_adder);

	check(0, 0, 0, 0, 0);
	check(0, 0, 1, 1, 0);
	check(0, 1, 0, 1, 0);
	check(0, 1, 1, 0, 1);
	check(1, 0, 0, 1, 0);
	check(1, 0, 1, 0, 1);
	check(1, 1, 0, 0, 1);
	check(1, 1, 1, 1, 1);

	$display("ALL full adder tests passed");
	$finish;
end

endmodule
