# Encoding (instruction decoder & ALU)

## Instruction Decoder

## ALU controller

### **ALU Operations and ALUControl Encodings**

The 5 bits used are the last 5 bits of the encodings for `OP[0] = 1`.

| **Operation** | **ALUControl Encoding (5 bits)** | **Description**                                                                                   |
| ------------- | -------------------------------- | ------------------------------------------------------------------------------------------------- |
| `ADD`         | `00000`                          | Adds two operands: `Result = A + B`.                                                              |
| `SUB`         | `00001`                          | Subtracts the second operand from the first: `Result = A - B`.                                    |
| `MUL`         | `00010`                          | Multiplies two operands: `Result = A * B`.                                                        |
| `SDIV`        | `00011`                          | Divides the first operand by the second (signed): `Result = A / B`.                               |
| `UDIV`        | `00100`                          | Divides the first operand by the second (unsigned): `Result = A / B`.                             |
| `AND`         | `00101`                          | Bitwise AND operation: `Result = A & B`.                                                          |
| `ORR`         | `00110`                          | Bitwise OR operation: `Result = A \| B`.                                                          |
| `EOR`         | `00111`                          | Bitwise Exclusive OR (XOR) operation: `Result = A ^ B`.                                           |
| `BIC`         | `01000`                          | Bit Clear: `Result = A & ~B`.                                                                     |
| `ORN`         | `01001`                          | OR Not: `Result = A \| ~B`.                                                                       |
| `ADC`         | `01010`                          | Add with Carry: `Result = A + B + Carry`.                                                         |
| `SBC`         | `01011`                          | Subtract with Carry: `Result = A - B - ~Carry`.                                                   |
| `RSB`         | `01100`                          | Reverse Subtract: `Result = B - A`.                                                               |
| `QADD`        | `01101`                          | Saturated Add: Adds two operands with saturation to prevent overflow: `Result = saturate(A + B)`. |
| `QSUB`        | `01110`                          | Saturated Subtract: Subtracts two operands with saturation: `Result = saturate(A - B)`.           |
| `CMP`         | `10101`                          | Compare: Subtracts one operand from another and updates flags: `A - B`.                           |
| `CMN`         | `10110`                          | Compare Negative: Adds two operands and updates flags without storing the result: `A + B`.        |
| `TST`         | `10111`                          | Test: Performs a bitwise AND on two operands and updates flags: `A & B`.                          |
| `TEQ`         | `11000`                          | Test Equivalence: Performs a bitwise Exclusive OR and updates flags: `A ^ B`.                     |
| `LSHIFT`      | `11001`                          | Logical Shift Left: `Result = A << ShiftAmount`.                                                  |
| `RSHIFT`      | `11010`                          | Logical Shift Right: `Result = A >> ShiftAmount`.                                                 |
| `ASHIFT`      | `11011`                          | Arithmetic Shift Right: `Result = A >>> ShiftAmount` (preserves sign).                            |
| `ROR`         | `11100`                          | Rotate Right: `Result = rotate_right(A, ShiftAmount)`.                                            |
| `RRX`         | `11101`                          | Rotate Right with Extend: `Result = (Carry << 31) v (A >> 1)`.                                    |

---

#### **Multiplication Operations and ALUControl Encodings**

| **Operation** | **ALUControl Encoding (5 bits)** | **Description**                                                                                   |
| ------------- | -------------------------------- | ------------------------------------------------------------------------------------------------- |
| `MLA`         | `01000`                          | Multiply-Accumulate: `Result = Ra + (A * B)`.                                                     |
| `MLS`         | `01001`                          | Multiply-Subtract: `Result = Ra - (A * B)`.                                                       |
| `UMULL`       | `01010`                          | Unsigned Multiply Long: Multiplies two operands to produce a 64-bit result (`RdHi:RdLo = A * B`). |
| `UMLAL`       | `01011`                          | Unsigned Multiply-Accumulate Long: `RdHi:RdLo += A * B`.                                          |
| `SMULL`       | `01100`                          | Signed Multiply Long: Multiplies two operands to produce a 64-bit result (`RdHi:RdLo = A * B`).   |
| `SMLAL`       | `01101`                          | Signed Multiply-Accumulate Long: `RdHi:RdLo += A * B`.                                            |

##### MLA / MLS

| Cond | OP  | I   | command | S   | Rn  | Rd  | Ra  | NULL | Rm  |
| ---- | --- | --- | ------- | --- | --- | --- | --- | ---- | --- |
| 4b   | 2b  | 1b  | 4b      | 1b  | 4b  | 4b  | 4b  | 4b   | 4b  |

- **Ra (4b):** Optional accumulated initial value

##### UMULL / UMLAL / SMULL / SMLAL

| Cond | OP  | I   | command | S   | Rn  | RdLo | RdHi | NULL | Rm  |
| ---- | --- | --- | ------- | --- | --- | ---- | ---- | ---- | --- |
| 4b   | 2b  | 1b  | 4b      | 1b  | 4b  | 4b   | 4b   | 4b   | 4b  |

- **RdLo (4b):** Address of the less significant 32bits of the 64B number, also used as an accumulate (UMLAL, SMLAL)
- **RdHi (4b):** Address of the more significant 32bits of the 64B number.


##### Memory operations
| Cond | OP | I | P | U | B | W | L | Rn | Rd | Offset/Immediate |

 Campo             | Bits | Descripción                                                                 |
|--------------------|------|-----------------------------------------------------------------------------|
| **Cond**          | 4    | Condición para ejecutar la instrucción (e.g., `EQ`, `NE`, `AL`, etc.).       |
| **00**            | 2    | Especifica que es una instrucción de carga/almacenamiento.                  |
| **I**             | 1    | Define si el desplazamiento es inmediato (`0`) o basado en un registro (`1`).|
| **P**             | 1    | Preindexado (`1`) o postindexado (`0`).                                     |
| **U**             | 1    | Incremento (`1`) o decremento (`0`) de la dirección base.                   |
| **B**             | 1    | Transferencia de bytes (`1`) o palabras completas (`0`).                   |
| **W**             | 1    | Escribe la dirección calculada en el registro base (`1`).                  |
| **L**             | 1    | Cargar (`1`) o almacenar (`0`).                                             |
| **Rn**            | 4    | Registro base que contiene la dirección.                                    |
| **Rd**            | 4    | Registro destino (para carga) o fuente (para almacenamiento).               |
| **Offset/Immediate** | 12 | Valor de desplazamiento inmediato o especificación de un registro.         |



---

TODO: Fix the md syntax
[= = =][Division 1] :

- Arithmetic: (x16) + ADD / IMM. ADD + ADC + QADD + SUB / IMM. SUB + SBS / IMM. SBS + RSB / IMM. RSB / POSTINT. RSB + QSUB + MUL + MLA + MLS + UMULL + UMLAL + SMULL + SMLAL + UDIV + SDIV +
  [= = =][Division 2] :
- Logic: (x5) + AND / IMM. AND + BIC / IMM. BIC + ORR / IMM. ORR + ORN / IMM. ORN + EOR / IMM. EOR +
  [= = =][Division 3] :
- Test: (X4) + CMN / CONS. + TST / CONS. + TEQ / CONS. + CMP / CONS. +
  [= = =][Division 4] :
- Move: (x1) + MOV
  [= = =][Division 5] :
- Shift/Rot: (x5) + LSR / IMM. LSR + ASR / IMM. ASR + LFL / IMM. LFL + ROR / IMM. ROR + RRX / IMM. RRX +
  [= = =][Division 6] :
- Load & Store: (x2) + LDR (x7) - Offset - Pre-offset - Post-offset - Indexed - Literal - Positive/Negative Stack (STMIA) + STR (x7) - Offset - Pre-offset - Post-offset - Indexed - Literal - Positive/Negative Stack (LDMDB) +
  [= = =][Division 6] :
- Branch: (x2)
  - Branch On Flags (x2)
  * B
  * BL
  - Test & Branch (x2)
  * CBZ
  * CBNZ
  -

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
