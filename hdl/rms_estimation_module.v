// Filename: rms_estimation_module.v
// Function: Calculates the real-time RMS current using a 16-sample moving window 
//           and Xilinx CORDIC IP for the final square root.

module rms_estimation_module (
    input clk_800hz,              // 800 Hz Clock signal
    input reset,
    input [15:0] filtered_data_in, // 16-bit fixed-point data from the MAF module
    output [15:0] I_rms           // 16-bit fixed-point RMS current value
);

    // -- Parameters --
    localparam N_SAMPLES = 16;
    localparam LOG2_N = 4;

    // -- Registers and Declarations --
    reg [31:0] squared_history [0:N_SAMPLES-1]; 
    reg [35:0] sum_of_squares_reg; 
    
    integer i;
    
    // -- Wires --
    wire [31:0] squared_new_sample;
    assign squared_new_sample = filtered_data_in * filtered_data_in; 

    wire [31:0] squared_oldest_sample = squared_history[N_SAMPLES-1]; 

    // --- Pipelined Logic ---
// --- Pipelined Logic ---
always @(posedge clk_800hz) begin
    if (reset) begin
        // 1. Initialize the accumulator to zero
        sum_of_squares_reg <= 0;
        // 2. THIS IS THE CRITICAL FIX:
        // Initialize the entire history array to zero
        for (i = 0; i < N_SAMPLES; i = i + 1) begin
            squared_history[i] <= 32'd0;
        end
    end else begin
        
        // 1. Moving Window Sum Update
        sum_of_squares_reg <= sum_of_squares_reg - squared_oldest_sample + squared_new_sample;

        // 2. Shift Register Update
        for (i = N_SAMPLES - 1; i > 0; i = i - 1) begin 
            squared_history[i] <= squared_history[i-1];
        end
        squared_history[0] <= squared_new_sample;
        
    end
end
    // 3. Mean Square Value (Division by N=16)
    wire [31:0] mean_square_value = sum_of_squares_reg >> LOG2_N;
    
    // 4. Square Root Calculation: INSTANTIATION of the CORDIC IP Core
    // NOTE: Replace 'rms_cordic_sqroot' with the name you used when generating the IP.
    rms_cordic_sqroot uut_cordic (
        // Control Signals (Adjust signals based on your specific CORDIC configuration)
        .aclk(clk_800hz),      
        // For a simple square root function, many control signals can be left unconnected or tied low.
        
        // Input: Mean Square Value
        // The CORDIC IP takes the Mean Square Value and calculates its square root.
        .s_axis_cartesian_tdata(mean_square_value), 
        
        // Output: I_rms (The true RMS value)
        .m_axis_dout_tdata(I_rms) 
    );

endmodule
