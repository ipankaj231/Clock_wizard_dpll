`timescale 1ns/1ps

module pfd(
    input  wire IN,       // Reference clock input
    input  wire FB,       // Feedback clock input
    input  wire RESET,    // Active-high reset (added for better control)
    output reg  flagu,    // UP signal (increase frequency)
    output reg  flagd     // DOWN signal (decrease frequency)
);

    reg QU, QD;           // Flip-flop outputs
    wire CDN;             // Clear signal for flip-flops

    // Clear signal: Reset flip-flops when both QU and QD are high
    assign CDN = ~(QU & QD);

    // UP and DOWN signals
    wire OUTU, OUTD;
    assign OUTU = ~(QU & ~QD); // UP signal (IN leads FB)
    assign OUTD = ~(QD & ~QU); // DOWN signal (FB leads IN)

    // Flip-flop for reference clock (IN)
    always @(posedge IN or negedge CDN) begin
        if (!CDN) begin
            QU <= 1'b0; // Clear flip-flop
        end else begin
            QU <= 1'b1; // Set flip-flop
        end
    end

    // Flip-flop for feedback clock (FB)
    always @(posedge FB or negedge CDN) begin
        if (!CDN) begin
            QD <= 1'b0; // Clear flip-flop
        end else begin
            QD <= 1'b1; // Set flip-flop
        end
    end

    // Generate flagu (UP signal)
    always @(posedge IN or posedge RESET) begin
        if (RESET) begin
            flagu <= 1'b0; // Reset flagu
        end else begin
            flagu <= OUTU; // Set flagu based on OUTU
        end
    end

    // Generate flagd (DOWN signal)
    always @(posedge FB or posedge RESET) begin
        if (RESET) begin
            flagd <= 1'b0; // Reset flagd
        end else begin
            flagd <= OUTD; // Set flagd based on OUTD
        end
    end

endmodule
