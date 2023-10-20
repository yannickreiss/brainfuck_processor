#include "../include/analyzer.h"

/**
 *	@name analyze
 *	@return int
 *  @brief Check for errors and warnings.
 *
 *	@param char* token
 *	@param char* device
 */
int analyze (char* token, char* device) {
    int rv = 0;
    int position = 0;

    for (char* cursor = token; *cursor; cursor++) {

        /* Analyze form */
        if (*cursor == '[') {
            rv += 1;
        } else if (*cursor == ']') {
            rv -= 1;
        }

        /* Check value for errors. */
        if (rv < 0) {
            (void)printf("Error on token %d\n", position);
            perror("ERROR: Closing bracket without opening bracket!");
            rv = EXIT_FAILURE;
            break;
        }

        /* check for nested loops in case of using the logisim model */
        if (rv > 1 && !strcmp(device, "logisim")) {
            (void)printf("Warning on token %d\n", position);
            (void)printf("WARNING: Nested loops are not supported on all versions of the target device!\n");
        }
    }

    if (rv > 0) {
        (void)printf("There are %d loops without end!\n", rv);
        perror("ERROR: Loop not closed!");
        rv = EXIT_FAILURE;
    }

    return rv;
}
