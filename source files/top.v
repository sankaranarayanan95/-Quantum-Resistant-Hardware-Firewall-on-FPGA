module top(
    input wire clk,          // Pin 52 (27MHz)
    input wire reset_n,      // Pin 4 (Active-low reset)
    input wire uart_rx_pin,  // Pin 3 (UART RX)
    output wire alert_led    // Pin 15 (On-board LED)
);
    wire [7:0] rx_data;
    wire data_valid;
    wire match_flag;

    uart_rx uart_rx_inst(
        .clk(clk),
        .reset_n(reset_n),
        .rx_pin(uart_rx_pin),
        .data_out(rx_data),
        .data_valid(data_valid)
    );

    pattern_match matcher(
        .data_in(rx_data),
        .match_flag(match_flag)
    );

    fsm_controller fsm(
        .clk(clk),
        .reset_n(reset_n),
        .data_valid(data_valid),
        .match_flag(match_flag),
        .alert_led(alert_led)
    );
endmodule