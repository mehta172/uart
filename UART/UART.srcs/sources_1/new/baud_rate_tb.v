`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 05:12:38 PM
// Design Name: 
// Module Name: baud_rate_tb
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


module baud_rate_tb();

reg i_clk;
wire o_tx_clk;
wire o_rx_clk;

baud_rate DUT(.i_clk(i_clk), .o_tx_clk(o_tx_clk), .o_rx_clk(o_rx_clk));

initial begin
    i_clk = 0;
    forever #6.67 i_clk = ~i_clk;
end

//always #6.67 i_clk = ~i_clk;

endmodule
