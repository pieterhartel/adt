/* TO DO: catch ( int x ) FOO( int x ) */

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

extern char yytext[] ;
extern int yyparse( void ) ;
extern void yyerror( char *s ) ;
extern int yylex( void ) ;

#include "primitive.h"
#include "flags.h"
#include "generated.h"

input	*root = NULL ;

%}

%union {
	char		*token ;
	input		*input ;
	body		*body ;
	adt		*adt ;
	def		*def ;
	sum		*sum ;
	summand		*summand ;
	product		*product ;
	factor		*factor ;
	ident		*ident ;
	int		flags ;
}

%start input

%token	TOKEN TEXT COMMENT SHORTCUTSY HIDDENSY STRUCTURALSY INSTANCESY

%type	<token>		TOKEN TEXT text COMMENT comment SHORTCUTSY HIDDENSY STRUCTURALSY INSTANCESY
%type	<input>		input
%type	<body>		body
%type	<def>		def
%type	<adt>		adt
%type	<sum>		sum
%type	<summand>		summand
%type	<product>	product
%type	<factor>	factor
%type	<ident>		ident
%type	<flags>		flags

%%

input	: text body text		{ root = mkINPUT( $1, $2, $3 ) ; }
	;

text	: TEXT
	| /*empty */			{ $$ = NULL ; }
	;

comment	: COMMENT
	| /*empty */			{ $$ = NULL ; }
	;

body	: def				{ $$ = mkBODY( $1, NULL ) ; }
	| def ';'			{ $$ = mkBODY( $1, NULL ) ; }
	| def ';' body			{ $$ = mkBODY( $1, $3 ) ; }
	;

def	: comment ident '=' adt		{ $$ = mkDEF( $1, $2, NULL, $4 ) ; }
	| comment ident '=' '(' product ')' adt
					{ $$ = mkDEF( $1, $2, $5, $7 ) ; }
	;

adt	: sum				{ $$ = mkADT( $1, NULL, NULL ) ; }
	| '[' product ']'		{ $$ = mkADT( NULL, "list", $2 ) ; }
	| INSTANCESY TOKEN '(' product ')'
					{ $$ = mkADT( NULL, $2, $4 ) ; }
	;

sum	: summand			{ $$ = mkSUM( $1, NULL ) ; }
	| summand '|' sum		{ $$ = mkSUM( $1, $3 ) ; }
	;

summand	: comment ident '(' product ')'	{ $$ = mkSUMMAND( $1, $2, $4 ) ; }
	| comment ident			{ $$ = mkSUMMAND( $1, $2, NULL ) ; }
	;

product	: factor			{ $$ = mkPRODUCT( $1, NULL ) ;}
	| factor ',' product		{ $$ = mkPRODUCT( $1, $3 ) ; }
	;

factor	: comment flags ident '*' ident	{ $$ = mkFACTOR( $1, $2, $3, "*", $5 ) ; }
	| comment flags ident ident	{ $$ = mkFACTOR( $1, $2, $3, "",  $4 ) ; }
	;

flags	: HIDDENSY			{ $$ = FACTOR_HIDDEN ; }
	| SHORTCUTSY			{ $$ = FACTOR_SHORTCUT ; }
	| STRUCTURALSY			{ $$ = FACTOR_STRUCTURAL ; }
	| /* */				{ $$ = FACTOR_STRUCTURAL ; }
	;

ident	: TOKEN				{ $$ = mkIDENT( $1 ) ; }
	;
%%

#include <ctype.h>

/*Lexical analyser */

int charno = 0;
int lineno = 0;
char *filename = NULL;
bool defcomment = True ;
bool summandcomment = True ;
bool factorcomment = True ;
bool error_details = True ;
bool sharing_check = True ;

#define MAX 10000

void yyerror( char *s ) ;
char *flipcase( char *input, char *suffix ) ;
char *listnm( char *org ) ;
char *tabtabs( char *tabs ) ;
char *visibility( factorflags vis ) ;
product *flproduct( factorflags mask, product *cur ) ;
product *func_approduct( product *subject, product *object ) ;
product *func_approduct_3( product *subject, product *object1, product *object2 ) ;
sum *func_apsum( sum *subject, sum *object ) ;

void general_product( char *product_fmt, char *factor_fmt, char *tabs, char *def_nm, char *constr_nm, product *cur ) ;
void general_factor( char *factor_fmt, char *tabs, char *def_nm, char *constr_nm, factor *cur ) ;

bool is_adt_input( input *root, char *nm ) ;
bool is_adt_body( body *cur, char *nm ) ;
bool is_adt_def( def *cur, char *nm ) ;

void latex_text( string s ) ;
void latex_string( string s ) ;
void latex_input( input *cur ) ;
void latex_body( body *cur ) ;
void latex_def( def *cur ) ;
void latex_adt( adt *cur ) ;
void latex_sum( sum *cur ) ;
void latex_summand( summand *cur ) ;
void latex_product( product *cur ) ;

void nocomment_string( string s ) ;
void nocomment_input( input *cur ) ;
void nocomment_body( body *cur ) ;
void nocomment_def( def *cur ) ;
void nocomment_adt( adt *cur ) ;
void nocomment_sum( sum *cur ) ;
void nocomment_summand( summand *cur ) ;
void nocomment_product( product *cur ) ;

int cnt_sum( sum *cur ) ;
int cnt_summand( summand *cur ) ;
int cnt_product( product *cur ) ;

void enum_input( input *root ) ;
void enum_body( body *cur ) ;
int enum_def( int cnt, def *cur ) ;
int enum_adt( char *def_nm, adt *cur, int cnt, int fcnt ) ;
int enum_sum( char *def_nm, sum *cur, int cnt, int fcnt ) ;
int enum_summand( char *def_nm, summand *cur, int cnt, int fcnt ) ;

void nametable_input( input *root ) ;
void nametable_body( body *cur ) ;
void nametable_def( def *cur ) ;
void nametable_adt( char *def_nm, adt *cur ) ;
void nametable_sum( sum *cur ) ;
void nametable_summand( summand *cur ) ;

void struct_input( input *root ) ;
void struct_body( body *cur ) ;
void struct_def( def *cur ) ;
void struct_adt( char *def_nm, adt *cur ) ;
void struct_sum( char *def_nm, sum *cur ) ;
void struct_summand( char *def_nm, summand *cur ) ;
void struct_product( char *tabs, char *def_nm,  product *cur ) ;
void struct_factor( char *tabs, factor *cur ) ;

void initialiser_input( input *root ) ;
void initialiser_body( body *cur ) ;
void initialiser_def( def *cur ) ;
void initialiser_adt( char *def_nm, adt *cur ) ;
void initialiser_sum( char *def_nm, sum *cur ) ;
void initialiser_summand( char *def_nm, summand *cur ) ;

void case_input( input *root ) ;
void case_body( body *cur ) ;
void case_def( def *cur ) ;
void case_adt( char *def_nm, adt *cur ) ;
void case_sum( char *def_nm, sum *cur ) ;
void case_summand( char *def_nm, summand *cur ) ;

void field_product( product *cur ) ;
void initialiser_product( char * def_nm, char *constr_nm, product *cur ) ;
void case_product( char * def_nm, char *constr_nm, product *cur ) ;
void decl_product( product *cur ) ;
void formal_product( product *cur ) ;
void actual_product( char *constr_nm, product *cur ) ;

void pro_input( input *root ) ;
void pro_body( body *cur ) ;
void pro_def( def *cur ) ;
void pro_adt( char *def_nm, product *prod, adt *cur ) ;

void pro_high_level_instance_list( char *def_nm, product *prod, adt *cur ) ;

void pro_high_level_instance_dlist( char *def_nm, product *prod, adt *cur ) ;

void pro_high_level_instance_tree( char *def_nm, product *prod, adt *cur ) ;

void pro_sum( char *def_nm, product *prod, sum *cur ) ;
void pro_summand( char *def_nm, product *prod, summand *cur ) ;
void pro_product( char *def_nm, char *constr_nm, product *cur ) ;
void pro_factor( char *def_nm, char *constr_nm, factor *cur ) ;

void init_product( char *constr_nm, product *cur ) ;

void bind_def( char *def_nm, def *cur ) ;

void free_def( char *def_nm, def *cur ) ;

void free_deep_def( char *def_nm, def *cur ) ;
void free_deep_adt( char *def_nm, product *prod, adt *cur ) ;
void free_deep_sum( char *tabs, sum *cur ) ;
void free_deep_summand( char *tabs, summand *cur ) ;
void free_deep_product( char *tabs, char *constr_nm, product *cur ) ;

void copy_def( char *def_nm, def *cur ) ;

void print_def( char *def_nm, def *cur ) ;
void print_adt( char *def_nm, product *prod, adt *cur ) ;
void print_instance_adt( char *def_nm, product *prod, adt *cur ) ;
void print_instance_list( char *def_nm, product *prod, adt *cur ) ;
void print_sum( char *tabs, product *prod, sum *cur ) ;
void print_summand( char *tabs, product *prod, summand *cur ) ;
void print_product( char *tabs, char *constr_nm, product *cur ) ;

void clear_def( char *def_nm, def *cur ) ;
void clear_adt( char *def_nm, product *prod, adt *cur ) ;
void clear_instance_adt( char *def_nm, product *prod, adt *cur ) ;
void clear_sum( char *tabs, sum *cur ) ;
void clear_summand( char *tabs, summand *cur ) ;
void clear_product( char *tabs, char *constr_nm, product *cur ) ;

void high_level_instance_list_append( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_list_map( char *def_nm, product *prod, adt *cur ) ;

void high_level_instance_dlist_size( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_empty( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_front( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_back( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_push_back( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_push_front( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_pop_back( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_pop_front( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_erase( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_insert( char *def_nm, product *prod, adt *cur ) ;
void high_level_instance_dlist_remove_if( char *def_nm, product *prod, adt *cur ) ;

void high_level_instance_tree_traverse( char *def_nm, product *prod, adt *cur ) ;

void match_def( char *def_nm, def *cur ) ;
void match_adt( char *def_nm, product *prod, adt *cur ) ;
void match_instance_adt( char *def_nm, product *prod, adt *cur ) ;
void match_sum( char *tabs, sum *cur ) ;
void match_summand( char *tabs, summand *cur ) ;
void match_product( char *tabs, char *constr_nm, product *cur ) ;

void tag_def( char *def_nm, def *cur ) ;

void fun_input( input *root ) ;
void fun_body( body *cur ) ;
void fun_def( def *cur ) ;
void fun_adt( char *def_nm, product *prod, adt *cur ) ;
void fun_sum( char *def_nm, product *prod, sum *cur ) ;
void fun_summand( char *def_nm, product *prod, summand *cur ) ;
void fun_product( char *def_nm, char *constr_nm, product *cur ) ;
void fun_factor( char *def_nm, char *constr_nm, factor *cur ) ;

void protemp_input( input *root ) ;
void protemp_body( body *cur ) ;
void protemp_def( def *cur ) ;

void funtemp_input( input *root ) ;
void funtemp_body( body *cur ) ;
void funtemp_def( def *cur ) ;
void funtemp_adt( char *def_nm, product *prod, adt *cur ) ;
void funtemp_sum( char *tabs, char *def_nm, sum *cur ) ;
void funtemp_summand( char *tabs, char *def_nm, summand *cur ) ;
void funtemp_product( char *tabs, char *def_nm, char *constr_nm, product *cur ) ;

int def_body( char *subject, body *cur ) ;
int def_def( char *subject, def *cur ) ;

int constr_body( char *subject, body *cur ) ;
int constr_def( char *subject, def *cur ) ;
int constr_adt( char *subject, adt *cur ) ;
int constr_sum( char *subject, sum *cur ) ;
int constr_summand( char *subject, summand *cur ) ;

void check_input( input *root ) ;
void check_body( body *body_root, body *cur ) ;
void check_def( body *body_root, def *cur ) ;
void check_adt( body *body_root, adt *cur ) ;
void check_sum( body *body_root, sum *cur ) ;
void check_summand( body *body_root, summand *cur ) ;
void check_product( product *cur ) ;
void check_factor( factor *cur ) ;

void instantiate_adt_input( input *root ) ;
void instantiate_adt_body( body *cur ) ;
void instantiate_adt_def( def *cur ) ;
void instantiate_adt_adt( char *def_nm, adt *cur ) ;

void instantiate_adt_list( char *def_nm, adt *cur ) ;

void instantiate_adt_dlist( char *def_nm, adt *cur ) ;

void instantiate_adt_tree( char *def_nm, adt *cur ) ;

void usage( char *prog ) ;

void yyerror( char *s ) {
	fprintf( stderr, "%s:%d: %s\n", filename, lineno, s ) ;
}

char *flipcase( char *input, char * suffix ) {
	char *s, *result = calloc( strlen( input ) + strlen( suffix ), sizeof( char ) ) ;
	check_ptr( result, "flipcase" ) ;
	strcat( result, input );
	strcat( result, suffix );
	for( s = result; *s != '\0'; s++ ) {
		if( *s >= 'a' && *s <= 'z' ) {
			*s = *s - 'a' + 'A' ;
		} else if( *s >= 'A' && *s <= 'Z' ) {
			*s = *s - 'A' + 'a' ;
		}
	}
	return result ;
}

char *listnm( char *org ) {
	char *result = calloc( strlen( org ) + 4, sizeof( char ) ) ;
	check_ptr( result, "listnm" ) ;
	strcpy( result, org ) ;
	strcat( result, "list" ) ;
	return result ;
}

char *tabtabs( char *tabs ) {
	char *result = calloc( strlen( tabs ) + 1, sizeof( char ) ) ;
	check_ptr( result, "tabtabs" ) ;
	strcpy( result, tabs ) ;
	strcat( result, "\t" ) ;
	return result ;
}

char *visibility( factorflags vis ) {
	char * result = NULL ;
	switch( vis ) {
	case FACTOR_NONE :
		result = "" ;
		break ;
	case FACTOR_HIDDEN :
		result = "hidden" ;
		break ;
	case FACTOR_SHORTCUT :
		result = "shortcut" ;
		break ;
	case FACTOR_STRUCTURAL :
		result = "structural" ;
		break ;
	case FACTOR_ALL :
		fatal( 0, "visibility" ) ;
		break ;
	}
	return result ;
}

product *flproduct( factorflags mask, product *cur ) {
	if( cur == NULL ) {
		return NULL ;
	} else {
		product *next = gtPRODUCTnext( cur ) ;
		factorflags vis = gtFACTORvisibility( gtPRODUCTfactor( cur ) ) ;
		if( (mask & vis) == vis ) {
			cur = cpproduct( cur ) ;
			stPRODUCTnext( cur, flproduct( mask, next ) ) ;
			return cur ;
		} else {
			return flproduct( mask, next ) ;
		}
	}
}

product *func_approduct( product *subject, product *object ) {
	if( subject == NULL ) {
		return object ;
	} else {
		product *current = cpproduct( subject ) ;
		product *last = current ;
		product *result = current ;
		subject = gtPRODUCTnext( subject ) ;
		while( subject != NULL ) {
			current = cpproduct( subject ) ;
			stPRODUCTnext( last, current ) ;
			last = current ;
			subject = gtPRODUCTnext( subject ) ;
		}
		stPRODUCTnext( last, object ) ;
		return result ;
	}
}

product *func_approduct_3( product *subject, product *object1, product *object2 ) {
	return func_approduct( func_approduct( subject, object1 ), object2 ) ;
}

sum *func_apsum( sum *subject, sum *object ) {
	if( subject == NULL ) {
		return object ;
	} else {
		sum *current = cpsum( subject ) ;
		sum *last = current ;
		sum *result = current ;
		subject = gtSUMnext( subject ) ;
		while( subject != NULL ) {
			current = cpsum( subject ) ;
			stSUMnext( last, current ) ;
			last = current ;
			subject = gtSUMnext( subject ) ;
		}
		stSUMnext( last, object ) ;
		return result ;
	}
}

void general_product( char *product_fmt, char *factor_fmt, char *tabs, char *def_nm, char *constr_nm, product *cur ) {
	while( cur != NULL ) {
		general_factor( factor_fmt, tabs, def_nm, constr_nm, gtPRODUCTfactor( cur ) ) ;
		cur = gtPRODUCTnext( cur ) ;
		if( cur != NULL ) {
			int i ;
			for( i = 0; i < strlen( product_fmt ); i++ ) {
				if( product_fmt[i] != '%' ) {
					putchar( product_fmt[i] ) ;
				} else {
					i++ ;
					switch( product_fmt[i] ) {
					case 'c' :
						printf( "%s", constr_nm ) ;
						break ;
					case 'C' :
						if( constr_nm != NULL ) {
							printf( "data._%s.", constr_nm ) ;
						}
						break ;
					case 'd' :
						printf( "%s", def_nm ) ;
						break ;
					case 'i' :
						printf( tabs ) ;
						break ;
					default :
						fatal( 0, "generalproduct" ) ;
					}
				}
			}
		}
	}
}

void general_factor( char *factor_fmt, char *tabs, char *def_nm, char *constr_nm, factor *cur ) {
	char *type_nm = gtIDENTident( gtFACTORtype( cur ) ) ;
	char *field_nm = gtIDENTident( gtFACTORfield( cur ) ) ;
	char *star = gtFACTORstar( cur ) ;
	factorflags flags = gtFACTORvisibility( cur ) ;
	char *comment = gtFACTORcomment( cur ) ;

	int i = 0;
	for( i = 0; i < strlen( factor_fmt ); i++ ) {
		if( factor_fmt[i] != '%' ) {
			putchar( factor_fmt[i] ) ;
		} else {
			i++ ;
			switch( factor_fmt[i] ) {
			case 'c' :
				printf( "%s", constr_nm ) ;
				break ;
			case 'C' :
				if( constr_nm != NULL ) {
					printf( "data._%s.", constr_nm ) ;
				}
				break ;
			case 'd' :
				printf( "%s", def_nm ) ;
				break ;
			case 'f' :
				printf( "%s", field_nm ) ;
				break ;
			case 'i' :
				printf( tabs ) ;
				break ;
			case 'L' :
				if( comment != NULL ) {
					latex_string( comment ) ;
				}
				break ;
			case 's' :
				printf( "%s", star ) ;
				break ;
			case 't' :
				printf( "%s", type_nm ) ;
				break ;
			case 'T' :
				if( strlen( star ) == 0 ) {
					printf( "(%s)", type_nm ) ;
				}
				break ;
			case 'S' :
				if( strlen( star ) != 0 && is_adt_input( root, type_nm ) ) {
					printf( "struct %s_struct", type_nm ) ;
				} else {
					printf( "%s", type_nm ) ;
				}
				break ;
			case 'v' :
				printf( "%s", visibility( flags ) ) ;
				break ;
			default :
				fatal( 0, "generalfactor" ) ;
			}
		}
	}
}

bool is_adt_input( input *root, char *nm ) {
	return is_adt_body( gtINPUTbody( root ), nm ) ;
}

bool is_adt_body( body *cur, char *nm ) {
	while( cur != NULL ) {
		if( is_adt_def( gtBODYdef( cur ), nm ) ) {
			return True ;
		}
		cur = gtBODYnext( cur ) ;
	}
	return False ;
}

bool is_adt_def( def *cur, char *nm ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	if( strcmp( def_nm, nm ) == 0 ) {
		return True ;
	} else {
		return False ;
	}
}

void latex_text( string s ) {
	int i ;
	printf( "\\verb=" ) ;
	for( i = 0; i < strlen( s ) ; i++ ) {
		if( s[i] <= ' ' ) {
			printf( "= \\verb=" ) ;
		} else if( s[i] == '=' ) {
			printf( "=\\verb|=|\\verb=" ) ;
		} else {
			putchar( s[i] ) ;
		}
	}
	printf( "=" ) ;
}

void latex_string( string s ) {
	int i ;
	for( i = 0; i < strlen( s ) ; i++ ) {
		if( s[i] <= ' ' ) {
			printf( " " ) ;
		} else if( 0&& s[i] == '_' ) {
			printf( "\\_" ) ;
		} else {
			putchar( s[i] ) ;
		}
	}
}

void latex_input( input *cur ) {
	switch( gtinputtag( cur ) ) {
	case INPUT :
		if( gtINPUTheader( cur ) != NULL ) {
			latex_text( gtINPUTheader( cur ) ) ;
		}
		latex_body( gtINPUTbody( cur ) ) ;
		if( gtINPUTtrailer( cur ) != NULL ) {
			latex_text( gtINPUTtrailer( cur ) ) ;
		}
		break ;
	}
}

void latex_body( body *cur ) {
	while( cur != NULL ) {
		latex_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void latex_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	printf( "\n\n\\adtdef{" ) ;
	latex_string( def_nm ) ;
	printf( "}{" ) ;
	if( gtDEFcomment( cur ) != NULL ) {
		latex_string( gtDEFcomment( cur ) ) ;
	}
	if( gtDEFproduct( cur ) != NULL ) {
		printf( "\\adtadtcommon{" ) ;
		latex_product( gtDEFproduct( cur ) ) ;
		printf( "}" ) ;
	}
	printf( "\\adtadtconstructors{" ) ;
	latex_adt( gtDEFadt( cur ) ) ;
	printf( "}" ) ;
	printf( "}" ) ;
}

void latex_adt( adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		if( gtADTclass( cur ) != NULL ) {
			printf( "%s INSTANCE ", gtADTclass( cur ) ) ;
		}
		latex_sum( gtADTsum( cur ) ) ;
		break ;
	}
}

void latex_sum( sum *cur ) {
	while( cur != NULL ) {
		latex_summand( gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void latex_summand( summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;
	printf( "\\adtsummand{" ) ;
	latex_string( constr_nm ) ;
	printf( "}{" ) ;
	if( gtSUMMANDcomment( cur ) != NULL ) {
		latex_string( gtSUMMANDcomment( cur ) ) ;
		printf( "\n" ) ;
	}
	printf( "\\adtfields\n" ) ;
	latex_product( gtSUMMANDproduct( cur ) ) ;
	printf( "}" ) ;
}

void latex_product( product *cur ) {
	general_product( "", "\\adtfactor{%v}{%t}{%s}{%f}{%L}\n", "", NULL, NULL, cur ) ;
}

void nocomment_string( string s ) {
	int i ;
	printf( "%%{" ) ;
	for( i = 0; i < strlen( s ) ; i++ ) {
		if( s[i] <= ' ' ) {
			putchar( ' ' ) ;
		} else {
			putchar( s[i] ) ;
		}
	}
	printf( "%%}" ) ;
}

void nocomment_input( input *cur ) {
	switch( gtinputtag( cur ) ) {
	case INPUT :
		nocomment_body( gtINPUTbody( cur ) ) ;
		break ;
	}
}

void nocomment_body( body *cur ) {
	while( cur != NULL ) {
		nocomment_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
		if( cur != NULL ) {
			printf( " ;" ) ;
		}
		printf( "\n" ) ;
	}
}

void nocomment_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	printf( "%s =", def_nm ) ;
	if( gtDEFproduct( cur ) != NULL ) {
		printf( "\n\t( " ) ;
		nocomment_product( gtDEFproduct( cur ) ) ;
		printf( " )" ) ;
	}
	nocomment_adt( gtDEFadt( cur ) ) ;
}

void nocomment_adt( adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		printf( "\n" ) ;
		if( gtADTclass( cur ) != NULL ) {
			printf( "\tINSTANCE %s(", gtADTclass( cur ) ) ;
			nocomment_product( gtADTparameters( cur ) ) ;
			printf( ") ==>\n" ) ;
		}
		nocomment_sum( gtADTsum( cur ) ) ;
		break ;
	}
}

void nocomment_sum( sum *cur ) {
	while( cur != NULL ) {
		nocomment_summand( gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
		if( cur != NULL ) {
			printf( " |\n" ) ;
		}
	}
}

void nocomment_summand( summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;
	printf( "\t%s( ", constr_nm ) ;
	nocomment_product( gtSUMMANDproduct( cur ) ) ;
	printf( " )" ) ;
}

void nocomment_product( product *cur ) {
	general_product( ", ", "%v %t %s%f", "", NULL, NULL, cur ) ;
}

int cnt_sum( sum *cur ) {
	int accu = 0 ;
	while( cur != NULL ) {
		accu ++ ;
		cur = gtSUMnext( cur ) ;
	}
	return accu ;
}

int cnt_summand( summand *cur ) {
	return cnt_product( gtSUMMANDproduct( cur ) ) ;
}

int cnt_product( product *cur ) {
	int accu = 0 ;
	while( cur != NULL ) {
		accu ++ ;
		cur = gtPRODUCTnext( cur ) ;
	}
	return accu ;
}

void enum_input( input *root ) {
	enum_body( gtINPUTbody( root ) ) ;
}

void enum_body( body *cur ) {
	int cnt = 0 ;
	while( cur != NULL ) {
		cnt = enum_def( cnt, gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
	printf( "#define nametablelength %d", cnt ) ;
}

int enum_def( int cnt, def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	printf( "#define %s_BIND %d\n", def_nm, cnt ) ;
	printf( "typedef\tenum { " ) ;
	cnt = enum_adt( def_nm, gtDEFadt( cur ), cnt+1, cnt+1 ) ;
	printf( " } %s_tag ;\n", def_nm ) ;
	return cnt ;
}

int enum_adt( char *def_nm, adt *cur, int cnt, int fcnt ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		cnt = enum_sum( def_nm, gtADTsum( cur ), cnt, fcnt ) ;
		break ;
	}
	return cnt ;
}

int enum_sum( char *def_nm, sum *cur, int cnt, int fcnt ) {
	while( cur != NULL ) {
		cnt = enum_summand( def_nm, gtSUMsummand( cur ), cnt, fcnt ) ;
		cur = gtSUMnext( cur ) ;
	}
	return cnt ;
}

int enum_summand( char *def_nm, summand *cur, int cnt, int fcnt ) {
	if( cur == NULL ) {
		return cnt ;
	} else {
		char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;
		printf( "%s%s=%d", cnt==fcnt?"":", ", constr_nm, cnt ) ;
		return cnt+1 ;
	}
}

void nametable_input( input *root ) {
	printf( "char *nametable [] = {" ) ;
	nametable_body( gtINPUTbody( root ) ) ;
	printf( "\n\tNULL } ;\n" ) ;
}

void nametable_body( body *cur ) {
	while( cur != NULL ) {
		nametable_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void nametable_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	printf( "\n\t\"%s_BIND\", ", def_nm ) ;
	nametable_adt( def_nm, gtDEFadt( cur ) ) ;
}

void nametable_adt( char *def_nm, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		nametable_sum( gtADTsum( cur ) ) ;
		break ;
	}
}

void nametable_sum( sum *cur ) {
	while( cur != NULL ) {
		nametable_summand( gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void nametable_summand( summand *cur ) {
	if( cur != NULL ) {
		char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;
		printf( "\"%s\", ", constr_nm ) ;
	}
}

void struct_input( input *root ) {
	struct_body( gtINPUTbody( root ) ) ;
}

void struct_body( body *cur ) {
	while( cur != NULL ) {
		struct_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void struct_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	printf( "typedef\tstruct %s_struct {\n", def_nm ) ;
	printf( "\t%s_tag tag ;\n", def_nm ) ;
	if( sharing_check ) {
		printf( "\tint flag ;\n" ) ;
	}
	if( error_details ) {
		printf( "\tint lineno ;\n" ) ;
		printf( "\tint charno ;\n" ) ;
		printf( "\tchar *filename ;\n" ) ;
	}
	struct_product( "\t", def_nm, gtDEFproduct( cur ) ) ;
	printf( "\tunion {\n" ) ;
	printf( "\t\tstruct %s_struct **_binding ;\n", def_nm ) ;
	struct_adt( def_nm, gtDEFadt( cur ) ) ;
	printf( "\t} data ;\n" ) ;
	printf( "} %s ;\n\n", def_nm ) ;
}

void struct_adt( char *def_nm, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		struct_sum( def_nm, gtADTsum( cur ) ) ;
		break ;
	}
}

void struct_sum( char *def_nm, sum *cur ) {
	while( cur != NULL ) {
		struct_summand( def_nm, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void struct_summand( char *def_nm, summand *cur ) {
	if( cur != NULL ) {
		char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;
		if( cnt_summand( cur ) > 0 ) {
			printf( "\t\tstruct {\n" ) ;
			struct_product( "\t\t\t", def_nm, gtSUMMANDproduct( cur ) ) ;
			printf( "\t\t} _%s ;\n", constr_nm ) ;
		}
	}
}

void struct_product( char *tabs, char *def_nm, product *cur ) {
	general_product( "", "%i%S %s_%f ;\n", tabs, def_nm, NULL, cur ) ;
}

void initialiser_input( input *root ) {
	initialiser_body( gtINPUTbody( root ) ) ;
}

void initialiser_body( body *cur ) {
	while( cur != NULL ) {
		initialiser_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void initialiser_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;

	printf( "#define in%s( binding ) { \\\n", def_nm ) ;
	printf( "\t.tag = %s_BIND, \\\n", def_nm ) ;
	printf( "\t.data._binding = binding \\\n" ) ;
	printf( "}\n" );

	initialiser_adt( def_nm, gtDEFadt( cur ) ) ;
}

void initialiser_adt( char *def_nm, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		initialiser_sum( def_nm, gtADTsum( cur ) ) ;
		break ;
	}
}

void initialiser_sum( char *def_nm, sum *cur ) {
	while( cur != NULL ) {
		initialiser_summand( def_nm, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void initialiser_summand( char *def_nm, summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;

	printf( "#define in%s( ", constr_nm ) ;
	field_product( gtSUMMANDproduct( cur ) ) ;
	printf( " ) { \\\n" ) ;
	printf( "\t.tag = %s", constr_nm ) ;
	if( cnt_summand( cur ) > 0 ) {
		initialiser_product( def_nm, constr_nm, gtSUMMANDproduct( cur ) ) ;
	}
	printf( " \\\n}\n" ) ;
}

void case_input( input *root ) {
	case_body( gtINPUTbody( root ) ) ;
}

void case_body( body *cur ) {
	while( cur != NULL ) {
		case_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void case_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	case_adt( def_nm, gtDEFadt( cur ) ) ;
}

void case_adt( char *def_nm, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		case_sum( def_nm, gtADTsum( cur ) ) ;
		break ;
	}
}

void case_sum( char *def_nm, sum *cur ) {
	while( cur != NULL ) {
		case_summand( def_nm, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void case_summand( char *def_nm, summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;

	if( cnt_summand( cur ) > 0 ) {
		printf( "#define cs%s( _%s_, ", constr_nm, def_nm ) ;
		field_product( gtSUMMANDproduct( cur ) ) ;
		printf( " ) \\\n" ) ;
		printf( "\tcase %s :", constr_nm ) ;
		case_product( def_nm, constr_nm, gtSUMMANDproduct( cur ) ) ;
		printf( "\n" ) ;
	}
}

void field_product( product *cur ) {
	general_product( ", ", "%f", NULL, NULL, NULL, cur ) ;
}

void case_product( char * def_nm, char *constr_nm, product *cur ) {
	general_product( "", " \\\n%i%f = _%d_->%C_%f ;", "\t\t", def_nm, constr_nm, cur ) ;
}

void initialiser_product( char * def_nm, char *constr_nm, product *cur ) {
	general_product( "", ", \\\n%i.%C_%f = %T%f", "\t", def_nm, constr_nm, cur ) ;
}

void decl_product( product *cur ) {
	cur = flproduct( FACTOR_STRUCTURAL, cur ) ;
	general_product( ", ", "%t %s_%f", NULL, NULL, NULL, cur ) ;
}

void formal_product( product *cur ) {
	cur = flproduct( FACTOR_STRUCTURAL, cur ) ;
	general_product( ", ", "%t %s", NULL, NULL, NULL, cur ) ;
}

void actual_product( char *constr_nm, product *cur ) {
	cur = flproduct( FACTOR_STRUCTURAL, cur ) ;
	general_product( ", ", "subject->%C_%f", "", NULL, constr_nm, cur ) ;
}

void pro_input( input *root ) {
	pro_body( gtINPUTbody( root ) ) ;
}

void pro_body( body *cur ) {
	while( cur != NULL ) {
		pro_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void pro_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	printf( "#define nl%s ( ( %s*) NULL )\n", def_nm, def_nm ) ;
	printf( "%s *bd%s( %s **binding ) ;\n", def_nm, def_nm, def_nm ) ;
	printf( "bool mt%s( %s *pattern, %s *subject ) ;\n", def_nm, def_nm, def_nm ) ;
	printf( "void fr%s( %s **subject ) ;\n", def_nm, def_nm ) ;
	printf( "void fd%s( %s **subject ) ;\n", def_nm, def_nm ) ;
	printf( "%s *cp%s( %s *subject ) ;\n", def_nm, def_nm, def_nm ) ;
	printf( "void mv%s( %s *subject, %s *object ) ;\n", def_nm, def_nm, def_nm ) ;
	printf( "void pr%s( int indent, %s *subject ) ;\n", def_nm, def_nm ) ;
	printf( "void cl%s( %s *subject ) ;\n", def_nm, def_nm ) ;
	printf( "#ifndef _FAST_\n" ) ;
	printf( "%s_tag gt%stag( %s *subject ) ;\n", def_nm, def_nm, def_nm ) ;
	printf( "#else\n" ) ;
	printf( "#define gt%stag( subject ) ( ( subject )->tag )\n", def_nm ) ;
	printf( "#endif\n" ) ;
	printf( "void st%stag( %s *subject, %s_tag tag ) ;\n", def_nm, def_nm, def_nm ) ;
	if( error_details ) {
		printf( "#define gt%sfilename( subject ) ( ( subject )->filename )\n", def_nm ) ;
		printf( "#define gt%slineno( subject ) ( ( subject )->lineno )\n", def_nm ) ;
		printf( "#define gt%scharno( subject ) ( ( subject )->charno )\n", def_nm ) ;
	}
	printf( "void lf%s( %s *subject ) ;\n", def_nm, def_nm ) ;
	pro_product( def_nm, NULL, gtDEFproduct( cur ) ) ;
	pro_adt( def_nm, gtDEFproduct( cur ), gtDEFadt( cur ) ) ;
	printf( "\n" ) ;
}

void pro_adt( char *def_nm, product *prod, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		pro_sum( def_nm, prod, gtADTsum( cur ) ) ;
		if( gtADTclass( cur ) == NULL ) {
			break ;
		} else if( strcmp( gtADTclass( cur ), "list" ) == 0 ) {
			pro_high_level_instance_list( def_nm, prod, cur ) ;
		} else if( strcmp( gtADTclass( cur ), "dlist" ) == 0 ) {
			pro_high_level_instance_dlist( def_nm, prod, cur ) ;
		} else if( strcmp( gtADTclass( cur ), "tree" ) == 0 ) {
			pro_high_level_instance_tree( def_nm, prod, cur ) ;
		}
		break ;
	}
}

void pro_high_level_instance_list( char *def_nm, product *prod, adt *cur ) {
	product *combined  = func_approduct( prod, gtADTparameters( cur ) ) ;

	printf( "%s *ap%s( %s *subject, %s *object ) ;\n", def_nm, def_nm, def_nm, def_nm ) ;

	printf( "void it%s( void ( *f ) ( void *, ", def_nm ) ;
	formal_product( combined ) ;
	printf( " ), void *x, %s *subject ) ;\n", def_nm ) ;
}

void pro_high_level_instance_dlist( char *def_nm, product *prod, adt *cur ) {
	printf( "int size_%s( %s *subject ) ;\n", def_nm, def_nm ) ;
	printf( "bool empty_%s( %s *subject ) ;\n", def_nm, def_nm ) ;
	printf( "%s *front_%s( %s *subject ) ;\n", def_nm, def_nm, def_nm ) ;
	printf( "%s *back_%s( %s *subject ) ;\n", def_nm, def_nm, def_nm ) ;
	printf( "%s *push_back_%s( %s *subject, %s *object ) ; \n", def_nm, def_nm, def_nm, def_nm ) ;
	printf( "%s *push_front_%s( %s *subject, %s *object ) ; \n", def_nm, def_nm, def_nm, def_nm ) ;
	printf( "%s *pop_back_%s( %s *subject ) ; \n", def_nm, def_nm, def_nm ) ;
	printf( "%s *pop_front_%s( %s *subject ) ; \n", def_nm, def_nm, def_nm ) ;
	printf( "%s *erase_%s( %s *subject, %s *start, %s *end ) ;\n", def_nm, def_nm, def_nm, def_nm, def_nm ) ;
	printf( "%s *insert_%s( %s *subject, %s *start, %s *object ) ;\n", def_nm, def_nm, def_nm, def_nm, def_nm ) ;
}

void pro_high_level_instance_tree( char *def_nm, product *prod, adt *cur ) {
	product *combined  = func_approduct( prod, gtADTparameters( cur ) ) ;

	printf( "void tr%s( void ( *f ) ( void *, ", def_nm ) ;
	formal_product( combined ) ;
	printf( " ), void *x, %s *subject ) ;\n", def_nm ) ;
}

void pro_sum( char *def_nm, product *prod, sum *cur ) {
	while( cur != NULL ) {
		pro_summand( def_nm, prod, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void pro_summand( char *def_nm, product *prod, summand *cur ) {
	if( cur != NULL ) {
		char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;
		product *combined = func_approduct( prod, gtSUMMANDproduct( cur ) ) ;

		printf( "%s *mk%s( ", def_nm, constr_nm ) ;
		decl_product( combined ) ;
		printf( " ) ;\n" ) ;

		printf( "%s *pt%s( ", def_nm, constr_nm ) ;
		decl_product( combined ) ;
		printf( " ) ;\n" ) ;

		pro_product( def_nm, constr_nm, gtSUMMANDproduct( cur ) ) ;
	}
}

void pro_product( char *def_nm, char *constr_nm, product *cur ) {
	while( cur != NULL ) {
		pro_factor( def_nm, constr_nm, gtPRODUCTfactor( cur ) ) ;
		cur = gtPRODUCTnext( cur ) ;
	}
}

void pro_factor( char *def_nm, char *constr_nm, factor *cur ) {
	char *type_nm = gtIDENTident( gtFACTORtype( cur ) ) ;
	char *field_nm = gtIDENTident( gtFACTORfield( cur ) ) ;
	char *star = gtFACTORstar( cur ) ;
	char *nm = constr_nm == NULL ? def_nm : constr_nm ;

	printf( "%s *%sad%s%s( %s *subject ) ;\n", type_nm, star, nm, field_nm, def_nm ) ;
	printf( "#ifndef _FAST_\n" ) ;
	printf( "%s %sgt%s%s( %s *subject ) ;\n", type_nm, star, nm, field_nm, def_nm ) ;
	printf( "#else\n" ) ;
	if( constr_nm == NULL ) {
		printf( "#define gt%s%s( subject ) ( ( subject )->_%s )\n", nm, field_nm, field_nm ) ;
	} else {
		printf( "#define gt%s%s( subject ) ( ( subject )->data._%s._%s )\n", nm, field_nm, nm, field_nm ) ;
	}
	printf( "#endif\n" ) ;
	printf( "void st%s%s( %s *subject, %s %svalue ) ;\n", nm, field_nm, def_nm, type_nm, star ) ;
}

void init_product( char *constr_nm, product *cur ) {
	cur = flproduct( FACTOR_STRUCTURAL, cur ) ;
	general_product( "", "%iresult->%C_%f = _%f ;\n", "\t", NULL, constr_nm, cur ) ;
}

void bind_def( char *def_nm, def *cur ) {
	printf( "%s *bd%s( %s **binding ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\t%s *result = calloc( 1, sizeof( struct %s_struct ) ) ;\n", def_nm, def_nm ) ;
	printf( "\tcheck_ptr( result, \"calloc bd%s\" ) ;\n", def_nm ) ;
	printf( "\tresult->tag = %s_BIND ;\n", def_nm ) ;
	printf( "\tresult->data._binding = binding ;\n" ) ;
	if( sharing_check ) {
		printf( "\tresult->flag = 0 ;\n" ) ;
	}
	printf( "\treturn result ;\n" ) ;
	printf( "}\n\n" ) ;
}

void free_def( char *def_nm, def *cur ) {
	printf( "void fr%s( %s **subject ) {\n", def_nm, def_nm ) ;
	printf( "\tif( *subject != NULL ) {\n" ) ;
	printf( "\t\tfree( *subject ) ;\n" ) ;
	printf( "\t\t*subject = NULL ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void free_deep_def( char *def_nm, def *cur ) {
	printf( "void fd%s( %s **subject ) {\n", def_nm, def_nm ) ;
	free_deep_adt( def_nm, gtDEFproduct( cur ), gtDEFadt( cur ) ) ;
	printf( "}\n\n" ) ;
}

void free_deep_adt( char *def_nm, product *prod, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		printf( "\tif( *subject != NULL ) {\n" ) ;
		free_deep_product( "\t\t", NULL, prod ) ;
		printf( "\t\tif( (*subject)->tag != %s_BIND ) {\n", def_nm ) ;
		printf( "\t\t\tswitch( (*subject)->tag ) {\n" ) ;
		free_deep_sum( "\t\t\t", gtADTsum( cur ) ) ;
		printf( "\t\t\t}\n" ) ;
		printf( "\t\t}\n" ) ;
		printf( "\t\tfree( *subject ) ;\n" ) ;
		printf( "\t\t*subject = NULL ;\n" ) ;
		printf( "\t}\n" ) ;
		break ;
	}
}

void free_deep_sum( char *tabs, sum *cur ) {
	while( cur != NULL ) {
		free_deep_summand( tabs, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void free_deep_summand( char *tabs, summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;

	printf( "%scase %s:\n", tabs, constr_nm ) ;
	free_deep_product( tabtabs( tabs ), constr_nm, gtSUMMANDproduct( cur ) ) ;
	printf( "%s\tbreak ;\n", tabs ) ;
}

void free_deep_product( char *tabs, char *constr_nm, product *cur ) {
	cur = flproduct( FACTOR_STRUCTURAL, cur ) ;
	general_product( "", "%ifd%t( &((*subject)->%C_%f) ) ;\n", tabs, NULL, constr_nm, cur ) ;
}

void copy_def( char *def_nm, def *cur ) {
	printf( "%s *cp%s( %s *subject ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\t%s *result = calloc( 1, sizeof( struct %s_struct ) ) ;\n", def_nm, def_nm ) ;
	printf( "\tcheck_ptr( result, \"calloc cp%s\" ) ;\n", def_nm ) ;
	printf( "\tcheck_ptr( subject, \"cp%s\" ) ;\n", def_nm ) ;
	printf( "\tmemcpy( result, subject, sizeof( struct %s_struct ) ) ;\n", def_nm ) ;
	printf( "\treturn result ;\n" ) ;
	printf( "}\n\n" ) ;

	printf( "void mv%s( %s *subject, %s *object ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\tcheck_ptr( subject, \"mv%s\" ) ;\n", def_nm ) ;
	printf( "\tcheck_ptr( object, \"mv%s\" ) ;\n", def_nm ) ;
	printf( "\tmemcpy( object, subject, sizeof( struct %s_struct ) ) ;\n", def_nm ) ;
	printf( "}\n\n" ) ;
}

void print_def( char *def_nm, def *cur ) {
	print_adt( def_nm, gtDEFproduct( cur ), gtDEFadt( cur ) ) ;
}

void print_adt( char *def_nm, product *prod, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		if( gtADTclass( cur ) == NULL ) {
			print_instance_adt( def_nm, prod, cur ) ;
		} else if( strcmp( gtADTclass( cur ), "list" ) == 0 ) {
			print_instance_list( def_nm, prod, cur ) ;
		} else {
			print_instance_adt( def_nm, prod, cur ) ;
		}
		break ;
	}
}

void print_instance_adt( char *def_nm, product *prod, adt *cur ) {
	printf( "void pr%s( int indent, %s *subject ) {\n", def_nm, def_nm ) ;
	printf( "\tif( subject == NULL ) {\n" ) ;
	printf( "\t\tprintf( \"NULL\" ) ;\n" ) ;
	if( sharing_check ) {
		printf( "\t} else if( subject->flag ) {\n" ) ;
		printf( "\t\tprintf( \"@%%d@\", subject->flag ) ;\n" ) ;
		printf( "\t} else {\n" ) ;
		printf( "\t\tsubject->flag = cnt++ ;\n" ) ;
		printf( "\t\tprintf( \"\\n%%-3d: %%*s\", subject->flag, indent, \"\" ) ;\n" ) ;
	} else {
		printf( "\t} else {\n" ) ;
		printf( "\t\tprintf( \"\\n%%*s\", indent, \"\" ) ;\n" ) ;
	}
	printf( "\t\tif( subject->tag == %s_BIND ) {\n", def_nm ) ;
	printf( "\t\t\tprintf( \"%s_BIND( %%p )\", (void*)subject->data._binding ) ;\n", def_nm ) ;
	printf( "\t\t} else {\n" ) ;
	printf( "\t\t\tswitch( subject->tag ) {\n" ) ;
	print_sum( "\t\t\t", prod, gtADTsum( cur ) ) ;
	printf( "\t\t\t}\n" ) ;
	printf( "\t\t}\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void print_instance_list( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "void pr%s( int indent, %s *subject ) {\n", def_nm, def_nm ) ;
	printf( "\tprintf( \"[\" ) ;\n" ) ;
	printf( "\twhile( subject != NULL ) {\n" ) ;
	if( sharing_check ) {
		printf( "\t\tif( subject->flag ) {\n" ) ;
		printf( "\t\t\tprintf( \"@%%d@\", subject->flag ) ;\n" ) ;
		printf( "\t\t\tbreak ;\n" ) ;
		printf( "\t\t} else if( subject->tag == %s_BIND ) {\n", def_nm ) ;
	} else {
		printf( "\t\tif( subject->tag == %s_BIND ) {\n", def_nm ) ;
	}
	printf( "\t\t\tprintf( \"%s_BIND( %%p )\", (void*)subject->data._binding ) ;\n", def_nm ) ;
	printf( "\t\t\tbreak ;\n" ) ;
	printf( "\t\t} else {\n" ) ;
	if( sharing_check ) {
		printf( "\t\t\tsubject->flag = cnt++ ;\n" ) ;
		printf( "\t\t\tprintf( \"\\n%%-3d: %%*s(\", subject->flag, indent, \"\" ) ;\n" ) ;
	} else {
		printf( "\t\t\tprintf( \"\\n%%*s(\", indent, \"\" ) ;\n" ) ;
	}
	if( prod != NULL ) {
		print_product( "\t\t\t", NULL, prod ) ;
		if( gtADTparameters( cur ) != NULL ) {
			printf( "\t\t\tprintf( \",\" ) ;\n" ) ;
		}
	}
	print_product( "\t\t\t", constr_nm, gtADTparameters( cur ) ) ;
	printf( "\t\t\tprintf( \" )\" ) ;\n" ) ;
	printf( "\t\t\tsubject = subject->data._%s._next ;\n", constr_nm ) ;
	printf( "\t\t\tif( subject != NULL ) {\n" ) ;
	printf( "\t\t\t\tprintf( \",\" ) ;\n" ) ;
	printf( "\t\t\t}\n" ) ;
	printf( "\t\t}\n" ) ;
	printf( "\t}\n" ) ;
	printf( "\tprintf( \"]\" ) ;\n" ) ;
	printf( "}\n\n" ) ;
}

void print_sum( char *tabs, product *prod, sum *cur ) {
	while( cur != NULL ) {
		print_summand( tabs, prod, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void print_summand( char *tabs, product *prod, summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;

	printf( "%scase %s:\n", tabs, constr_nm ) ;
	printf( "%s\tprintf( \"%%s( \", nametable[%s] ) ;\n", tabs, constr_nm ) ;
	if( prod != NULL ) {
		print_product( tabtabs( tabs ), NULL, prod ) ;
		if( gtSUMMANDproduct( cur ) != NULL ) {
			printf( "%s\tprintf( \",\" ) ;\n", tabs ) ;
		}
	}
	print_product( tabtabs( tabs ), constr_nm, gtSUMMANDproduct( cur ) ) ;
	printf( "%s\tprintf( \" )\" ) ;\n", tabs ) ;
	printf( "%s\tbreak ;\n", tabs ) ;
}

void print_product( char *tabs, char *constr_nm, product *cur ) {
	general_product( "%iprintf( \",\" ) ;\n",
		"%iprintf( \"%f=\" ) ;\n%ipr%t( indent+1, subject->%C_%f ) ;\n", tabs, NULL, constr_nm, cur ) ;
}

void clear_def( char *def_nm, def *cur ) {
	clear_adt( def_nm, gtDEFproduct( cur ), gtDEFadt( cur ) ) ;
}

void clear_adt( char *def_nm, product *prod, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		clear_instance_adt( def_nm, prod, cur ) ;
		break ;
	}
}

void clear_instance_adt( char *def_nm, product *prod, adt *cur ) {
	printf( "void cl%s( %s *subject ) {\n", def_nm, def_nm ) ;
	if( sharing_check ) {
		printf( "\tif( subject != NULL && subject->flag ) {\n" ) ;
		clear_product( "\t\t", NULL, prod ) ;
		printf( "\t\tsubject->flag = 0 ;\n" ) ;
	} else {
		printf( "\tif( subject != NULL ) {\n" ) ;
		clear_product( "\t\t", NULL, prod ) ;
	}
	printf( "\t\tif( subject->tag != %s_BIND ) {\n", def_nm ) ;
	printf( "\t\t\tswitch( subject->tag ) {\n" ) ;
	clear_sum( "\t\t\t", gtADTsum( cur ) ) ;
	printf( "\t\t\t}\n" ) ;
	printf( "\t\t}\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void clear_sum( char *tabs, sum *cur ) {
	while( cur != NULL ) {
		clear_summand( tabs, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void clear_summand( char *tabs, summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;

	printf( "%scase %s:\n", tabs, constr_nm ) ;
	clear_product( tabtabs( tabs ), constr_nm, gtSUMMANDproduct( cur ) ) ;
	printf( "%s\tbreak ;\n", tabs ) ;
}

void clear_product( char *tabs, char *constr_nm, product *cur ) {
	general_product( "", "%icl%t( subject->%C_%f ) ;\n", tabs, NULL, constr_nm, cur ) ;
}

void high_level_instance_list_append( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;

	printf( "%s *ap%s( %s *subject, %s *object ) {\n", def_nm, def_nm, def_nm, def_nm ) ;
	printf( "\t%s *last = NULL ;\n", def_nm ) ;
	printf( "\t%s *curr = subject ;\n", def_nm ) ;
	printf( "\twhile( curr != NULL ) {\n" ) ;
	printf( "\t\tif( curr->tag != %s ) {\n", constr_nm ) ;
	printf( "\t\t\tfatal( 0, \"ap%s\" ) ;\n", def_nm ) ;
	printf( "\t\t} else {\n" ) ;
	printf( "\t\t\tlast = curr ;\n" ) ;
	printf( "\t\t\tcurr = curr->data._%s._next ;\n", constr_nm ) ;
	printf( "\t\t}\n" ) ;
	printf( "\t}\n" ) ;
	printf( "\tif( last == NULL ) {\n" ) ;
	printf( "\t\treturn object ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\tlast->data._%s._next = object ;\n", constr_nm ) ;
	printf( "\t\treturn subject ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_list_map( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	product *combined = func_approduct( prod, gtADTparameters( cur ) ) ;

	printf( "void it%s( void ( *f ) ( void *, ", def_nm ) ;
	formal_product( combined ) ;
	printf( "), void *x, %s *subject ) {\n", def_nm ) ;
	printf( "\twhile( subject != NULL ) {\n" ) ;
	printf( "\t\tif( subject->tag != %s ) {\n", constr_nm ) ;
	printf( "\t\t\tfatal( 0, \"it%s\" ) ;\n", def_nm ) ;
	printf( "\t\t} else {\n" ) ;
	printf( "\t\t\tf( x, " ) ;
	actual_product( constr_nm, combined ) ;
	printf( " ) ;\n" ) ;
	printf( "\t\t\tsubject = subject->data._%s._next ;\n", constr_nm ) ;
	printf( "\t\t}\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_size( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "int size_%s( %s *subject ) {\n", def_nm, def_nm ) ;
	printf( "\tif( subject == NULL ) {\n" ) ;
	printf( "\t\treturn 0 ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\tint n = 0 ;\n" ) ;
	printf( "\t\t%s *cur = subject ;\n", def_nm ) ;
	printf( "\t\t\tcheck_ptr( cur, \"size_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tdo {\n" ) ;
	printf( "\t\t\tn++ ;\n" ) ;
	printf( "\t\t\tcur = cur->data._%s._next ;\n", constr_nm ) ;
	printf( "\t\t\tcheck_ptr( cur, \"size_%s\" ) ;\n", def_nm ) ;
	printf( "\t\t} while ( cur != subject ) ;\n" ) ;
	printf( "\t\treturn n ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_empty( char *def_nm, product *prod, adt *cur ) {
	printf( "bool empty_%s( %s *subject ) {\n", def_nm, def_nm ) ;
	printf( "\tif( subject == NULL ) {\n" ) ;
	printf( "\t\treturn True ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\treturn False ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_front( char *def_nm, product *prod, adt *cur ) {
	printf( "%s *front_%s( %s *subject ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\tcheck_ptr( subject, \"front_%s\" ) ;\n", def_nm ) ;
	printf( "\treturn subject ;\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_back( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "%s *back_%s( %s *subject ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\tcheck_ptr( subject, \"back_%s\" ) ;\n", def_nm ) ;
	printf( "\treturn subject->data._%s._prev ;\n", constr_nm ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_push_back( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "%s *push_back_%s( %s *subject, %s *object ) {\n", def_nm, def_nm, def_nm, def_nm ) ;
	printf( "\tcheck_ptr( object, \"push_back_%s\" ) ;\n", def_nm ) ;
	printf( "\tif( subject == NULL ) {\n" ) ;
	printf( "\t\treturn object ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\t%s *last ;\n", def_nm ) ;
	printf( "\t\tcheck_ptr( subject, \"push_back_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tlast = subject->data._%s._prev ;\n", constr_nm ) ;
	printf( "\t\tobject->data._%s._prev = last ;\n", constr_nm ) ;
	printf( "\t\tobject->data._%s._next = subject ;\n", constr_nm ) ;
	printf( "\t\tsubject->data._%s._prev = object ;\n", constr_nm ) ;
	printf( "\t\tlast->data._%s._next = object ;\n", constr_nm ) ;
	printf( "\t\treturn subject ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_push_front( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "%s *push_front_%s( %s *subject, %s *object ) {\n", def_nm, def_nm, def_nm, def_nm ) ;
	printf( "\tcheck_ptr( object, \"push_front_%s\" ) ;\n", def_nm ) ;
	printf( "\tif( subject == NULL ) {\n" ) ;
	printf( "\t\treturn object ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\t%s *last ;\n", def_nm ) ;
	printf( "\t\tcheck_ptr( subject, \"push_front_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tlast = subject->data._%s._prev ;\n", constr_nm ) ;
	printf( "\t\tobject->data._%s._prev = last ;\n", constr_nm ) ;
	printf( "\t\tobject->data._%s._next = subject ;\n", constr_nm ) ;
	printf( "\t\tsubject->data._%s._prev = object ;\n", constr_nm ) ;
	printf( "\t\tlast->data._%s._next = object ;\n", constr_nm ) ;
	printf( "\t\treturn object ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_pop_back( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "%s *pop_back_%s( %s *subject ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\t%s *object ;\n", def_nm ) ;
	printf( "\tcheck_ptr( subject, \"pop_back_%s\" ) ;\n", def_nm ) ;
	printf( "\tobject = subject->data._%s._prev ;\n", constr_nm ) ;
	printf( "\tcheck_ptr( object, \"pop_back_%s\" ) ;\n", def_nm ) ;
	printf( "\tif( subject == object ) {\n" ) ;
	printf( "\t\treturn NULL ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\t%s *last = object->data._%s._prev ;\n", def_nm, constr_nm ) ;
	printf( "\t\tcheck_ptr( last, \"pop_back_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tsubject->data._%s._prev = last ;\n", constr_nm ) ;
	printf( "\t\tlast->data._%s._next = subject ;\n", constr_nm ) ;
	printf( "\t\treturn subject ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_pop_front( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "%s *pop_front_%s( %s *object ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\t%s *subject ;\n", def_nm ) ;
	printf( "\tcheck_ptr( object, \"pop_front_%s\" ) ;\n", def_nm ) ;
	printf( "\tsubject = object->data._%s._next ;\n", constr_nm ) ;
	printf( "\tcheck_ptr( subject, \"pop_front_%s\" ) ;\n", def_nm ) ;
	printf( "\tif( object == subject ) {\n" ) ;
	printf( "\t\treturn NULL ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\t%s *last = object->data._%s._prev ;\n", def_nm, constr_nm ) ;
	printf( "\t\tcheck_ptr( last, \"pop_front_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tsubject->data._%s._prev = last ;\n", constr_nm ) ;
	printf( "\t\tlast->data._%s._next = subject ;\n", constr_nm ) ;
	printf( "\t\treturn subject ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_erase( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "%s *erase_%s( %s *subject, %s *start, %s *end ) {\n", def_nm, def_nm, def_nm, def_nm, def_nm ) ;
	printf( "\tcheck_ptr( subject, \"erase_%s\" ) ;\n", def_nm ) ;
	printf( "\tcheck_ptr( start, \"erase_%s\" ) ;\n", def_nm ) ;
	printf( "\tcheck_ptr( end, \"erase_%s\" ) ;\n", def_nm ) ;
	printf( "\tif( start == end ) {\n" ) ;
	printf( "\t\treturn subject ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\tstart->data._%s._next = end ;\n", constr_nm ) ;
	printf( "\t\tend->data._%s._prev = start ;\n", constr_nm ) ;
	printf( "\t\treturn subject ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_insert( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	printf( "%s *insert_%s( %s *subject, %s *start, %s *object ) {\n", def_nm, def_nm, def_nm, def_nm, def_nm ) ;
	printf( "\t%s *prev, *last ;\n", def_nm ) ;
	printf( "\tif( object != NULL ) {\n" ) ;
	printf( "\t\tcheck_ptr( subject, \"insert_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tcheck_ptr( start, \"insert_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tcheck_ptr( object, \"insert_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tprev = start->data._%s._prev ;\n", constr_nm ) ;
	printf( "\t\tlast = object->data._%s._prev ;\n", constr_nm ) ;
	printf( "\t\tprev->data._%s._next = object ;\n", constr_nm ) ;
	printf( "\t\tobject->data._%s._prev = prev ;\n", constr_nm ) ;
	printf( "\t\tstart->data._%s._prev = last ;\n", constr_nm ) ;
	printf( "\t\tlast->data._%s._next = start ;\n", constr_nm ) ;
	printf( "\t}\n" ) ;
	printf( "\treturn subject ;\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_dlist_remove_if( char *def_nm, product *prod, adt *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	product *combined = func_approduct( prod, gtADTparameters( cur ) ) ;
	printf( "%s *remove_if_%s( bool ( *f ) ( void *, ", def_nm, def_nm ) ;
	formal_product( combined ) ;
	printf( "), void *x, %s *subject ) {\n", def_nm ) ;
	printf( "\tif( subject == NULL ) {\n" ) ;
	printf( "\t\treturn NULL ;\n" ) ;
	printf( "\t} else {\n" ) ;
	printf( "\t\t%s *cur = subject ;\n", def_nm ) ;
	printf( "\t\t%s *object = NULL ;\n", def_nm ) ;
	printf( "\t\tcheck_ptr( cur, \"remove_if_%s\" ) ;\n", def_nm ) ;
	printf( "\t\tdo {\n" ) ;
	printf( "\t\t\t%s *next = cur->data._%s._next ;\n", def_nm, constr_nm ) ;
	printf( "\t\t\tcheck_ptr( next, \"remove_if_%s\" ) ;\n", def_nm ) ;
	printf( "\t\t\tif( f( x, " ) ;
	actual_product( constr_nm, combined ) ;
	printf( " ) ) {\n" ) ;
	printf( "\t\t\t\t%s *prev = cur->data._%s._prev ;\n", def_nm, constr_nm ) ;
	printf( "\t\t\t\tcheck_ptr( prev, \"remove_if_%s\" ) ;\n", def_nm ) ;
	printf( "\t\t\t\tprev->data._%s._next = next ;\n", constr_nm ) ;
	printf( "\t\t\t\tnext->data._%s._prev = prev ;\n", constr_nm ) ;
	printf( "\t\t\t} else if( object == NULL ) {\n" ) ;
	printf( "\t\t\t\tobject = cur ;\n" ) ;
	printf( "\t\t\t}\n" ) ;
	printf( "\t\t\tcur = next ;\n" ) ;
	printf( "\t\t} while ( cur != subject ) ;\n" ) ;
	printf( "\t\treturn object ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void high_level_instance_tree_traverse( char *def_nm, product *prod, adt *cur ) {
	char *constr1_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtADTsum( cur ) ) ) ) ;
	char *constr2_nm = gtIDENTident( gtSUMMANDident( gtSUMsummand( gtSUMnext( gtADTsum( cur ) ) ) ) ) ;
	product *combined = func_approduct( prod, gtADTparameters( cur ) ) ;

	printf( "void tr%s( void ( *f ) ( void *, ", def_nm ) ;
	formal_product( combined ) ;
	printf( "), void *x, %s *subject ) {\n", def_nm ) ;
	printf( "\tcheck_ptr( subject, \"tr%s\" ) ;\n", def_nm ) ;
	printf( "\tswitch( subject->tag ) {\n" ) ;
	printf( "\tcase %s :\n", constr1_nm ) ;
	printf( "\t\tf( x, " ) ;
	actual_product( constr1_nm, combined ) ;
	printf( " ) ;\n" ) ;
	printf( "\t\tbreak ;\n" ) ;
	printf( "\tcase %s :\n", constr2_nm ) ;
	printf( "\t\ttr%s( f, x, subject->data._%s._left ) ;\n", def_nm, constr2_nm ) ;
	printf( "\t\tf( x, " ) ;
	actual_product( constr2_nm, combined ) ;
	printf( " ) ;\n" ) ;
	printf( "\t\ttr%s( f, x, subject->data._%s._right ) ;\n", def_nm, constr2_nm ) ;
	printf( "\t\tbreak ;\n" ) ;
	printf( "\t}\n" ) ;
	printf( "}\n\n" ) ;
}

void match_def( char *def_nm, def *cur ) {
	match_adt( def_nm, gtDEFproduct( cur ), gtDEFadt( cur ) ) ;
}

void match_adt( char *def_nm, product *prod, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		match_instance_adt( def_nm, prod, cur ) ;
		break ;
	}
}

void match_instance_adt( char *def_nm, product *prod, adt *cur ) {
	printf( "bool mt%s( %s *pattern, %s *subject ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\tif( pattern == NULL ) {\n" ) ;
	printf( "\t\treturn True ;\n" ) ;
	printf( "\t} else if( pattern->tag == %s_BIND ) {\n", def_nm ) ;
	printf( "\t\t*( pattern->data._binding ) = subject ;\n" ) ;
	printf( "\t\treturn True ;\n" ) ;
	printf( "\t} else if( subject == NULL ) {\n" ) ;
	printf( "\t\treturn False ;\n" ) ;
	if( flproduct( FACTOR_STRUCTURAL, prod ) != NULL ) {
		printf( "\t} else if( !(" ) ;
		match_product( "\t\t", NULL, prod ) ;
		printf( " ) ) {\n" ) ;
		printf( "\t\treturn False ;\n" ) ;
	}
	printf( "\t} else {\n" ) ;
	printf( "\t\tswitch( pattern->tag ) {\n" ) ;
	match_sum( "\t\t", gtADTsum( cur ) ) ;
	printf( "\t\t}\n" ) ;
	printf( "\t}\n" ) ;
	printf( "\treturn False ;\n" ) ;
	printf( "}\n\n" ) ;
}

void match_sum( char *tabs, sum *cur ) {
	while( cur != NULL ) {
		match_summand( tabs, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void match_summand( char *tabs, summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;

	printf( "%scase %s:\n", tabs, constr_nm ) ;
	printf( "%s\treturn pattern->tag == subject->tag", tabs ) ;
	if( gtSUMMANDproduct( cur ) != NULL ) {
		printf( " &&\n%s\t\t", tabs ) ;
		match_product( tabtabs( tabtabs( tabs ) ), constr_nm, gtSUMMANDproduct( cur ) ) ;
	}
	printf( " ;\n" ) ;
	printf( "%s\tbreak ;\n", tabs ) ;
}

void match_product( char *tabs, char *constr_nm, product *cur ) {
	cur = flproduct( FACTOR_STRUCTURAL, cur ) ;
	general_product( " &&\n%i", "mt%t( pattern->%C_%f, subject->%C_%f )", tabs, NULL, constr_nm, cur ) ;
}

void tag_def( char *def_nm, def *cur ) {
	printf( "#ifndef _FAST_\n" ) ;
	printf( "%s_tag gt%stag( %s *subject ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\tcheck_ptr( subject, \"gt%stag\" ) ;\n", def_nm ) ;
	printf( "\tif( subject->tag == %s_BIND ) {\n", def_nm ) ;
	printf( "\t\tfatal( 0, \"gt%stag\" ) ;\n", def_nm ) ;
	printf( "\t}\n" ) ;
	printf( "\treturn subject->tag ;\n" ) ;
	printf( "}\n" ) ;
	printf( "#endif\n\n" ) ;
	printf( "void st%stag( %s *subject, %s_tag tag ) {\n", def_nm, def_nm, def_nm ) ;
	printf( "\tcheck_ptr( subject, \"st%stag\" ) ;\n", def_nm ) ;
	printf( "\tif( tag == %s_BIND ) {\n", def_nm ) ;
	printf( "\t\tfatal( 0, \"st%stag\" ) ;\n", def_nm ) ;
	printf( "\t}\n" ) ;
	printf( "\tsubject->tag = tag ;\n" ) ;
	printf( "}\n\n" ) ;
	printf( "void lf%s( %s *subject ) {\n", def_nm, def_nm ) ;
	printf( "\tcheck_ptr( subject, \"lf%s\" ) ;\n", def_nm ) ;
	if( error_details ) {
		printf( "\tif( subject->filename != NULL ) {\n" ) ;
		printf( "\t\tlineno = subject->lineno ; \n" ) ;
		printf( "\t\tcharno = subject->charno ; \n" ) ;
		printf( "\t\tfilename=subject->filename ;\n\t}\n" ) ;
	}
	printf( "}\n\n" ) ;
}

void fun_input( input *root ) {
	fun_body( gtINPUTbody( root ) ) ;
}

void fun_body( body *cur ) {
	while( cur != NULL ) {
		fun_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void fun_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;

	bind_def( def_nm, cur ) ;
	free_def( def_nm, cur ) ;
	free_deep_def( def_nm, cur ) ;
	copy_def( def_nm, cur ) ;
	print_def( def_nm, cur ) ;
	clear_def( def_nm, cur ) ;
	match_def( def_nm, cur ) ;
	tag_def( def_nm, cur ) ;

	fun_product( def_nm, NULL, gtDEFproduct( cur ) ) ;
	fun_adt( def_nm, gtDEFproduct( cur ), gtDEFadt( cur ) ) ;
}

void fun_adt( char *def_nm, product *prod, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		fun_sum( def_nm, prod, gtADTsum( cur ) ) ;
		if( gtADTclass( cur ) == NULL ) {
			break ;
		} else if( strcmp( gtADTclass( cur ), "list" ) == 0 ) {
			high_level_instance_list_append( def_nm, prod, cur ) ;
			high_level_instance_list_map( def_nm, prod, cur ) ;
		} else if( strcmp( gtADTclass( cur ), "dlist" ) == 0 ) {
			high_level_instance_dlist_size( def_nm, prod, cur ) ;
			high_level_instance_dlist_empty( def_nm, prod, cur ) ;
			high_level_instance_dlist_front( def_nm, prod, cur ) ;
			high_level_instance_dlist_back( def_nm, prod, cur ) ;
			high_level_instance_dlist_push_back( def_nm, prod, cur ) ;
			high_level_instance_dlist_push_front( def_nm, prod, cur ) ;
			high_level_instance_dlist_pop_back( def_nm, prod, cur ) ;
			high_level_instance_dlist_pop_front( def_nm, prod, cur ) ;
			high_level_instance_dlist_erase( def_nm, prod, cur ) ;
			high_level_instance_dlist_insert( def_nm, prod, cur ) ;
			high_level_instance_dlist_remove_if( def_nm, prod, cur ) ;
		} else if( strcmp( gtADTclass( cur ), "tree" ) == 0 ) {
			high_level_instance_tree_traverse( def_nm, prod, cur ) ;
		}
		break ;
	}
}

void fun_sum( char *def_nm, product *prod, sum *cur ) {
	while( cur != NULL ) {
		fun_summand( def_nm, prod, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void fun_summand( char *def_nm, product *prod, summand *cur ) {
	if( cur != NULL ) {
		char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;
		product *combined = func_approduct( prod, gtSUMMANDproduct( cur ) ) ;

		printf( "%s *mk%s( ", def_nm, constr_nm ) ;
		decl_product( combined ) ;
		printf( " ) { \n" ) ;
		printf( "\t%s *result = calloc( 1, sizeof( struct %s_struct ) ) ;\n", def_nm, def_nm ) ;
		printf( "\tcheck_ptr( result, \"calloc mk%s\" ) ;\n", constr_nm ) ;
		printf( "\tresult->tag = %s ;\n", constr_nm ) ;
		if( sharing_check ) {
			printf( "\tresult->flag = 0 ;\n" ) ;
		}
		if( error_details ) {
			printf( "\tresult->lineno = lineno ;\n" ) ;
			printf( "\tresult->charno = charno ;\n" ) ;
			printf( "\tresult->filename = filename ;\n" ) ;
		}
		init_product( NULL, prod ) ;
		init_product( constr_nm, gtSUMMANDproduct( cur ) ) ;
		printf( "\treturn result ;\n" ) ;
		printf( "}\n\n" ) ;

		printf( "%s *pt%s( ", def_nm, constr_nm ) ;
		decl_product( combined ) ;
		printf( " ) { \n" ) ;
		printf( "\t%s *result = calloc( 1, sizeof( struct %s_struct ) ) ;\n", def_nm, def_nm ) ;
		printf( "\tcheck_ptr( result, \"calloc pt%s\" ) ;\n", constr_nm ) ;
		printf( "\tresult->tag = %s ;\n", constr_nm ) ;
		if( sharing_check ) {
			printf( "\tresult->flag = 0 ;\n" ) ;
		}
		if( error_details ) {
			printf( "\tresult->lineno = lineno ;\n" ) ;
			printf( "\tresult->charno = charno ;\n" ) ;
			printf( "\tresult->filename = filename ;\n" ) ;
		}
		init_product( NULL, prod ) ;
		init_product( constr_nm, gtSUMMANDproduct( cur ) ) ;
		printf( "\treturn result ;\n" ) ;
		printf( "}\n\n" ) ;

		fun_product( def_nm, constr_nm, gtSUMMANDproduct( cur ) ) ;
	}
}

void fun_product( char *def_nm, char *constr_nm, product *cur ) {
	while( cur != NULL ) {
		fun_factor( def_nm, constr_nm, gtPRODUCTfactor( cur ) ) ;
		cur = gtPRODUCTnext( cur ) ;
	}
}

void fun_factor( char *def_nm, char *constr_nm, factor *cur ) {
	char *type_nm = gtIDENTident( gtFACTORtype( cur ) ) ;
	char *field_nm = gtIDENTident( gtFACTORfield( cur ) ) ;
	char *star = gtFACTORstar( cur ) ;

	if( constr_nm == NULL ) {
		printf( "%s *%sad%s%s( %s *subject ) {\n", type_nm, star, def_nm, field_nm, def_nm ) ;
		printf( "\tcheck_ptr( subject, \"ad%s%s\" ) ;\n", def_nm, field_nm ) ;
		printf( "\treturn &subject->_%s ;\n", field_nm ) ;
		printf( "}\n" ) ;
		printf( "#ifndef _FAST_\n" ) ;
		printf( "%s %sgt%s%s( %s *subject ) {\n", type_nm, star, def_nm, field_nm, def_nm ) ;
		printf( "\tcheck_ptr( subject, \"gt%s%s\" ) ;\n", def_nm, field_nm ) ;
		printf( "\treturn subject->_%s ;\n", field_nm ) ;
		printf( "}\n" ) ;
		printf( "#endif\n\n" ) ;
	
		printf( "void st%s%s( %s *subject, %s %svalue ) {\n", def_nm, field_nm, def_nm, type_nm, star ) ;
		printf( "\tcheck_ptr( subject, \"st%s%s\" ) ;\n", def_nm, field_nm ) ;
		printf( "\tsubject->_%s = value ;\n", field_nm ) ;
		printf( "}\n\n" ) ;
	} else {
		printf( "%s *%sad%s%s( %s *subject ) {\n", type_nm, star, constr_nm, field_nm, def_nm ) ;
		printf( "\tcheck_tag( subject, %s, \"ad%s%s\" ) ;\n", constr_nm, constr_nm, field_nm ) ;
		printf( "\treturn &subject->data._%s._%s ;\n", constr_nm, field_nm ) ;
		printf( "}\n\n" ) ;
		printf( "#ifndef _FAST_\n" ) ;
		printf( "%s %sgt%s%s( %s *subject ) {\n", type_nm, star, constr_nm, field_nm, def_nm ) ;
		printf( "\tcheck_tag( subject, %s, \"gt%s%s\" ) ;\n", constr_nm, constr_nm, field_nm ) ;
		printf( "\treturn subject->data._%s._%s ;\n", constr_nm, field_nm ) ;
		printf( "}\n\n" ) ;
		printf( "#endif\n\n" ) ;
	
		printf( "void st%s%s( %s *subject, %s %svalue ) {\n", constr_nm, field_nm, def_nm, type_nm, star ) ;
		printf( "\tcheck_tag( subject, %s, \"st%s%s\" ) ;\n", constr_nm, constr_nm, field_nm ) ;
		printf( "\tsubject->data._%s._%s = value ;\n", constr_nm, field_nm ) ;
		printf( "}\n\n" ) ;
	}
}

void protemp_input( input *root ) {
	protemp_body( gtINPUTbody( root ) ) ;
}

void protemp_body( body *cur ) {
	while( cur != NULL ) {
		protemp_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void protemp_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;

	printf( "void XXX%s( %s *subject ) ;\n", def_nm, def_nm ) ;
}

void funtemp_input( input *root ) {
	funtemp_body( gtINPUTbody( root ) ) ;
}

void funtemp_body( body *cur ) {
	while( cur != NULL ) {
		funtemp_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void funtemp_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;

	printf( "void XXX%s( %s *subject ) {\n", def_nm, def_nm ) ;
	funtemp_adt( def_nm, gtDEFproduct( cur ), gtDEFadt( cur ) ) ;
	printf( "}\n\n" ) ;
}

void funtemp_adt( char *def_nm, product *prod, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		funtemp_product( "\t", def_nm, def_nm, prod ) ;
		printf( "\tswitch( gt%stag( subject ) ) {\n", def_nm ) ;
		funtemp_sum( "\t", def_nm, gtADTsum( cur ) ) ;
		printf( "\t}\n" ) ;
		break ;
	}
}

void funtemp_sum( char *tabs, char *def_nm, sum *cur ) {
	while( cur != NULL ) {
		funtemp_summand( tabs, def_nm, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void funtemp_summand( char *tabs, char *def_nm, summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;

	printf( "%scase %s :\n", tabs, constr_nm ) ;
	funtemp_product( tabtabs( tabs ), def_nm, constr_nm, gtSUMMANDproduct( cur ) ) ;
	printf( "%s\tbreak ;\n", tabs ) ;
}

void funtemp_product( char *tabs, char *def_nm, char *constr_nm, product *cur ) {
	cur = flproduct( FACTOR_STRUCTURAL, cur ) ;
	general_product( "", "%iXXX%t( gt%c%f( subject ) ) ;\n", tabs, def_nm, constr_nm, cur ) ;
}

int def_body( char *subject, body *cur ) {
	int accu = 0 ;
	while( cur != NULL ) {
		accu += def_def( subject, gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
	return accu ;
}

int def_def( char *subject, def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	return strcmp( def_nm, subject ) == 0 ? 1 : 0 ;
}

int constr_body( char *subject, body *cur ) {
	int accu = 0 ;
	while( cur != NULL ) {
		accu += constr_def( subject, gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
	return accu ;
}

int constr_def( char *subject, def *cur ) {
	return constr_adt( subject, gtDEFadt( cur ) ) ;
}

int constr_adt( char *subject, adt *cur ) {
	int result = 0 ;
	switch( gtadttag( cur ) ) {
	case ADT :
		result = constr_sum( subject, gtADTsum( cur ) ) ;
		break;
	}
	return result ;
}

int constr_sum( char *subject, sum *cur ) {
	int accu = 0 ;
	while( cur != NULL ) {
		accu += constr_summand( subject, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
	return accu ;
}

int constr_summand( char *subject, summand *cur ) {
	if( cur != NULL ) {
		char *constr_nm = gtIDENTident( gtSUMMANDident ( cur ) ) ;
		return strcmp( constr_nm, subject ) == 0 ? 1 : 0 ;
	} else {
		return 0 ;
	}
}

void check_input( input *root ) {
	check_body( gtINPUTbody( root ), gtINPUTbody( root ) ) ;
}

void check_body( body *body_root, body *cur ) {
	while( cur != NULL ) {
		check_def( body_root, gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void check_def( body *body_root, def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;
	if( gtDEFcomment( cur ) == NULL && defcomment ) {
		fprintf( stderr, "%s:%d: warning: comment missing for %s.\n", gtdeffilename( cur ), gtdeflineno( cur ), def_nm ) ;
	}
	if( def_body( def_nm, body_root ) > 1 ) {
		fprintf( stderr, "%s:%d: warning: algebraic data type %s multiply defined.\n", gtdeffilename( cur ), gtdeflineno( cur ), def_nm ) ;
	}
	check_adt( body_root, gtDEFadt( cur ) ) ;
	check_product( gtDEFproduct( cur ) ) ;
}

void check_adt( body *body_root, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		check_sum( body_root, gtADTsum( cur ) ) ;
		break ;
	}
}

void check_sum( body *body_root, sum *cur ) {
	while( cur != NULL ) {
		check_summand( body_root, gtSUMsummand( cur ) ) ;
		cur = gtSUMnext( cur ) ;
	}
}

void check_summand( body *body_root, summand *cur ) {
	char *constr_nm = gtIDENTident( gtSUMMANDident( cur ) ) ;
	if( gtSUMMANDcomment( cur ) == NULL && summandcomment ) {
		fprintf( stderr, "%s:%d: warning: comment missing for %s.\n", gtsummandfilename( cur ), gtsummandlineno( cur ), constr_nm ) ;
	}
	if( constr_body( constr_nm, body_root ) > 1 ) {
		fprintf( stderr, "%s:%d: warning: constructor %s multiply defined.\n", gtsummandfilename( cur ), gtsummandlineno( cur ), constr_nm ) ;
	}
}

void check_product( product *cur ) {
	while( cur != NULL ) {
		check_factor( gtPRODUCTfactor( cur ) ) ;
		cur = gtPRODUCTnext( cur ) ;
	}
}

void check_factor( factor *cur ) {
	char *field_nm = gtIDENTident( gtFACTORfield( cur ) ) ;
	if( gtFACTORcomment( cur ) == NULL && factorcomment ) {
		fprintf( stderr, "%s:%d: warning: comment missing for %s.\n", gtfactorfilename( cur ), gtfactorlineno( cur ), field_nm ) ;
	}
	if( strcmp( field_nm, "tag" ) == 0 || strcmp( field_nm, "prev" ) == 0 || strcmp( field_nm, "next" ) == 0 ) {
		fprintf( stderr, "%s:%d: warning: reserved field name.\n", gtfactorfilename( cur ), gtfactorlineno( cur ) ) ;
	}
}

void instantiate_adt_input( input *root ) {
	instantiate_adt_body( gtINPUTbody( root ) ) ;
}

void instantiate_adt_body( body *cur ) {
	while( cur != NULL ) {
		instantiate_adt_def( gtBODYdef( cur ) ) ;
		cur = gtBODYnext( cur ) ;
	}
}

void instantiate_adt_def( def *cur ) {
	char *def_nm = gtIDENTident( gtDEFident( cur ) ) ;

	instantiate_adt_adt( def_nm, gtDEFadt( cur ) ) ;
}

void instantiate_adt_adt( char *def_nm, adt *cur ) {
	switch( gtadttag( cur ) ) {
	case ADT :
		if( gtADTclass( cur ) == NULL ) {
			break ;
		} else if( strcmp( gtADTclass( cur ), "list" ) == 0 ) {
			instantiate_adt_list( def_nm, cur ) ;
		} else if( strcmp( gtADTclass( cur ), "dlist" ) == 0 ) {
			instantiate_adt_dlist( def_nm, cur ) ;
		} else if( strcmp( gtADTclass( cur ), "tree" ) == 0 ) {
			instantiate_adt_tree( def_nm, cur ) ;
		}
		break ;
	}
}

void instantiate_adt_list( char *def_nm, adt *cur ) {
	factor *next = mkFACTOR( "", FACTOR_STRUCTURAL, mkIDENT( def_nm ), "*", mkIDENT( "next" ) ) ;
	product *product = func_approduct( gtADTparameters( cur ), mkPRODUCT( next, NULL ) ) ;
	ident *ident = mkIDENT( flipcase( def_nm, "" ) ) ;
	summand *summand = mkSUMMAND( "", ident, product ) ;
	sum *sum = mkSUM( summand, NULL ) ;
	stADTsum( cur, sum ) ;
}

void instantiate_adt_dlist( char *def_nm, adt *cur ) {
	factor *prev = mkFACTOR( "", FACTOR_STRUCTURAL, mkIDENT( def_nm ), "*", mkIDENT( "prev" ) ) ;
	factor *next = mkFACTOR( "", FACTOR_STRUCTURAL, mkIDENT( def_nm ), "*", mkIDENT( "next" ) ) ;
	product *product = func_approduct_3( gtADTparameters( cur ), mkPRODUCT( prev, NULL ), mkPRODUCT( next, NULL ) ) ;
	ident * ident = mkIDENT( flipcase( def_nm, "" ) ) ;
	summand *summand = mkSUMMAND( "", ident, product ) ;
	sum *sum = mkSUM( summand, NULL ) ;
	stADTsum( cur, sum ) ;
}

void instantiate_adt_tree( char *def_nm, adt *cur ) {
	product *product1 = gtADTparameters( cur ) ;
	ident * ident1 = mkIDENT( flipcase( def_nm, "leaf" ) ) ;
	summand *summand1 = mkSUMMAND( "", ident1, product1 ) ;

	factor *left2 = mkFACTOR( "", FACTOR_STRUCTURAL, mkIDENT( def_nm ), "*", mkIDENT( "left" ) ) ;
	factor *right2 = mkFACTOR( "", FACTOR_STRUCTURAL, mkIDENT( def_nm ), "*", mkIDENT( "right" ) ) ;
	product *product2 = func_approduct_3( gtADTparameters( cur ), mkPRODUCT( left2, NULL ), mkPRODUCT( right2, NULL ) ) ;
	ident * ident2 = mkIDENT( flipcase( def_nm, "branch" ) ) ;
	summand *summand2 = mkSUMMAND( "", ident2, product2 ) ;

	sum *sum = mkSUM( summand1, mkSUM( summand2, NULL) ) ;
	stADTsum( cur, sum ) ;
}

void usage( char *prog ) {
	fprintf( stderr, "usage: %s {flags} file.adt\n", prog ) ;
	fprintf( stderr, "     -N: do not generate a void fatal( ... ).\n" ) ;
	fprintf( stderr, "    -cd: do not check that there is a comment before a definition.\n" ) ;
	fprintf( stderr, "    -ct: do not check that there is a comment before a summand.\n" ) ;
	fprintf( stderr, "    -cf: do not check that there is a comment before a factor.\n" ) ;
	fprintf( stderr, "     -d: dump the abstract syntax tree of the input.\n" ) ;
	fprintf( stderr, "     -h: generate typedefs and prototypes.\n" ) ;
	fprintf( stderr, "     -c: generate function bodies.\n" ) ;
	fprintf( stderr, "     -t: generate template for traversal function.\n" ) ;
	fprintf( stderr, "     -l: generate latex document.\n" ) ;
	fprintf( stderr, "     -e: do not print error details, such as finename, lineo and charno.\n" ) ;
	fprintf( stderr, "default: perform all checks only.\n" ) ;
	abort( ) ;
}

int main( int argc, char *argv[] ) {
	bool code = False ;
	bool dump = False ;
	bool header = False ;
	bool template = False ;
	bool latex = False ;
	char *buffer = NULL ;
	char *suffix = NULL ;
	int fataldefined = False ;
	int i ;

	for( i = 1 ; i < argc ; i++ ) {
		if( strcmp( argv[i], "-c" ) == 0 ) {
			code = True ;
		} else if( strcmp( argv[i], "-cd" ) == 0 ) {
			defcomment = False ;
		} else if( strcmp( argv[i], "-ct" ) == 0 ) {
			summandcomment = False ;
		} else if( strcmp( argv[i], "-cf" ) == 0 ) {
			factorcomment = False ;
		} else if( strcmp( argv[i], "-N" ) == 0 ) {
			fataldefined = True ;
		} else if( strcmp( argv[i], "-d" ) == 0 ) {
			dump = True ;
		} else if( strcmp( argv[i], "-h" ) == 0 ) {
			header = True ;
		} else if( strcmp( argv[i], "-t" ) == 0 ) {
			template = True ;
		} else if( strcmp( argv[i], "-e" ) == 0 ) {
			error_details = False ;
		} else if( strcmp( argv[i], "-s" ) == 0 ) {
			sharing_check = False ;
		} else if( strcmp( argv[i], "-l" ) == 0 ) {
			latex = True ;
		} else if( argv[i][0] != '-' ) {
			filename = argv[i] ;
			buffer = strdup( filename ) ;
			suffix = strstr( buffer, ".adt" ) ;
		} else {
			usage( argv[0] ) ;
			exit( 1 ) ;
		}
	}
	if( filename == NULL || suffix == NULL || strcmp( suffix, ".adt" ) != 0 ) {
		usage( argv[0] ) ;
	}
	if( freopen( filename, "r", stdin ) == NULL ) {
		fatal( 0, "Cannot read inputfile" ) ;
	}

	yyparse( ) ;
	if( root == NULL ) {
		return 0 ;
	}
	instantiate_adt_input( root ) ;
	check_input( root ) ;

	if( dump ) {
		prinput( 1, root ) ;
		printf( "\n" ) ;
	}
	if( header ) {
		*suffix = '\0' ;
		strcat( buffer, ".h" ) ;
		if( freopen( buffer, "w", stdout ) == NULL ) {
			fatal( 0, "Cannot write .h file" ) ;
		}
		printf( "/* FILE GENERATED BY ADT, DO NOT EDIT\n" ) ;
		nocomment_input( root ) ;
		printf( "\n*/\n\n" ) ;

		*suffix = '\0' ;
		printf( "#ifndef _%s_\n", buffer ) ;
		printf( "#define _%s_\n\n", buffer ) ;
		if( !fataldefined ) {
			printf( "extern void fatal( int dummy, char *s, ... ) ;\n" ) ;
		}
		printf( "#define\tcheck_ptr( source, proc )\\\n" ) ;
		printf( "\tif( source == NULL ) { \\\n" ) ;
		printf( "\t\tfatal( 0, \"%%s( NULL )\", proc ) ;\\\n" ) ;
		printf( "\t}\n\n" ) ;
		printf( "#define\tcheck_tag( source, constr, proc )\\\n" ) ;
		printf( "\tcheck_ptr( source, proc )\\\n" ) ;
		printf( "\tif( source->tag != constr ) {\\\n" ) ;
		printf( "\t\t__adterr__( source, source->tag, constr, proc ) ;\\\n" ) ;
		printf( "\t}\n\n" ) ;
		enum_input( root ) ;
		printf( "\n" ) ;
		printf( "extern char *nametable [] ;\n" ) ;
		printf( "extern void __adterr__( void *, int, int, char * ) ;\n" ) ;
		printf( "typedef\tstruct admin_struct {\n" ) ;
		printf( "\tint tag ;\n" ) ;
		if( sharing_check ) {
			printf( "\tint flag ;\n" ) ;
		}
		if( error_details ) {
			printf( "\tint lineno ;\n" ) ;
			printf( "\tint charno ;\n" ) ;
			printf( "\tchar *filename ;\n" ) ;
		}
		printf( "} admin ;\n\n" ) ;
		struct_input( root ) ;
		pro_input( root ) ;
		case_input( root ) ;
		initialiser_input( root ) ;
		printf( "\n#endif\n" ) ;
	}
	if( code ) {
		*suffix = '\0' ;
		strcat( buffer, ".c" ) ;
		if( freopen( buffer, "w", stdout ) == NULL ) {
			fatal( 0, "Cannot write .c file" ) ;
		}

		printf( "/* FILE GENERATED BY ADT, DO NOT EDIT */\n" ) ;

		*suffix = '\0' ;
		strcat( buffer, ".h" ) ;
		if( gtINPUTheader( root ) != NULL ) {
			printf( "%s\n", gtINPUTheader( root ) ) ;
		}
		printf( "#include \"%s\"\n", buffer ) ;
		printf( "#include <stdlib.h>\n" ) ;
		printf( "#include <stdio.h>\n" ) ;
		printf( "#include <string.h>\n" ) ;
		if( !fataldefined ) {
			printf( "#include <stdarg.h>\n" ) ;
			printf( "void fatal( int dummy, char *s, ... ) {\n" ) ;
			printf( "\tva_list a ;\n" ) ;
			printf( "\tva_start( a, s ) ;\n" ) ;
			printf( "\tvfprintf( stderr, s, a ) ;\n" ) ;
			printf( "\tfprintf( stderr, \"\\n\" ) ;\n" ) ;
			printf( "\tabort() ;\n" ) ;
			printf( "\tva_end( a ) ;\n" ) ;
			printf( "}\n\n" ) ;
		}
		nametable_input( root ) ;
		printf( "static int cnt = 1 ;\n" ) ;
		if( error_details ) {
			printf( "extern int lineno ;\n" ) ;
			printf( "extern int charno ;\n" ) ;
			printf( "extern char *filename ;\n\n" ) ;
		}
		printf( "void __adterr__ ( void *p, int tg, int tg2, char *name ) {\n" ) ;
		printf( "\tif( tg < nametablelength ) {\n" ) ;
		printf( "\t\tfatal( 0, \"%%s: Corrupt tag: %%p, %%s found, %%s expected\", name, (void*)p, nametable[tg], nametable[tg2] ) ;\n" ) ;
		printf( "\t} else {\n" ) ;
		printf( "\t\tfatal( 0, \"%%s: Very corrupt tag: %%p, %%d found, %%s expected\", name, (void*)p, tg, nametable[tg] ) ;\n" ) ;
		printf( "\t}\n" ) ;
		printf( "}\n\n" ) ;
		fun_input( root ) ;
		if( gtINPUTtrailer( root ) != NULL ) {
			printf( "%s\n", gtINPUTtrailer( root ) ) ;
		}
	}
	if( template ) {
		protemp_input( root ) ;
		printf( "\n" ) ;
		funtemp_input( root ) ;
	}
	if( latex ) {
		latex_input( root ) ;
	}
	return 0 ;
}
