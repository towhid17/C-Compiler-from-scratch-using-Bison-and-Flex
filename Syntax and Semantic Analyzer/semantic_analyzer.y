%{
#include<bits/stdc++.h>
#include "SymbolTable.h"

#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);

extern FILE *yyin;
extern int error_count;
extern int line_count;

bool isMisMatch = true;
bool argMisMatch = true;

SymbolTable *symbolTable;

ofstream errFile("error.txt", ios::out);

// lists
vector<pair<string, int>> variableList;
vector<pair<string, string>> parameterList;
vector<string> argumentList;
pair<string, string> tempPar;
pair<string, string> tempParF;

void yyerror(char *s)
{
	//write your code
}

void setError(string msg){
	cout<<"Error at line "<<line_count<<": "<<msg<<endl<<endl;
	errFile<<"Error at line "<<line_count<<": "<<msg<<endl<<endl;
	error_count++;
}


%}

%token IF ELSE FOR WHILE INT CHAR VOID FLOAT DOUBLE RETURN PRINTF
%token DECOP INCOP ADDOP MULOP 
%token RELOP ASSIGNOP LOGICOP 
%token NOT LPAREN RPAREN LTHIRD RTHIRD LCURL RCURL COMMA SEMICOLON
%token ID CONST_FLOAT CONST_INT

// %left 
// %right

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
		{
			cout<<"Line "<<(--line_count)<<": start : program"<<endl<<endl;
            //cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
		}
	;

program : program unit
		{
			cout<<"Line "<<line_count<<": program : program unit"<<endl<<endl;
            cout<<(string)$1->getName()+(string)$2->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)$2->getName(), "nt");
		}
		| unit
		{
			cout<<"Line "<<line_count<<": program : unit"<<endl<<endl;
            cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
		}
	;
	
unit : var_declaration
		{
			cout<<"Line "<<line_count<<": unit : var_declaration"<<endl<<endl;
            cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
		}
		| func_declaration
		{
			cout<<"Line "<<line_count<<": unit : func_declaration"<<endl<<endl;
            cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
		}
		| func_definition
		{
			cout<<"Line "<<line_count<<": unit : func_definition"<<endl<<endl;
            cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
		}
    ;
     
func_declaration : type_specifier id emd LPAREN parameter_list RPAREN emdOutDec SEMICOLON
		{ 
			cout<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl<<endl;
            cout<<(string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)$5->getName()+(string)");"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)$5->getName()+(string)");\n", "nt");
            parameterList.clear();
		}
		| type_specifier id emd LPAREN RPAREN emdOutDec SEMICOLON
		{
			cout<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
            cout<<(string)$1->getName()+(string)" "+(string)$2->getName()+(string)"();"<<endl<<endl;
            $$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"();\n", "nt");
			parameterList.clear();
		}
	;
		 
func_definition : type_specifier id emd LPAREN parameter_list RPAREN emdOutDef compound_statement
		{
			cout<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl<<endl;
            cout<<(string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)$5->getName()+(string)")"+(string)$8->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)$5->getName()+(string)")"+(string)$8->getName()+(string)"\n", "nt");
		}
		| type_specifier id emd LPAREN RPAREN emdOutDef compound_statement
		{
			cout<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
            cout<<(string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)")"+(string)$7->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)")"+(string)$7->getName()+(string)"\n", "nt");
		}
 	;				

emd: 
		{
            tempParF = tempPar;
    	}
    ;	

emdOutDec: 
		{
            SymbolInfo* si = symbolTable->Lookup(tempParF.first);

            if(si != NULL) setError((string)"Multiple declaration of "+tempParF.first);
			else {
				SymbolInfo* si = new SymbolInfo(tempParF.first, "ID");
				si->setReturnType(tempParF.second);
				si->setCategory(1);
				for(int i=0; i<parameterList.size(); i++){
					si->insertParameter(parameterList[i].first, parameterList[i].second);
				}
				symbolTable->Insert(si);
            }
    	}
    ;		

emdOutDef: 
		{
            SymbolInfo* lu = symbolTable->currentScopeLookup(tempParF.first);

            if(lu == NULL) {
				SymbolInfo* si = new SymbolInfo(tempParF.first, "ID");
				si->setReturnType(tempParF.second);
				si->setCategory(2);
				for(int i=0; i<parameterList.size(); i++){
					si->insertParameter(parameterList[i].first, parameterList[i].second);
				}
				symbolTable->Insert(si);
			} 
			else if(lu->getCategory() != 1) setError((string)"Multiple declaration of "+tempParF.first);
			else {
                if(lu->getReturnType() != tempParF.second) 
					setError((string)"Return type mismatch with function declaration in function "+ (string)lu->getName());
				else if(lu->getParameterCount()==1 && parameterList.size()==0 && lu->getParameter(0).second=="void") 
					lu->setCategory(2); 
				else if(lu->getParameterCount()==0 && parameterList.size()==1 && parameterList[0].second=="void") 
					lu->setCategory(2);
				else if(lu->getParameterCount() != parameterList.size()) {
					setError((string)"Total number of arguments mismatch with declaration in function "+ (string)lu->getName());
					isMisMatch = false;
				}
				else {
                    bool isOk = true;
                    for(int i=0; i<parameterList.size(); i++) {
                        if(lu->getParameter(i).second != parameterList[i].second) {
                            isOk = false;
							if(argMisMatch){
							int k = i+1;
							stringstream ss;  
							ss<<k;  
							string s;  
							ss>>s; 
                    		setError(s+(string)"th argument mismatch in function "+ (string)lu->getName());
							}
							else argMisMatch = true;
							break;
                        }
                    }
                    if(isOk) lu->setCategory(2);
                }
            }
   		}
    ;	


parameter_list  : parameter_list COMMA type_specifier id
		{
			cout<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier ID"<<endl<<endl;
            cout<<(string)$1->getName()+(string)","+(string)$3->getName()+(string)" "+(string)$4->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName()+(string)" "+(string)$4->getName(), "NON_TERMINAL");
            parameterList.push_back(make_pair((string)$4->getName(),(string)$3->getName()));

			SymbolInfo* si = symbolTable->Lookup((string)$4->getName());

            if(si!=NULL)
			{
                setError((string)"Multiple declaration of "+(string)$4->getName()+(string)" in parameter");
            }
		}
		| parameter_list COMMA type_specifier
		{
			cout<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier"<<endl<<endl;
            cout<<(string)$1->getName()+(string)","+(string)$3->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName(), "nt");
            parameterList.push_back(make_pair("",(string)$3->getName()));
		}
 		| type_specifier id
		{
			cout<<"Line "<<line_count<<": parameter_list : type_specifier ID"<<endl<<endl;
            cout<<(string)$1->getName()+(string)" "+(string)$2->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName(), "nt");
            parameterList.push_back(make_pair((string)$2->getName(), (string)$1->getName()));
		}
		| type_specifier
		{
			cout<<"Line "<<line_count<<": parameter_list : type_specifier"<<endl<<endl;
            cout<<(string)$1->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName(), "nt");
            parameterList.push_back(make_pair("", (string)$1->getName()));
		}
 	;

 		
compound_statement : LCURL emdin statements RCURL
		{
			cout<<"Line "<<line_count<<": compound_statement : LCURL statements RCURL"<<endl<<endl;
            cout<<(string)"{\n"+(string)$3->getName()+(string)"}"<<endl<<endl;
			$$ = new SymbolInfo((string)"{\n"+(string)$3->getName()+(string)"}", "nt");
            symbolTable->printAllScope();
            symbolTable->ExitScope();
		}
 		| LCURL emdin RCURL
		{
			cout<<"Line "<<line_count<<": compound_statement : LCURL RCURL"<<endl<<endl;	
            cout<<(string)"{ }"<<endl<< endl;
			$$ = new SymbolInfo((string)"{\n}\n", "nt");
            symbolTable->printAllScope();
            symbolTable->ExitScope();
		}
 	;

emdin: 
		{
            symbolTable->EnterScope();
            if(!(parameterList.size()==1 && parameterList[0].second=="void")) {
                for(int i=0; i<parameterList.size(); i++) {
					SymbolInfo* si = new SymbolInfo(parameterList[i].first, "ID");
					si->setCategory(0);
					si->setReturnType(parameterList[i].second);
					symbolTable->Insert(si);
                }
            }
            parameterList.clear();
    	}
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{
			cout<<"Line "<<line_count<<": var_declaration : type_specifier declaration_list SEMICOLON"<<endl<<endl;	
            cout<<(string)$1->getName()+(string)" "+(string)$2->getName()+(string)";"<<endl<< endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)";\n", "nt");

			if((string)$1->getName()=="void"){
				setError("Variable type cannot be void");

				for(int i=0; i<variableList.size(); i++){
					SymbolInfo* si = new SymbolInfo(variableList[i].first, "ID");
					if(variableList[i].second==-1){
						si->setCategory(0);
					}
					else{
						si->setCategory(3);
						si->setArraySize(variableList[i].second);
					}
					si->setReturnType("float");
					symbolTable->Insert(si);
				}
			}
			else{
				for(int i=0; i<variableList.size(); i++){
					SymbolInfo* si = new SymbolInfo(variableList[i].first, "ID");
					if(variableList[i].second==-1){
						si->setCategory(0);
					}
					else{
						si->setCategory(3);
						si->setArraySize(variableList[i].second);
					}
					si->setReturnType((string)$1->getName());
					symbolTable->Insert(si);
				}
			}
			variableList.clear();
		}
 	;
 		 
type_specifier	: INT
		{
			cout<<"Line "<<line_count<<": type_specifier : INT"<<endl<<endl;	
			cout<<"int"<<endl<<endl;
			$$ = new SymbolInfo("int", "nt");
			tempPar.second = "int";
		}
 		| FLOAT
		{
			cout<<"Line "<<line_count<<": type_specifier : FLOAT"<<endl<<endl;	
            cout<<"float"<<endl<< endl;
			$$ = new SymbolInfo("float", "nt");
            tempPar.second = "float";
		}
 		| VOID
		{
			cout<<"Line "<<line_count<<": type_specifier : VOID"<<endl<<endl;	
			cout<<"void"<<endl<< endl;
			$$ = new SymbolInfo("void", "nt");
            tempPar.second = "void";
		}
 	;

id : ID 
		{
            $$ = new SymbolInfo((string)$1->getName(), "nt");
            tempPar.first = $1->getName();
    	}
    ;
 		
declaration_list : declaration_list COMMA id
		{
			cout<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)","+(string)$3->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName(), "nt");

			variableList.push_back(make_pair($3->getName(), -1));

			SymbolInfo* si = symbolTable->currentScopeLookup((string)$3->getName());
            if(si != NULL) setError((string)"Multiple declaration of "+(string)$3->getName());

		}
		| declaration_list COMMA id LTHIRD CONST_INT RTHIRD
		{
			cout<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)","+(string)$3->getName()+(string)"["+(string)$5->getName()+(string)"]"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName()+(string)"["+(string)$5->getName()+(string)"]", "nt");

			int s = 0;
			string n = $3->getName();
            stringstream strToint($5->getName());
            strToint >> s;
            variableList.push_back(make_pair(n, s));

			SymbolInfo* si = symbolTable->currentScopeLookup((string)$3->getName());
            if(si != NULL) setError((string)"Multiple declaration of "+(string)$3->getName());
		}
		| id
		{
			cout<<"Line "<<line_count<<": declaration_list : ID"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");	

            variableList.push_back(make_pair($1->getName(), -1));

			SymbolInfo* si = symbolTable->currentScopeLookup((string)$1->getName());
            if(si != NULL) setError((string)"Multiple declaration of "+(string)$1->getName());
		}
		| id LTHIRD CONST_INT RTHIRD
		{
			cout<<"Line "<<line_count<<": declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)"["+(string)$3->getName()+(string)"]"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"["+(string)$3->getName()+(string)"]", "nt");

			int s = 0;
			string n = $1->getName();
            stringstream strToint($3->getName());
            strToint >> s;
            variableList.push_back(make_pair(n, s));

			SymbolInfo* si = symbolTable->currentScopeLookup((string)$1->getName());
            if(si != NULL) setError((string)"Multiple declaration of "+(string)$1->getName());
		}
	;
 		  
statements : statement
		{
			cout<<"Line "<<line_count<<": statements : statement"<<endl<<endl;
			cout<<$1->getName()<<endl<<endl;	
			$$ = new SymbolInfo($1->getName(), "nt");
		}
		| statements statement
		{
			cout<<"Line "<<line_count<<": statements : statements statement"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)$2->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)$2->getName(), "nt");
		}
	;
	   
statement : var_declaration
		{
			cout<<"Line "<<line_count<<": statement : var_declaration"<<endl<<endl;
			cout<<$1->getName()<<endl<<endl;	
            $$ = new SymbolInfo((string)$1->getName(), "nt");
		}
		| expression_statement
		{
			cout<<"Line "<<line_count<<": statement : expression_statement"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
		}
		| compound_statement
		{
			cout<<"Line "<<line_count<<": statement : compound_statement"<<endl<<endl;	
            cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"\n", "nt");
		}
		| FOR LPAREN expression_statement dummyExpression dummyVoid expression_statement dummyExpression dummyVoid expression dummyExpression dummyVoid RPAREN statement
		{
			cout<<"Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl<<endl;	
			cout<<(string)"for ("+(string)$3->getName()+(string)$6->getName()+(string)$9->getName()+(string)")"+(string)$13->getName()<<endl<<endl;
            $$ = new SymbolInfo((string)"for ("+(string)$3->getName()+(string)$6->getName()+(string)$9->getName()+(string)")"+(string)$13->getName()+(string)"\n", "nt");
		}
		| IF LPAREN expression dummyExpression RPAREN dummyVoid statement %prec LOWER_THAN_ELSE
		{
			cout<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement"<<endl<<endl;	
			cout<<(string)"if ("+(string)$3->getName()+(string)")"+(string)$7->getName()<<endl<<endl;
            $$ = new SymbolInfo((string)"if ("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)"\n", "nt");
		}
		| IF LPAREN expression dummyExpression RPAREN dummyVoid statement ELSE statement
		{
			cout<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl<<endl;	
			cout<<(string)"if ("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)" else "+(string)$9->getName()<<endl<<endl;
            $$ = new SymbolInfo((string)"if ("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)" else "+(string)$9->getName()+(string)"\n", "nt");
		}
		| WHILE LPAREN expression dummyExpression RPAREN dummyVoid statement
		{
			cout<<"Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement"<<endl<<endl;	
			cout<<(string)"while ("+(string)$3->getName()+(string)")"+(string)$7->getName()<<endl<<endl;
            $$ = new SymbolInfo((string)"while ("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)"\n", "nt");
		}
		| PRINTF LPAREN id RPAREN SEMICOLON
		{
			cout<<"Line "<<line_count<<": statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl<<endl;	
			cout<<(string)"printf("+(string)$3->getName()+(string)");"<<endl<<endl;
			$$ = new SymbolInfo((string)"printf("+(string)$3->getName()+(string)");\n", "nt");

			SymbolInfo* si = symbolTable->Lookup((string)$3->getName());

			if(si == NULL)
			{
                setError((string)"Undeclared variable "+(string)$3->getName());
				isMisMatch = false;
            }
            
		}
		| RETURN expression SEMICOLON
		{
			cout<<"Line "<<line_count<<": statement : RETURN expression SEMICOLON"<<endl<<endl;	
			cout<<(string)"return "+(string)$2->getName()+(string)";"<<endl<<endl;
			$$ = new SymbolInfo((string)"return "+(string)$2->getName()+(string)";\n", "nt");

			if($2->getReturnType()=="void") setError("Void function used in expression");
		}
	;

dummyExpression: 
		{
            tempParF.second = tempPar.second;
    	}
    ;	

dummyVoid: 
		{
			if(tempParF.second=="void") setError("Void function used in expression");
    	}
    ;	
	  
expression_statement 	: SEMICOLON
		{
			cout<<"Line "<<line_count<<": expression_statement : SEMICOLON"<<endl<<endl;	
			cout<<";"<<endl<<endl;
			$$ = new SymbolInfo(";\n", "nt");
			$$->setReturnType("int");
			tempPar.second = "int";
		}			
		| expression SEMICOLON 
		{
			cout<<"Line "<<line_count<<": expression_statement : expression SEMICOLON"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)";"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)";\n", "nt");
			$$->setReturnType((string)$1->getReturnType());
			tempPar.second = $1->getReturnType();
		}
	;
	  
variable : id 
		{
			cout<<"Line "<<line_count<<": variable : ID"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");

			SymbolInfo* si = symbolTable->Lookup((string)$1->getName());

			if(si == NULL)
			{
                setError((string)"Undeclared variable "+(string)$1->getName());
                $$->setReturnType("float");
				isMisMatch = false;
            }
			else
			{
                if(si->getReturnType()!="void") $$->setReturnType(si->getReturnType());
                else $$->setReturnType("float");

				if(si->getCategory()!=0){
					setError((string)"Type mismatch, "+(string)$1->getName()+(string)" is an array");
					argMisMatch = false;
				}
								
			}
		}		
	 	| id LTHIRD expression RTHIRD 
		{
			cout<<"Line "<<line_count<<": variable : ID LTHIRD expression RTHIRD"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)"["+(string)$3->getName()+(string)"]"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"["+(string)$3->getName()+(string)"]", "nt");
		
            SymbolInfo* si = symbolTable->Lookup((string)$1->getName());

            if(si == NULL)
			{
                setError((string)"Undeclared variable "+(string)$1->getName());
                $$->setReturnType("float");
				isMisMatch = false;
            }
			else
			{
                if(si->getReturnType()!="void") $$->setReturnType(si->getReturnType());
                else $$->setReturnType("float");
				if(si->getCategory()!=3){
					setError((string)$1->getName()+(string)" not an array");
					argMisMatch = false;
				}

			}

			string rt3 = (string)$3->getReturnType();
            if(rt3!="int") setError("Expression inside third brackets not an integer");     
            if(rt3=="void") setError("Void function called within expression");
		}
	;
	 
 expression : logic_expression
		{
			cout<<"Line "<<line_count<<": expression : logic expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType((string)$1->getReturnType());
			tempPar.second = (string)$1->getReturnType();
		}
	   	| variable ASSIGNOP logic_expression
		{
			cout<<"Line "<<line_count<<": expression : variable ASSIGNOP logic_expression"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)"="+(string)$3->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"="+(string)$3->getName(), "nt");
		
			string rt1 = (string)$1->getReturnType();
			string rt3 = (string)$3->getReturnType();

			if(rt3=="void")
			{
                setError("Void function used in expression");
                $3->setReturnType("float");
				rt3 = "float";
				isMisMatch = false;
            } 
            
			if(rt1=="int" && rt3=="float") {
				if(isMisMatch){
					setError((string)"Type Mismatch");
				}
				else{
					isMisMatch = true;
				}
			}
			
            $$->setReturnType($1->getReturnType());
            tempParF.second = rt1;

		} 	
	;
			
logic_expression : rel_expression 
		{
			cout<<"Line "<<line_count<<": logic_expression : rel_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType($1->getReturnType());
		}	
		| rel_expression LOGICOP rel_expression
		{
			cout<<"Line "<<line_count<<": logic_expression : rel_expression LOGICOP rel_expression"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)$2->getName()+(string)$3->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)$2->getName()+(string)$3->getName(), "nt");
		
			string rt1 = (string)$1->getReturnType();
			string rt3 = (string)$3->getReturnType();

			if(rt1=="void") setError("Void function used in expression");
            if(rt3=="void") setError("Void function used in expression");
            $$->setReturnType("int");
		} 	
	;
			
rel_expression	: simple_expression
		{
			cout<<"Line "<<line_count<<": rel_expression : simple_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType($1->getReturnType());
		}
		| simple_expression RELOP simple_expression	
		{
			cout<<"Line "<<line_count<<": rel_expression : simple_expression RELOP simple_expression"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)$2->getName()+(string)$3->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)$2->getName()+(string)$3->getName(), "nt");
		
			string rt1 = (string)$1->getReturnType();
			string rt3 = (string)$3->getReturnType();

			if(rt1=="void") setError("Void function used in expression");
            if(rt3=="void") setError("Void function used in expression");
            $$->setReturnType("int");
		}
	;
				
simple_expression : term 
		{
			cout<<"Line "<<line_count<<": simple_expression : term"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType((string)$1->getReturnType());
		}
		| simple_expression ADDOP term
		{
			cout<<"Line "<<line_count<<": simple_expression : simple_expression ADDOP term"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)$2->getName()+(string)$3->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)$2->getName()+(string)$3->getName(), "nt");

			string rt1 = (string)$1->getReturnType();
			string rt3 = (string)$3->getReturnType();

			$$->setReturnType(rt1);

			if(rt1=="void")
			{
                setError("Void function used in expression");
                $1->setReturnType("float");
				rt1 = "float";
            }
            if(rt3=="void")
			{
                setError("Void function used in expression");
                $3->setReturnType("float");
				rt3 = "float";
            }
            if(rt1=="float" || rt3=="float") $$->setReturnType("float");
		} 
	;
					
term :	unary_expression
		{
			cout<<"Line "<<line_count<<": term : unary_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType($1->getReturnType());
		}
		|  term MULOP unary_expression
		{
			cout<<"Line "<<line_count<<": term : term MULOP unary_expression"<<endl<<endl;	
			cout<<$1->getName()+$2->getName()+$3->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName()+$2->getName()+$3->getName(), "nt");
		
			string rt1 = (string)$1->getReturnType();
			string rt3 = (string)$3->getReturnType();
			string n2 = (string)$2->getName();
			string n3 = (string)$3->getName();
			
            if(rt1=="void")
			{
                setError("Void function used in expression");
                $1->setReturnType("float");
				rt1 = "float";
            } 
            if(rt3=="void")
			{
                setError("Void function used in expression");
                $3->setReturnType("float");
				rt3 = "float";
            } 
			if(n2=="%" && n3=="0"){
				setError("Modulus by Zero");
			}
            if(n2=="%" && (rt1!="int" || rt3!="int"))
			{
                setError("Non-Integer operand on modulus operator");
                $$->setReturnType("int");
            }
			else if(n2!="%" && (rt1=="float" || rt3=="float"))
                $$->setReturnType("float");
            else  $$->setReturnType($1->getReturnType());
		}
    ;

unary_expression : ADDOP unary_expression
		{
			cout<<"Line "<<line_count<<": unary_expression : ADDOP unary_expression"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)$2->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)$2->getName(), "nt");
		    $$->setReturnType($2->getReturnType());

			if($2->getReturnType()=="void")
			{
                setError("Void function used in expression");
                $$->setReturnType("float");
            }
		}
		| NOT unary_expression 
		{
			cout<<"Line "<<line_count<<": unary_expression : NOT unary expression"<<endl<<endl;	
			cout<<(string)"!"+(string)$2->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)"!"+(string)$2->getName(), "int");

			if((string)$2->getReturnType()=="void")
                setError("Void function used in expression");
            $$->setReturnType("int");
		}
		| factor 
		{
			cout<<"Line "<<line_count<<": unary_expression : factor"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType((string)$1->getReturnType());
		}
	;
	
factor	: variable 
		{
			cout<<"Line "<<line_count<<": factor : variable"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType((string)$1->getReturnType());
		}
		| id LPAREN argument_list RPAREN
		{
			cout<<"Line "<<line_count<<": factor : ID LPAREN argument_list RPAREN"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)"("+(string)$3->getName()+(string)")"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"("+(string)$3->getName()+(string)")", "nt");
			
            SymbolInfo* si = symbolTable->Lookup((string)$1->getName());

            if(si==NULL)
			{
                setError((string)"Undeclared function "+(string)$1->getName());
                $$->setReturnType("float");
				isMisMatch = false;
            }
			else if(si->getCategory()!=2)
			{
                setError((string)"Undeclared function "+(string)$1->getName());
                $$->setReturnType("float");
				isMisMatch = false;
            }
			else
			{
				int pc = si->getParameterCount();
				int as = argumentList.size();
				pair<string, string> pr = si->getParameter(0);
				string pt = pr.second;

                if(as!=pc)
				{
					if(as==0 && pc==1 && pt=="void") $$->setReturnType(si->getReturnType());
                    else
					{
						setError((string)"Total number of arguments mismatch in function "+(string)si->getName());
						$$->setReturnType("float");
						isMisMatch = false;
					}
                }
				else
				{
                    bool isConsistent = true;
                    for(int i=0; i<pc; i++) {
						pair<string, string> pp = si->getParameter(i);
						string ppp = pp.second;
                        if(ppp!=argumentList[i]) {
                            isConsistent = false;
							if(argMisMatch){
								int k = i+1;
								stringstream ss;  
								ss<<k;  
								string s;  
								ss>>s; 
								setError(s+(string)"th argument mismatch in function "+(string)si->getName());
							}
							else argMisMatch = true;
							break;
                        }
                    }
 					if(isConsistent) {
						 $$->setReturnType(si->getReturnType());
					}
					else $$->setReturnType("float");
                    
                }
            }
			argumentList.clear();
		}
		| LPAREN expression RPAREN
		{
			cout<<"Line "<<line_count<<": factor : LPAREN expression RPAREN"<<endl<<endl;	
			cout<<(string)"("+(string)$2->getName()+(string)")"<<endl<<endl;
			$$ = new SymbolInfo((string)"("+(string)$2->getName()+(string)")", $2->getType());
			
			if($2->getReturnType()=="void") {
                setError("Void function used in expression");
                $2->setReturnType("float");
            } 
            $$->setReturnType($2->getReturnType());
		}
		| CONST_INT
		{
			cout<<"Line "<<line_count<<": factor : CONST_INT"<<endl<<endl;	
			cout<<(string)$1->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName(), "int");
			$$->setReturnType("int");
		} 
		| CONST_FLOAT
		{
			cout<<"Line "<<line_count<<": factor : CONST_FLOAT"<<endl<<endl;	
			cout<<(string)$1->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName(), "float");
			$$->setReturnType("float");
		}
		| variable INCOP 
		{
			cout<<"Line "<<line_count<<": factor : variable INCOP"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)"++"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"++", "nt");
			$$->setReturnType($1->getReturnType());
		}
		| variable DECOP
		{
			cout<<"Line "<<line_count<<": factor : variable DECOP"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)"--"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"--", "nt");
			$$->setReturnType($1->getReturnType());
		}
	;
	
argument_list : arguments
		{
			cout<<"Line "<<line_count<<": argument_list : arguments"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
		}
		|
		{
			cout<<"Line "<<line_count<<" argument_list"<<endl<<endl;	
			cout<<endl<<endl;
			$$ = new SymbolInfo("", "nt");
		}	  
	;
	
arguments : arguments COMMA logic_expression
		{
			cout<<"Line "<<line_count<<": arguments : arguments COMMA logic_expression"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)","+(string)$3->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName(), "nt");

			if((string)$3->getReturnType()=="void") {
                setError("Void function called within argument of function "+(string)$3->getName());
                $3->setReturnType("float");
            }
			argumentList.push_back($3->getReturnType());
		}
	    | logic_expression
		{
			cout<<"Line "<<line_count<<": arguments : logic_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");

			if((string)$1->getReturnType()=="void") {
                setError("Void function called within argument of function "+(string)$1->getName());
                $1->setReturnType("float");
            }
			argumentList.push_back($1->getReturnType());
		}
	;
%%
int main(int argc,char *argv[])
{

	if(argc!=2){
		printf("input file not found\n");
		return 0;
	}

	FILE *input = fopen(argv[1], "r");
	if(input==NULL){
		printf("cannot open file\n");
		return 0;
	}

	symbolTable = new SymbolTable(30);

	freopen("log.txt","w",stdout);

	yyin = input;
	yyparse();

	symbolTable->printAllScope();

	cout<<"Total lines: "<<line_count<<endl;
	cout<<"Total errors: "<<error_count<<endl;

	fclose(yyin);
	errFile.close();

	return 0;
}

