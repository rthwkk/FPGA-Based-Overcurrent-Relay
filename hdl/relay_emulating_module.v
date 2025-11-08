// Filename: relay_emulating_module.v
// Function: Implements an INSTANTANEOUS Overcurrent Relay.
//           It generates a trip signal immediately if Irms > Ip.

module relay_emulating_module (
    input clk_800hz,            // 800 Hz Clock signal
    input reset,
    
    // Inputs from the processing chain
    input [15:0] I_rms,            // 16-bit Fixed-Point RMS Current
    
    // User Configuration
    input [15:0] I_p,              // 16-bit Fixed-Point Pick-up Current
    
    output reg trip_signal         // Output to the Circuit Breaker (CB)
);

    // Synchronous logic for the trip signal
    always @(posedge clk_800hz) begin
        if (reset) begin
            trip_signal <= 0;
        end else begin
            // Compare the RMS current to the Pick-up current
            if (I_rms > I_p) begin
                // Fault Condition: Trip immediately
                trip_signal <= 1;
            end else begin
                // Normal Condition: Do not trip (or reset if latching isn't required)
                // For a simple non-latching relay:
                trip_signal <= 0;
            end
        end
    end

endmodule
