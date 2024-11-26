# ALU Structure Documentation

## Components

- **ALU (Codification)**  
  Responsible for executing arithmetic and logical operations.  
- **Decoder (Codification)**  
  Assigns and decodes operations for execution in the ALU.

---

## Operations

### ALU Operations

#### **Basic Set**
- `ADD [000000/000000]`  
- `SUB [000000]`  
- `AND [000000]`  
- `ORR [000000]`  
- `MUL [000000]`  

#### **Secondary Set**
- `STR [000000]`  
- `LDR [000000]`  
- `LSL [000000]`  
- `LSR [000000]`  

#### **DLC Set**
- `SLT [000000]`  
- `ASR [000000]`  
- `STR [000000]` *(With immediate)*  
- `LDR [000000]` *(With immediate)*  

#### **Premium Set**
- Variants of arithmetic and logical operations, optimized for advanced use cases:  
  - **All ADD / SUB variants**: (x5) and (x7) `[X1XXX0]`  
  - **All MUL variants**: (x7) `[XXX001]`  
  - **All DIV variants**: (x2) `[X10000]`  
  - **All logical operands**: (x10) `[X1XXX0]`  
  - **Testers** (e.g., SLT): (x8) `[010XXX]`  
  - **Move operands**: (x2) `[1X0000]`  
  - **Branch operations**: (x8) `[00XXX1]`  

#### **Completionist Set**
- **All Load/Store variants**: (x14)  
- *(Includes advanced configurations such as XD)*  

---

## Tables

*(No content provided—consider adding tables for operation encoding or timing information.)*

[= = =][Division 1] :
  - Arithmetic: (x16)
    +   ADD / IMM. ADD
    +   ADC
    +   QADD
    +   SUB / IMM. SUB
    +   SBS / IMM. SBS
    +   RSB / IMM. RSB / POSTINT. RSB
    +   QSUB
    +   MUL
    +   MLA
    +   MLS
    +   UMULL
    +   UMLAL
    +   SMULL
    +   SMLAL
    +   UDIV
    +   SDIV
[= = =][Division 2] :
  - Logic: (x5)
    +   AND / IMM. AND
    +   BIC / IMM. BIC
    +   ORR / IMM. ORR
    +   ORN / IMM. ORN
    +   EOR / IMM. EOR
[= = =][Division 3] :
[= = =][Division 4] :


---

## Description

The ALU stage performs all arithmetic and logical operations and generates condition codes for instructions requiring flag setting.

### Key Features:
1. **Logic Unit**: Handles logical operations like AND, ORR, etc.  
2. **Arithmetic Unit**: Executes operations such as ADD, SUB, MUL, and DIV.  
3. **Flag Generator**: Enabled for flag-setting operations, evaluates condition flags in parallel with the main adder.  

### Pipeline Optimization:
- The ALU stage separates carry chains in the main adder to enable 8-bit and 16-bit SIMD instructions for DSP operations.
- The pipeline logic allows efficient evaluation of flag settings, improving overall performance for both scalar and SIMD operations.
