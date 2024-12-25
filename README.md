# HAL9000 Emulator

This project implements an emulator for the HAL9000, a simple hypothetical 16-bit machine. The emulator was developed as part of the **Computer Structure I** course and focuses on emulating the fetch, decode, and execute phases of a Von Neumann machine. It was implemented in assembly language for the Motorola 68000 microprocessor.

## 📖 Description

The HAL9000 machine features:
- **Registers**:
  - `T0`, `T1`: Interface with memory and used for ALU operations.
  - `X2`, `X3`, `X4`, `X5`, `X6`, `X7`: General-purpose registers for ALU operations.
- **16-bit Instruction Set**: A total of 15 instructions, each with specific encoding, actions, and flags.

The emulator is written entirely in Motorola 68000 assembly language. The program follows the standard instruction cycle:
1. **Fetch**: Load the current instruction from memory.
2. **Decode**: Analyze the instruction bits to identify the operation.
3. **Execute**: Perform the operation and update registers or flags as needed.

## 💡 Features

- **Instruction Decoding**: Implements a decision tree to decode 15 instructions.
- **Full Emulation**: Emulates instruction execution, memory management, and register operations.
- **Flag Updates**: Tracks and updates the Z (zero), N (negative), and C (carry) flags.
- **Memory Representation**: Stores instructions and data in a simulated memory space.

## 🗂 Project Structure

- **Registers**:
  - `EIR`: Instruction register.
  - `EPC`: Program counter.
  - `ET0`, `ET1`, `EX2`–`EX7`: Data and general-purpose registers.
  - `ESR`: Status register for flags (C, N, Z).

- **Memory (`EMEM`)**:
  - A vector of 16-bit words used to store the program instructions and data.

- **Instruction Set**:
  - Examples:
    - `ELOA`: Load a value from memory into `T0` or `T1`.
    - `ESTO`: Store a value from `T0` or `T1` into memory.
    - `EADD`, `ESUB`, `EAND`: Arithmetic and logical operations.
    - `EGOI`, `EGOZ`, `EGON`: Jump instructions.

- **Subroutines**:
  - `VALOR_M_OUT`, `VALOR_K_OUT`, `INSERTAR_A`: Extract and process instruction fields.
  - `ACTU_FLAG_Z`, `ACTU_FLAG_N`, `ACTU_FLAG_C`: Update flags after operations.

## 🚀 How It Works

1. **Initialization**:
   - The memory (`EMEM`) is preloaded with instructions and data.
   - Registers are initialized to zero.

2. **Fetch Phase**:
   - Load the next instruction from memory based on the program counter (`EPC`).
   - Increment the `EPC` to point to the next instruction.

3. **Decode Phase**:
   - Analyze the instruction's bit pattern using a decision tree.
   - Identify the operation type and extract relevant fields (e.g., source/destination registers).

4. **Execute Phase**:
   - Perform the operation based on the instruction.
   - Update memory, registers, and flags as necessary.

5. **Repeat**:
   - The cycle continues until the `EEXIT` instruction is encountered.

## 🔧 Usage

1. **Load the Code**:
   - Write the program to memory (`EMEM`) in the emulator.

2. **Run the Emulator**:
   - Execute the code step-by-step, observing register and memory changes.

3. **Debugging**:
   - Use test programs to verify correct functionality of instructions.

## 📝 Author

- **Gaizka Medina Gordo**  
