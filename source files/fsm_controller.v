module fsm_controller(
    input wire clk,
    input wire reset_n,
    input wire data_valid,
    input wire match_flag,
    output reg alert_led
);
    reg [1:0] state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 0;
            alert_led <= 0;
        end else begin
            case (state)
                0: begin // IDLE
                    if (data_valid) begin
                        state <= 1;
                        alert_led <= match_flag;
                    end
                end
                1: begin // ALERT (hold LED for 1 clock cycle)
                    alert_led <= 0;
                    state <= 0;
                end
            endcase
        end
    end
endmodule