module uart_rx(
    input wire clk,          // 27MHz clock
    input wire reset_n,      // Active-low reset
    input wire rx_pin,       // UART RX pin (Pin 3)
    output reg [7:0] data_out, // Received byte
    output reg data_valid    // High when byte is ready
);
    localparam BAUD_RATE = 9600;
    localparam CLK_FREQ = 27_000_000;
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [3:0] bit_counter = 0;
    reg [15:0] clock_counter = 0;
    reg [1:0] state = 0;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 0;
            data_valid <= 0;
        end else begin
            case (state)
                0: begin // IDLE: Wait for start bit (falling edge)
                    if (!rx_pin) begin
                        state <= 1;
                        clock_counter <= 0;
                    end
                end
                1: begin // SAMPLE: Count to mid-bit
                    if (clock_counter == BIT_PERIOD/2) begin
                        state <= 2;
                        bit_counter <= 0;
                        clock_counter <= 0;
                    end else begin
                        clock_counter <= clock_counter + 1;
                    end
                end
                2: begin // RECEIVE: Sample 8 data bits
                    if (clock_counter == BIT_PERIOD) begin
                        data_out <= {rx_pin, data_out[7:1]};
                        clock_counter <= 0;
                        if (bit_counter == 7) begin
                            state <= 3;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end else begin
                        clock_counter <= clock_counter + 1;
                    end
                end
                3: begin // STOP: Validate data
                    data_valid <= 1;
                    state <= 0;
                end
            endcase
        end
    end
endmodule