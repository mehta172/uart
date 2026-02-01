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


// module uart_tx(
//     input wire i_tx_clk,
//     input wire i_tx_rst,
//     input wire i_start_bit,
//     input wire [7:0]i_data_in,
//     input wire i_parity_bit,
//     output reg o_tx_data_out,
//     output reg o_tx_data_done,
//     output reg o_tx_busy
//     );
    
//     parameter S0_RESET_STATE = 4'b0000;
//     parameter S1_START_STATE = 4'b0001;
//     parameter S2_DATA_STATE = 4'b0010;
//     parameter S3_PARITY_STATE = 4'b0100;
//     parameter S4_STOP_STATE = 4'b1000;
    
//     reg [7:0] temp_data;
    
//     reg [3:0]present_state;
//     reg [3:0]next_state;
//     wire [2:0] indx;
//     reg [2:0]bit_indx;
    
//     assign indx = bit_indx;
//     always@(posedge i_tx_clk or negedge i_tx_rst)begin
//         case(present_state)
//             S0_RESET_STATE:begin
//                 o_tx_data_out <= 1'b1;
//                 o_tx_data_done <= 1'b0;
//                 o_tx_busy <= 1'b0;
//                 bit_indx <= 3'b0;
//             end
            
//             S1_START_STATE:begin
//                 o_tx_data_out <= 1'b0;
//                 o_tx_data_done <= 1'b0;
//                 o_tx_busy <= 1'b1;
//                 if(i_start_bit)begin
//                     temp_data <= i_data_in;
//                     bit_indx <= 0;
//                 end
//             end
            
//             S2_DATA_STATE:begin
//                 o_tx_data_out <= temp_data[indx];
//                     if(&bit_indx)begin
//                         bit_indx <= 0;
//                     end
//                     else begin
//                         bit_indx <= bit_indx + 1'b1;
//                     end
//             end
//             S3_PARITY_STATE:begin
//                 if(i_parity_bit)begin
//                     if(^temp_data)begin
//                         o_tx_data_out <= 1'b1;
//                     end
//                     else begin
//                         o_tx_data_out <= 1'b0;
//                     end
//                 end
//             end
//             S4_STOP_STATE:begin
//                o_tx_data_out <= 1'b1;
//                o_tx_data_done <= 1'b1;
//                o_tx_busy <= 1'b1;      
//             end

//         endcase
//     end

//     always@(*) begin

//         case(present_state)
//             S0_RESET_STATE : begin
//                 next_state = S1_START_STATE;
//             end
//             S1_START_STATE : begin
//                 if(i_start_bit) begin
//                     next_state = S2_DATA_STATE;
//                 end
//             end
//             S2_DATA_STATE : begin
//                 if(&bit_indx)begin
//                     next_state = S3_PARITY_STATE;
//                 end
//             end
//             S3_PARITY_STATE : begin
//                 if(i_parity_bit)begin    
//                     next_state = S4_STOP_STATE;
//                 end
//             end
//             S4_STOP_STATE : begin
//                 next_state = S0_RESET_STATE;
//             end
//         endcase
//     end
    
//     always@(posedge i_tx_clk or negedge i_tx_rst)begin
//         if(!i_tx_rst)begin
//             present_state <= S0_RESET_STATE;
//         end
//         else begin
//             present_state <= next_state;
//         end
//     end
    
// endmodule

module uart_tx(
    input wire i_tx_clk,
    input wire i_tx_rst,
    input wire i_start_bit,
    input wire [7:0] i_data_in,
    output reg o_tx_data_out,
    output reg o_tx_data_done,
    output reg o_tx_busy
);

    typedef enum logic [2:0] {
        S0_RESET_STATE  = 3'b000,
        S1_START_STATE  = 3'b001,
        S2_DATA_STATE   = 3'b010,
        S3_PARITY_STATE = 3'b011,
        S4_STOP_STATE   = 3'b100
    } state_t;

    state_t present_state, next_state;


    reg [7:0] temp_data;
    reg [2:0] bit_indx;

    wire [2:0] indx;
    assign indx = bit_indx;

    always @(posedge i_tx_clk or negedge i_tx_rst) begin
        if (!i_tx_rst) begin
            o_tx_data_out  <= 1'b1;
            o_tx_data_done <= 1'b0;
            o_tx_busy      <= 1'b0;
            bit_indx       <= 3'b0;
            temp_data      <= 8'b0;
        end
        else begin
            case (present_state)

                S0_RESET_STATE: begin
                    o_tx_data_out  <= 1'b1;
                    o_tx_data_done <= 1'b0;
                    o_tx_busy      <= 1'b0;
                    bit_indx       <= 3'b0;
                end

                S1_START_STATE: begin
                    o_tx_data_out  <= 1'b0;
                    o_tx_data_done <= 1'b0;
                    o_tx_busy      <= 1'b1;
                    if (i_start_bit) begin
                        temp_data <= i_data_in;
                        //bit_indx  <= 3'b0;
                    end
                end

                S2_DATA_STATE: begin
                    //o_tx_data_out <= temp_data[bit_indx];
                    //temp_data <= temp_data << 1;
                    if (!(&bit_indx))
                        bit_indx <= bit_indx + 1'b1;
                end

                S3_PARITY_STATE: begin
                    //o_tx_data_out <= ^temp_data;
                end

                S4_STOP_STATE: begin
                    //o_tx_data_out  <= 1'b1;
                    o_tx_data_done <= 1'b1;
                    o_tx_busy      <= 1'b0;
                end

            endcase
        end
    end

    always @(*) begin
        next_state = present_state;
        case (present_state)

            S0_RESET_STATE:
                next_state = S1_START_STATE;

            S1_START_STATE:
                if (i_start_bit)
                    next_state = S2_DATA_STATE;

            S2_DATA_STATE:begin
                o_tx_data_out <= temp_data[bit_indx];
                if (&bit_indx)
                    next_state = S3_PARITY_STATE;
            end
            S3_PARITY_STATE:begin
                o_tx_data_out <= ^temp_data;
                next_state = S4_STOP_STATE;
            end
            S4_STOP_STATE:begin
                o_tx_data_out  <= 1'b1;
                next_state = S0_RESET_STATE;
            end

        endcase
    end

    always @(posedge i_tx_clk or negedge i_tx_rst) begin
        if (!i_tx_rst)
            present_state <= S0_RESET_STATE;
        else
            present_state <= next_state;
    end

endmodule


