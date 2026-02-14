`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Group13
//
// Create Date:    18:10:34 02/12/2026
// Module Name:    pipeline_datapath
//
// Dependencies: regfile, ins_mem, data_mem
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Pipelined Datapath with I-Mem, Regfile, and D-Mem
//
//////////////////////////////////////////////////////////////////////////////////
// Pipelined Datapath

module pipeline_datapath_Lab5
   #(
		parameter DATA_WIDTH  = 64,
		parameter DMEM_ADDR_WIDTH  = 8,
		parameter INSTR_WIDTH = 32,
		parameter IMEM_DEPTH_BITS = 9,
		parameter REGFILE_ADDRESS_WIDTH = 5
	)   
	(
	input clk,
	input reset
	);

	//Instruction Count for address of I-Mem
    reg [IMEM_DEPTH_BITS-1:0] PC; //9 bits

//-------------------Module Outputs-------------------
	
	//I-Mem Interface
	wire [INSTR_WIDTH-1:0]       imem_dout_wire; //32 bits
	
	//Regfile
	wire [DATA_WIDTH-1:0]	  	  r1out_wire;	 	//64  bits
	wire [DATA_WIDTH-1:0]        r2out_wire;		//64 bits
	
	//D-Mem Interface
	wire [DATA_WIDTH-1:0]        dmem_dout_wire; //64 bits
	
	
//-------------------Pipeline Registers-------------------
	
	//Instruction Mem
	reg [INSTR_WIDTH-1:0]      imem_pipereg; 	   //9 bits: Instruction Memory Pipeline Register
	
	//Register File 1
	reg                        			rf1_wreg_en; //1  bit
	reg                        			rf1_wmem_en; //1  bit
	reg [DATA_WIDTH-1:0]  					rf1_r1out;	 //64 bits to match 8 bits
	reg [DATA_WIDTH-1:0]       			rf1_r2out;	 //64 bits
	reg [REGFILE_ADDRESS_WIDTH-1:0]     rf1_wreg1;	 //5  bits
	
	//Register File 2
	reg                        			rf2_wreg_en; //1  bit
	reg                        			rf2_wmem_en; //1  bit
	reg [DATA_WIDTH-1:0]  					rf2_r1out;	 //64 bits to match 8 bits
	reg [DATA_WIDTH-1:0]       			rf2_r2out;	 //64 bits
	reg [REGFILE_ADDRESS_WIDTH-1:0]     rf2_wreg1;	 //5  bits
	
	//Data Mem
	reg                        			dmem_wreg_en;//1  bit
	reg [DATA_WIDTH-1:0]       			dmem_dout;	 //64 bits
	reg [REGFILE_ADDRESS_WIDTH-1:0]     dmem_wreg1;	 //5  bits
	
//Module Instantiations

	//Instruction Memory
	inst_mem imem32x512(
	
		//inputs
		.addr(PC),
		.clk(clk),
		
		//outputs
		.dout(imem_dout_wire)
	);
	
	//Register File
	regfile #(
	   .REGISTERED_OUTPUT(0),
		.ADDRESS_WIDTH(REGFILE_ADDRESS_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	)regfile(
		//inputs
		.clk      	(clk),
		.r0addr     (imem_pipereg[29:25]),
		.r1addr     (imem_pipereg[24:20]),
		.wdata      (dmem_dout),
		.wena  		(dmem_wreg_en),
		.waddr      (dmem_wreg1),
		.rst			(reset),
		//outputs
		.r0data(r1out_wire),
		.r1data(r2out_wire)
	);
	
	//Data Memory
	data_mem dmem64x256(
		//inputs
		.clka(clk),
		.clkb(clk),
		.wea(rf2_wmem_en),
		.addrb(rf2_r1out[DMEM_ADDR_WIDTH-1:0]),
		.addra(rf2_r1out[DMEM_ADDR_WIDTH-1:0]),
		.dina(rf2_r2out),
		
		//outputs
		.doutb(dmem_dout_wire)
	);
	
	
	//Data Passing Logic
	always @(posedge clk) begin
		if(reset) begin
		    //Instruction Fetch
			PC 			  <= 0;
			
			// IMEM/REGFILE
			imem_pipereg  <= 0;
			
			// REGFILE1
			rf1_wmem_en   <= 0;
			rf1_wreg_en   <= 0;
			rf1_r1out     <= 0;
			rf1_r2out     <= 0;
			rf1_wreg1     <= 0;
		 
			// REGFILE2
			rf2_wmem_en   <= 0;
			rf2_wreg_en   <= 0;
			rf2_r1out     <= 0;
			rf2_r2out     <= 0;
			rf2_wreg1     <= 0;
			
			// DMEM/WB
			dmem_dout     <= 0;
			dmem_wreg_en  <= 0;
			dmem_wreg1    <= 0;
			
			
			
			
		end
		else begin
			//Instruction Fetch
			PC <= PC + 1; //We increment by one in the imem
			
			// IMEM/REGFILE
			imem_pipereg <= imem_dout_wire;
			
			
			// REGFILE1
			rf1_wmem_en  <= imem_pipereg[31];
			rf1_wreg_en  <= imem_pipereg[30];
			rf1_r1out    <= r1out_wire;
			rf1_r2out    <= r2out_wire;
			rf1_wreg1    <= imem_pipereg[19:15];
						 
			// REGFILE2  
			rf2_wmem_en  <= rf1_wmem_en;
			rf2_wreg_en  <= rf1_wreg_en;
			rf2_r1out    <= rf1_r1out;
			rf2_r2out    <= rf1_r2out;
			rf2_wreg1    <= rf1_wreg1;
			
			// DMEM/WB
			dmem_dout    <= dmem_dout_wire;
			dmem_wreg_en <= rf2_wreg_en;
			dmem_wreg1   <= rf2_wreg1;
		end
	
	end
	
endmodule