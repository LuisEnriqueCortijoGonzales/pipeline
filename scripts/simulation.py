# Función para leer las instrucciones desde un archivo
def leer_instrucciones(archivo):
    instrucciones = []
    with open(archivo, 'r') as f:
        for linea in f:
            partes = linea.strip().split()
            op = partes[0]
            args = [partes[1].rstrip(',')]
            for arg in partes[2:]:
                if arg.startswith('#'):
                    # Manejar valores hexadecimales
                    if arg[1:].startswith('0x'):
                        args.append(int(arg[1:], 16))
                    else:
                        args.append(int(arg[1:]))
                else:
                    args.append(arg.rstrip(','))
            instrucciones.append((op, *args))
    return instrucciones

# Leer las instrucciones desde el archivo
instructions = leer_instrucciones('assets/instrucciones.txt')

# Inicializamos los registros
registers = {f"r{i}": 0 for i in range(13)}

# Almacenamos los estados a lo largo del tiempo
states = []

# Función para ejecutar las instrucciones
def execute_instruction(inst):
    global registers
    op = inst[0]
    if op == "MOV":
        # Verifica si el segundo argumento es un número o un registro
        if isinstance(inst[2], int):
            registers[inst[1]] = inst[2]
        else:
            registers[inst[1]] = registers[inst[2]]
    elif op == "ADD":
        registers[inst[1]] = int(registers[inst[2]]) + (inst[3] if isinstance(inst[3], int) else int(registers[inst[3]]))
    elif op == "ADC":
        registers[inst[1]] = int(registers[inst[2]]) + (inst[3] if isinstance(inst[3], int) else int(registers[inst[3]])) + 1
    elif op == "SUB":
        registers[inst[1]] = int(registers[inst[2]]) - (inst[3] if isinstance(inst[3], int) else int(registers[inst[3]]))
    elif op == "SBC":
        registers[inst[1]] = int(registers[inst[2]]) - (inst[3] if isinstance(inst[3], int) else int(registers[inst[3]])) - 1
    elif op == "MUL":
        registers[inst[1]] = int(registers[inst[2]]) * int(registers[inst[3]])
    elif op == "MLA":
        registers[inst[1]] = int(registers[inst[2]]) * int(registers[inst[3]]) + int(registers[inst[4]])
    elif op == "MLS":
        registers[inst[1]] = int(registers[inst[2]]) * int(registers[inst[3]]) - int(registers[inst[4]])
    elif op == "AND":
        registers[inst[1]] = int(registers[inst[2]]) & (inst[3] if isinstance(inst[3], int) else int(registers[inst[3]]))
    elif op == "BIC":
        registers[inst[1]] = int(registers[inst[2]]) & ~(inst[3] if isinstance(inst[3], int) else int(registers[inst[3]]))
    elif op == "ORR":
        registers[inst[1]] = int(registers[inst[2]]) | (inst[3] if isinstance(inst[3], int) else int(registers[inst[3]]))
    elif op == "EOR":
        registers[inst[1]] = int(registers[inst[2]]) ^ (inst[3] if isinstance(inst[3], int) else int(registers[inst[3]]))
    elif op == "LSR":
        registers[inst[1]] = int(registers[inst[2]]) >> inst[3]
    elif op == "ASR":
        registers[inst[1]] = int(registers[inst[2]]) >> inst[3]  # Sign bit not considered for simplicity
    elif op == "LSL":
        registers[inst[1]] = int(registers[inst[2]]) << inst[3]
    elif op == "ROR":
        shift = inst[3] % 32
        registers[inst[1]] = ((int(registers[inst[2]]) >> shift) | (int(registers[inst[2]]) << (32 - shift))) & 0xFFFFFFFF
    elif op == "RRX":
        carry = 0  # Not implemented, assumed 0
        registers[inst[1]] = (int(registers[inst[2]]) >> 1) | (carry << 31)

# Ejecutamos las instrucciones
for inst in instructions:
    execute_instruction(inst)
    states.append(registers.copy())

# Mostramos los estados
for i, state in enumerate(states):
    print(f"Estado {i + 1}: {state}")
