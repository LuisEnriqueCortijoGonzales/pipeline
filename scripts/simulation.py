# Definimos las instrucciones
instructions = [
    ("MOV", "r0", 5),
    ("MOV", "r1", 10),
    ("MOV", "r2", 15),
    ("MOV", "r3", 20),
    ("MOV", "r4", 25),
    ("MOV", "r5", 30),
    ("MOV", "r6", 35),
    ("MOV", "r7", 40),
    ("MOV", "r8", 45),
    ("MOV", "r9", 50),
    ("MOV", "r10", 55),
    ("MOV", "r11", 60),
    ("MOV", "r12", 65),
    ("MOV", "r1", 70),
    ("ADD", "r0", "r1", "r2"),
    ("ADD", "r3", "r3", 5),
    ("MOV", "r4", 1),
    ("ADC", "r5", "r6", "r7"),
    ("ADC", "r8", "r8", 10),
    ("QADD", "r9", "r10", "r11"),
    ("SUB", "r0", "r1", "r2"),
    ("SUB", "r3", "r3", 5),
    ("SBC", "r7", "r8", "r9"),
    ("SBC", "r10", "r10", 10),
    ("QSUB", "r11", "r12", "r1"),
    ("MUL", "r0", "r1", "r2"),
    ("MLA", "r3", "r4", "r5", "r6"),
    ("MLS", "r7", "r8", "r9", "r10"),
    ("UMULL", "r11", "r12", "r1", "r2"),
    ("UMLAL", "r3", "r4", "r5", "r6"),
    ("SMULL", "r7", "r8", "r9", "r10"),
    ("SMLAL", "r11", "r12", "r1", "r2"),
    ("AND", "r0", "r1", "r2"),
    ("AND", "r3", "r3", 0),
    ("BIC", "r4", "r5", "r6"),
    ("BIC", "r7", "r7", 0xF),
    ("ORR", "r8", "r9", "r10"),
    ("ORR", "r11", "r11", 0xF),
    ("EOR", "r3", "r4", "r5"),
    ("EOR", "r6", "r6", 1),
    ("LSR", "r6", "r7", 1),
    ("ASR", "r8", "r9", 2),
    ("LSL", "r10", "r11", 3),
    ("ROR", "r12", "r1", 4),
    ("RRX", "r2", "r3"),
]

# Inicializamos los registros
registers = {f"r{i}": 0 for i in range(13)}

# Almacenamos los estados a lo largo del tiempo
states = []

# Función para ejecutar las instrucciones
def execute_instruction(inst):
    global registers
    op = inst[0]
    if op == "MOV":
        registers[inst[1]] = inst[2]
    elif op == "ADD":
        registers[inst[1]] = registers[inst[2]] + (inst[3] if isinstance(inst[3], int) else registers[inst[3]])
    elif op == "ADC":
        registers[inst[1]] = registers[inst[2]] + (inst[3] if isinstance(inst[3], int) else registers[inst[3]]) + 1
    elif op == "SUB":
        registers[inst[1]] = registers[inst[2]] - (inst[3] if isinstance(inst[3], int) else registers[inst[3]])
    elif op == "SBC":
        registers[inst[1]] = registers[inst[2]] - (inst[3] if isinstance(inst[3], int) else registers[inst[3]]) - 1
    elif op == "MUL":
        registers[inst[1]] = registers[inst[2]] * registers[inst[3]]
    elif op == "MLA":
        registers[inst[1]] = registers[inst[2]] * registers[inst[3]] + registers[inst[4]]
    elif op == "MLS":
        registers[inst[1]] = registers[inst[2]] * registers[inst[3]] - registers[inst[4]]
    elif op == "AND":
        registers[inst[1]] = registers[inst[2]] & (inst[3] if isinstance(inst[3], int) else registers[inst[3]])
    elif op == "BIC":
        registers[inst[1]] = registers[inst[2]] & ~(inst[3] if isinstance(inst[3], int) else registers[inst[3]])
    elif op == "ORR":
        registers[inst[1]] = registers[inst[2]] | (inst[3] if isinstance(inst[3], int) else registers[inst[3]])
    elif op == "EOR":
        registers[inst[1]] = registers[inst[2]] ^ (inst[3] if isinstance(inst[3], int) else registers[inst[3]])
    elif op == "LSR":
        registers[inst[1]] = registers[inst[2]] >> inst[3]
    elif op == "ASR":
        registers[inst[1]] = registers[inst[2]] >> inst[3]  # Sign bit not considered for simplicity
    elif op == "LSL":
        registers[inst[1]] = registers[inst[2]] << inst[3]
    elif op == "ROR":
        shift = inst[3] % 32
        registers[inst[1]] = (registers[inst[2]] >> shift) | (registers[inst[2]] << (32 - shift))
    elif op == "RRX":
        carry = 0  # Not implemented, assumed 0
        registers[inst[1]] = (registers[inst[2]] >> 1) | (carry << 31)

# Ejecutamos las instrucciones
for inst in instructions:
    execute_instruction(inst)
    states.append(registers.copy())

# Mostramos los estados
for i, state in enumerate(states):
    print(f"Estado {i + 1}: {state}")
