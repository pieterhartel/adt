#include <stdio.h>
#include "primitive.h"

bool bdbool( bool *binding ) {
	return (bool) binding ;
}

bool mtbool( bool pattern, bool subject ) {
	if( (bool *) pattern != NULL ) {
		*((bool *) pattern) = subject ;
	}
	return True ;
}

void frbool( bool *subject ) { }
void fdbool( bool *subject ) { }

void prbool( bool indent, bool subject ) {
	printf( "%s", subject ? "True" : "False" ) ;
}

void clbool( bool subject ) { }


int bdint( int *binding ) {
	return (int) binding ;
}

bool mtint( int pattern, int subject ) {
	if( (int *) pattern != NULL ) {
		*((int *) pattern) = subject ;
	}
	return True ;
}

void frint( int *subject ) { }
void fdint( int *subject ) { }

void print( int indent, int subject ) {
	printf( "%d", subject ) ;
}

void clint( int subject ) { }

long bdlong( long *binding ) {
	return (long) binding ;
}

bool mtlong( long pattern, long subject ) {
	if( (long *) pattern != NULL ) {
		*((long *) pattern) = subject ;
	}
	return True ;
}

void frlong( long *subject ) { }
void fdlong( long *subject ) { }

void prlong( int indent, long subject ) {
	printf( "%ld", subject ) ;
}

void cllong( long subject ) { }

string bdstring( string *binding ) {
	return (string) binding ;
}

bool mtstring( string pattern, string subject ) {
	if( (string *) pattern != NULL ) {
		*((string *) pattern) = subject ;
	}
	return True ;
}

void frstring( string *subject ) { }
void fdstring( string *subject ) { }

void prstring( int indent, string subject ) {
	if( subject == NULL ) {
		printf( "\"\"" ) ;
	} else {
		printf( "\"%s\"", subject ) ;
	}
}

void clstring( string subject ) {
}


void *bdvoid( void **binding ) {
	return NULL ;
}

bool mtvoid( void *pattern, void *subject ) {
	return False ;
}

void frvoid( void **source ) { }
void fdvoid( void **source ) { }

void prvoid( int indent, void *source ) {
	printf( "(void)" ) ;
}

void clvoid( void *source ) { }
