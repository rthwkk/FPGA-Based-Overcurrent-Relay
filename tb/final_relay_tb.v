// Filename: final_relay_tb.v
// Test bench for the COMPLETE Overcurrent Relay (MAF + RMS + REM).
// *** USES 'relay_emulating2_module' ***

`timescale 1ns / 1ps

module final_relay_tb;

    // Simulation Parameters
    parameter CLK_PERIOD = 10;
    parameter CLK_800HZ_DIV = 125000;
    
    // Signals for the pipeline
    reg clk_master;
    reg reset;
    reg [15:0] adc_data_out;
    reg [15:0] I_p;
    
    wire [15:0] filtered_data_out; // MAF -> RMS
    wire [15:0] I_rms;             // RMS -> REM
    wire trip_signal;         // FINAL OUTPUT

    // 800 Hz clock generation
    reg clk_800hz_reg = 0;
    reg [17:0] clk_counter = 0; 
    reg [15:0] sine_wave [0:15];
    reg [3:0] sample_index = 0;

    // --- Instantiate ALL THREE modules ---
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
    
    // --- CORRECTION: Instantiating the correctly named module ---
    relay_emulating2_module u_rem (
        .clk_800hz(clk_800hz_reg),
        .reset(reset),
        .I_rms(I_rms),
        .I_p(I_p),
        .trip_signal(trip_signal)
    );
    
    // 100 MHz Master Clock Generation
    initial begin
        clk_master = 0;
        forever #(CLK_PERIOD/2) clk_master = ~clk_master;
    end
    
    // Free-running 800 Hz Clock Divider
    always @(posedge clk_master) begin
        if (clk_counter == CLK_800HZ_DIV - 1) begin
            clk_counter <= 0;
            clk_800hz_reg <= ~clk_800hz_reg; 
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end

    // Test sequence
    initial begin
        // 1. Set Pick-up Current (I_p)
        I_p = 16'd1500; 
        
        // 2. Load NORMAL Current Array (Peak 2000, RMS ~1414)
        sine_wave[0]=16'd0; sine_wave[1]=16'd765; sine_wave[2]=16'd1414; sine_wave[3]=16'd1847;
        sine_wave[4]=16'd2000; sine_wave[5]=16'd1847; sine_wave[6]=16'd1414; sine_wave[7]=16'd765;
        sine_wave[8]=16'd0; sine_wave[9]=16'd765; sine_wave[10]=16'd1414; sine_wave[11]=16'd1847;
        sine_wave[12]=16'd2000; sine_wave[13]=16'd1847; sine_wave[14]=16'd1414; sine_wave[15]=16'd765;

        // 3. Reset System (Synchronized)
        $display("Time: %t | Resetting system... I_p = %d", $time, I_p);
        reset = 1;
        adc_data_out = 16'd0;
        @(posedge clk_800hz_reg);
        @(posedge clk_800hz_reg);
        @(posedge clk_800hz_reg);

        // 4. Start Simulation (Normal Current)
        reset = 0;
        $display("Time: %t | Starting NORMAL current (I_rms ~1414). Should NOT trip.", $time);
        #(CLK_PERIOD * CLK_800HZ_DIV * 16 * 4); // Wait 4 cycles
        
        // 5. SIMULATE FAULT
        $display("Time: %t | === SIMULATING FAULT === (I_rms ~2828). Should TRIP.", $time);
        sine_wave[0]=16'd0; sine_wave[1]=16'd1530; sine_wave[2]=16'd2828; sine_wave[3]=16'd3695;
        sine_wave[4]=16'd4000; sine_wave[5]=16'd3695; sine_wave[6]=16'd2828; sine_wave[7]=16'd1530;
        sine_wave[8]=16'd0; sine_wave[9]=16'd1530; sine_wave[10]=16'd2828; sine_wave[11]=16'd3695;
        sine_wave[12]=16'd4000; sine_wave[13]=16'd3695; sine_wave[14]=16'd2828; sine_wave[15]=16'd1530;
        
        // Wait 2 more cycles
        #(CLK_PERIOD * CLK_800HZ_DIV * 16 * 2); 
        
        $display("Time: %t | Simulation finished. Check trip_signal.", $time);
        //$finish;
    end

    // Sinusoidal Data Injection Logic
    always @(posedge clk_800hz_reg) begin
        if (!reset) begin
            adc_data_out <= sine_wave[sample_index]; 
            sample_index <= sample_index + 1;
        end
    end

endmodule
