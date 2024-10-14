%option noyywrap

%{
#include<bits/stdc++.h>
#include "SymbolTable.cpp"

int error_count=0;
int line_count=1;
string str = "";
string ostr = "";
string cmt = "";
string mcmt = "";
int strerrorline = 0;
int cmtl, strl;
SymbolTable st(7);
ofstream token("1705017_token.txt");


void setKeyword(string tk, string key){
	cout<<"Line no "<<line_count<<": "<<"Token <"<<tk<<"> Lexeme "<<key<<" found"<<endl<<endl;
	token<<"<"<<tk<<"> ";
}

void setNumber(string tk, string key){
	cout<<"Line no "<<line_count<<": "<<"Token <"<<tk<<"> Lexeme "<<key<<" found"<<endl<<endl;
	token<<"<"<<tk<<", "<<key<<"> ";
	
	if(st.Insert(key, tk)){
		st.printAllScope();
	}
}

void setChar(string tk, string key){
	cout<<"Line no "<<line_count<<": "<<"Token <"<<tk<<"> Lexeme "<<key<<" found --> <CHAR_CONST, "<<key[1]<<"> "<<endl<<endl;
	token<<"<"<<tk<<", "<<key[1]<<"> ";
	
	if(st.Insert(key, tk))
		st.printAllScope();
}

void setSChar(string tk, string key){
	string c;
	switch(key[2]){
		case 'n': c = "\n"; break;
		case 't': c = "\t"; break;
		case 'a': c = "\a"; break;
		case 'f': c = "\f"; break;
		case 'r': c = "\r"; break;
		case 'b': c = "\b"; break;
		case 'v': c = "\v"; break;
		case '0': c = "\0"; break;
		case '\'': c += '\''; break;
		case '\\': c += '\\'; break;
		default: c= ' ';
	}
	cout<<"Line no "<<line_count<<": "<<"Token <"<<tk<<"> Lexeme "<<key<<" found --> <CHAR_CONST, "<<c<<"> "<<endl<<endl;
	token<<"<"<<tk<<", "<<c<<"> ";

	if(st.Insert(key, tk))
		st.printAllScope();
}

void setSymbol(string tk, string key){
	cout<<"Line no "<<line_count<<": "<<"Token <"<<tk<<"> Lexeme "<<key<<" found"<<endl<<endl;
	token<<"<"<<tk<<", "<<key<<"> ";
	
	if(tk=="LCURL") {
		st.EnterScope();
	}
	
	else if(tk=="RCURL") {
		st.ExitScope();
	}
}

void setID(string tk, string key){
	cout<<"Line no "<<line_count<<": "<<"Token <"<<tk<<"> Lexeme "<<key<<" found"<<endl<<endl;
	token<<"<"<<tk<<", "<<key<<"> ";

	if(st.Insert(key, tk))
		st.printAllScope();
}

void setString(){
	cout<<"Line no "<<strl<<": "<<"Token <STRING> Lexeme "<<ostr<<" found --> <STRING, \""<<str<<"\"> "<<endl<<endl;
	token<<"<STRING, "<<"\""<<str<<"\"> ";
	str = "";
	ostr="";
}

void setComment(){
	cout<<"Line no "<<cmtl<<": "<<"Token <COMMENT> Lexeme "<<cmt<<" found"<<endl<<endl;
	cmt = "";
}

void setmComment(){
	cout<<"Line no "<<cmtl<<": "<<"Token <COMMENT> Lexeme "<<mcmt<<" found"<<endl<<endl;
	mcmt = "";
}

char getSchar(){
	switch(yytext[1]){
		case 'n': return '\n'; break;
		case 't': return '\t'; break;
		case 'a': return '\a'; break;
		case 'f': return '\f'; break;
		case 'r': return '\r'; break;
		case 'b': return '\b'; break;
		case 'v': return '\v'; break;
		case '0': return '\0'; break;
		default: ' ';
	}
	return ' ';
}

void tooManyDecimalError(){
	cout<<"Error at line no "<<line_count<<": Too many decimal points "<<yytext<<endl<<endl;
}

void illNumberError(){
	cout<<"Error at line no "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
}

void undeterminedCharError(){
	string st;
	string mystr = yytext;
	int l = 0;
	if(yytext[mystr.size()-1]=='\n'){
		st = mystr.substr(0, mystr.size()-1);
		l=1;
	}
	else st = yytext;
	cout<<"Error at line no "<<line_count<<": Unterminated character "<<st<<endl<<endl;
	line_count+=l;
}

void multiCharError(){
	cout<<"Error at line no "<<line_count<<": Multi character constant error "<<yytext<<endl<<endl;
}

void emptyCharError(){
	cout<<"Error at line no "<<line_count<<": Empty character constant error "<<yytext<<endl<<endl;
}

void undeterminedStringError(){
	cout<<"Error at line no "<<strl<<": Unterminated String "<<ostr<<endl<<endl;
	ostr = "";
	str = "";
}

void undeterminedCommentError(){
	cout<<"Error at line no "<<cmtl<<": Unterminated Comment "<<mcmt<<endl<<endl;
	mcmt = "";
}

void invalidIDError(){
	cout<<"Error at line no "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl<<endl;
}

void unrecogniseError(){
	cout<<"Error at line no "<<line_count<<": Unrecognized character "<<yytext<<endl<<endl;
}

%}

Letter [a-zA-Z]
digit [0-9]
digits {digit}+

%x Comment
%x String
%x mComment

%%
[ \t\v]+ {}

(if) 	{ setKeyword("IF", yytext);}

(else) 	{ setKeyword("ELSE", yytext);}

(for) 	{ setKeyword("FOR", yytext);}

(while) 	{ setKeyword("WWHILE", yytext);}

(do) 	{ setKeyword("DO", yytext);}

(break) 	{ setKeyword("BREAK", yytext);}

(int) 	{ setKeyword("INT", yytext);}

(char) 	{ setKeyword("CHAR", yytext);}

(float) 	{ setKeyword("FLOAT", yytext);}

(double) 	{ setKeyword("DOUBLE", yytext);}

(void) 	{ setKeyword("VOID", yytext);}

(return) 	{ setKeyword("RETURN", yytext);}

(switch) 	{ setKeyword("SWITCH", yytext);}

(case) 	{ setKeyword("CASE", yytext);}

(default) 	{ setKeyword("DEFAULT", yytext);}

(continue) 	{ setKeyword("CONTINUE", yytext);}

("++"|"--") { setSymbol("INCOP", yytext);}
[+-] { setSymbol("ADDOP", yytext);}
[*\/%] { setSymbol("MULOP", yytext);}
("<"|"<="|">"|">="|"=="|"!=") { setSymbol("RELOP", yytext);}
= { setSymbol("ASSIGNOP", yytext);}
("&&"|"||") { setSymbol("LOGICOP", yytext);}
! { setSymbol("NOT", yytext);}
\( { setSymbol("LPAREN", yytext);}
\) { setSymbol("RPAREN", yytext);}
\{ { setSymbol("LCURL", yytext);}
\} { setSymbol("RCURL", yytext);}
\[ { setSymbol("LTHIRD", yytext);}
\] { setSymbol("RTHIRD", yytext);}
"," { setSymbol("COMMA", yytext);}
";" { setSymbol("SEMICOLON", yytext);}
	
{digits} { setNumber("CONST_INT", yytext);}	

{digits}(\.{digits})?([Ee][-+]?{digits})? { setNumber("CONST_FLOAT", yytext);}

[\.]{digits}?([Ee][-+]?{digits})? { setNumber("CONST_FLOAT", yytext);}

{digits}(\.{digits})?[Ee]([-+]?[0-9]*)(\.[0-9]*)+ { illNumberError(); error_count++;}

[\.]{digits}?[Ee]([-+]?[0-9]*)(\.[0-9]*)+ { illNumberError(); error_count++;}

[0-9]+(\.[0-9]*)(\.[0-9]*)+ { tooManyDecimalError(); error_count++;}

('{Letter}') { setChar("CONST_CHAR", yytext);}

'[\\][nt\\\'afrbv0]' { setSChar("CONST_CHAR", yytext);}

'[^'\n][^'\n]+' { multiCharError(); error_count++;}
'[^'\n]*[\n] { undeterminedCharError(); error_count++;}

"''" { emptyCharError(); error_count++;}

'[\\]'|'[\\][nt\\\'afrbv0][^'\n]+'|'[\\][nt\\\'afrbv0][^'\n]*[\n] { undeterminedCharError(); error_count++;}

[a-zA-Z_][a-zA-Z0-9_]* { setID("ID", yytext);}

[0-9]+[a-zA-Z_][a-zA-Z0-9_]* { invalidIDError(); error_count++;}


\" { BEGIN String; ostr+="\""; strl = line_count;}
<String>[^\"\n\\]+ { str+=yytext; ostr+=yytext;}
<String>[\\][\"] { str+=yytext[1]; ostr+=yytext;}
<String>[\\][nt\\\'afrbv0] {str+=getSchar(); ostr+=yytext;}
<String>[\\][\n] { line_count++; ostr+=yytext;}
<String>[\n] { line_count++; undeterminedStringError(); error_count++; BEGIN INITIAL;}
<String><<EOF>> { undeterminedStringError(); line_count-=strerrorline; strerrorline=0; error_count++; BEGIN INITIAL;}
<String>\" { ostr+=yytext; setString(); strerrorline=0; BEGIN INITIAL;}

"//" { BEGIN Comment; cmt+=yytext; cmtl=line_count;}
<Comment>[^\\\n]+ { cmt+=yytext;}
<Comment>[\\][\n] { line_count++; cmt+=yytext;}
<Comment>[\\][nt\\\'afrbv0]* {cmt+=yytext;}
<Comment><<EOF>> { setComment(); BEGIN INITIAL;}
<Comment>[\n] { line_count++; setComment(); BEGIN INITIAL;}

"/*" { BEGIN mComment; mcmt+=yytext; cmtl=line_count;}
<mComment>([\/\"]*[^"*\/"\\\n]*[\/\"]*)+ { mcmt+=yytext;}
<mComment>"*" { mcmt+=yytext;} 
<mComment>\n { mcmt+=yytext; line_count++; strerrorline++;}
<mComment>[\\][t\\\'afrbv0] {mcmt+=yytext;}
<mComment><<EOF>> { undeterminedCommentError(); line_count-=strerrorline; strerrorline=0; error_count++; BEGIN INITIAL;}
<mComment>"*/" { mcmt+=yytext; setmComment(); strerrorline = 0; BEGIN INITIAL;}

[\n] {line_count++;}
<<EOF>> {
		st.printAllScope(); 
		cout<<"Total lines: "<<line_count<<endl;
		cout<<"Total errors: "<<error_count<<endl;		
		return 0;
	}

. { unrecogniseError(); error_count++;}	
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	freopen ("1705017_log.txt","w",stdout);

	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}
