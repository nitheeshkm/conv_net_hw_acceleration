`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2019 04:34:30 PM
// Design Name: 
// Module Name: dot_product_testbench
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
module dot_product_testbench#(parameter size = 8)(

    );
    
    reg clk,reset;
    reg [7:0] filterInput, imageInput;
    integer period = 10;
    
    initial begin
    forever #period clk = ~clk;
    end
    
    dot_product#(size)uut(.clk(clk),.reset(reset),.filterInput(filterInput),.imageInput(imageInput));
    
    initial begin
    
    reset=1;
    #(period*100);
    reset=0;
    #period
    filterInput = 8'h07;
    imageInput = 8'h06;
    #period
    filterInput = 8'h05;
    imageInput = 8'h03;
    #period
    filterInput = 8'h01;
    imageInput = 8'h00;
    #period
    filterInput = 8'h02;
    imageInput = 8'h01;
    #period
    filterInput = 8'h02;
    imageInput = 8'h03;
    #period
    filterInput = 8'h05;
    imageInput = 8'h04;
    end
    
endmodule
