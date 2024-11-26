# Encoding (instruction decoder & ALU)

## Instruction Decoder

## ALU controller

### **ALU Operations and ALUControl Encodings**

| **Operation** | **ALUControl Encoding (4 bits)** | **Description**                                     |
| ------------- | -------------------------------- | --------------------------------------------------- |
| `ADD`         | `0000`                           | Adds two operands.                                  |
| `SUB`         | `0001`                           | Subtracts the second operand from the first.        |
| `MUL`         | `0010`                           | Multiplies two operands.                            |
| `SDIV`        | `0011`                           | Divides the first operand by the second (signed).   |
| `UDIV`        | `0100`                           | Divides the first operand by the second (unsigned). |
| `AND`         | `0101`                           | Performs a bitwise AND operation.                   |
| `OR`          | `0110`                           | Performs a bitwise OR operation.                    |
| `XOR`         | `0111`                           | Performs a bitwise Exclusive OR (XOR) operation.    |
| `SHIFTL`      | `1000`                           | Shifts bits to the left (Logical Shift Left).       |
| `SHIFTR`      | `1001`                           | Shifts bits to the right (Logical Shift Right).     |
| `BIC`         | `1010`                           | Bit Clear: Performs `Rd = Rn & ~Operand2`.          |
| `ORN`         | `1011`                           | OR Not: Performs `Rd = Rn v ~Operand2`.             |

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
- _(Includes advanced configurations such as XD)_

---

## Tables

_(No content provided—consider adding tables for operation encoding or timing information.)_

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
    +   
[= = =][Division 2] :
  - Logic: (x5)
    +   AND / IMM. AND
    +   BIC / IMM. BIC
    +   ORR / IMM. ORR
    +   ORN / IMM. ORN
    +   EOR / IMM. EOR
    +   
[= = =][Division 3] :
  - Test: (X4)
    +  CMN / CONS.
    +  TST / CONS.
    +  TEQ / CONS.
    +  CMP / CONS.
    +  
[= = =][Division 4] :
  - Move: (x1)
    +  MOV
[= = =][Division 5] :
  - Shift/Rot: (x5)
    +  LSR / IMM. LSR
    +  ASR / IMM. ASR
    +  LFL / IMM. LFL
    +  ROR / IMM. ROR
    +  RRX / IMM. RRX
    +  
[= = =][Division 6] :
  - Load & Store: (x2)
    +  LDR (x7)
      - Offset
      - Pre-offset
      - Post-offset
      - Indexed
      - Literal
      - Positive/Negative Stack (STMIA)
    +  STR (x7)
      - Offset
      - Pre-offset
      - Post-offset
      - Indexed
      - Literal
      - Positive/Negative Stack (LDMDB)
      + 
[= = =][Division 6] :
  - Branch: (x2)
    +  Branch On Flags (x2)
      - B
      - BL
    +  Test & Branch (x2) 
      - CBZ
      - CBNZ
      + 
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
