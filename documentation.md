### ALU structure documentation

## Components

- ALU (Codification)_(Arithmetical and logical).
- Decoder (Codification)_(Assignment for operation).

## Stata

- Alu Operations
### Basic Set
  ´ADD [000000/000000]´ <BR>
  ´SUB [000000]´ <BR>
  ´AND [000000]´ <BR>
  ´ORR [000000]´ <BR>
  ´MUL [000000]´ <BR>
### Secondary Set
  ´STR [000000]´ <BR>
  ´LDR [000000]´ <BR>
  ´LSL [000000]´ <BR>
  ´LSR [000000]´ <BR>
### DLC Set
  ´SLT [000000]´ <BR>
  ´ASR [000000]´ <BR>
  ´STR [000000] (With immediate)´ <BR>
  ´LDR [000000] (With immediate)´ <BR>
### Premium Set
  ´All ADD / SUB variants´ (x5) (x7) [X1XXX0] <BR>
  ´All MUL variants´ (x7) [XXX001] <BR>
  ´All DIV variants´ (x2) [X10000] <BR>
  ´All Logic Operands´ (x10) [X1XXX0] <BR>
  ´All testers´ (x8) [010XXX] <BR>
  ´Move operands´ (x2) [1X0000]<BR>
  ´All branch operations´ (x8) [00XXX1] <BR>
### Completionist Set
  ´All Load/Store variants´ (x14) <BR> (XD)
## Tables

## Description

The ALU stage performs all arithmetic and logic operations, and generates the condition codes for instructions that set these operations.

The ALU stage consists of a logic unit, an arithmetic unit, and a flag generator. The pipeline logic evaluates the flag settings in parallel with the main adder in the ALU. The flag generator is enabled only on flag-setting operations.

The ALU stage separates the carry chains of the main adder enable 8 and 16-bit SIMD instructions for DSP operations.
