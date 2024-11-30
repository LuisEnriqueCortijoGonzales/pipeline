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
    encoding, count = ks.asm()

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


instructions = b"MOV R0, #10"

# Generate encodings and save to a file
generate_encodings(instructions, "output.hex")
