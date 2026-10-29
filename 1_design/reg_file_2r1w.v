`timescale 1ns / 1ps

module reg_file_2r1w (
    input  wire        clk,
    input  wire        rst_n,          // Asynchronous active-low reset
    input  wire        write_enable,   // Synchronous write control
    input  wire [2:0]  write_addr,     // 3-bit write address (R0 to R7)
    input  wire [31:0] write_data,     // 32-bit input data
    input  wire [2:0]  read_addr1,     // Read Port 1 address
    input  wire [2:0]  read_addr2,     // Read Port 2 address
    output wire [31:0] read_data1,     // Read Port 1 asynchronous output
    output wire [31:0] read_data2      // Read Port 2 asynchronous output
);

    // 8 registers of 32 bits each = 256 bits total storage
    reg [31:0] registers [7:0];
    integer i;

    // Dual asynchronous continuous read networks
    assign read_data1 = registers[read_addr1];
    assign read_data2 = registers[read_addr2];

    // Synchronous write logic with asynchronous active-low reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                registers[i] <= 32'h0000_0000;
            end
        end else if (write_enable) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule
