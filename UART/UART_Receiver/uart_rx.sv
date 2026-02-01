// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: Tushar Mehta
// // 
// // Create Date: 02/28/2025 12:18:51 PM
// // Design Name: UART_Receiver
// // Module Name: uart_rx
// // Project Name: UART
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////

// module uart_rx(
//     input wire i_rx_clk,
//     input wire i_rx_rst,
//     input wire i_tx_rx_data,
//     output reg [7:0]o_rx_data,
//     output reg o_rx_data_valid,
//     output wire o_rx_data_error,
//     output reg o_rx_busy
// );

//     parameter S0_RESET_STATE = 4'b0000;
//     parameter S1_START_STATE = 4'b0001;
//     parameter S2_DATA_STATE = 4'b0010;
//     parameter S3_PARITY_STATE = 4'b0100;
//     parameter S4_STOP_STATE = 4'b1000;
    
//     reg [7:0]temp_data;
//     reg [2:0]bit_index;
//     reg [3:0]present_state;
//     reg [3:0]next_state;
//     reg flag;

// always@(*)begin
//     if(!i_rx_rst)begin
//             present_state <= S0_RESET_STATE;
//         end
//         else begin
//             present_state <= next_state;
//         end
// end


// always@(*)begin
//         case(present_state)
//            S0_RESET_STATE:begin
//                 temp_data <= 8'b0;
//                 o_rx_data <= 8'b0;
//                 o_rx_data_valid <= 1'b0;
//                 o_rx_busy    <= 1'b0;
//                 bit_index    <= 3'b000;
//                 flag <= 0;
//            end
           
//            S1_START_STATE:begin
//                  o_rx_busy <= 1'b1;
//            end
           
//            S2_DATA_STATE: begin
//                 temp_data[bit_index] = i_tx_rx_data;
//                 end
                
//             S3_PARITY_STATE: begin
//                 flag = 1;
//             end
           
//            S4_STOP_STATE: begin
//                 flag =0;
//                  if (i_tx_rx_data == 1'b1) begin // Stop bit 
//                       o_rx_data_valid <= 1'b1;
//                  end 
//                  else begin
//                       o_rx_data_valid <= 1'b0;
//                  end
//                 end

//                 default: next_state <= S0_RESET_STATE;
//         endcase
//     end

//     always@(posedge i_rx_clk or negedge i_rx_rst) begin

//         case(present_state)
//             S0_RESET_STATE : begin
//                 next_state = S1_START_STATE;
//             end
//             S1_START_STATE : begin
//                  if (i_tx_rx_data == 1'b0) begin  // Start bit detected
//                       next_state = S2_DATA_STATE;
//                  end
//             end
//             S2_DATA_STATE : begin
//                 if(bit_index == 7)begin
//                     //bit_index = 0;
//                     o_rx_data   <= temp_data;
//                     temp_data <= temp_data;
//                     next_state = S3_PARITY_STATE;
//                 end
//                 else begin
//                     bit_index = bit_index + 1;
//                     //next_state = S2_DATA_STATE;
//                 end
//             end
//             S3_PARITY_STATE : begin
//                     next_state = S4_STOP_STATE;
//                 end
//             S4_STOP_STATE : begin
//                 next_state = S0_RESET_STATE;
//             end
//         endcase
//     end

//     assign o_rx_data_error = (flag) ? (i_tx_rx_data != ^o_rx_data) ? 1'b1 : 1'b0 : 1'b0;

//  endmodule 

module uart_rx (
    input  wire        i_rx_clk,
    input  wire        i_rx_rst,
    input  wire        i_tx_rx_data,
    output reg  [7:0]  o_rx_data,
    output reg         o_rx_data_valid,
    output reg         o_rx_data_error,
    output reg         o_rx_busy
);

    // FSM states
    typedef enum logic [2:0] {
        S_RESET  = 3'b000,
        S_START  = 3'b001,
        S_DATA   = 3'b010,
        S_PARITY = 3'b011,
        S_STOP   = 3'b100
    } state_t;

    state_t present_state, next_state;

    reg [7:0] temp_data;
    reg [2:0] bit_index;
    reg       parity_bit;

    // State Register

    always @(posedge i_rx_clk or negedge i_rx_rst) begin
        if (!i_rx_rst)
            present_state <= S_RESET;
        else
            present_state <= next_state;
    end

    //  Next State Logic

    always @(*) begin
        next_state = present_state;
        case (present_state)

            S_RESET:
                next_state = S_START;

            S_START:
                if (i_tx_rx_data == 1'b0)
                    next_state = S_DATA;

            S_DATA:
                if (bit_index == 3'd7)begin
                    next_state = S_PARITY;
                end

            S_PARITY: begin
                next_state = S_STOP;
            end
            S_STOP:
                next_state = S_RESET;

            default:
                next_state = S_RESET;

        endcase
    end

    //  Data Path & Output Logic

    always @(posedge i_rx_clk or negedge i_rx_rst) begin
        if (!i_rx_rst) begin
            temp_data        <= 8'b0;
            bit_index        <= 3'b0;
            o_rx_data        <= 8'b0;
            o_rx_data_valid  <= 1'b0;
            o_rx_data_error  <= 1'b0;
            o_rx_busy        <= 1'b0;
            parity_bit       <= 1'b0;
        end
        else begin
            o_rx_data_valid <= 1'b0;

            case (present_state)

                S_START: begin
                    o_rx_busy  <= 1'b1;
                    bit_index  <= 3'b0;
                    temp_data  <= 'h0;
                end

                S_DATA: begin
                    
                    if(bit_index < 3'd7)begin
                        bit_index <= bit_index + 1'b1;
                        temp_data[bit_index] <= i_tx_rx_data;
                    end
                    if(bit_index == 3'd7)begin
                        temp_data[7] <= i_tx_rx_data;
                    end
                end

                S_PARITY: begin
                    parity_bit <= i_tx_rx_data;
                end

                S_STOP: begin
                    o_rx_busy <= 1'b0;
                    if (i_tx_rx_data == 1'b1) begin
                        o_rx_data       <= temp_data;
                        o_rx_data_valid <= 1'b1;
                        o_rx_data_error <= (parity_bit != ^temp_data);
                    end
                end

            endcase
        end
    end

endmodule
