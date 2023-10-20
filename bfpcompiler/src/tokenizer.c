#include "../include/tokenizer.h"

static char operators[] = {'>', '<', '+', '-', ',', '.', '[', ']'};

/**
 *	@name extractTokens
 *	@return int
 *  @brief Extract only allowed tokens from buffer.
 *
 *	@param char* buffer
 *	@param char* tokens
 */
int extractTokens (char* buffer, char* tokens) {
    int rv = 0;

    size_t token_size = 1;
    size_t tokens_found = 0;

    for (char* cursor = buffer; *cursor; cursor++) {

        /* check tokens size and reallocate if necessary */
        if (tokens_found >= token_size) {
            token_size *= 2;
            tokens = (char*)realloc(tokens, token_size);
            if (!tokens) {
                perror("ERROR: Could not expand token array!");
                exit(-1);
            }
        }

        /* check if current symbol is a token */
        for (int i = 0; i < 8; i++) {
            if (*cursor == operators[i]) {
                tokens[tokens_found] = *cursor;
                tokens_found++;
            }
        }

    }

    /* Terminate the array using a null character */
    tokens[tokens_found] = 0; /* same as \0 */

    rv = tokens_found;

    return rv;
}
