`timescale 1ns/1ps

module tb_pipeline_datapath_Lab5;

  localparam integer DMEM_ADDR_WIDTH = 8;

  reg clk  = 1'b0;
  reg reset = 1'b1;

  // 100MHz clock
  always #5 clk = ~clk;

  // DUT
  pipeline_datapath_Lab5 dut (
    .clk(clk),
    .reset(reset)
  );

  integer cycle;

  reg        saw_wb_r2, saw_wb_r3, saw_wb_r4;
  reg [63:0] wb_r2_val, wb_r3_val, wb_r4_val;

  initial begin
    cycle      = 0;
    saw_wb_r2  = 0;
    saw_wb_r3  = 0;
    saw_wb_r4  = 0;
    wb_r2_val  = 0;
    wb_r3_val  = 0;
    wb_r4_val  = 0;

    repeat (4) @(posedge clk);
    reset = 1'b0;

    repeat (120) @(posedge clk);

    $display("\n================ FINAL REPORT ================");
    $display("WB to R2: saw=%0d val=%0d (0x%h)", saw_wb_r2, wb_r2_val, wb_r2_val);
    $display("WB to R3: saw=%0d val=%0d (0x%h)", saw_wb_r3, wb_r3_val, wb_r3_val);
    $display("WB to R4: saw=%0d val=%0d (0x%h)", saw_wb_r4, wb_r4_val, wb_r4_val);

    if (!saw_wb_r2) $display("FAIL: never observed writeback to R2");
    if (!saw_wb_r3) $display("FAIL: never observed writeback to R3");
    if (!saw_wb_r4) $display("FAIL: never observed writeback to R4");

    if (saw_wb_r2 && wb_r2_val !== 64'd4) $display("FAIL: R2 writeback not 4");
    if (saw_wb_r3 && wb_r3_val !== 64'd4) $display("FAIL: R3 writeback not 4");
    if (saw_wb_r4 && wb_r4_val !== 64'd4) $display("FAIL: R4 writeback not 4");

    if (saw_wb_r2 && saw_wb_r3 && saw_wb_r4 &&
        wb_r2_val === 64'd4 &&
        wb_r3_val === 64'd4 &&
        wb_r4_val === 64'd4) begin
      $display("PASS: pipeline behaves as expected");
    end else begin
      $display("RESULT: FAIL");
    end

    $display("================================================\n");
    $finish;
  end

  always @(posedge clk) begin
    cycle <= cycle + 1;
  end

  // Debug print
  always @(posedge clk) begin
    if (!reset) begin
      $display("[cyc=%0d] PC=%0d instr=%h | rf1(wmem,wreg,wrd)=(%b,%b,%0d) rf2(wmem,wreg,wrd)=(%b,%b,%0d) | WB(en,addr,data)=(%b,%0d,%0d)",
        cycle,
        dut.PC,
        dut.imem_pipereg,
        dut.rf1_wmem_en, dut.rf1_wreg_en, dut.rf1_wreg1,
        dut.rf2_wmem_en, dut.rf2_wreg_en, dut.rf2_wreg1,
        dut.dmem_wreg_en, dut.dmem_wreg1, dut.dmem_dout
      );
    end
  end

  // Capture writeback events
  always @(posedge clk) begin
    if (!reset && dut.dmem_wreg_en) begin
      if (dut.dmem_wreg1 == 5'd2 && !saw_wb_r2) begin
        saw_wb_r2 <= 1'b1;
        wb_r2_val <= dut.dmem_dout;
        $display("CAPTURE WB: R2 <= %0d (0x%h) @cyc=%0d",
                 dut.dmem_dout, dut.dmem_dout, cycle);
      end

      if (dut.dmem_wreg1 == 5'd3 && !saw_wb_r3) begin
        saw_wb_r3 <= 1'b1;
        wb_r3_val <= dut.dmem_dout;
        $display("CAPTURE WB: R3 <= %0d (0x%h) @cyc=%0d",
                 dut.dmem_dout, dut.dmem_dout, cycle);
      end

      if (!reset && dut.dmem_wreg_en && (dut.dmem_wreg1 == 5'd4)) begin
		  wb_r4_val <= dut.dmem_dout;
		  $display("WB R4 <= %0d (0x%h) @cyc=%0d",
					 dut.dmem_dout, dut.dmem_dout, cycle);
	  end
    end
  end

  // Optional store monitor
  always @(posedge clk) begin
    if (!reset && dut.rf2_wmem_en) begin
      $display("STORE: DMem[%0d] <= %0d (0x%h) @cyc=%0d",
               dut.rf2_r1out[DMEM_ADDR_WIDTH-1:0],
               dut.rf2_r2out,
               dut.rf2_r2out,
               cycle);
    end
  end

endmodule
