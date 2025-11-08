// Filename: top_level_ocr_tb.v
// Test bench for the complete Top-Level OCR pipeline.
// NOTE: This version contains the critical fixes for reset timing and clock generation.

`timescale 1ns / 1ps

module top_level_ocr_tb;

    // Simulation Parameters
    parameter CLK_PERIOD = 10;      // 10ns period (100 MHz master clock)
    parameter CLK_800HZ_DIV = 125000; // Divider for 800 Hz clock

    // Signals to connect to the top-level module
    reg clk_master;
    reg reset;
    reg [15:0] adc_data_out;
    reg [15:0] I_p;
    wire trip_signal;

    // Internal 800 Hz clock generation (for data injection)
    reg clk_800hz_reg = 0;
    reg [17:0] clk_counter = 0; 

    // Sine wave data array
    reg [15:0] sine_wave [0:15];
    reg [3:0] sample_index = 0;

    // Instantiate the Device Under Test (DUT): top_level_ocr
top_level_ocr uut (
        .clk_master(clk_master),
        .clk_800hz(clk_800hz_reg),  // <-- FIX: Connect the 800Hz clock
        .reset(reset),
        .adc_data_in(adc_data_out),
        .I_p(I_p),
        .trip_signal(trip_signal)
    );
    
    // 100 MHz Master Clock Generation
    initial begin
        clk_master = 0;
        forever #(CLK_PERIOD/2) clk_master = ~clk_master;
    end
    
    // --- FIX 1: CORRECTED 800 Hz CLOCK DIVIDER ---
    // This is now "free-running" and NOT affected by reset.
    // The problematic #10 and #100 delays are REMOVED.
    always @(posedge clk_master) begin
        if (clk_counter == CLK_800HZ_DIV - 1) begin
            clk_counter <= 0;
            clk_800hz_reg <= ~clk_800hz_reg; 
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end

    // --- FIX 2: CORRECTED TEST SEQUENCE ---
    initial begin
        // --- 1. Set Pick-up Current ---
        I_p = 16'd2000; 
        
        // --- 2. Load NORMAL Current Array (Peak 2000, RMS ~1414) ---
        sine_wave[0] = 16'd0;    sine_wave[1] = 16'd765;
        sine_wave[2] = 16'd1414; sine_wave[3] = 16'd1847;
        sine_wave[4] = 16'd2000; sine_wave[5] = 16'd1847;
        sine_wave[6] = 16'd1414; sine_wave[7] = 16'd765;
        sine_wave[8] = 16'd0;    sine_wave[9] = 16'd765;
        sine_wave[10] = 16'd1414; sine_wave[11] = 16'd1847;
        sine_wave[12] = 16'd2000; sine_wave[13] = 16'd1847;
        sine_wave[14] = 16'd1414; sine_wave[15] = 16'd765;

        // --- 3. Reset System (Synchronized to the 800Hz clock) ---
        $display("Time: %t | Resetting system... I_p = %d", $time, I_p);
        reset = 1;
        adc_data_out = 16'd0;
        
        // This waits for the free-running 800Hz clock to have a few edges
        // before releasing the reset. This is the only reliable way.
        @(posedge clk_800hz_reg);
        @(posedge clk_800hz_reg);
        @(posedge clk_800hz_reg);

        // --- 4. Start Simulation (Normal Current) ---
        reset = 0;
        $display("Time: %t | Starting NORMAL current injection. (I_rms ~1414). Should NOT trip.", $time);
        
        // Wait for 4 full 50Hz cycles
        #(CLK_PERIOD * CLK_800HZ_DIV * 16 * 4); 
        
        // --- 5. SIMULATE FAULT ---
        $display("Time: %t | === SIMULATING FAULT === (I_rms ~2828). Should TRIP.", $time);
        
        // Load FAULT Current Array (Peak 4000, RMS ~2828)
        sine_wave[0] = 16'd0;    sine_wave[1] = 16'd1530;
        sine_wave[2] = 16'd2828; sine_wave[3] = 16'd3695;
        sine_wave[4] = 16'd4000; sine_wave[5] = 16'd3695;
        sine_wave[6] = 16'd2828; sine_wave[7] = 16'd1530;
        sine_wave[8] = 16'd0;    sine_wave[9] = 16'd1530;
        sine_wave[10] = 16'd2828; sine_wave[11] = 16'd3695;
        sine_wave[12] = 16'd4000; sine_wave[13] = 16'd3695;
        sine_wave[14] = 16'd2828; sine_wave[15] = 16'd1530;
        
        // Wait for 2 more cycles to see the trip signal
        #(CLK_PERIOD * CLK_800HZ_DIV * 16 * 2); 
        
        $display("Time: %t | Simulation finished. Check trip_signal.", $time);
        $finish;
    end

    // --- 6. Sinusoidal Data Injection Logic ---
    // This block is now safe because clk_800hz_reg will be clean.
    always @(posedge clk_800hz_reg) begin
        if (!reset) begin
            // Inject the sine wave sample data
            adc_data_out <= sine_wave[sample_index]; 
            
            // Advance sample index
            sample_index <= sample_index + 1;
        end
    end

endmodule
