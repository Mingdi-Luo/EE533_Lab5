`timescale 1ns/1ps

module regfile_tb2;
    // Parameters
    parameter REGISTERED_OUTPUT = 1;
    parameter ADDRESS_WIDTH     = 5;
    parameter DATA_WIDTH        = 64;
    
    // Inputs
    reg                         clk;
    reg                         rst;
    reg [ADDRESS_WIDTH-1:0]     r0addr;
    reg [ADDRESS_WIDTH-1:0]     r1addr;
    reg [ADDRESS_WIDTH-1:0]     waddr;
    reg [DATA_WIDTH-1:0]        wdata;
    reg                         wena;
    
    // Outputs
    wire [DATA_WIDTH-1:0]       r0data;
    wire [DATA_WIDTH-1:0]       r1data;
    
    // Instantiate the Unit Under Test (UUT)
    regfile #(
        .REGISTERED_OUTPUT(REGISTERED_OUTPUT),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .r0addr(r0addr),
        .r1addr(r1addr),
        .waddr(waddr),
        .wdata(wdata),
        .wena(wena),
        .r0data(r0data),
        .r1data(r1data)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;
    end
    
    // Testbench logic
    initial begin
        // Initialize
        clk    = 0;
        rst    = 1;
        r0addr = 0;
        r1addr = 0;
        waddr  = 0;
        wdata  = 0;
        wena   = 0;
        
        // Reset phase
        #20;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        
        // Test Case 1: Write to register 1, read from r0addr
        $display("=== Test Case 1: Write and read register 1 ===");
        @(posedge clk);
        waddr = 5'd1;
        wdata = 64'd42;
        wena  = 1;
        @(posedge clk);
        wena  = 0;
        
        r0addr = 5'd1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        if (r0data !== 64'd42) begin
            $display("FAILED: Expected 42, Got %d", r0data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 2: Write to register 2, read from r1addr
        $display("=== Test Case 2: Write and read register 2 ===");
        @(posedge clk);
        waddr = 5'd2;
        wdata = 64'd88;
        wena  = 1;
        @(posedge clk);
        wena  = 0;
        
        r1addr = 5'd2;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        if (r1data !== 64'd88) begin
            $display("FAILED: Expected 88, Got %d", r1data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 3: Write to register 0 (x0 always 0)
        $display("=== Test Case 3: Write to x0 (should be ignored) ===");
        @(posedge clk);
        waddr = 5'd0;
        wdata = 64'd99;
        wena  = 1;
        @(posedge clk);
        wena  = 0;
        
        r0addr = 5'd0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        if (r0data !== 64'd0) begin
            $display("FAILED: Expected 0, Got %d", r0data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 4: Simultaneous read and write
        $display("=== Test Case 4: Simultaneous read and write ===");
        @(posedge clk);
        waddr  = 5'd3;
        wdata  = 64'd55;
        wena   = 1;
        r0addr = 5'd3;
        @(posedge clk);
        wena   = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        if (r0data !== 64'd55) begin
            $display("FAILED: Expected 55, Got %d", r0data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 5: Dual port read
        $display("=== Test Case 5: Dual port read ===");
        @(posedge clk);
        waddr = 5'd4;
        wdata = 64'd77;
        wena  = 1;
        @(posedge clk);
        wena  = 0;
        
        r0addr = 5'd1;
        r1addr = 5'd4;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        if (r0data !== 64'd42 || r1data !== 64'd77) begin
            $display("FAILED: r0data=%d, r1data=%d", r0data, r1data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 6: Multiple writes and reads
        $display("=== Test Case 6: Multiple writes and reads ===");
        @(posedge clk);
        waddr = 5'd10; wdata = 64'd10; wena = 1;
        @(posedge clk);
        waddr = 5'd20; wdata = 64'd20;
        @(posedge clk);
        waddr = 5'd30; wdata = 64'd30;
        @(posedge clk);
        wena  = 0;
        
        r0addr = 5'd10;
        r1addr = 5'd20;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        if (r0data !== 64'd10 || r1data !== 64'd20) begin
            $display("FAILED: r0data=%d, r1data=%d", r0data, r1data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 7: Write disabled
        $display("=== Test Case 7: Write disabled ===");
        @(posedge clk);
        waddr = 5'd5;
        wdata = 64'd66;
        wena  = 0;
        @(posedge clk);
        @(posedge clk);
        
        r0addr = 5'd5;
        @(posedge clk);
        @(posedge clk);
        
        if (r0data === 64'd66) begin
            $display("FAILED: Write should have been disabled");
        end else begin
            $display("PASSED: r0data=%d (expected 0 after reset)", r0data);
        end
        
        // Test Case 8: Overwrite register
        $display("=== Test Case 8: Overwrite existing register ===");
        @(posedge clk);
        waddr = 5'd1;
        wdata = 64'd99;
        wena  = 1;
        @(posedge clk);
        wena  = 0;
        
        r0addr = 5'd1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        if (r0data !== 64'd99) begin
            $display("FAILED: Expected 99, Got %d", r0data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 9: Reset functionality
        $display("=== Test Case 9: Reset clears all registers ===");
        @(posedge clk);
        rst = 1;
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        
        r0addr = 5'd1;
        r1addr = 5'd2;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        if (r0data !== 64'd0 || r1data !== 64'd0) begin
            $display("FAILED: r0data=%d, r1data=%d (expected 0)", r0data, r1data);
        end else begin
            $display("PASSED: All registers cleared");
        end
        
        // End simulation
        $display("=== Simulation Finished ===");
        #100;
        $finish;
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, regfile_tb2);
    end
endmodule
