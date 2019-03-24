`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2018 04:25:50 PM
// Design Name: 
// Module Name: single_port_RAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


/**
Instantiation block:
    single_port_RAM #(
        .memoryDepth(), // depth of the memory
        .addressBitWidth(), // number of address bits
        .dataBitWidth(), // number of data bits
        .MEM_FILE() //path of the file to initialize the memory to default values
    ) uut(
        .clk(), //clock signal
        .read_enable(), // signal for reading the memory data
        .write_enable(), // signal for writing the value to the memory
        .address(), //address for reading or writing the data
        .data_in(), // data to be written to the memory
        .data_out() // data read from the address
    );
**/

module single_port_RAM #(
    parameter memoryDepth = 27, //depth of the memory
    parameter addressBitWidth = 16, //no of address bit required to access memory locations
    parameter dataBitWidth = 16, // data bit width
    parameter MEM_FILE = "" //absolute path for the memory file
)(
    input clk,
    input read_enable,
    input write_enable,
    input [addressBitWidth-1:0] address,
    input signed [dataBitWidth-1:0] data_in,
    (* keep = "true" *) output reg signed [dataBitWidth-1:0] data_out
    );
    
    reg signed [dataBitWidth-1:0]mem[0:memoryDepth-1];
    
    initial begin
        $readmemb(MEM_FILE,mem);
    end
        
    always @(posedge clk) begin
        if( write_enable) begin
//            mem[address] <= (data_in[0] == 1'bx) ? 0 : data_in; 
              mem[address] <= data_in;
        end
        else if(read_enable) begin
//            assign data_out = read_enable ? mem[address] : 0;
//            assign data_out = (mem[address][0]== 1'bx) ? 0 : mem[address];
              if (address < 0 || address >= memoryDepth) begin
                data_out <= 0;
              end
              else begin
                data_out <= mem[address];
              end
        end
        
    end

endmodule
