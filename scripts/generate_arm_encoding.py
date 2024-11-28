from keystone import Ks, KS_ARCH_ARM, KS_MODE_ARM

# Keystone engine initialization for ARM architecture
ks = Ks(KS_ARCH_ARM, KS_MODE_ARM)


lengths = [4, 2, 1, 4, 1, 4, 4, 12]


def format_bytes(s):
    return " ".join(
        s[sum(lengths[:i]) : sum(lengths[: i + 1])] for i in range(len(lengths))
    )


def assemble_instructions(instructions):
    """Assemble a list of instructions into hexadecimal."""
    # Join all instructions into a single string with line breaks
    code = "\n".join(instructions)
    encoding, _ = ks.asm(code)

    if encoding is None:
        raise ValueError("Failed to assemble the instructions.")

    # Split the encoding into 4-byte words (ARM instructions are 32-bit)
    hex_encodings = [
        "".join(f"{byte:02X}" for byte in encoding[i : i + 4])
        for i in range(0, len(encoding), 4)
    ]
    base_encodings = [
        format_bytes("".join(f"{byte:08b}" for byte in encoding[i : i + 4]))
        for i in range(0, len(encoding), 4)
    ]

    return hex_encodings, base_encodings


def generate_encodings(instructions, filename):
    """Generate hexadecimal encodings for a list of ARMv7 instructions."""
    hex_encodings, base_encodings = assemble_instructions(instructions)
    with open(filename, "w") as file:
        for instr, hex_encoding, base_encoding in zip(
            instructions, hex_encodings, base_encodings
        ):
            file.write(f"// {instr}\n")
            file.write(f"// {base_encoding}\n")
            file.write(hex_encoding + "\n\n")

            print(f"Instruction: {instr} -> {hex_encoding}")


# Instruction function examples
def add(rd, rn, operand2, shift=None):
    if isinstance(operand2, int):
        return f"add {rd}, {rn}, #{operand2}"
    elif shift:
        return f"add {rd}, {rn}, {operand2}, {shift}"
    else:
        return f"add {rd}, {rn}, {operand2}"


def sub(rd, rn, operand2, shift=None):
    if isinstance(operand2, int):
        return f"sub {rd}, {rn}, #{operand2}"
    elif shift:
        return f"sub {rd}, {rn}, {operand2}, {shift}"
    else:
        return f"sub {rd}, {rn}, {operand2}"


def mov(rd, operand):
    if isinstance(operand, str):
        return f"mov {rd}, {operand}"  # Register move
    else:
        return f"mov {rd}, #{operand}"  # Immediate value move


def cmn(rn, operand2):
    if isinstance(operand2, int):
        return f"cmn {rn}, #{operand2}"
    else:
        return f"cmn {rn}, {operand2}"


def mul(rd, rn, rm):
    return f"mul {rd}, {rn}, {rm}"


def lsl(rd, rm, shift):
    return f"lsl {rd}, {rm}, #{shift}"


def and_instr(rd, rn, operand2):
    if isinstance(operand2, int):
        return f"and {rd}, {rn}, #{operand2}"
    else:
        return f"and {rd}, {rn}, {operand2}"


def eor(rd, rn, operand2):
    if isinstance(operand2, int):
        return f"eor {rd}, {rn}, #{operand2}"
    else:
        return f"eor {rd}, {rn}, {operand2}"


def branch(label, condition=None):
    if condition:
        return f"b{condition} {label}"
    else:
        return f"b {label}"


# Example usage
instructions = [
    mov("r0", 10),
    sub("r0", "r0", 1),
    add("r1", "r0", 6),
    mov("r2", 2),
    mul("r3", "r1", "r2"),
    lsl("r2", "r2", 2),
    and_instr("r5", "r2", "r2"),
    eor("r4", "r0", "r2"),
    cmn("r0", 1),
    "label:",
    branch("label", condition="eq"),
    "nop",  # No operation (fills space, if needed)
]

# Generate encodings and save to a file
generate_encodings(instructions, "output.hex")
