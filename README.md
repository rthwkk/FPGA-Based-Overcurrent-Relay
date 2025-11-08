# ⚡ FPGA-Based Overcurrent Relay  

**Design and Implementation of an Overcurrent Relay on FPGA (Xilinx Artix-7)**  

This project demonstrates the design and FPGA implementation of a **digital overcurrent relay** using **Verilog HDL** on the **XC7A100T Artix-7** FPGA.  
It is based on the academic work by **Sanjay R Senan, Rithwik D, Rinoofa Sherin MM, Mohammed Ryan Mullaveettil, and Rinky Kumari** from **NIT Calicut**.  
The original report can be found in the [`/doc`](./doc) folder.  

---

## 🚀 Features  

- **Pipelined Architecture**  
  Three-stage pipeline for high-speed operation:  

- **Efficient Filtering**  
- Implements a **4-sample Moving Average Filter (MAF)**  
- Uses only **bit-shifting and addition** for low resource usage  
- Reduces harmonic distortions effectively  

- **Accurate RMS Measurement**  
- Uses a **16-sample moving window** to compute the RMS value  
- Employs **CORDIC IP Core** for hardware-accelerated square root computation  

- **CORDIC IP Core Integration**  
- Function: *Square Root*  
- Input Width: 32 bits  
- Output Width: 16 bits  
- Implemented using Xilinx CORDIC IP  

- **Protection Logic**  
- Implements **Instantaneous Overcurrent Relay (OCR)** logic *(or IDMT — specify if applicable)*  
- Generates a **latching trip signal** when the RMS current exceeds the threshold  

---

```text
## 📘 Module Flow Diagram

        ┌────────────┐       ┌────────────────┐       ┌────────────┐
        │   FILTER   │ --->  │  RMS MEASURE   │ --->  │  PROTECT   │
        └────────────┘       └────────────────┘       └────────────┘



---

📁 Repository Structure

FPGA-Based-Overcurrent-Relay/
│
├── /hdl/      # Synthesizable Verilog source files (MAF, RMS, REM, Top-Level)
├── /tb/      # Testbench files (final_relay_tb.v)
├── /constrs/    # Xilinx Design Constraints (.xdc)
├── /doc/     # Project report, documentation, and flowchart
├── /sim_waveforms/ # Simulation result screenshots
└── README.md   # This file



