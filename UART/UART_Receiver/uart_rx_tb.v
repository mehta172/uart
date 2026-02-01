`timescale 1ns / 1ps

module uart_rx_tb;

  // Parameters
  reg clk;
  reg rst_n;
  reg rx_serial;
 // reg parity_en;

  wire [7:0] data_out;
  wire data_valid;
  wire data_error;
  wire rx_busy;

  reg [7:0] data1;
  


  // Instantiate UART Receiver
  uart_rx dut (.i_rx_clk(clk), .i_rx_rst(rst_n), .i_tx_rx_data(rx_serial),
               .o_rx_data(data_out), .o_rx_data_valid(data_valid),
               .o_rx_data_error(data_error), .o_rx_busy(rx_busy)
              );

initial begin
  clk = 0;
  forever #1 clk = ~clk;
end

task send_data(input [7:0] data);
    integer i;
    begin
      for (i = 0; i < 8; i = i + 1) begin
        @(posedge clk);
        rx_serial = data[i];
        data1 = data[i];
      end
    end
  endtask


initial begin
  rst_n = 0;
  rx_serial = 1;
  //parity_en = 0;
  #2;
  rst_n = 1;
  #2;
  repeat(20)begin
  @(posedge clk);
  rx_serial = 0;
  send_data(8'hA5);
  //parity_en = 1;
  #2;
  rx_serial = ^data1;
//  @(posedge clk);
  //parity_en = 1;
  #2
  rx_serial = 1;
  #4;
  end
  #50;
  $finish;
end

endmodule

