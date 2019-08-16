%{

#include <stdlib.h>
#include <string.h>
#include "primitive.h"
#include "generated.h"
#include "y.tab.h"
static char *collect( char ) ;
extern int lineno ;

#define input __input_____

%}
%x N P C

%%
[\ \t]				{ ; }
[\n\r]				{lineno++ ; }
hidden				{return HIDDENSY; }
shortcut			{return SHORTCUTSY; }
structural			{return STRUCTURALSY; }
INSTANCE			{return INSTANCESY; }
[A-Za-z][a-zA-Z0-9_]*		{yylval.token = strdup( yytext ) ; return TOKEN ; }
<<EOF>>				{return 0 ; }
.				{return yytext[0] ; }
\\\\.*\n			{collect( '\n' ) ; lineno++ ; }
\%\{				{BEGIN( P ) ; }
\/\*				{BEGIN( C ) ; }
<P>\n				{collect( yytext[0] ) ; lineno++; }
<P>.				{collect( yytext[0] ) ; }
<P>\%\}				{yylval.token = collect( '\0' ) ; BEGIN( INITIAL ) ; return TEXT ; }
<C>\*\/				{yylval.token = collect( '\0' ) ; BEGIN( INITIAL ) ; return COMMENT ; }
<C>.				{collect( yytext[0] ) ; }
<C>\n				{collect( '\n' ) ; lineno++ ; }
%%
char *collect( char x ) {
	static char *collector = NULL ;
	static int collectmax = 10 ;
	static int ncollect = 0 ;
	if( collector == NULL ) {
		collector = malloc( collectmax ) ;
	} else if( collectmax <= ncollect ) {
		collectmax = collectmax * 2 ;
		collector = realloc( collector, collectmax ) ;
	}
	collector[ncollect++] = x ;
	if( x == 0 ) {
		ncollect = 0 ;
		return strdup( collector ) ;
	}
	return NULL ;
}
