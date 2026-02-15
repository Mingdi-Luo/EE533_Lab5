`timescale 1ns/1ps
module regfile_tb;
    // Parameters
    parameter REGISTERED_OUTPUT = 0;
    parameter ADDRESS_WIDTH     = 6;
    parameter DATA_WIDTH        = 64;
    
    // Inputs
    reg                         clk;
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
        .r0addr(r0addr),
        .r1addr(r1addr),
        .waddr(waddr),
        .wdata(wdata),
        .wena(wena),
        .r0data(r0data),
        .r1data(r1data)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Testbench logic
    initial begin
        // Initialize inputs
        r0addr = 0;
        r1addr = 0;
        waddr  = 0;
        wdata  = 0;
        wena   = 0;
        
        // Wait for a few clock cycles
        #20;
        
        // Test Case 1: Write to register 1, read from r0addr
        $display("=== Test Case 1: Write and read register 1 ===");
        waddr = 6'd1;
        wdata = 64'h123456789ABCDEF0;
        wena  = 1;
        #10;
        wena  = 0;
        
        r0addr = 6'd1;
        #10;
        if (r0data !== 64'h123456789ABCDEF0) begin
            $display("FAILED: Expected 0x123456789ABCDEF0, Got %h", r0data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 2: Write to register 2, read from r1addr
        $display("=== Test Case 2: Write and read register 2 ===");
        waddr = 6'd2;
        wdata = 64'hFEDCBA9876543210;
        wena  = 1;
        #10;
        wena  = 0;
        
        r1addr = 6'd2;
        #10;
        if (r1data !== 64'hFEDCBA9876543210) begin
            $display("FAILED: Expected 0xFEDCBA9876543210, Got %h", r1data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 3: Write to register 0 (should not write, x0 always 0)
        $display("=== Test Case 3: Write to x0 (should be ignored) ===");
        waddr = 6'd0;
        wdata = 64'hDEADBEEFDEADBEEF;
        wena  = 1;
        #10;
        wena  = 0;
        
        r0addr = 6'd0;
        #10;
        if (r0data !== 64'd0) begin
            $display("FAILED: Expected 0x0, Got %h", r0data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 4: Simultaneous read and write
        $display("=== Test Case 4: Simultaneous read and write ===");
        waddr  = 6'd3;
        wdata  = 64'hAABBCCDDEEFF0011;
        wena   = 1;
        r0addr = 6'd3;
        #10;
        wena   = 0;
        #10;
        if (r0data !== 64'hAABBCCDDEEFF0011) begin
            $display("FAILED: Expected 0xAABBCCDDEEFF0011, Got %h", r0data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 5: Read two registers simultaneously
        $display("=== Test Case 5: Dual port read ===");
        waddr = 6'd4;
        wdata = 64'h1111222233334444;
        wena  = 1;
        #10;
        wena  = 0;
        
        r0addr = 6'd1;  // Previously written 0x123456789ABCDEF0
        r1addr = 6'd4;  // Just written 0x1111222233334444
        #10;
        if (r0data !== 64'h123456789ABCDEF0 || r1data !== 64'h1111222233334444) begin
            $display("FAILED: r0data=%h, r1data=%h", r0data, r1data);
        end else begin
            $display("PASSED");
        end
        
        // Test Case 6: Write multiple registers, verify data integrity
        $display("=== Test Case 6: Multiple writes and reads ===");
        waddr = 6'd10; wdata = 64'hAAAAAAAAAAAAAAAA; wena = 1; #10;
        waddr = 6'd20; wdata = 64'hBBBBBBBBBBBBBBBB; #10;
        waddr = 6'd30; wdata = 64'hCCCCCCCCCCCCCCCC; #10;
        wena  = 0;
        
        r0addr = 6'd10;
        r1addr = 6'd20;
        #10;
        if (r0data !== 64'hAAAAAAAAAAAAAAAA || r1data !== 64'hBBBBBBBBBBBBBBBB) begin
            $display("FAILED: r0data=%h, r1data=%h", r0data, r1data);
        end else begin
            $display("PASSED");
        end
        
        // End simulation
        $display("=== Simulation Finished ===");
        $finish;
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule