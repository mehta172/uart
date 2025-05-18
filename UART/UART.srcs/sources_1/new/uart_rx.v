`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Tushar Mehta
// 
// Create Date: 02/28/2025 12:18:51 PM
// Design Name: UART_Receiver
// Module Name: uart_rx
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

module uart_rx(
    input wire i_rx_clk,
    input wire i_rx_rst,
    input wire i_tx_rx_data,
    input wire i_parity_bit,
    output reg [7:0]o_rx_data,
    output reg o_rx_data_valid,
    output reg o_rx_data_error,
    output reg o_rx_busy
);

    parameter S0_RESET_STATE = 4'b0000;
    parameter S1_START_STATE = 4'b0001;
    parameter S2_DATA_STATE = 4'b0010;
    parameter S3_PARITY_STATE = 4'b0100;
    parameter S4_STOP_STATE = 4'b1000;
    
    reg [7:0]temp_data;
    reg [2:0]bit_index;
    reg [3:0]present_state;
    reg [3:0]next_state;

always@(posedge i_rx_clk or negedge i_rx_rst)begin
    if(!i_rx_rst)begin
            present_state <= S0_RESET_STATE;
        end
        else begin
            present_state <= next_state;
        end
end

always@(posedge i_rx_clk or negedge i_rx_rst)begin
    if(!i_rx_rst)begin
         o_rx_data    <= 8'b0;
         o_rx_data_valid <= 1'b0;
         o_rx_data_error <= 1'b0;
         o_rx_busy    <= 1'b0;
         bit_index    <= 3'b0;
         next_state   <= S0_RESET_STATE;
    end
    else begin
        case(present_state)
           S0_RESET_STATE:begin
                o_rx_data_valid <= 1'b0;
                o_rx_data_error <= 1'b0;
                o_rx_busy    <= 1'b0;
                bit_index    <= 3'b000;
                next_state   <= S1_START_STATE;
           end
           
           S1_START_STATE:begin
                 o_rx_busy <= 1'b1;
                 if (i_tx_rx_data == 1'b0) begin  // Start bit detected
                      next_state <= S2_DATA_STATE;
                 end 
                 else begin
                      next_state <= S1_START_STATE;
                 end
           end
           
           S2_DATA_STATE: begin
                 temp_data[bit_index] <= i_tx_rx_data;
                 if (bit_index == 3'd7) begin
                      bit_index <= 3'd0;
                      next_state <= S3_PARITY_STATE;
                 end 
                 else begin
                      bit_index <= bit_index + 1'b1;
                      next_state <= S2_DATA_STATE;
                    end
                end
                
            S3_PARITY_STATE: begin
                 if (i_parity_bit) begin
                     if (i_tx_rx_data != ^temp_data) begin
                            o_rx_data_error <= 1'b1; // Parity mismatch
                        end
                    end
                    next_state <= S4_STOP_STATE;
                end
           
           S4_STOP_STATE: begin
                 if (i_tx_rx_data == 1'b1) begin // Stop bit OK
                      o_rx_data   <= temp_data;
                      o_rx_data_valid <= 1'b1;
                 end 
                 else begin
                      o_rx_data_valid <= 1'b0;
                 end
                    next_state <= S0_RESET_STATE;
                end

                default: next_state <= S0_RESET_STATE;
        endcase
    end
end

endmodule 