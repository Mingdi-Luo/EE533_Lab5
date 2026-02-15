`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Group Number: G13
// Group members: Yanchen Zhang; zhangy38@usc.edu
//                Mingdi Luo; mingdilu@usc.edu
//                Yizheng Qiao; yizhengq@usc.edu
//
// Create Date:    19:48:41 02/12/2026 
// Design Name:    64bit Arithmetic Logic Unit Testbench
// Module Name:    ALUG13_tb
// Project Name:   EE533 Lab 5
// 
// Description: Verilog Test Fixture created by ISE for module: ALUG13
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Nothing
//
//////////////////////////////////////////////////////////////////////////////////

module ALUG13_tb;

	reg clk;
	reg rst_n;
	reg [63:0] A;
	reg [63:0] B;
	reg [3:0] op_code;
	reg [5:0] sub_start;
	reg [5:0] sub_len;
	reg [5:0] shift_amt;

	// Outputs
	wire [63:0] O;
	wire overflow;

	// Instantiate the Unit Under Test (UUT)
	ALUG13 uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.A(A), 
		.B(B), 
		.op_code(op_code), 
		.sub_start(sub_start), 
		.sub_len(sub_len), 
		.shift_amt(shift_amt), 
		.O(O), 
		.overflow(overflow)
	);

	// clk：10ns
	always #5 clk = ~clk;

	initial begin
		// initialize inputs
		clk = 0;
		rst_n = 0;
		A = 0;
		B = 0;
		op_code = 0;
		sub_start = 0;
		sub_len = 0;
		shift_amt = 0;

		#20;
		rst_n = 1;

		// ADD
		A = 15; B = 20;
		op_code = 4'b0000;
		#10;
		$display("ADD: %d + %d = %d, carry=%b", A, B, O, overflow);

		// SUB
		A = 50; B = 10;
		op_code = 4'b0001;
		#10;
		$display("SUB: %d - %d = %d, borrow=%b", A, B, O, overflow);

		// AND
		A = 64'hF0F0; B = 64'h0FF0;
		op_code = 4'b0010;
		#10;
		$display("AND: %h & %h = %h", A, B, O);

		// OR
		op_code = 4'b0011;
		#10;
		$display("OR: %h | %h = %h", A, B, O);

		// XNOR
		op_code = 4'b0100;
		#10;
		$display("XNOR result = %h", O);

		// Comparator (A > B)
		A = 100; B = 50;
		op_code = 4'b0101;
		#10;
		$display("COMPARE A>B result = %d", O);

		// Left Shift
		A = 8; shift_amt = 3;
		op_code = 4'b0110;
		#10;
		$display("LSHIFT: %d << %d = %d", A, shift_amt, O);

		// Right Shift
		A = 64; shift_amt = 3;
		op_code = 4'b0111;
		#10;
		$display("RSHIFT: %d >> %d = %d", A, shift_amt, O);

		// Substring Compare
		A = 64'h123456789ABCDEF0;
		B = 64'h000000009ABC0000;
		sub_start = 16;
		sub_len = 16;
		op_code = 4'b1000;
		#10;
		$display("SUBSTRING compare result = %d", O);

		// Right Shift Then Compare
		A = 64; shift_amt = 3; B = 8;
		op_code = 4'b1001;
		#10;
		$display("Right Shift Then Compare result = %d", O);

		// Left Shift Then Compare
		A = 2; shift_amt = 3; B = 16;
		op_code = 4'b1010;
		#10;
		$display("Left Shift Then Compare result = %d", O);

		#20;
		$finish;
	end

endmodule
