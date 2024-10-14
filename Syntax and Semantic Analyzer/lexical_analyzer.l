%option noyywrap

%{
#include<bits/stdc++.h>
#include "SymbolTable.h"

#define YYSTYPE SymbolInfo*

#include "y.tab.h"


extern YYSTYPE yylval;
extern SymbolTable *symbolTable;
void yyerror(char *);

int error_count=0;
int line_count=1;


%}

Letter [a-zA-Z]
digit [0-9]
digits {digit}+

%%
[ \t\v\f\r]+ {}

(if) 	{ return IF;}

(else) 	{ return ELSE;}

(for) 	{ return FOR;}

(while) 	{ return WHILE;}

(int) 	{ return INT;}

(char) 	{ return CHAR;}

(float) 	{ return FLOAT;}

(double) 	{ return DOUBLE;}

(void) 	{ return VOID;}

(return) 	{ return RETURN;}

(printf) { return PRINTF;}

"--" { return DECOP;}
"++" { return INCOP;}

[+-] { 
 	SymbolInfo* si = new  SymbolInfo(yytext, "ADDOP");
    yylval = (YYSTYPE) si;
 	return ADDOP;
 	}

[*\/%] { 
 	SymbolInfo* si = new  SymbolInfo(yytext, "MULOP");
    yylval = (YYSTYPE) si;
 	return MULOP;
 	}

("<"|"<="|">"|">="|"=="|"!=") { 
 	SymbolInfo* si = new  SymbolInfo(yytext, "RELOP");
    yylval = (YYSTYPE) si;
 	return RELOP;
 	}

= { return ASSIGNOP;}

("&&"|"||") { 
	SymbolInfo* si = new  SymbolInfo(yytext, "LOGICOP");
    yylval = (YYSTYPE) si;
	return LOGICOP;
	}

! { return NOT;}
\( { return LPAREN;}
\) { return RPAREN;}
\{ { return LCURL;}
\} { return RCURL;}
\[ { return LTHIRD;}
\] { return RTHIRD;}
"," { return COMMA;}
";" { return SEMICOLON;}
	
{digits} { 
	SymbolInfo* si = new  SymbolInfo(yytext, "CONST_INT");
    yylval = (YYSTYPE) si;
    return CONST_INT;
	}	

{digits}(\.{digits})?([Ee][-+]?{digits})? {
	SymbolInfo* si = new  SymbolInfo(yytext, "CONST_FLOAT");
    yylval = (YYSTYPE) si;
    return CONST_FLOAT;
	}

[a-zA-Z_][a-zA-Z0-9_]* { 
	SymbolInfo* si = symbolTable->Lookup(yytext);
	if(si==NULL){
		si = new  SymbolInfo(yytext, "ID");
	}
    yylval = (YYSTYPE) si;
    return ID;
	}

[\n] {line_count++;}

%%
