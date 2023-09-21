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

    /* check for right amount of cl arguments (1 filename at the moment) */
    if (argc != 2) {
        exit(EXIT_FAILURE);
    }

    /* Parse arguments */
    char* filename = argv[1];


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
    int scan_result = analyze(tokens);
    if (scan_result < 0) {
        exit(scan_result);
    }

    /* Just print the tokens as example. */
    for (char* index = tokens; *index; index++) {
        (void)printf("%c", *index);
    }
    (void)printf("\n");

    return rv;
}
