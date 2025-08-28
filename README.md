# Griffin's Tiny GPU

This repository contains my implementation of a small-scale GPU, designed and 
validated in **SystemVerilog** using **Xilinx Vivado**. The project explores GPU 
architecture at a fundamental level, including support for integer and floating 
point arithmetic.  

The goal of this work was to gain a deeper understanding of GPU design and to 
develop familiarity with industry-standard tools such as Vivado.  

👉 For a detailed write-up of the project, please visit my website:  
[gfaecher.github.io](https://gfaecher.github.io)

---

## Project Overview

The GPU is designed to be **scalable**, meaning the number of cores and 
functional units can be adjusted depending on the FPGA's size and power.  
It executes **LEGv8 instructions** (with one additional instruction for 
simplicity).  

### High-Level Architecture
<p align="center">
  <img src="gpuSchematic.png" alt="GPU Architecture Diagram" width="600"/>
</p>

At a high level, the CPU sends data (threads) to the GPU for execution. The GPU 
manages them through a **warp scheduler** and **warp dispatcher**, before 
execution begins on one of the **SIMD cores**.  

### Key Modules
- **Warp Scheduler**  
  Stores kernels in a circular buffer and manages kernel state (idle, 
  loading, launching).  

- **Warp Dispatcher**  
  Assigns kernels to available SIMD cores and tracks which cores are free.  

- **SIMD Core**  
  Executes instructions via a fetch–decode–execute cycle. Each core contains 
  its own register files and functional units for parallelism.  

- **Functional Units**  
  Custom **floating-point and integer ALUs**, implemented primarily using 
  logical operations instead of arithmetic operators, to deepen understanding 
  of low-level hardware design.

<p align="center">
  <img src="gpuSIMD.png" alt="SIMD Core Diagram" width="400"/>
</p>

---

## Lessons Learned

This was my first large-scale personal project, and it was a challenging yet 
rewarding experience. Highlights include:
- Gained experience with **SystemVerilog** after primarily using VHDL before.  
- Learned how to design scalable hardware architectures.  
- Developed insight into GPU scheduling, instruction execution, and arithmetic 
  unit design.  
- Built proficiency in **Xilinx Vivado** and explored how tools used in 
  industry support hardware design and verification.  

---

## More Information

For a full explanation of the design process, detailed module breakdowns, and 
additional diagrams, please check out the project website:  

🔗 [gfaecher.github.io](https://gfaecher.github.io)
