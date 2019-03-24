`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2019 12:40:28 PM
// Design Name: 
// Module Name: dot_product
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


module dot_product #(
    parameter dataWidth = 16,
    parameter filterDataWidth = 4
    )(
    input clk,
    input reset,
    input macEnable,
    input oneConvDone,
    input signed [filterDataWidth-1:0] filterData_out,
    input signed [dataWidth-1:0] imageData_out,
    output signed [dataWidth-1:0] mac_output
    );

reg signed [dataWidth:0]  product;
reg signed [dataWidth:0]  sum = 0;
(* keep = "true" *)reg signed [dataWidth:0]  temp1 = 0;

    always@(*) begin
        if(reset) begin
            product = 0;
            sum = 0;
        end
        else begin
            if(macEnable) begin
                product = filterData_out*imageData_out;
                sum = temp1+product;
            end
            else begin
                product ={dataWidth{1'b0}};
                sum ={dataWidth{1'b0}};
            end
        end
    end
    
    always@(posedge clk) begin
        if(oneConvDone) begin
            temp1 <= 0;
        end
        else begin
            temp1 <= sum;
        end
    end

assign mac_output = oneConvDone? sum : {dataWidth{1'bz}};
    
endmodule
