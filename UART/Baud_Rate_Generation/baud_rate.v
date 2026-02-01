
module baud_rate #(
    parameter clk_rate = 150000000,
    parameter Baud_rate = 9600
)(
    input i_clk,
    output reg o_tx_clk,
    output reg o_rx_clk
);

parameter Rate_tx = (clk_rate/Baud_rate);
parameter Rate_rx = (clk_rate/(Baud_rate));

parameter Rate_tx_cnt_width = $clog2(Rate_tx);
parameter Rate_rx_cnt_width = $clog2(Rate_rx);

reg [Rate_tx_cnt_width - 1: 0] tx_counter = 0;
reg [Rate_rx_cnt_width - 1: 0] rx_counter = 0;

initial begin
    o_tx_clk = 1'b0;
    o_rx_clk = 1'b0;
end

always@(posedge i_clk)begin
    if(tx_counter == Rate_tx[Rate_tx_cnt_width - 1: 0]) begin
        tx_counter <= 0;
        o_tx_clk <= ~o_tx_clk;
    end
    else begin
        tx_counter <= tx_counter + 1'b1;
    end
end

always@(posedge i_clk)begin
    if(rx_counter == Rate_rx[Rate_rx_cnt_width - 1: 0]) begin
        rx_counter <= 0;
        o_rx_clk <= ~o_rx_clk;
    end
    else begin
        rx_counter <= rx_counter + 1'b1;
    end
end

endmodule 