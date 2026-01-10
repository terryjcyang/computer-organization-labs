# Computer Organization Labs

This repository contains laboratory assignments for a Computer Organization course at NYCU (National Yang Ming Chiao Tung University). The labs progress from basic C programming to increasingly complex CPU implementations in Verilog.

## 📚 Lab Overview

### Lab 1: C Programming Fundamentals

Basic C programming exercises covering fundamental algorithms:

- **factorial.c** - Recursive factorial calculation
- **gcd_lcm.c** - Greatest Common Divisor and Least Common Multiple
- **max_min.c** - Finding maximum and minimum values
- **sum_of_digits.c** - Calculating sum of digits in a number
- **exp.c** - Exponential calculations

**Compilation:**

```bash
cd lab1
gcc -o factorial factorial.c
./factorial
```

### Lab 2: ALU Design in Verilog

Implementation of a 32-bit Arithmetic Logic Unit with modular components:

- **ALU.v** - Top-level 32-bit ALU module
- **ALU_1bit.v** - 1-bit ALU building block
- **MUX_2to1.v** - 2-to-1 multiplexer
- **MUX_4to1.v** - 4-to-1 multiplexer
- **testbench.v** - Test harness with 30 test patterns

**Features:**

- 4-bit operation code support
- Zero, carry-out, and overflow flag generation
- Modular design with hierarchical structure

**Simulation:**

```bash
cd lab2
iverilog -o alu testbench.v
vvp alu
```

### Lab 3: Single-Cycle CPU

Implementation of a MIPS-like single-cycle processor with all instructions completing in one clock cycle.

**Core Components:**

- **Simple_Single_CPU.v** - Top-level CPU module integrating all components
- **ALU.v** / **ALU_Ctrl.v** - Arithmetic Logic Unit and control
- **Reg_File.v** - 32-register register file
- **Instr_Memory.v** - Instruction memory
- **Data_Memory.v** - Data memory
- **Decoder.v** - Instruction decoder for control signals
- **Sign_Extend.v** - 16-bit to 32-bit sign extension
- **Shifter.v** - Barrel shifter
- **ProgramCounter.v** - Program counter

**Features:**

- R-type, I-type, and J-type instruction support
- Branch and jump operations
- Load/store instructions
- Support for operations like `add`, `sub`, `and`, `or`, `slt`, `beq`, `bne`, `j`, `jal`, `jr`, `lw`, `sw`

**Note:** Lab 3 contains known issues and may not pass all test cases. Lab 4 and Lab 5 implementations are independent and correct.

**Simulation:**

```bash
cd lab3/hand_in_version
iverilog -o lab3.vvp testbench.v
vvp lab3.vvp
```

### Lab 4: Pipelined CPU

Five-stage pipelined processor implementation with pipeline registers between stages:

**Pipeline Stages:**

1. **IF (Instruction Fetch)** - Fetch instruction from memory
2. **ID (Instruction Decode)** - Decode instruction and read registers
3. **EX (Execute)** - Execute ALU operations
4. **MEM (Memory Access)** - Access data memory
5. **WB (Write Back)** - Write results back to registers

**Key Components:**

- **Pipe_CPU.v** - Top-level pipelined CPU module
- **Pipe_Reg.v** - Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
- All supporting components from Lab 3

**Features:**

- Improved throughput through instruction pipelining
- Pipeline register storage between stages
- Basic hazard handling structure

**Simulation:**

```bash
cd lab4/hand_in_version
iverilog -o pipe_cpu testbench.v
vvp pipe_cpu
```

### Lab 5: Pipelined CPU with Hazard Detection and Forwarding

Enhanced pipelined CPU with advanced hazard handling mechanisms:

**New Components:**

- **Pipe_CPU_PRO.v** - Advanced pipelined CPU with hazard handling
- **Forwarding_Unit.v** - Data forwarding to resolve data hazards
- **Hazard_Detection.v** - Detects and handles pipeline hazards
- **MUX_3to1.v** - 3-to-1 multiplexer for forwarding paths

**Hazard Handling:**

- **Data Forwarding** - EX-to-EX and MEM-to-EX forwarding paths
- **Stall Detection** - Pipeline stalls for load-use hazards
- **Control Hazard** - Branch prediction and flushing

**Features:**

- Eliminates unnecessary stalls through data forwarding
- Handles RAW (Read After Write) hazards
- Improved performance over basic pipeline
- Supports all MIPS-like instructions with proper hazard handling

**Simulation:**

```bash
cd lab5/hand_in_version
iverilog -o pipe_cpu_pro testbench.v
vvp pipe_cpu_pro
```

## 🛠️ Tools Required

- **C Compiler:** GCC or Clang (for Lab 1)
- **Verilog Simulator:** Icarus Verilog (iverilog) or ModelSim (for Labs 2-5)
- **Waveform Viewer:** GTKWave (optional, for viewing .vcd files)

## 📁 Repository Structure

```
computer-organization-labs/
├── lab1/                    # C programming exercises
├── lab2/                    # ALU implementation
├── lab3/                    # Single-cycle CPU
│   ├── hand_in_version/    # Submitted version
│   └── testcase/           # Test data files
├── lab4/                    # Pipelined CPU
│   ├── hand_in_version/    # Submitted version
│   └── testcase/           # Test data files
├── lab5/                    # Pipelined CPU with hazards
│   ├── hand_in_version/    # Submitted version
│   └── testcase/           # Test data files
├── Lab2_ref_ans/           # Reference solutions for Lab 2
└── Lab3_ref_ans/           # Reference solutions for Lab 3
```

## 🚀 Getting Started

### For C Labs (Lab 1):

```bash
cd lab1
gcc -o program_name source_file.c
./program_name
```

### For Verilog Labs (Labs 2-5):

```bash
cd labX/hand_in_version    # Replace X with lab number
iverilog -o output_name testbench.v
vvp output_name
gtkwave *.vcd              # Optional: view waveforms
```

## 📝 Course Context

These labs are part of a Computer Organization course that covers:

- Computer arithmetic and logic units
- Processor design and implementation
- Instruction set architectures (MIPS-like)
- Pipelining concepts and hazard handling
- Memory hierarchies

## ⚠️ Notes

- Lab 3 has known issues and may not pass all test cases
- Each lab includes a `hand_in_version/` directory containing the submitted implementation
- Reference answers (`Lab2_ref_ans/`, `Lab3_ref_ans/`) are provided for comparison
- Test cases are included in `testcase/` directories for verification

## 📖 Learning Outcomes

By completing these labs, you will gain:

- Understanding of basic computer organization principles
- Experience with hardware description languages (Verilog)
- Knowledge of CPU design from single-cycle to pipelined architectures
- Skills in handling pipeline hazards and optimizing processor performance
- Practical experience with simulation and testing of digital circuits

---

**Institution:** National Yang Ming Chiao Tung University (NYCU)  
**Course:** Computer Organization
