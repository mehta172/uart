//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 04/20/2025 08:44:50 PM
//// Design Name: 
//// Module Name: uart_top
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

`include "uart_tx.sv"
`include "uart_rx.sv"
`include "baud_rate.v"


module uart_top(
    input wire i_clk,
    input wire i_top_rst,
    input wire i_top_start_bit,
    input wire [7:0] i_top_tx_data,
    output reg o_top_tx_data_done,
    output reg o_top_tx_busy,
    output reg  [7:0] o_data,
    output reg o_data_valid,
    output reg o_data_error,
    output reg o_top_rx_busy
    );
   wire w_top_tx_data;
   //wire w_top_rx_busy;
   wire w_tx_clk;
   wire w_rx_clk;

   uart_tx DUT_Tx(.i_tx_clk(w_tx_clk),
               .i_tx_rst(i_top_rst),
               .i_start_bit(i_top_start_bit),
               .i_data_in(i_top_tx_data),
               .o_tx_data_out(w_top_tx_data),
               .o_tx_data_done(o_top_tx_data_done),
               .o_tx_busy(o_top_tx_busy)
            );
    
    uart_rx DUT_Rx(.i_rx_clk(w_rx_clk),
                .i_rx_rst(i_top_rst),
                .i_tx_rx_data(w_top_tx_data),
                .o_rx_data(o_data),
                .o_rx_data_valid(o_data_valid),
                .o_rx_data_error(o_data_error),
                .o_rx_busy(o_top_rx_busy)
    );
                
    baud_rate DUT_Baud(.i_clk(i_clk),
                  .o_tx_clk(w_tx_clk),
                  .o_rx_clk(w_rx_clk)
    );


endmodule
