#ifndef _flags_H
#define _flags_H

typedef enum {
	FACTOR_NONE		= 0,
	FACTOR_HIDDEN		= 1,
	FACTOR_SHORTCUT		= 2,
	FACTOR_STRUCTURAL	= 4,
	FACTOR_ALL		= FACTOR_HIDDEN | FACTOR_SHORTCUT | FACTOR_STRUCTURAL
} factorflags ;

/* $Id: flags.h,v 1.1 2010/07/18 19:46:42 phh Exp $ */
#endif
