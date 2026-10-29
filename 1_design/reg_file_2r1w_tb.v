`timescale 1ns / 1ps

module reg_file_2r1w_tb;

    reg         clk;
    reg         rst_n;
    reg         write_enable;
    reg  [2:0]  write_addr;
    reg  [31:0] write_data;
    reg  [2:0]  read_addr1;
    reg  [2:0]  read_addr2;
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    reg_file_2r1w uut (
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // 100 MHz clock generation (10ns period)
    always #5 clk = ~clk;

    integer err_count;

    initial begin
        err_count = 0;
        clk = 0;
        rst_n = 0;
        write_enable = 0;
        write_addr = 0;
        write_data = 0;
        read_addr1 = 0;
        read_addr2 = 0;

        $display("=== Starting 2R/1W Register File Functional Verification ===");

        // Test 1: Asynchronous Reset Assertion
        #12;
        if (read_data1 !== 32'h0 || read_data2 !== 32'h0) begin
            $display("[FAIL] Test 1: Registers not cleared after reset.");
            err_count = err_count + 1;
        end else begin
            $display("[PASS] Test 1: Asynchronous active-low reset verified.");
        end

        // Deassert reset
        rst_n = 1;
        #10;

        // Test 2: Synchronous Sequential Writes (R1 and R2)
        @(posedge clk);
        write_enable = 1; write_addr = 3'd1; write_data = 32'hAAAA_5555;
        @(posedge clk);
        write_enable = 1; write_addr = 3'd2; write_data = 32'h1234_5678;
        @(posedge clk);
        write_enable = 0;
        #2;

        // Test 3: Dual Independent Asynchronous Reads (R1 on Port 1, R2 on Port 2)
        read_addr1 = 3'd1;
        read_addr2 = 3'd2;
        #5;
        if (read_data1 !== 32'hAAAA_5555 || read_data2 !== 32'h1234_5678) begin
            $display("[FAIL] Test 3: Dual simultaneous reads mismatch.");
            err_count = err_count + 1;
        end else begin
            $display("[PASS] Test 3: Dual simultaneous reads verified.");
        end

        // Test 4: Simultaneous Read from the Same Register (R1 on both ports)
        read_addr1 = 3'd1;
        read_addr2 = 3'd1;
        #5;
        if (read_data1 !== 32'hAAAA_5555 || read_data2 !== 32'hAAAA_5555) begin
            $display("[FAIL] Test 4: Simultaneous same-register read mismatch.");
            err_count = err_count + 1;
        end else begin
            $display("[PASS] Test 4: Simultaneous same-register read verified.");
        end

        // Test 5: Simultaneous Read and Write to Different Registers
        @(posedge clk);
        write_enable = 1; write_addr = 3'd3; write_data = 32'hCAFE_BABE;
        read_addr1 = 3'd1; read_addr2 = 3'd2;
        #2;
        if (read_data1 !== 32'hAAAA_5555 || read_data2 !== 32'h1234_5678) begin
            $display("[FAIL] Test 5: Read affected by concurrent write.");
            err_count = err_count + 1;
        end else begin
            $display("[PASS] Test 5: Simultaneous read/write to separate registers verified.");
        end
        @(posedge clk);
        write_enable = 0;

        // Test 6: Verify Data Written in Test 5
        read_addr1 = 3'd3;
        #5;
        if (read_data1 !== 32'hCAFE_BABE) begin
            $display("[FAIL] Test 6: Data in R3 was not written correctly.");
            err_count = err_count + 1;
        end else begin
            $display("[PASS] Test 6: Synchronous write commit verified.");
        end

        // Test 7: Write Enable Low (Data Retention Check)
        @(posedge clk);
        write_enable = 0; write_addr = 3'd3; write_data = 32'hDEAD_DEAD;
        @(posedge clk);
        read_addr1 = 3'd3;
        #5;
        if (read_data1 !== 32'hCAFE_BABE) begin
            $display("[FAIL] Test 7: Register overwritten while write_enable is low.");
            err_count = err_count + 1;
        end else begin
            $display("[PASS] Test 7: Write-inhibit and data retention verified.");
        end

        // Test 8: Asynchronous Reset During Active Cycle
        #10;
        rst_n = 0;
        #2;
        read_addr1 = 3'd1; read_addr2 = 3'd2;
        #2;
        if (read_data1 !== 32'h0 || read_data2 !== 32'h0) begin
            $display("[FAIL] Test 8: Asynchronous reset failed during runtime.");
            err_count = err_count + 1;
        end else begin
            $display("[PASS] Test 8: Runtime asynchronous reset confirmed.");
        end

        #20;
        $display("==========================================================");
        if (err_count == 0)
            $display("ALL 8 VERIFICATION TESTS PASSED SUCCESSFULLY!");
        else
            $display("VERIFICATION COMPLETED WITH %0d ERRORS.", err_count);
        $display("==========================================================");
        $finish;
    end

endmodule


