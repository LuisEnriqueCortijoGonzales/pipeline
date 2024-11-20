### ALU structure documentation

## Components

- ALU (Codification)_(Arithmetical and logical).
- Decoder (Codification)_(Assignment for operation).

## Stata

- Alu Operations
### Basic Set
  ´ADD/SUB []´ <BR>
  ´AND []´ <BR>
  ´ORR []´ <BR>
  ´MUL []´ <BR>
### Secondary Set
  ´STR []´ <BR>
  ´LDR []´ <BR>
  ´LSL []´ <BR>
  ´LSR []´ <BR>
### Suplementary Set
  ´SLT []´ <BR>
  ´ASR []´ <BR>
  ´STR [] (With immediate)´ <BR>
  ´LDR [] (With immediate)´ <BR>
### Premium Set
  ´All ADD / SUB variants´ <BR>
  ´All MUL variants´ <BR>
  ´All Carry ops´ <BR>
## Tables

## Description

The ALU stage performs all arithmetic and logic operations, and generates the condition codes for instructions that set these operations.

The ALU stage consists of a logic unit, an arithmetic unit, and a flag generator. The pipeline logic evaluates the flag settings in parallel with the main adder in the ALU. The flag generator is enabled only on flag-setting operations.

The ALU stage separates the carry chains of the main adder enable 8 and 16-bit SIMD instructions for DSP operations.
