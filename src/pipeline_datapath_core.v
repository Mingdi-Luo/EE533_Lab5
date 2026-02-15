`timescale 1ns / 1ps

module pipeline_datapath_core #(
    parameter DATA_WIDTH              = 64,
    parameter INSTR_WIDTH             = 32,
    parameter IMEM_ADDR_WIDTH         = 9,   // inst_mem addr[8:0]
    parameter DMEM_ADDR_WIDTH         = 8,   // data_mem addra/addrb[7:0]
    parameter REGFILE_ADDRESS_WIDTH   = 5
)(
    input  wire                         clk,
    input  wire                         reset,
    input  wire                         enable,

    // IMEM interface (read-only from core perspective)
    output reg  [IMEM_ADDR_WIDTH-1:0]    imem_addr,
    input  wire [INSTR_WIDTH-1:0]        imem_dout,

    // DMEM interface (core as master)
    output wire                         dmem_wea,
    output wire [DMEM_ADDR_WIDTH-1:0]   dmem_addra,
    output wire [DMEM_ADDR_WIDTH-1:0]   dmem_addrb,
    output wire [DATA_WIDTH-1:0]        dmem_dina,
    input  wire [DATA_WIDTH-1:0]        dmem_doutb
);

    // ----------------------------
    // PC / IF stage
    // ----------------------------
    reg [IMEM_ADDR_WIDTH-1:0] PC;

    // ----------------------------
    // Pipeline registers
    // ----------------------------
    reg [INSTR_WIDTH-1:0]              if_id_instr;

    reg                               id_ex_wmem_en;
    reg                               id_ex_wreg_en;
    reg [DATA_WIDTH-1:0]              id_ex_r1out;
    reg [DATA_WIDTH-1:0]              id_ex_r2out;
    reg [REGFILE_ADDRESS_WIDTH-1:0]   id_ex_wreg;

    reg                               ex_mem_wmem_en;
    reg                               ex_mem_wreg_en;
    reg [DATA_WIDTH-1:0]              ex_mem_r1out;
    reg [DATA_WIDTH-1:0]              ex_mem_r2out;
    reg [REGFILE_ADDRESS_WIDTH-1:0]   ex_mem_wreg;

    reg                               mem_wb_wreg_en;
    reg [DATA_WIDTH-1:0]              mem_wb_wdata;
    reg [REGFILE_ADDRESS_WIDTH-1:0]   mem_wb_wreg;

    // ----------------------------
    // Regfile (same style as yours)
    // ----------------------------
    wire [DATA_WIDTH-1:0] r0data;
    wire [DATA_WIDTH-1:0] r1data;

    regfile #(
        .REGISTERED_OUTPUT(0),
        .ADDRESS_WIDTH(REGFILE_ADDRESS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_regfile (
        .clk   (clk),
        .r0addr(if_id_instr[29:25]),
        .r1addr(if_id_instr[24:20]),
        .wdata (mem_wb_wdata),
        .wena  (mem_wb_wreg_en),
        .waddr (mem_wb_wreg),
        .rst   (reset),
        .r0data(r0data),
        .r1data(r1data)
    );

    // ----------------------------
    // DMEM drive from EX/MEM stage (same behavior as before)
    // ----------------------------
    assign dmem_wea   = ex_mem_wmem_en;
    assign dmem_addra = ex_mem_r1out[DMEM_ADDR_WIDTH-1:0];
    assign dmem_addrb = ex_mem_r1out[DMEM_ADDR_WIDTH-1:0];
    assign dmem_dina  = ex_mem_r2out;

    // ----------------------------
    // Sequential pipeline
    // ----------------------------
    always @(posedge clk) begin
        if (reset) begin
            PC         <= {IMEM_ADDR_WIDTH{1'b0}};
            imem_addr  <= {IMEM_ADDR_WIDTH{1'b0}};

            if_id_instr <= {INSTR_WIDTH{1'b0}};

            id_ex_wmem_en <= 1'b0;
            id_ex_wreg_en <= 1'b0;
            id_ex_r1out   <= {DATA_WIDTH{1'b0}};
            id_ex_r2out   <= {DATA_WIDTH{1'b0}};
            id_ex_wreg    <= {REGFILE_ADDRESS_WIDTH{1'b0}};

            ex_mem_wmem_en <= 1'b0;
            ex_mem_wreg_en <= 1'b0;
            ex_mem_r1out   <= {DATA_WIDTH{1'b0}};
            ex_mem_r2out   <= {DATA_WIDTH{1'b0}};
            ex_mem_wreg    <= {REGFILE_ADDRESS_WIDTH{1'b0}};

            mem_wb_wreg_en <= 1'b0;
            mem_wb_wdata   <= {DATA_WIDTH{1'b0}};
            mem_wb_wreg    <= {REGFILE_ADDRESS_WIDTH{1'b0}};
        end else if (enable) begin
            // IF
            imem_addr <= PC;
            PC <= PC + 1'b1;

            // IF/ID
            if_id_instr <= imem_dout;

            // ID/EX
            id_ex_wmem_en <= if_id_instr[31];
            id_ex_wreg_en <= if_id_instr[30];
            id_ex_r1out   <= r0data;
            id_ex_r2out   <= r1data;
            id_ex_wreg    <= if_id_instr[19:15];

            // EX/MEM
            ex_mem_wmem_en <= id_ex_wmem_en;
            ex_mem_wreg_en <= id_ex_wreg_en;
            ex_mem_r1out   <= id_ex_r1out;
            ex_mem_r2out   <= id_ex_r2out;
            ex_mem_wreg    <= id_ex_wreg;

            // MEM/WB
            mem_wb_wdata   <= dmem_doutb;
            mem_wb_wreg_en <= ex_mem_wreg_en;
            mem_wb_wreg    <= ex_mem_wreg;
        end
        // else: enable==0 -> freeze all state, keep outputs stable
    end

endmodule
