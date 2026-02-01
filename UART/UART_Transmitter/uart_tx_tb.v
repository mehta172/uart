`timescale 1ns / 1ps

module uart_tx_tb;

    // Inputs
    reg i_tx_clk;
    reg i_tx_rst;
    reg i_start_bit;
    reg [7:0] i_data_in;
    //reg i_parity_bit;
    //reg i_stop_bit;

    // Outputs
    wire o_tx_data_out;
    wire o_tx_data_done;
    wire o_tx_busy;

    // Instantiate the UART Transmitter
    uart_tx DUT (
        .i_tx_clk(i_tx_clk),
        .i_tx_rst(i_tx_rst),
        .i_start_bit(i_start_bit),
        .i_data_in(i_data_in),
        //.i_parity_bit(i_parity_bit),
        //.i_stop_bit(i_stop_bit),
        .o_tx_data_out(o_tx_data_out),
        .o_tx_data_done(o_tx_data_done),
        .o_tx_busy(o_tx_busy)
    );

    // Clock generation
    initial i_tx_clk = 1;
    always #1 i_tx_clk = ~i_tx_clk; // 10ns period => 100MHz clock

    initial begin
        // Initialize inputs
        i_tx_rst = 0;
        i_start_bit = 0;
        i_data_in = 8'b10100011;
        //i_parity_bit = 0;
        //i_stop_bit = 1;

        // Apply reset
        #4;
        i_tx_rst = 1;

        // Wait a bit before starting transmission
        #2;
        //@(posedge i_tx_clk)
        // Set data to transmit
        //i_data_in = 8'b10101011; // Example data        // Enable parity
        //i_stop_bit = 1;

        // Pulse start bit to begin transmission
        i_start_bit = 1;
        #2;
        i_start_bit = 0;

        // Wait for transmission to complete
        wait(o_tx_data_done);
        #100;

        // Finish simulation
        $display("Transmission completed.");
        
        $finish;
        //$stop;
    end

endmodule
