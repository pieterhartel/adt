#ifndef PRIMITIVE_H
#define PRIMITIVE_H

typedef	char *string ;
typedef	enum { False=0, True=1 } bool ;

typedef	unsigned int unsigned_int ;
typedef	unsigned long int unsigned_long_int ;
typedef	unsigned long long int unsigned_long_long_int ;

bool bdbool( bool *binding ) ;
bool mtbool( bool pattern, bool subject ) ;
void frbool( bool *subject ) ;
void fdbool( bool *subject ) ;
void prbool( bool indent, bool subject ) ;
void clbool( bool subject ) ;

int bdint( int *binding ) ;
bool mtint( int pattern, int subject ) ;
void frint( int *subject ) ;
void fdint( int *subject ) ;
void print( int indent, int subject ) ;
void clint( int subject ) ;

long bdlong( long *binding ) ;
bool mtlong( long pattern, long subject ) ;
void frlong( long *subject ) ;
void fdlong( long *subject ) ;
void prlong( int indent, long subject ) ;
void cllong( long subject ) ;

string bdstring( string *binding ) ;
bool mtstring( string pattern, string subject ) ;
void frstring( string *subject ) ;
void fdstring( string *subject ) ;
void prstring( int indent, string subject ) ;
void clstring( string subject ) ;

void *bdvoid( void **binding ) ;
bool mtvoid( void *pattern, void *subject ) ;
void frvoid( void **subject ) ;
void fdvoid( void **subject ) ;
void prvoid( int indent, void *subject ) ;
void clvoid( void *subject ) ;

#endif
