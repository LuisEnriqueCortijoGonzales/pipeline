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
        "B": "010000",
        "BL": "010001",
        "CBZ": "010010",
        "CBNZ": "010011"
    }

    # Separar la instrucción en partes
    parts = instruction.split()
    op = parts[0]

    # Codificación por defecto
    condition = "1110"
    op_code = encoding_dict[op][:2]
    encoding = encoding_dict[op]

    # Modificaciones para instrucciones de salto
    if op in ["B", "BL", "CBZ", "CBNZ"]:
        imm24 = format(int(parts[1]), '024b')  # Convertir IMM24 a binario de 24 bits
        binary = f"{condition}{op_code}1{encoding[2:]}{imm24}"
    else:
        # Resto del código para otras instrucciones
        rd = parts[1].strip(',')
        rn = parts[2].strip(',') if len(parts) > 3 else "R0"
        operand2 = parts[3] if len(parts) > 3 else parts[2]
        bit_25 = "1" if operand2.startswith('#') else "0"
        function = f"{bit_25}{encoding[2:]}"
        bit_20 = "1" if op in ["MOV", "CMP", "TST", "TEQ"] else "0"

        if op in ["MLA", "MLS"]:
            ra = parts[3].strip(',')
            rm = parts[4]
            ra_bin = format(int(ra[1:]), '04b')
            rm_bin = format(int(rm[1:]), '04b')
            rn_bin = format(int(rn[1:]), '04b')
            rd_bin = format(int(rd[1:]), '04b')
            binary = f"{condition}{op_code}{function}{bit_20}{rn_bin}{rd_bin}{ra_bin}0000{rm_bin}"
        elif op in ["UMULL", "UMLAL", "SMULL", "SMLAL"]:
            rd_hi = parts[1].strip(',')
            rd_lo = parts[2].strip(',')
            rn = parts[3].strip(',')
            rm = parts[4]
            rd_hi_bin = format(int(rd_hi[1:]), '04b')
            rd_lo_bin = format(int(rd_lo[1:]), '04b')
            rn_bin = format(int(rn[1:]), '04b')
            rm_bin = format(int(rm[1:]), '04b')
            binary = f"{condition}{op_code}{function}{bit_20}{rn_bin}{rd_hi_bin}{rd_lo_bin}0000{rm_bin}"
        else:
            rn_bin = format(int(rn[1:]), '04b')
            rd_bin = format(int(rd[1:]), '04b')
            if bit_25 == "1":
                imm_value = int(operand2.strip('#'), 16) if operand2.startswith('#0x') else int(operand2.strip('#'))
                imm_bin = format(imm_value, '012b')
            else:
                imm_bin = format(int(operand2[1:].strip(',')), '012b')
            binary = f"{condition}{op_code}{function}{bit_20}{rn_bin}{rd_bin}{imm_bin}"

    # Convertir a hexadecimal
    hex_output = f"{int(binary, 2):08X}"

    return binary, hex_output

def process_instructions(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            instruction = line.strip()
            if instruction:  # Asegurarse de que la línea no esté vacía
                binary, hex_output = arm_to_bin_hex(instruction)
                outfile.write(f"// {instruction}\n")
                outfile.write(f"// {binary}\n")
                outfile.write(f"{hex_output}\n\n")

# Ejemplo de uso
input_file = 'assets/instrucciones.txt'
output_file = 'assets/mem.dat'
process_instructions(input_file, output_file)