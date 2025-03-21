module CKGATE (
    input  TE,  // Test Enable (active high)
    input  E,   // Enable (active high)
    input  CK,  // Input Clock
    output GCK  // Gated Clock
);

    // Internal signal to store the gated clock value
    reg gated_clock;

    // Clock gating logic
    always @(*) begin
        if (TE) begin
            // Test mode: bypass clock gating
            gated_clock = CK;
        end else begin
            // Normal operation: gate the clock based on enable signal
            gated_clock = E ? CK : 1'b0;
        end
    end

    // Assign the gated clock to the output
    assign GCK = gated_clock;

endmodule
