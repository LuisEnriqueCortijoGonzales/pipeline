def arm_to_bin_hex(instruction):
    # Diccionario de codificaciones para las instrucciones
    encoding_dict = {
        "ADD": "100000",
        "ADC": "100001",
        "QADD": "100010",
        "SUB": "100011",
        "SUBS": "100011",
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
        "B": "00",
        "BL": "01",
        "CBZ": "10",
        "CBNZ": "11",
        "LDR": "00",
        "STR": "00",
        "STMIA": "00",
        "LDMDB": "00",
        "STMDB": "00",
        "LDMIA": "00"
    }

    # Diccionario de condiciones
    condition_dict = {
        "EQ": "0000",  # Equal
        "NE": "0001",  # Not equal
        "CS": "0010",  # Carry set
        "CC": "0011",  # Carry clear
        "MI": "0100",  # Minus
        "PL": "0101",  # Plus
        "VS": "0110",  # Overflow
        "VC": "0111",  # No overflow
        "HI": "1000",  # Unsigned higher
        "LS": "1001",  # Unsigned lower or same
        "GE": "1010",  # Signed greater than or equal
        "LT": "1011",  # Signed less than
        "GT": "1100",  # Signed greater than
        "LE": "1101",  # Signed less than or equal
        "AL": "1110",  # Always (default)
        "NV": "1111"   # Never
    }

    # Separar la instrucción en partes
    parts = instruction.replace(',', '').replace('[', '').replace(']', '').split()
    op = parts[0].upper()

    # Determinar la condición
    condition = "1110"  # Valor por defecto
    if len(op) > 2 and op[-2:] in condition_dict:
        condition = condition_dict[op[-2:]]
        op = op[:-2]  # Remover la condición del opcode

    # Modificaciones para instrucciones aritméticas con 'S'
    if op.endswith('S') and op[:-1] in encoding_dict:
        op = op[:-1]  # Remover 'S' para obtener el opcode base
        bit_20 = "1"  # Indicar que se actualizan los flags
    else:
        bit_20 = "0"

    op_code = encoding_dict[op][:2]
    encoding = encoding_dict[op]

    if op in ["LDR", "STR"]:
        rd = parts[1]
        rn = parts[2]
        rm = parts[3]
        
        I = "0"  # Registro indexado
        P = "1"  # Pre-indexado
        U = "1"  # Incremento
        B = "0"  # Palabras completas
        W = "0"  # No escribir en el registro base
        L = "1" if op == "LDR" else "0"  # Cargar o almacenar

        if '!' in instruction:
            W = "1"  # Escribir en el registro base

        # Caso especial para LDR/STR con desplazamiento y shifting
        if len(parts) > 4 and parts[4].upper() in ["LSL", "LSR", "ASR", "ROR"]:
            shift_type = parts[4].upper()
            shift_amount = int(parts[5].strip('#'))
            
            # Aplicar el desplazamiento lógico
            if shift_type == "LSL":
                shifted_amount = shift_amount << 1
            elif shift_type == "LSR":
                shifted_amount = shift_amount >> 1
            elif shift_type == "ASR":
                shifted_amount = shift_amount >> 1  # ASR es similar a LSR para este propósito
            elif shift_type == "ROR":
                shifted_amount = (shift_amount >> 1) | ((shift_amount & 1) << 5)  # Rotar a la derecha

            shift_type_bin = {
                "LSL": "00",
                "LSR": "01",
                "ASR": "10",
                "ROR": "11"
            }[shift_type]
            shift_amount_bin = format(shifted_amount, '06b')
            I = "1"  # Indica que se usa un registro para el desplazamiento
        else:
            shift_type_bin = "00"
            shift_amount_bin = "000000"

        rn_bin = format(int(rn[1:]), '04b')
        rd_bin = format(int(rd[1:]), '04b')
        rm_bin = format(int(rm[1:]), '04b')

        binary = f"{condition}{op_code}{I}{P}{U}{B}{W}{L}{rn_bin}{rd_bin}{shift_amount_bin}{shift_type_bin}{rm_bin}"
    
    elif op in ["STMIA", "LDMDB", "STMDB", "LDMIA"]:
        rn = parts[1].strip('!,')
        registers = parts[2].strip('{}').split('-')
        start_reg = int(registers[0][1:])
        end_reg = int(registers[1][1:])
        reg_list = sum([1 << i for i in range(start_reg, end_reg + 1)])
        reg_list_bin = format(reg_list, '016b')

        P = "1" if op in ["STMIA", "LDMIA"] else "0"
        U = "1" if op in ["STMIA", "LDMIA"] else "0"
        W = "1"
        L = "1" if op in ["LDMDB", "LDMIA"] else "0"

        rn_bin = format(int(rn[1:]), '04b')

        binary = f"{condition}{op_code}100{P}{U}0{W}{L}{rn_bin}0000{reg_list_bin}"

    # Modificaciones para instrucciones de salto
    elif op in ["B", "BL", "CBZ", "CBNZ"]:
        op_code = "01"
        imm_value = int(parts[1], 16) if parts[1].startswith('0x') else int(parts[1])
        if imm_value < 0:
            imm24 = format((1 << 24) + imm_value, '024b')  # Convertir a complemento a dos
        else:
            imm24 = format(imm_value, '024b')
        binary = f"{condition}{op_code}{encoding}{imm24}"
    else:
        # Resto del código para otras instrucciones
        rd = parts[1].strip(',')
        rn = parts[2].strip(',') if len(parts) > 3 else "R0"
        operand2 = parts[3] if len(parts) > 3 else parts[2]
        bit_25 = "1" if operand2.startswith('#') else "0"
        function = f"{bit_25}{encoding[2:]}"

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
            binary = f"{condition}{op_code}{function}{bit_20}{rn_bin}{rd_lo_bin}{rd_hi_bin}0000{rm_bin}"
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
    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        for line in infile:
            instruction = line.strip()
            if instruction:  # Asegurarse de que la línea no esté vacía
                binary, hex_output = arm_to_bin_hex(instruction)
                outfile.write(f"// {instruction}\n")
                outfile.write(f"// {binary}\n")
                outfile.write(f"{hex_output}\n\n")


# Ejemplo de uso
input_file = "assets/fibo.txt"
output_file = "assets/fibo.dat"
process_instructions(input_file, output_file)
