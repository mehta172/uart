`timescale 1ns/1ps

module uart_top_tb;

  // Clock & reset
  reg i_clk;
  reg i_top_rst;

  // TX interface
  reg        i_top_start_bit;
  reg [7:0]  i_top_tx_data;

  // Outputs
  wire       o_top_tx_data_done;
  wire       o_top_tx_busy;
  wire [7:0] o_data;
  wire       o_data_valid;
  wire       o_data_error;
  wire       o_top_rx_busy;

  // -------------------------------
  // DUT instantiation
  // -------------------------------
  uart_top DUT (
    .i_clk              (i_clk),
    .i_top_rst          (i_top_rst),
    .i_top_start_bit    (i_top_start_bit),
    .i_top_tx_data      (i_top_tx_data),
    .o_top_tx_data_done (o_top_tx_data_done),
    .o_top_tx_busy      (o_top_tx_busy),
    .o_data             (o_data),
    .o_data_valid       (o_data_valid),
    .o_data_error       (o_data_error),
    .o_top_rx_busy      (o_top_rx_busy)
  );

  // -------------------------------
  // Clock generation (50 MHz)
  // -------------------------------
  always #10 i_clk = ~i_clk;

  // -------------------------------
  // Task: Send UART byte
  // -------------------------------
  task send_uart_byte(input [7:0] data);
    begin
      //@(posedge uart_top_tb.DUT.DUT_Baud.o_tx_clk);
      //while (o_top_tx_busy)
        @(posedge uart_top_tb.DUT.DUT_Baud.o_tx_clk);

      i_top_tx_data   <= data;
      //i_top_start_bit <= 1'b0;

      @(posedge uart_top_tb.DUT.DUT_Baud.o_tx_clk);
      i_top_start_bit <= 1'b1;
      @(posedge uart_top_tb.DUT.DUT_Baud.o_tx_clk);
      i_top_start_bit <= 1'b0;

      wait (o_top_tx_data_done);
      $display("[%0t] TX DONE : 0x%0h", $time, data);
    end
  endtask

  // -------------------------------
  // Initial block
  // -------------------------------
  initial begin
    // Init
    i_clk           = 0;
    i_top_rst       = 0;
    i_top_start_bit = 0;
    i_top_tx_data   = 8'h00;

    // Reset
    #100;
    i_top_rst = 1;

    $display("==== UART TOP TEST START ====");

    send_uart_byte(8'h55);
    #40;
    send_uart_byte(8'hA5);
    #40;
    send_uart_byte(8'h3C);
    #40;
    send_uart_byte(8'hFF);

    // Wait for last RX
    wait (o_data_valid);
    #6000;

    $display("==== UART TOP TEST END ====");
    $finish;
  end

  // -------------------------------
  // RX Monitor
  // -------------------------------
  always @(posedge uart_top_tb.DUT.DUT_Baud.o_rx_clk) begin
    if (o_data_valid) begin
      if (!o_data_error)
        $display("[%0t] RX DATA : 0x%0h ✔", $time, o_data);
      else
        $display("[%0t] RX ERROR ❌", $time);
    end
  end

endmodule
