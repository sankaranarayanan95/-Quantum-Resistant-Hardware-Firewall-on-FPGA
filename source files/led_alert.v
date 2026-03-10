module led_alert(
    input wire clk,
    input wire trigger,
    output reg led_out
);
    always @(posedge clk) begin
        led_out <= trigger; // Directly mirror the trigger signal
    end
endmodule