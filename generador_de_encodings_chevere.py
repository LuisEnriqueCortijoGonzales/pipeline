def arm_to_bin_hex(instruction):
    # Diccionario de codificaciones para las instrucciones
    encoding_dict = {
        "ADD": "100000",
        "ADC": "100001",
        "QADD": "100010",
        "SUB": "100011",
        "SBS": "100100",
        "SBC": "100101",
        "QSUB": "100110",
        "MUL": "100111",
        "MLA": "101000",
        "MLS": "101001",
        "UMULL": "101010",
        "UMLAL": "101011",
        "SMULL": "101100",
        "SMLAL": "101101",
        "UDIV": "101110",
        "SDIV": "101111",
        "AND": "110000",
        "BIC": "110001",
        "ORR": "110010",
        "ORN": "110011",
        "EOR": "110100",
        "CMN": "110101",
        "TST": "110110",
        "TEQ": "110111",
        "CMP": "111000",
        "MOV": "111001",
        "LSR": "111010",
        "ASR": "111011",
        "LSL": "111100",
        "ROR": "111101",
        "RRX": "111110",
    }

    # Separar la instrucción en partes
    parts = instruction.split()
    op = parts[0]
    rd = parts[1].strip(",")
    rn = (
        parts[2].strip(",") if len(parts) > 3 else "R0"
    )  # Asumimos Rn si hay más de dos operandos
    operand2 = parts[3] if len(parts) > 3 else parts[2]

    # Codificación por defecto
    condition = "1110"
    op_code = encoding_dict[op][
        :2
    ]  # Los dos primeros bits de op dependen de encoding_dict
    encoding = encoding_dict[op]
    bit_25 = (
        "1" if operand2.startswith("#") else "0"
    )  # Usamos inmediato si empieza con '#'
    function = f"{bit_25}{encoding[2:]}"  # Primer bit de func es bit_25, los siguientes 4 son del encoding
    bit_20 = (
        "1" if op in ["MOV", "CMP", "TST", "TEQ"] else "0"
    )  # Flags para ciertas operaciones
    rn_bin = format(int(rn[1:]), "04b")
    rd_bin = format(int(rd[1:]), "04b")
    imm_bin = (
        format(int(operand2.strip("#")), "012b")
        if bit_25 == "1"
        else format(int(operand2[1:]), "012b")
    )

    # Construir el binario completo
    binary = f"{condition}{op_code}{function}{bit_20}{rn_bin}{rd_bin}{imm_bin}"

    # Convertir a hexadecimal
    hex_output = f"{int(binary, 2):08X}"

    return binary, hex_output


instructions = ["MOV R1, #23"]


for instruction in instructions:
    binary, hex_output = arm_to_bin_hex(instruction)
    print("// " + instruction)
    print("// " + binary)
    print(hex_output)
