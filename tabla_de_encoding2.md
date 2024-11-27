# Instruction Encodings

| Instruction | Encoding | Type            |
|-------------|----------|-----------------|
| LDR         | 000000   | Offset          |
| STR         | 000001   | Offset          |
| LDR         | 000010   | Pre-offset      |
| STR         | 000011   | Pre-offset      |
| LDR         | 000100   | Post-offset     |
| STR         | 000101   | Post-offset     |
| LDR         | 000110   | Indexed         |
| STR         | 000111   | Indexed         |
| LDR         | 001000   | Literal         |
| STR         | 001001   | Literal         |
| STMIA       | 001010   | Positive stack  |
| LDMDB       | 001011   | Positive stack  |
| STMDB       | 001100   | Negative stack  |
| LDMIA       | 001101   | Negative stack  |
| B           | 001110   | Branch on flags |
| BL          | 001111   | Branch on flags |
| CBZ         | 010000   | Test & branch   |
| CBNZ        | 010001   | Test & branch   |
