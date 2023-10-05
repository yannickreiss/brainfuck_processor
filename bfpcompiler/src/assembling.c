#include "../include/assembling.h"

/**
 *	@name intoVHDL
 *	@return static char*
 *  @brief Return binary as VHDL code.
 *
 *	@param char* tokens
 */
static char* intoVHDL (char* tokens) {
    char* binary = 0;

    /* The maximum size would be 256 instructions wide.
     *  'b"000",' => one instruction has the length 7 which adds up to 256 * 7 = 1792 at max.
     *  The declaration is wrapped in (code); which adds another 3 to the length.
     *  At the end, the remaining registers are set to zero with 'others=>"000"', so another 13 characters are added:
     *  Finally, the string must be terminated by '\0' (+1).
     *  The buffer size is 1792 + 3 + 13 + 1 = 1809.
     */
    int binary_size = 1809;
    int pos = 0; /* cursor to navigate the buffer. */

    /* Allocate memory for binary */
    binary = (char*)malloc(sizeof(char) * binary_size);
    if (!binary) {
        /* Error */
        perror("malloc error on memory allocation of: binary");
        exit(EXIT_FAILURE);
    }

    /* insert first bracket */
    binary[pos++] = '(';

    /* insert tokens */
    for (int token = 0; tokens[token]; token++) {

        /* check if maximum amount of 256 instructions is violated */
        if (token > 256) {
            (void)printf("ERROR: More instructions than possible!\n");
            exit(EXIT_FAILURE);
        }

        binary[pos++] = 'b';
        binary[pos++] = '"';

        switch (tokens[token]) {
            case '>':
                binary[pos++] = '0';
                binary[pos++] = '0';
                binary[pos++] = '0';
                break;
            case '<':
                binary[pos++] = '0';
                binary[pos++] = '0';
                binary[pos++] = '1';
                break;
            case '+':
                binary[pos++] = '0';
                binary[pos++] = '1';
                binary[pos++] = '0';
                break;
            case '-':
                binary[pos++] = '0';
                binary[pos++] = '1';
                binary[pos++] = '1';
                break;
            case ',':
                binary[pos++] = '1';
                binary[pos++] = '0';
                binary[pos++] = '0';
                break;
            case '.':
                binary[pos++] = '1';
                binary[pos++] = '0';
                binary[pos++] = '1';
                break;
            case '[':
                binary[pos++] = '1';
                binary[pos++] = '1';
                binary[pos++] = '0';
                break;
            case ']':
                binary[pos++] = '1';
                binary[pos++] = '1';
                binary[pos++] = '1';
                break;
            default:
                (void)printf("ERROR: Unknown token %c (%d)!\n", token, token);
                exit(EXIT_FAILURE);
        }

        binary[pos++] = '"';
        binary[pos++] = ',';

    }

    /* This is the closing term. */
    binary[pos++] = 'o';
    binary[pos++] = 't';
    binary[pos++] = 'h';
    binary[pos++] = 'e';
    binary[pos++] = 'r';
    binary[pos++] = 's';
    binary[pos++] = '=';
    binary[pos++] = '>';
    binary[pos++] = '"';
    binary[pos++] = '0';
    binary[pos++] = '0';
    binary[pos++] = '0';
    binary[pos++] = '"';

    /* Close initial memory. */
    binary[pos++] = ')';
    binary[pos++] = ';';

    /* Terminate string */
    binary[pos++] = 0;

    return binary;
}


/**
 *	@name intoLogisim
 *	@return static char*
 *  @brief Return binary as logisim file.
 *
 *	@param char* tokens
 */
static char* intoLogisim (char* tokens) {
    char* binary = 0;

    /* Using logisim with the current memory space (256x4) has the fixed size of 533 bytes. */
    int filesize = 533;
    int pos = 0; /* used to navigate around binary */

    /* Allocate memory for binary */
    binary = (char*)malloc(sizeof(char) * filesize);
    if (!binary) {
        /* Error */
        perror("malloc error on memory allocation of: binary");
        exit(EXIT_FAILURE);
    }

    char version_number[] = "v3.0 hex words plain";
    for (int i = 0; i < 20; i++) {
        binary[i] = version_number[i];
    }
    pos = 20; /* position after loop */

    binary[pos++] = '\n';

    int pos_space = pos + 1; /* save the index to fill with spaces here */

    /* Loop through tokens and add matching code to binary. */
    for (char* cursor = tokens; *cursor; cursor++) {

        /* Switch case holds all operands. */
        switch (*cursor) {
            case '>': binary[pos] = '0';break;
            case '<': binary[pos] = '1';break;
            case '+': binary[pos] = '2';break;
            case '-': binary[pos] = '3';break;
            case ',': binary[pos] = '4';break;
            case '.': binary[pos] = '5';break;
            case '[': binary[pos] = '6';break;
            case ']': binary[pos] = '7';break;
            default: return (char*)EXIT_FAILURE;
        }

        /* every second position is space or newline */
        pos += 2;
    }

    /* fill remaining instruction space with > operations */
    for (; pos < filesize; pos += 2) {
        binary[pos] = '0';
    }

    /* reset position to the first space and start filling up */
    pos = pos_space;
    for (; pos < filesize; pos += 2) {
        /* Calculate whether to use space or newline. */
        if ((pos - 20) % 64 == 0) {
            binary[pos] = '\n';
        } else {
            binary[pos] = ' ';
        }
    }

    /* Finally, end the string. */
    binary[filesize-1] = '\n';

    return binary;
}

/**
 *	@name assemble
 *	@return char*
 *  @brief Assemble tokens into binary for chosen device.
 *
 *	@param char* device
 *	@param char* tokens
 */
char* assemble (char* device, char* tokens) {
    char* rv = 0;

    /* supported devices are hardcoded here. */
    if (!strcmp(device, "logisim")) {
        rv = intoLogisim(tokens);
    } else if (!strcmp(device, "FPGA")) {
        rv = intoVHDL(tokens);
    } else {
        (void)printf("ERROR: Chosen device %s does not exist!\n", device);
        rv = (char*)EXIT_FAILURE;
    }

    return rv;
}
