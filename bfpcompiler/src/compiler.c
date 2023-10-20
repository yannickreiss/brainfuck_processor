#include <stdlib.h>
#include <stdio.h>

#include "../include/analyzer.h"
#include "../include/assembling.h"
#include "../include/tokenizer.h"

/**
 *	@name main
 *	@return int
 *  @brief Parse command line options and run compilation.
 *
 *	@param int argc
 *	@param char** argv
 */
int main (int argc, char** argv) {
    int rv = EXIT_SUCCESS;

    char* filename_compiled = "brainfuck.bin";

    /* Parse arguments */
    char* filename;
    char* device = "FPGA";

    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-' && ((i+1) < argc)) {
            switch (argv[i][1]) {
                case 'o': if (argv[i+1]) filename_compiled = argv[i+1];break;
                case 'd': if (argv[i+1]) device = argv[i+1];break;
                default: printf("ERROR: unknown argument: %c\n", argv[i][1]);exit(EXIT_FAILURE);
            }
            i++;
        } else {
            filename = argv[i];
            break;
        }
    }

    /* read file into buffer */
    FILE* fd = 0; /* File descriptor */
    fd = fopen(filename, "r");

    /* make sure the file was loaded successfully */
    if (!fd) {
        perror("ERROR: Could not open file!");
        exit(EXIT_FAILURE);
    }

    /* create buffer and read file */
    size_t chunk_size = 512;
    char* buffer;

    /* Allocate memory for buffer */
    buffer = malloc(sizeof(char) * chunk_size);
    if (!buffer) {
        /* Error */
        perror("malloc error on memory allocation of: buffer");
        exit(EXIT_FAILURE);
    }

    size_t total_size;
    size_t bytes_read;
    size_t buffer_size = chunk_size;

    for (;( bytes_read = fread(buffer + total_size, 1, chunk_size, fd) ) > 0;) {
        total_size += bytes_read;

        if ( total_size + chunk_size > buffer_size ) {
            buffer_size += chunk_size;
            buffer = (char*)realloc(buffer, buffer_size);
            if (!buffer) {
                perror("ERROR: Could not reallocate file buffer!");
                exit(EXIT_FAILURE);
         }
        }
    }

    fclose(fd);

    /* extract tokens from buffer */
    char* tokens;
    /* Allocate memory for tokens */
    tokens = (char*)malloc(sizeof(char) * 1);
    if (!tokens) {
        /* Error */
        perror("malloc error on memory allocation of: tokens");
        exit(EXIT_FAILURE);
    }

    int token_count = extractTokens(buffer, tokens);
    if (!token_count) {
        (void)printf("WARNING: The program is empty!\n");
    }

    /* end of lifetime for buffer */
    free( buffer );

    /* Analyze the code for errors and warnings. */
    int scan_result = analyze(tokens, device);
    /* Exit if analyzer detects errors. */
    if (scan_result < 0) {
        exit(scan_result);
    }

    /* Translate into binary */
    char* binary = assemble(device, tokens);
    if (binary <= 0) {
        (void)printf("ERROR: Error during assembling step!\n");
        exit(EXIT_FAILURE);
    }
    free(tokens);

    /* Write to file. */
    FILE* fout = 0; /* File descriptor */
    fout = fopen(filename_compiled, "w");

    if (!fout) {
        (void)printf("ERROR: Could not open file %s!\n", filename_compiled);
        exit(EXIT_FAILURE);
    }

    if (fprintf(fout, "%s", binary) < 0) {
        (void)printf("ERROR: Could not write to file %s!\n", filename_compiled);
        exit(EXIT_FAILURE);
    }

    fclose(fout);

    return rv;
}
