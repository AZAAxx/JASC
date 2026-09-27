# JASC — RV32I RISC-V Processor

JASC is an **in-development** 32-bit RISC-V processor implemented in SystemVerilog. The project currently establishes a modular five-stage pipeline architecture, typed control/pipeline interfaces, RV32I instruction decoding, and register-file infrastructure. ALU operations, branch/jump control logic, fetch, memory, writeback, hazard handling, and verification infrastructure **remain under development**. The project is being developed as a hardware-design study of **CPU microarchitecture, RTL design, instruction decoding, datapaths, control logic, and FPGA implementation**.

### Implemented RTL Architecture

- 32-bit **RISC-V RV32I** processor architecture
- Five-stage processor architecture: **Fetch → Decode → Execute → Memory → Writeback**
- Strongly typed SystemVerilog control and pipeline structures using:
  - `typedef struct packed`
  - Enumerated control signals
  - `always_comb` / `always_ff` RTL constructs
- RV32I instruction-field and immediate decoding for major instruction formats
- Centralized instruction and control decoder
- ALU operation definitions for arithmetic, logical operations, shifts, signed and unsigned comparisons
- 32 × 32-bit integer register-file architecture with `x0` hardwired to zero
- Branch and jump control logic architecture
- Pipeline packets carrying instruction metadata, control signals, and datapath information
- `instr_info_t` structure providing an initial foundation for future **RVFI-based instruction-level verification**
- Quartus project structure for eventual FPGA implementation

### In-Progress Components

The following components are currently implemented as partial RTL or architectural scaffolding:

- Program counter and instruction-fetch logic
- Clocked pipeline-register implementation
- Execute-stage integration
- Load/store datapath and memory interface
- Writeback datapath
- Complete branch and jump pipeline control
- Hazard detection, forwarding, and pipeline flushing
- SYSTEM/CSR instruction support
- End-to-end processor integration
- Simulation, verification, and ISA-level testing

## Architecture

JASC follows a conventional five-stage RISC-V datapath:

```text
┌──────────────────────┐
│    Instruction       │
│       Memory         │
└──────────┬───────────┘
           │
           ▼
      ┌─────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
      │ Fetch   │────►│  Decode  │────►│ Execute  │────►│  Memory  │────►│ Writeback│
      │         │     │          │     │          │     │          │     │          │
      │ PC      │     │ Decoder  │     │   ALU    │     │ Load/    │     │ WB MUX   │
      │ Instr.  │     │ RegFile  │     │ Branch   │     │ Store    │     │ RegFile  │
      └─────────┘     └──────────┘     └──────────┘     └──────────┘     └──────────┘
                           │                 │                │                │
                           │                 │                │                │
                           └─────────────────┴────────────────┴────────────────┘
                                    Pipeline control / metadata
```

Pipeline information is represented using packed structures:

```text
if_id_t  →  id_ex_t  →  ex_mem_t  →  mem_wb_t
```

Each structure carries the information required by the following stage, including instruction data, PC values, register operands, immediate values, ALU results, memory data, and control signals.

## Datapath

### 1. Instruction Fetch

`fetch_stage.sv` forms the front end of the processor and produces the `if_id_t` pipeline packet containing:

- Current PC
- Instruction
- Valid bit

PC generation and instruction-memory integration are currently under development.

### 2. Instruction Decode

`decode_stage.sv` connects the instruction to the centralized `jasc_decoder`.

The decoder:

- Extracts `opcode`, `funct3`, and `funct7`
- Identifies `rs1`, `rs2`, and `rd`
- Generates sign-extended immediates
- Produces ALU and datapath control signals
- Selects branch and next-PC behavior
- Generates memory operation controls
- Determines register-file writeback behavior

Supported instruction encodings include:

- R-type
- I-type
- S-type
- B-type
- U-type
- J-type

The resulting information is packaged into `id_ex_t`.

### 3. Execute

`execute_stage.sv` defines the intended execute-stage datapath, including operand selection, ALU operations, branch comparison, and next-PC generation.

Operand multiplexing supports:

```text
Operand A:
    Register
    Immediate
    PC

Operand B:
    Register
    Immediate
    Constant 4
```

The stage contains the `jasc_ALU` and generates:

- Arithmetic/logic result
- Zero flag
- Negative flag
- Next PC

The decoder and execute-stage control structures currently define support for BEQ, BNE, BLT, BGE, BLTU, and BGEU; execution and pipeline integration remain under development.

### 4. Memory

`memory_stage.sv` defines the intended memory-access stage between execute and the data-memory subsystem.

The control architecture distinguishes:

```text
MEM_NONE
MEM_LOAD
MEM_STORE
```

The decoder also contains byte-enable control intended to support different memory access widths. The memory interface is currently being integrated into the datapath.

### 5. Writeback

`writeback_stage.sv` is responsible for selecting the value written back to the register file.

The intended writeback sources are:

```text
ALU result
Memory read data
Immediate
```

corresponding to:

```text
RD_ALU
RD_MEM
RD_IMM
```

---
## ALU

`jasc_ALU.sv` is the processor's 32-bit arithmetic and logic unit.

Supported operations include:

| Operation | Description |
|---|---|
| `ADD` | Addition |
| `SUB` | Subtraction |
| `AND` | Bitwise AND |
| `OR` | Bitwise OR |
| `XOR` | Bitwise XOR |
| `SLL` | Logical left shift |
| `SRL` | Logical right shift |
| `SRA` | Arithmetic right shift |
| `SLT` | Signed comparison |
| `SLTU` | Unsigned comparison |

The ALU also produces zero and negative status flags used by control-flow logic.

## Register File

`jasc_register_file.sv` implements the RISC-V integer register file:

- 32 registers
- 32-bit register width
- Two combinational read ports
- One synchronous write port
- `x0` hardwired to zero
- Reset support

```text
rs1 ─────► Read Port 1 ──► rs1_rdata
rs2 ─────► Read Port 2 ──► rs2_rdata

rd_wdata ────────────────► Write Port
                              │
                              ▼
                              rd
```

## Control Architecture

Control signals are defined centrally in `jasc_pkg.sv` using strongly typed SystemVerilog enumerations.

Examples include:

```systemverilog
opA_sel_e
opB_sel_e
alu_op_e
next_pc_sel_e
branch_type_e
mem_op_e
rd_wdata_sel_e
```

This provides a typed interface between the decoder and datapath rather than passing unstructured control bits throughout the processor.

The package also defines the pipeline structures:

```systemverilog
if_id_t
id_ex_t
ex_mem_t
mem_wb_t
```

and an `instr_info_t` structure intended to carry architectural information required for debugging and future formal verification.

## RISC-V Instruction Decoding

The decoder currently recognizes the major RV32I opcode classes:

```text
LOAD
OP-IMM
AUIPC
STORE
OP
LUI
BRANCH
JALR
JAL
SYSTEM
```

The repository also includes the RV32I reference material and instruction-set diagram used during development.

## Repository Structure

```text
JASC/
├── rtl/
│   ├── JASC.sv                 # Processor top-level datapath
│   ├── top.sv                  # System-level top module
│   ├── jasc_pkg.sv             # Types, control enums, pipeline structs
│   ├── jasc_decoder.sv         # Instruction and control decoder
│   ├── jasc_ALU.sv             # 32-bit ALU
│   ├── jasc_register_file.sv   # 32 × 32-bit register file
│   ├── jasc_fsm.sv             # Processor FSM framework
│   ├── fetch_stage.sv          # Instruction fetch stage
│   ├── decode_stage.sv         # Instruction decode stage
│   ├── execute_stage.sv        # Execute / ALU / branch stage
│   ├── memory_stage.sv         # Memory access stage
│   ├── writeback_stage.sv      # Register writeback stage
│   ├── JASC.qpf               # Quartus project
│   ├── JASC.qsf               # Quartus settings
│   └── db/                     # Quartus-generated project data
│
├── RV32I_IS.png                # RV32I instruction-set reference
├── RISCV_Reference.pdf         # RISC-V reference material
├── references                   # Project references
└── README.md
```

## Design Methodology

The processor is structured around **modular RTL blocks and typed interfaces** rather than implementing the entire CPU as a single monolithic module.

The main datapath is composed hierarchically:

```text
JASC
 │
 ├── Fetch Stage
 │
 ├── Decode Stage
 │    └── JASC Decoder
 │
 ├── Execute Stage
 │    └── JASC ALU
 │
 ├── Memory Stage
 │
 ├── Writeback Stage
 │
 └── Register File
```

Pipeline structures defined in `jasc_pkg.sv` provide a common interface between these modules.

## Verification & Future Work

The architecture is being developed incrementally, with planned work including:

- Complete instruction-memory integration
- Complete load/store datapath
- Pipeline register implementation
- Hazard detection and pipeline control
- Forwarding / dependency handling
- Complete writeback logic
- RISC-V instruction-level testing
- **Simulation-based verification**
- FPGA synthesis and timing analysis
- **RVFI integration for formal RISC-V compliance verification**

The `instr_info_t` structure already provides fields for architectural state such as:

```text
PC
instruction
source registers
destination register
register data
memory address
memory masks
memory data
trap state
```

providing a foundation for future instruction-level verification.

## Tools & Technologies

- **SystemVerilog**
- **RTL Design**
- **RISC-V RV32I**
- **Intel Quartus**
- **FPGA Design**
- **CPU Microarchitecture**
- **Digital Logic**
- **Simulation & Verification**
- **Formal Verification / RVFI (planned)**

## References

- RISC-V ISA reference material included in the repository
- SystemVerilog synthesizable RTL design reference included in the repository
