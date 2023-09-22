#ifndef ASSEMBLING_H
#define ASSEMBLING_H

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/**
 *	@name assemble
 *	@return char*
 *	@brief Assemble into binary for chosen device. Returns pointer on success, zero on error.
 *
 *	@param char* device:	assemble_device
 *	@param char* tokens:	assemble_tokens
 */
char* assemble (char* device, char* tokens);

#endif//ASSEMBLING_H
