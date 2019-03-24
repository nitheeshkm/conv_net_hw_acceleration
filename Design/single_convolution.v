`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2019 06:29:19 PM
// Design Name: 
// Module Name: single_convolution
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


module single_convolution#(
    parameter imageRow = 15,
    parameter imageColumn = 14,
    parameter filterRow = 3,
    parameter filterColumn = 3,
    parameter imageAddressWidth = 16,
    parameter filterAddressWidth = 5,
    parameter dataWidth = 9,
    parameter filterDataWidth = 4, 
    parameter image_memFile = "C:/Users/Nitheesh/Desktop/RA/Machine Learning/files/files/sample_img_bin.txt",
    parameter filter_memFile = "C:/Users/Nitheesh/Desktop/RA/Machine Learning/ConvNet/Text_files/cnnmatlabfiles/filter.txt",
    parameter output_file = "C:/Users/Nitheesh/Desktop/RA/Machine Learning/ConvNet/Text_files/cnnmatlabfiles/output_file.txt"
    )(
    input clk,
    input reset,
    input startConvolution,
    //dbg ports
    output [dataWidth-1:0] write_data_output,
    output convDone_,
    output fullConvDone_out
    );
    wire signed [dataWidth-1:0] imageData_out;
    wire signed [filterDataWidth-1:0] filterData_out;
    wire signed [dataWidth-1:0] mac_output; 
    reg signed [dataWidth-1:0] output_data;
    
    reg [imageAddressWidth-1:0] imageHorizontal_count;
    reg [imageAddressWidth-1:0] imageVertical_count;
    reg [filterAddressWidth-1:0] filterHorizontal_count;
    reg [filterAddressWidth-1:0] filterVertical_count;
    
    reg [2:0] idle=4'b000, State1=4'b001, State2=4'b010, State3=4'b011, State4=4'b100, State5=4'b101, State6=4'b110, State7=4'b111;
    reg [2:0] currentState, nextState;
    
    wire [imageAddressWidth-1:0] image_Address;
    wire [filterAddressWidth-1:0] filter_Address;
    reg  [imageAddressWidth-1:0] output_Address;
    
    reg startConvolution_int;
    reg write_enable;
    (* keep = "true" *) reg macEnable;
    reg isConvolutionRunnning;
    reg oneConvDone;
    reg oneConvDone_delay;
    reg fullConvDone;
    reg fullConvDone_delay;
    
    
    single_port_RAM #(
        .memoryDepth(imageRow*imageColumn), // depth of the memory
        .addressBitWidth(imageAddressWidth), // number of address bits
        .dataBitWidth(dataWidth), // number of data bits
        .MEM_FILE(image_memFile) //path of the file to initialize the memory to default values
    ) imageMemory(
        .clk(clk), //clock signal
        .read_enable(isConvolutionRunnning), // signal for reading the memory data
        .write_enable(), // signal for writing the value to the memory
        .address(image_Address), //address for reading or writing the data
        .data_in(), // data to be written to the memory
        .data_out(imageData_out) // data read from the address
    );

    single_port_RAM #(
        .memoryDepth(filterRow*filterColumn), // depth of the memory
        .addressBitWidth(filterAddressWidth), // number of address bits
        .dataBitWidth(filterDataWidth), // number of data bits
        .MEM_FILE(filter_memFile) //path of the file to initialize the memory to default values
    ) filterMemory(
        .clk(clk), //clock signal
        .read_enable(isConvolutionRunnning), // signal for reading the memory data
        .write_enable(), // signal for writing the value to the memory
        .address(filter_Address), //address for reading or writing the data
        .data_in(), // data to be written to the memory
        .data_out(filterData_out) // data read from the address
    );
    
    single_port_RAM #(
        .memoryDepth(((imageRow-filterRow)+1)*((imageColumn-filterColumn)+1)), // depth of the memory
        .addressBitWidth(imageAddressWidth), // number of address bits
        .dataBitWidth(dataWidth), // number of data bits
        .MEM_FILE() //path of the file to initialize the memory to default values
    ) outputMemory(
        .clk(clk), //clock signal
        .read_enable(), // signal for reading the memory data
        .write_enable(write_enable), // signal for writing the value to the memory
        .address(output_Address), //address for reading or writing the data
        .data_in(output_data), // data to be written to the memory
        .data_out() // data read from the address
    );
    
    
    dot_product #(
        .dataWidth(dataWidth),
        .filterDataWidth(filterDataWidth)
        ) dot_product_inst(
        .clk(clk),
        .reset(reset),
        .macEnable(macEnable),
        .oneConvDone(oneConvDone_delay),
        .filterData_out(filterData_out),
        .imageData_out(imageData_out),
        .mac_output(mac_output)
        );
        
    assign fullConvDone_out = fullConvDone_delay;
    assign convDone_ = oneConvDone_delay;
    assign write_data_output = mac_output;
    
//    always@(*) begin
//            image_Address =  ((imageVertical_count + filterVertical_count)*imageColumn + imageHorizontal_count + filterHorizontal_count);
//             filter_Address = ((filterVertical_count * filterColumn) + filterHorizontal_count); 
    assign image_Address =  ((imageVertical_count + filterVertical_count)*imageColumn + imageHorizontal_count + filterHorizontal_count);
    assign filter_Address = ((filterVertical_count * filterColumn) + filterHorizontal_count); 
//    end
    
    always@(posedge clk) begin
        if(reset) begin
            currentState <= idle;
        end
        else begin
            currentState <= nextState;
        end
    end
    
    always@(posedge clk) begin
        if(startConvolution) 
            startConvolution_int <= 1;
        else
            startConvolution_int <= 0;
    end
    
    always@(*) begin
        if(startConvolution_int) begin
            isConvolutionRunnning = 1;
        end
        else begin
            if(fullConvDone_delay)
                isConvolutionRunnning = 0;
            else
                isConvolutionRunnning = isConvolutionRunnning;
        end       
    end
    
    always@(posedge clk) begin
        oneConvDone_delay <= oneConvDone;
        fullConvDone_delay <= fullConvDone;
        if(isConvolutionRunnning) begin
            macEnable <= 1;
        end
        else
            macEnable <= 0;
    end
     
    always@(posedge clk) begin
        if(reset)
            output_Address <= 0;
        else begin
            if(write_enable) begin
                output_Address <= output_Address + 1;
            end
            else
//                output_Address <= {imageAddressWidth{1'bx}};
                output_Address <= output_Address;
         end
    end
            
    
    always@(*) begin
        if(oneConvDone_delay) begin
            output_data = mac_output;
            write_enable = 1;
        end
        else begin
            write_enable = 0;
            output_data = {imageAddressWidth{1'bz}};
        end
    end
    
    always@(*) begin
        oneConvDone = 0; 
        fullConvDone = 0;
        
        case(currentState)
            idle : begin
                if(startConvolution_int) begin
                    nextState = State1;
                end
                else begin
                    imageHorizontal_count = 0;
                    imageVertical_count = 0;
                    filterHorizontal_count = 0;
                    filterVertical_count = 0;
                    nextState = idle;
                end
            end
            
            State1 : begin
                filterHorizontal_count = filterHorizontal_count + 1;
                if(filterHorizontal_count==filterRow-2) 
                    nextState = State3;
                else
                    nextState = State2;
            end
            
            State2 : begin
                filterHorizontal_count = filterHorizontal_count + 1;
                if(filterHorizontal_count==filterRow-2)
                    nextState = State3;
                else
                    nextState = State1;
            end
            
            State3 : begin
                filterHorizontal_count = filterHorizontal_count + 1;    
                if(filterVertical_count==filterColumn-1 && filterHorizontal_count==filterRow-1) begin
                    if(imageHorizontal_count==imageColumn-filterColumn && imageVertical_count==imageRow-filterRow)
                        nextState = State7;
                    else 
                        nextState = State5;
                        oneConvDone = 1;
                end
                else
                        nextState = State4;           
            end

            State4 : begin
                filterVertical_count = filterVertical_count + 1;
                filterHorizontal_count = 0;
                nextState = State1;
            end
            
            State5 : begin
                filterHorizontal_count = 0;
                filterVertical_count = 0;
                if(imageHorizontal_count==imageColumn-filterRow) begin
                    nextState = State6;
                end
                else begin
                    imageHorizontal_count = imageHorizontal_count + 1;
                    nextState = State1;
                end
            end
            
            State6 : begin
                imageVertical_count = imageVertical_count + 1;
                filterHorizontal_count = filterHorizontal_count + 1;
                imageHorizontal_count = 0;
                if(filterHorizontal_count==filterRow-2) 
                    nextState = State3;
                else
                    nextState = State1;
            end
            
            State7 : begin
                fullConvDone = 1;
                nextState = idle;
//                imageHorizontal_count = 0;
//                imageVertical_count = 0;
//                filterHorizontal_count = 0;
//                filterVertical_count = 0;
            end 
            default: begin
                nextState = idle;
            end
        endcase  
    end
    
    
//    always@(*) begin
//        isConvolutionRunnning = 0;
//        case(currentState)
//            idle : begin
//            end
//            State1 : begin
//                isConvolutionRunnning = 1;
//            end
//            State2 : begin    
//                isConvolutionRunnning = 1;
//            end
//            State3 : begin
//                isConvolutionRunnning = 1;
//            end
//        endcase
//    end
 
endmodule
