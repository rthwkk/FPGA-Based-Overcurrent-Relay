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


## 📘 Module Flow Diagram

        ┌────────────┐       ┌────────────────┐       ┌────────────┐
        │   FILTER   │ --->  │  RMS MEASURE   │ --->  │  PROTECT   │
        └────────────┘       └────────────────┘       └────────────┘



---

## 📁 Repository Structure
```text

FPGA-Based-Overcurrent-Relay/
│
├── /hdl/              # Synthesizable Verilog source files (MAF, RMS, REM, Top-Level)
├── /tb/               # Testbench files (final_relay_tb.v)
├── /constrs/          # Xilinx Design Constraints (.xdc)
├── /doc/              # Project report, documentation, and flowchart
├── /sim_waveforms/    # Simulation result screenshots
└── README.md          # This file

```

---

## 🧠 How to Run the Project  

### 1. Create a New Vivado Project  
- Open **Xilinx Vivado**.  
- Create a new **RTL Project**.  
- Target device: **XC7A100TCSG323-3** (Artix-7).  

### 2. Add Sources  
- Add all files from `/hdl` → *Design Sources*  
- Add all files from `/tb` → *Simulation Sources*  
- Add constraint file from `/constrs` → *Constraints*

### 3. Generate CORDIC IP Core  
1. Open **IP Catalog**.  
2. Search for **CORDIC**.  
3. Configure as follows:  
   - Function: **Square Root**  
   - Input Width: **32 bits**  
   - Output Width: **16 bits**  
4. Generate the IP and ensure the **component name matches** the one instantiated in `rms_estimation_module.v` (e.g., `rms_cordic_sqroot`).

### 4. Run Simulation  
- Open **Behavioral Simulation**.  
- The testbench `final_relay_tb.v` automatically executes.  

### 5. Run Implementation  
- Click **Run Implementation** to synthesize, place, and route the design.  

### 6. Generate Bitstream  
- Click **Generate Bitstream** to create the final programming file for your FPGA.  

---

## 🧩 Simulation Results  

### ✅ 1. Normal Operation  
- Input: Sine wave with **peak = 2000**  
- Measured: `Irms ≈ 1414`  
- Since `1414 < 2000`, **trip signal = 0**

### ⚠️ 2. Fault Condition (Trip)  
- Input: Sine wave with **peak = 4000**  
- Measured: `Irms ≈ 2828`  
- Since `2828 > 2000`, **trip signal latches to 1**

---

## 🧪 Verification  

The testbench verifies:  
- End-to-end signal flow through the **Filter → RMS → Protection** pipeline.  
- Threshold-based **trip signal generation** and **latching behavior**.  

Simulation waveforms are available in the [`/sim_waveforms`](./sim_waveforms) folder.

---

## 🛠️ Tools & Technologies  

| Tool / Resource | Description |
|-----------------|--------------|
| **Xilinx Vivado** | Design, Simulation & Bitstream Generation |
| **Verilog HDL** | Hardware Description Language |
| **Artix-7 (XC7A100T)** | Target FPGA |
| **CORDIC IP Core** | Hardware-Accelerated Math Core |

---

## 📄 Authors  

**Authors:**  
- Sanjay R Senan  
- Rithwik D   

**Institution:**  
National Institute of Technology Calicut (NIT Calicut)

---

## 🧷 License  

This project is released under the **MIT License**.  
See the [LICENSE](./LICENSE) file for details.

---

## 🌟 Acknowledgements  

Special thanks to the **Department of Electrical Engineering, NIT Calicut** for academic guidance and FPGA lab resources.




