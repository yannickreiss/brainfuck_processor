#include <stdlib.h>

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

    return rv;
}
