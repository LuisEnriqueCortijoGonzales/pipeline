from enum import Enum


class INSTR_TYPE(Enum):
    DATA_PROCESSING = 0
    MEMORY = 1
    BRANCH = 2


# Function to format binary representation
data_lengths = [4, 2, 1, 4, 1, 4, 4, 12]
branch_lengths = [4, 2, 1, 4, 1, 4, 4, 12]
memory_lengths = [4, 2, 6, 4, 4, 12]

current_instr_type = INSTR_TYPE.DATA_PROCESSING


def format_bytes(s):
    lengths = (
        data_lengths
        if current_instr_type == INSTR_TYPE.DATA_PROCESSING
        else (
            branch_lengths
            if current_instr_type == INSTR_TYPE.BRANCH
            else memory_lengths
        )
    )

    return " ".join(
        s[sum(lengths[:i]) : sum(lengths[: i + 1])] for i in range(len(lengths))
    )


def process_file_in_place(file_path):
    # Read the file content
    with open(file_path, "r") as f:
        lines = f.readlines()

    processed_lines = []
    for line in lines:
        stripped_line = line.strip()
        # Check if line is not a comment and contains a 32-bit hexadecimal
        if stripped_line and not stripped_line.startswith("//"):
            try:
                # Validate if the line is a valid 32-bit hex
                int(stripped_line, 16)
                binary_representation = format_bytes(
                    bin(int(stripped_line, 16))[2:].zfill(32)
                )
                # Add the comment with the binary representation above the line
                processed_lines.append(f"// {binary_representation}\n")
            except ValueError:
                # If it's not a valid 32-bit hex, keep the line as is
                pass
        # Append the original line
        processed_lines.append(line)
        processed_lines.append("\n")

    # Write back to the same file
    with open(file_path, "w") as f:
        f.writelines(processed_lines)


# Specify the file path
file_path = "memfile.shift.dat"

process_file_in_place(file_path)
