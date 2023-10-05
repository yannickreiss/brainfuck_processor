# Implementation of brainfuck as a processor

## The processor

### VHDL / FPGA

#### Instruction vs. clock cycle

Every instruction cycle is lasting two clock cycles and is divided into two phases:

1. Execution
2. Write back

During **execution**, the alu computes the updated pointer position and cell value, or assigns the new values from and to the pins.
The branch disables the program counter during this cycle and executes the first step of the branch commands [ and ].

During the second cycle, the **write back** cycle, the registers are updated, the branch restores the stack and reenables the program counter.
When processing an branch-instruction, the jump signal is also set and the stack is updated.

#### Brainfuck logic

The brainfuck logic consists of three parts

1. An array with ~60k byte-sized registers as required by the brainfuck language (actually, twice the required cells)
2. A pointer with the size of two bytes to address this array, also required by brainfuck
3. The ALU computing the follwing instructions: ><+-,.

#### Instruction set and memory

The instruction memory can hold up to 256 instructions, which are currently hardcoded in the instruction memory source.

The instructions are direct translations of the 8 brainfuck operands:

| Brainfuck | Binary |
| --------- | ------ |
| >         | 000    |
| <         | 001    |
| +         | 010    |
| -         | 011    |
| ,         | 100    |
| .         | 101    |
| [         | 110    |
| ]         | 111    |

Every instruction is calculated in two clock cycles, or one instruction cycle.

-----------------------------------------------------------------------------------------------

## The compiler

The compiler located in the directory *bfpcompiler* can be used to create the machine code for the different destinations.

### Building the compiler

Assuming the root directory as current location, use the follwing commands to build the executable:

```shell
cd bfpcompiler
make
```

The executable will be located in the directory *bfpcompiler*.

### Usage

The executable can be called as

```shell
./bfc [-o filename] [-d device="logisim"] filename.bf
```

### Syntax check

The compiler is proofen to detect any error in an entered program.
This is fairly easy, as only loop errors (wrong order or count of brackets) could make a program invalid.

The compiler reacts to the following problems:

| Problem                                 | Reaction |
| --------------------------------------- | -------- |
| Closing bracket outside loop            | ERROR    |
| Loop not closed at the end of a program | ERROR    |
| Loop opened inside another loop         | WARNING  |

The last warning occurs, because the logisim implementation of the processor is not capable of processing nested loops.
It can be safely ignored on other devices.

### Code is correct by proof

The proof is located at *bfpcompiler/proof.md* and will be expanded on the whole compiler.
The proofs cover three claims:

- The compiler is working absolutely memory safe
- Every program accepted by the compiler is a valid brainfuck program
- The compiled program is working in the same way, as the entered brainfuck code