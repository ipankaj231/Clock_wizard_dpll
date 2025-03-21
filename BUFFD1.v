module BUFFD1 (
    input  I,  // Input signal
    output O   // Buffered output signal
);

    // The output is a buffered version of the input
    assign O = I;

endmodule
