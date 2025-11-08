// Filename: rms_maf_tb.v
// Test bench for the MAF and RMS pipeline. Verifies I_rms settles to the expected value (approx 1414).

`timescale 1ns / 1ps

module rms_maf_tb;

    // Simulation Parameters
    parameter CLK_PERIOD = 10;      // 10ns period (100 MHz master clock for simulation)
    parameter CLK_800HZ_DIV = 125000; // Divider for 800 Hz clock (100MHz / 800Hz = 125000)
    
    // Signals to connect to the pipeline
    reg clk_master;
    reg reset;
    reg [15:0] adc_data_out;       // Simulated input (from ADC)
    wire [15:0] filtered_data_out; // Output of the MAF
    wire [15:0] I_rms;             // Output of the RMS module (should be ~1414)

    // Internal 800 Hz clock generation
    reg clk_800hz_reg = 0;
    reg [17:0] clk_counter = 0; 

    // Sine wave data array (Peak = 2000, 16 samples for one 50Hz cycle)
    reg [15:0] sine_wave [0:15];
    reg [3:0] sample_index = 0;

    // Instantiate Modules (Ensure your module names match: moving_average_filter and rms_estimation_module)
    moving_average_filter u_maf (
        .clk(clk_800hz_reg),
        .reset(reset),
        .adc_data_in(adc_data_out),
        .filtered_data_out(filtered_data_out)
    );
    
    rms_estimation_module u_rms (
        .clk_800hz(clk_800hz_reg),
        .reset(reset),
        .filtered_data_in(filtered_data_out),
        .I_rms(I_rms)
    );
    
  
    // 100 MHz Master Clock Generation
    initial begin
        clk_master = 0;
        forever #(CLK_PERIOD/2) clk_master = ~clk_master;
    end
    
    // 800 Hz Clock Divider Logic
    always @(posedge clk_master) begin
        if (reset) begin
            clk_counter <= 0;
            clk_800hz_reg <= 0;
            #10;
            clk_800hz_reg <= ~clk_800hz_reg; //new_code
        #10;
        end 
        else begin
            if (clk_counter == CLK_800HZ_DIV - 1) begin
                clk_counter <= 0;
                clk_800hz_reg <= ~clk_800hz_reg; 
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end

    // Test sequence and Sine Wave Array Initialization
// Test sequence and Sine Wave Array Initialization
   initial begin
        // Sine Wave Array (Peak 2000. Expected RMS: 1414)
        // Using magnitude-only for simple unsigned test
        sine_wave[0] = 16'd0;    sine_wave[1] = 16'd765;
        sine_wave[2] = 16'd1414; sine_wave[3] = 16'd1847;
        sine_wave[4] = 16'd2000; sine_wave[5] = 16'd1847;
        sine_wave[6] = 16'd1414; sine_wave[7] = 16'd765;
        sine_wave[8] = 16'd0;    sine_wave[9] = 16'd765;
        sine_wave[10] = 16'd1414; sine_wave[11] = 16'd1847;
        sine_wave[12] = 16'd2000; sine_wave[13] = 16'd1847;
        sine_wave[14] = 16'd1414; sine_wave[15] = 16'd765;

        // 1. Reset System
        $display("Time: %t | Resetting system...", $time);
        reset = 1;
        adc_data_out = 16'd0;
        #(CLK_PERIOD * 20);

        // 2. Start Simulation
        reset = 0;
        $display("Time: %t | Starting sine wave injection. Expected RMS: 1414", $time);
        // Wait for RMS calculation to settle (6 full 50Hz cycles = 96 samples)
        // This ensures the 16-sample moving window is full multiple times.
        #(CLK_PERIOD * CLK_800HZ_DIV * 16 * 6); 
        
        $display("Time: %t | Simulation finished. Check I_rms for a value near 1414.", $time);
        $finish;
    end

    // Sinusoidal Data Injection Logic
    always @(posedge clk_800hz_reg) begin
        if (!reset) begin
            // Inject the sine wave sample data
            adc_data_out <= sine_wave[sample_index]; 
            
            // Advance sample index (0 to 15, then wraps around)
            sample_index <= sample_index + 1;
        end
    end

endmodule
