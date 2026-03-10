module firewall_core (
    input sys_clk,        // 27MHz system clock
    input sys_rst_n,      // Active-low reset
    input uart_rx,        // UART receive pin
    output reg uart_tx,   // UART transmit pin
    output reg [5:0] led  // LEDs for alerts
);
    parameter PATTERN_1 = 16'hDEAD; // Malicious pattern 1
    parameter PATTERN_2 = 16'hBEEF; // Malicious pattern 2

    reg [7:0] rx_data;
    reg rx_ready;
    localparam IDLE = 2'b00, READ = 2'b01, CHECK = 2'b10, BLOCK = 2'b11;
    reg [1:0] state;
    reg [15:0] malicious_count;
    reg [12:0] baud_cnt; // For 115200 baud
    reg [3:0] bit_cnt;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            state <= IDLE;
            rx_data <= 8'b0;
            rx_ready <= 1'b0;
            malicious_count <= 16'b0;
            led <= 6'b111111; // LEDs off (active-low)
            uart_tx <= 1'b1;  // Idle high
            baud_cnt <= 13'b0;
            bit_cnt <= 4'b0;
        end else begin
            case (state)
                IDLE: if (!uart_rx) begin // Start bit
                    state <= READ;
                    baud_cnt <= 13'b0;
                    bit_cnt <= 4'b0;
                end
                READ: begin
                    if (baud_cnt == 234) begin // 27MHz / 115200 baud
                        baud_cnt <= 13'b0;
                        if (bit_cnt < 8) begin
                            rx_data[bit_cnt] <= uart_rx;
                            bit_cnt <= bit_cnt + 1;
                        end else if (bit_cnt == 8) begin
                            rx_ready <= 1'b1;
                            state <= CHECK;
                            bit_cnt <= 4'b0;
                        end
                    end else baud_cnt <= baud_cnt + 1;
                end
                CHECK: begin
                    rx_ready <= 1'b0;
                    if (rx_data == PATTERN_1[15:8] || rx_data == PATTERN_2[15:8]) begin
                        state <= BLOCK;
                        malicious_count <= malicious_count + 1;
                        led <= ~malicious_count[5:0]; // Blink LEDs
                    end else begin
                        uart_tx <= rx_data; // Pass clean data
                        state <= IDLE;
                    end
                end
                BLOCK: state <= IDLE; // Drop packet
            endcase
        end
    end
endmodule