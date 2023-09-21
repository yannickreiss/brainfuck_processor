#ifndef ANALYZER_H
#define ANALYZER_H

#include <stdio.h>
#include <stdlib.h>

/**
 *	@name analyze
 *	@return int
 *	@brief Analyze the tokens syntax. Return -1 on error and 1 on warning, 0 else.
 *
 *	@param char* tokens:	analyze_tokens
 */
int analyze (char* tokens);

#endif//ANALYZER_H
