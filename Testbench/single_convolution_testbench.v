`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2019 06:03:06 PM
// Design Name: 
// Module Name: single_convolution_testbench
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


module single_convolution_testbench #(
        parameter imageRow = 220,
        parameter imageColumn = 170,
        parameter filterRow = 3,
        parameter filterColumn = 3,
        parameter imageAddressWidth = 16,
        parameter filterAddressWidth = 5,
        parameter dataWidth = 16,
        parameter filterDataWidth = 4, 
        parameter image_memFile = "C:/Users/Nitheesh/Desktop/RA/Machine Learning/files/files/sample_img_bin.txt",
        parameter filter_memFile = "C:/Users/Nitheesh/Desktop/RA/Machine Learning/ConvNet/Text_files/cnnmatlabfiles/filter.txt",
        parameter output_file = "C:/Users/Nitheesh/Desktop/RA/Machine Learning/ConvNet/Text_files/cnnmatlabfiles/output_file.txt"
        );
    reg clk,reset,startConvolution;
//   reg [dataWidth-1:0] imageDataIn, filterDataIn;
    wire [dataWidth-1:0] write_data_output;
    wire convDone_;
    wire fullConvDone;
    integer period = 10;
    integer f;
single_convolution #(
         imageRow,
         imageColumn,
         filterRow,
         filterColumn,
         imageAddressWidth,
         filterAddressWidth,
         dataWidth,
         filterDataWidth,
         image_memFile,
         filter_memFile,
         output_file
        )uut(
         .clk(clk),
         .reset(reset),
         .startConvolution(startConvolution),
         .write_data_output(write_data_output),
         .convDone_(convDone_),
         .fullConvDone_out(fullConvDone)
//         .imageDataIn(imageDataIn),
//         .filterDataIn(filterDataIn)
        );
    
    initial begin
//    f = $fopen("C:\\Users\\Nitheesh\\Desktop\\Verilog\\ConvNet\\Text_files\\cnnmatlabfiles\\output_file_2.txt","wb");
    f = $fopen(output_file,"wb");
    clk=0;
    forever  #(period/2) clk=~clk;
    end
    
    initial begin
    reset = 1;
    #period;
    reset = 0;
    startConvolution = 1;
    #period;
    startConvolution = 0;
    #296195;
//    $fclose(f);
    end

    
    always@(posedge clk) begin
        if(convDone_) begin
             $fwrite(f,"%d\n",$signed(write_data_output));
        end
        else begin
            if(fullConvDone) 
                $fclose(f);
        end
    end
    
endmodule
