`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Group Number: G13
// Group members: Yanchen Zhang; zhangy38@usc.edu
//                Mingdi Luo; mingdilu@usc.edu
//                Yizheng Qiao; yizhengq@usc.edu
//
// Create Date:    19:03:46 02/11/2026 
// Design Name:    64bit Arithmetic Logic Unit
// Module Name:    ALUG13 
// Project Name:   EE533 Lab 5
// 
// Description: Our group's ALU uses a 4-bit control code to select different operational functions.
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Nothing
//
//////////////////////////////////////////////////////////////////////////////////

module ALUG13 (
    input               clk,
    input               rst_n,
    input      [63:0]   A,
    input      [63:0]   B,
    input      [3:0]    op_code,
    input      [5:0]    sub_start,  
    input      [5:0]    sub_len,   
    input      [5:0]    shift_amt,
    output reg [63:0]   O,
    output reg          overflow   
);

    reg [63:0] result;
    reg        carry;
    reg [63:0] A_shifted;
    reg [63:0] mask;

    // Combinational Logic
    always @(*) begin
        result = 64'b0;
        carry  = 1'b0;
        //Add
        if (op_code == 4'b0000) begin
            {carry, result} = A + B;
        end
        //Subtract
        else if (op_code == 4'b0001) begin
            {carry, result} = A - B;
        end
        //Bitwise AND
        else if (op_code == 4'b0010) begin
            result = A & B;
        end
        //Bitwise OR
        else if (op_code == 4'b0011) begin
            result = A | B;
        end
        //Bitwise XNOR
        else if (op_code == 4'b0100) begin
            result = ~(A ^ B);
        end
        //Comparator
        else if (op_code == 4'b0101) begin
            if (A > B)
				result = 64'd1;
			else
				result = 64'd0;
            carry = 1'b0;
        end
        //logical left shift functions
        else if (op_code == 4'b0110) begin
            result = A << shift_amt;
        end
        //logical right shift functions
        else if (op_code == 4'b0111) begin
            result = A >> shift_amt;
        end
        //Substring comparison
        else if (op_code == 4'b1000) begin
            if (sub_len == 0)
                mask = 64'b0;
            else
                mask = (64'h1 << sub_len) - 1;

            if ( ((A >> sub_start) & mask) == ((B >> sub_start) & mask) )
                result = 64'b1;
            else
                result = 64'b0;
        end
        //Right shift-then-compare
        else if (op_code == 4'b1001) begin
            A_shifted = A >> shift_amt;

            if (A_shifted > B)
                result = 64'b1;
            else
                result = 64'b0;
            carry = 1'b0;
        end
        //Left shift-then-compare
        else if (op_code == 4'b1010) begin
            A_shifted = A << shift_amt;

            if (A_shifted > B)
                result = 64'b1;
            else
                result = 64'b0;
            carry = 1'b0;
        end
    end
 

    // Synchronous output register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            O <= 64'b0;
            overflow <= 1'b0;
        end 
        else begin
            O <= result;
            overflow <= carry;
        end
    end
endmodule
