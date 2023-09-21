#ifndef TOKENIZER_H
#define TOKENIZER_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/**
 *	@name extractTokens
 *	@return int
 *	@brief Extract only allowed characters from buffer;
 *
 *	@param char* buffer:	extractTokens_buffer
 *	@param char* tokens:	extractTokens_tokens
 */
int extractTokens (char* buffer, char* tokens);

#endif//TOKENIZER_H
