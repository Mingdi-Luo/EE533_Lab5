`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Group Number: G13
// Group members: Yanchen Zhang; zhangy38@usc.edu
//                Mingdi Luo; mingdilu@usc.edu
//                Yizheng Qiao; yizhengq@usc.edu
// 
// Create Date:    23:25:00 02/12/2026 
// Design Name:    64bit * 32 register_file
// Module Name:    regfile 
// Project Name:   EE533 Lab5
// Tool versions: 
// Description: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module regfile #(
    parameter REGISTERED_OUTPUT = 1,
    parameter ADDRESS_WIDTH     = 5,
    parameter DATA_WIDTH        = 64
)(
    input                          clk,
    input  [ADDRESS_WIDTH-1:0]     r0addr, r1addr,
    input  [ADDRESS_WIDTH-1:0]     waddr,
    input  [DATA_WIDTH-1:0]        wdata,
    input                          wena,
    input                          rst,
    output [DATA_WIDTH-1:0]        r0data,
    output [DATA_WIDTH-1:0]        r1data
);
    reg [DATA_WIDTH-1:0] register [0:2**ADDRESS_WIDTH-1];
    
    integer i;
    always @(negedge clk) begin
        if(rst) begin
            for (i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
                register[i] <= {DATA_WIDTH{1'b0}};
            end
        end
        else if (wena && waddr != 0)
            register[waddr] <= wdata;
    end
    
    generate
        if (REGISTERED_OUTPUT) begin
            reg [DATA_WIDTH-1:0] data_reg0;
            reg [DATA_WIDTH-1:0] data_reg1;
            always @(posedge clk) begin
                data_reg0 <= (r0addr != 0) ? register[r0addr] : {DATA_WIDTH{1'b0}};
                data_reg1 <= (r1addr != 0) ? register[r1addr] : {DATA_WIDTH{1'b0}};
            end
            assign r0data = data_reg0;
            assign r1data = data_reg1;
        end
        else begin
            assign r0data = (r0addr != 0) ? register[r0addr] : {DATA_WIDTH{1'b0}};
            assign r1data = (r1addr != 0) ? register[r1addr] : {DATA_WIDTH{1'b0}};
        end
    endgenerate
endmodule
