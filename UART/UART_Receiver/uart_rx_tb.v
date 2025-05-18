`timescale 1ns / 1ps

module uart_rx_tb;

  // Parameters
  reg clk;
  reg rst_n;
  reg rx_serial;
  reg parity_en;

  wire [7:0] data_out;
  wire data_valid;
  wire data_error;
  wire rx_busy;

  // Instantiate UART Receiver
  uart_rx dut (
    .i_rx_clk(clk),
    .i_rx_rst(rst_n),
    .i_tx_rx_data(rx_serial),
    .i_parity_bit(parity_en),
    .o_rx_data(data_out),
    .o_rx_data_valid(data_valid),
    .o_rx_data_error(data_error),
    .o_rx_busy(rx_busy)
  );

  // Clock generation: 1 MHz (period = 1 us)
  initial clk = 0;
  always #500 clk = ~clk;  // 1 MHz clock

  // Task to send UART byte
  task send_uart_byte(input [7:0] data, input bit parity_enable);
    reg parity_bit = ^data;  // Even parity
    int i;

    // Start bit
    rx_serial = 0; @(posedge clk);

    // Data bits (LSB first)
    for (i = 0; i < 8; i++) begin
      rx_serial = data[i]; @(posedge clk);
    end

    // Parity bit
    if (parity_enable) begin
      rx_serial = parity_bit; @(posedge clk);
    end

    // Stop bit
    rx_serial = 1; @(posedge clk);

    // Hold idle for a few cycles
    repeat (3) @(posedge clk);
  endtask

  // Main stimulus
  initial begin
    // Initialize
    rx_serial = 1;
    rst_n = 0;
    parity_en = 0;

    // Apply reset
    repeat (2) @(posedge clk);
    rst_n = 1;

    $display("---- UART RX Testbench Start ----");

    // Test 1: Transmit 8'hA5 without parity
    parity_en = 0;
    send_uart_byte(8'hA5, parity_en);
    wait (data_valid);
    $display("[Test 1] Received: %h, Error: %b", data_out, data_error);
    assert(data_out == 8'hA5 && !data_error) else $fatal("Test 1 failed!");

    // Test 2: Transmit 8'h3C with correct parity
    parity_en = 1;
    send_uart_byte(8'h3C, parity_en);
    wait (data_valid);
    $display("[Test 2] Received: %h, Error: %b", data_out, data_error);
    assert(data_out == 8'h3C && !data_error) else $fatal("Test 2 failed!");

    // Test 3: Transmit 8'h55 with incorrect parity
    // Here we manually flip parity bit to simulate error
//    int i;
//    rx_serial = 0; @(posedge clk);  // Start bit
//    for (i = 0; i < 8; i++) begin
//      rx_serial = 8'h55[i]; @(posedge clk);
//    end
//    rx_serial = ~(^8'h55); @(posedge clk);  // Wrong parity
//    rx_serial = 1; @(posedge clk);          // Stop bit
//    repeat (3) @(posedge clk);

//    wait (data_valid);
//    $display("[Test 3] Received: %h, Error: %b", data_out, data_error);
//    assert(data_error) else $fatal("Test 3 failed!");

    $display("---- All UART RX Tests Passed");
    end
    endmodule
