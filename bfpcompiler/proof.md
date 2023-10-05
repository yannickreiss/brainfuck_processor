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

The 8 operators of brainfuck can be divided into two different groups:

- < > + - , .
- [  ]

The operators of the first group can be used

- in any order
- with any amount

Following those conditions, there is no need for a syntax check, as every order is a valid program.

This is different with the second group, which holds the loop operators.
Those need to

- be included in a certain order: [  ]
- be included in the code with the same amount: $w_[ = w_]$

The code must be checked for the right amount and order of loop operators.
This is done by using the following code:
```c
for (char* cursor = token; *cursor; cursor++) {

    /* Analyze form */
    if (*cursor == '[') {
        rv += 1;
    } else if (*cursor == ']') {
        rv -= 1;
    }

    /* Check value for errors. */
    if (rv < 0) {
        (void)printf("ERROR!\n");
        rv = EXIT_FAILURE;
        break;
    }

    /* check for nested loops */
    if (rv > 1) {
        (void)printf("WARNING!\n");
    }
}

if (rv > 0) {
    (void)printf("ERROR!\n");
    rv = EXIT_FAILURE;
}
```

The value of rv is checked for the following conditions:

|Condition|Reaction|Description|
|---------|--------|-----------|
| $<0$    |ERROR   |A closing bracket is ending a non-existing loop. There is no address to jump back to.|
| $>2$    |WARNING |A nested bracket is opened. Although this is not wrong for brainfuck, my circuit does currently not support this.|
| $>0$    |ERROR   |This is checked after the loop. If the value of rv is greater than zero, a bracket was not closed.|

The last check maybe could be handled as warning, because the program can be run in a loop, even if it would never end.

By doing this check on the given program, it's safe to assume, that every program, that is accepted by the compiler, can be run.

## The compiled binaries are working the same way as the provided code.
