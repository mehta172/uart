`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Tushar Mehta
// 
// Create Date: 02/28/2025 12:18:51 PM
// Design Name: UART_Transmitter
// Module Name: uart_tx
// Project Name: UART
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


module uart_tx(
    input wire i_tx_clk,
    input wire i_tx_rst,
    input wire i_start_bit,
    input wire [7:0]i_data_in,
    input wire i_parity_bit,
    output reg o_tx_data_out,
    output reg o_tx_data_done,
    output reg o_tx_busy
    );
    
    parameter S0_RESET_STATE = 4'b0000;
    parameter S1_START_STATE = 4'b0001;
    parameter S2_DATA_STATE = 4'b0010;
    parameter S3_PARITY_STATE = 4'b0100;
    parameter S4_STOP_STATE = 4'b1000;
    
    reg [7:0] temp_data;
    
    reg [3:0]present_state;
    reg [3:0]next_state;
    wire [2:0] indx;
    reg [2:0]bit_indx;
    
    assign indx = bit_indx;
    always@(posedge i_tx_clk or negedge i_tx_rst)begin
        case(present_state)
            S0_RESET_STATE:begin
                o_tx_data_out <= 1'b1;
                o_tx_data_done <= 1'b0;
                o_tx_busy <= 1'b0;
                bit_indx <= 3'b0;
                next_state <= S1_START_STATE;
            end
            
            S1_START_STATE:begin
                o_tx_data_out <= 1'b0;
                o_tx_data_done <= 1'b0;
                o_tx_busy <= 1'b1;
                if(i_start_bit & i_tx_rst)begin
                    temp_data <= i_data_in;
                    next_state <= S2_DATA_STATE;
                end
            end
            
            S2_DATA_STATE:begin
                o_tx_data_out <= temp_data[indx];
                    if(&bit_indx)begin
                        bit_indx <= 0;
                        next_state <= S3_PARITY_STATE;
                    end
                    else begin
                        bit_indx <= bit_indx + 1'b1;
                        //next_state <= S2_DATA_STATE;
                    end
            end
            S3_PARITY_STATE:begin
                if(i_parity_bit)begin
                    if(^temp_data)begin
                        o_tx_data_out <= 1'b1;
                        next_state <= S4_STOP_STATE;
                    end
                    else begin
                        o_tx_data_out <= 1'b0;
                        next_state <= S4_STOP_STATE;
                    end
                end
                else begin
                next_state <= S3_PARITY_STATE;
                end
            end
            S4_STOP_STATE:begin
               o_tx_data_out <= 1'b1;
               o_tx_data_done <= 1'b1;
               o_tx_busy <= 1'b1; 
               next_state <=  S0_RESET_STATE;     
            end

        endcase
    end
    
    always@(*)begin
        if(!i_tx_rst)begin
            present_state <= S0_RESET_STATE;
        end
        else begin
            present_state <= next_state;
        end
    end
    
endmodule
