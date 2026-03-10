module pattern_match(
    input wire [7:0] data_in,
    output reg match_flag
);
    // Define malicious patterns (e.g., 0xDE, 0xAD, 0xBE, 0xEF)
    always @(*) begin
        case (data_in)
            8'hDE, 8'hAD, 8'hBE, 8'hEF: match_flag = 1;
            default: match_flag = 0;
        endcase
    end
endmodule