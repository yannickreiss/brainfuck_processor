# Proof that the compiler is working correctly

## The compiler is memory safe for all arguments and files.

The proof is partly inductive and therefore divided in multiple parts.

### Token extraction

### Code Analysis

### Assembling

### Compiling program

The memory safety is endangered on two ways.

1. Addressing unallocated memory in arrays, or based on pointers
2. Copying a pointer and change the values

#### Addressing unallocated memory

The first way is only possible in the parsing step of the command line arguments.

They are parsed in the following loop.

```c
for (int i = 1; i < argc; i++) {
    if (argv[i][0] == '-' && ((i+1) < argc)) {
        switch (argv[i][1]) {
            case 'o': filename_compiled = argv[i+1];break;
            case 'd': device = argv[i+1];break;
            default: printf("ERROR: unknown argument: %c\n", argv[i][1]);exit(EXIT_FAILURE);
        }
        i++;
    } else {
        filename = argv[i];
        break;
    }
}
```

The allowed range of the index is $(0, argc-1)$.
Note: The values $0$ and $argc-1$ are included.
In the loop, argv is indexed by i under the condition $0 < i < argc$ and $i+1$ with the additional condition $(i+1) < argc$.

The variable i is only incremented starting at 1.
This means, the lower border is always right.
The variable can't be raised higher than $argc-1$,
so the upper border can't be reached by i itself.
To avoid accessing undefined memory with $i+1$,
the value of $i+1$ is compared to argc and can't violate memory access.
Through this conditional constraints, the loop can be considered memory safe.

#### Changing the values of a cell accessed by multiple pointers

To identify memory leaks through assignment of the same address to multiple pointers, the manually allocated variables in the code are examined for such occasions and then for resulting errors:

|Variable name|Mutability|
|---|---|
|argv*||
|filename_compiled|reassigned, values immutable|
|filename|reassigned, values immutable|
|device|reassigned, values immutable|
|fd|reassigned, values immutable|
|buffer|expanded, writing values|
|tokens|reassigned, values immutable|
|binary||
|fout|reassigned, values immutable|

As suggested by the table above, the most pointers are just reassigned to a new space.
Even if connected to each other, none of them is changing the values in the addressed memory cells.
Only the buffer is changed, when filled with the content from the file with name *filename*.
As the buffer is not interfering with any other pointer, it can be considered memory safe.

This means, the main-function, and therefore the entire program, is memory safe if, as shown earlier, the argument-parsing loop and the functions

- extractTokens
- analyze
- assemble

are implemented memory safe.

## Every program, which is accepted by the compiler without error is working on the processor.

## The compiled binaries are working the same way as the provided code.

## The compiler is detecting any wrong argument or code.