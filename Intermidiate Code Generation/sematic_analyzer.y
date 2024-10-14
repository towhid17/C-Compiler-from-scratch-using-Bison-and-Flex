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
int isFuncDefinition = 0;
int current_label = 0;
int current_temp = 0;
int scope_count = 0;
bool isReturned = false;

SymbolTable *symbolTable;

ofstream errFile("1705017_error.txt", ios::out);
ofstream codeFile("1705017_code.asm", ios::out);
ofstream optimized_codeFile("1705017_optimized_code.asm");

// lists
vector<pair<string, int>> variableList;
vector<pair<string, string>> parameterList;
vector<string> argumentList;
pair<string, string> tempPar;
pair<string, string> tempParF;
vector<string> data_sgmt_varList;
vector<string> recieved_func_arg;
vector<string> sent_func_arg;

void yyerror(char *s)
{
	//write your code
}

void setError(string msg){
	cout<<"Error at line "<<line_count<<": "<<msg<<endl<<endl;
	errFile<<"Error at line "<<line_count<<": "<<msg<<endl<<endl;
	error_count++;
}

string get_number_to_string(int number){
	string str;
    stringstream stream;
    stream<<number;
    stream>>str;
    return str;
}

string newLabel(){
	string str = "LABEL";
	str+=get_number_to_string(current_label++);
	return str;
}

string newTemp(){
	string str = "TEMP";
	str+=get_number_to_string(current_temp++);
	return str;
}

string get_Asm_Print_func(){
	string code = "PRINTS PROC\n";
	code += (string)"LEA DX, MSG1\nMOV AH, 09H\nINT 21H\n";
	code += (string)"MOV CX, 0\n";
	code += (string)"MOV DX, 0\n\n";
	code += (string)"MOV AX, R\n";
	code += (string)"CMP AX, 0\n";
	code += (string)"JE PZERO\n";
	code += (string)"JMP PRINTAS\n";
	code += (string)"PZERO:\n";
	code += (string)"MOV AH, 02H\n";
	code += (string)"MOV DX, '0'\n";
	code += (string)"INT 21H\n";
	code += (string)"JMP ENDR\n\n";
	code += (string)"PRINTAS:\n";
	code += (string)"MOV AX, R\n";
	code += (string)"CMP AX, 0\n";
	code += (string)"JL PM\n";
	code += (string)"JMP PUSHR\n";
	code += (string)"PM:\n";
	code += (string)"MOV AH, 02H\n";
	code += (string)"MOV DX, '-'\n";
	code += (string)"INT 21H\n";
	code += (string)"MOV DX, 0\n";
	code += (string)"MOV AX, R\n";
	code += (string)"NEG AX\n\n";
	code += (string)"PUSHR:\n";
	code += (string)"CMP AX, 0\n";
	code += (string)"JE POPR\n\n";
	code += (string)"MOV BX, 10\n";
	code += (string)"IDIV BX\n\n";
	code += (string)"PUSH DX\n\n";
	code += (string)"XOR DX, DX\n";
	code += (string)"INC CX\n\n";
	code += (string)"JMP PUSHR\n\n";
	code += (string)"POPR:\n";
	code += (string)"CMP CX, 0\n";
	code += (string)"JE ENDR\n\n";
	code += (string)"POP DX\n";
	code += (string)"ADD DX, '0'\n\n";
	code += (string)"MOV AH, 02H\n";
	code += (string)"INT 21H\n\n";
	code += (string)"DEC CX\n";
	code += (string)"JMP POPR\n\n";
	code += (string)"ENDR:\n";
	code += (string)"MOV AH, 02H\n";
	code += (string)"MOV DX, 10\n";
	code += (string)"INT 21H\n";
	code += (string)"RET\n\n";
	code += (string)"PRINTS ENDP\n";

	return code;
}


string funcBody(string code, string t){
	string code1 = "";
	stringstream stream(code);
    vector<string> lines;
	vector<string> words1;
	string str;
	string str1;

	while(getline(stream, str, '\n')) {
        lines.push_back(str);
    }

    for(int i=0; i<lines.size(); i++) {
		stringstream stream1(lines[i]);
		
		while(getline(stream1, str1, ' ')) {
			words1.push_back(str1);
		}

		if(words1[0]=="RET") code1+=(string)"PUSH "+t+(string)"\n";

		code1+=lines[i];
		code1+="\n";
		words1.clear();
	}

	lines.clear();
	return code1;
}


string mainfuncBody(string code){
	string code1 = "";
	stringstream stream(code);
    vector<string> lines;
	vector<string> words1;
	string str;
	string str1;

	while(getline(stream, str, '\n')) {
        lines.push_back(str);
    }

    for(int i=0; i<lines.size(); i++) {
		stringstream stream1(lines[i]);
		
		while(getline(stream1, str1, ' ')) {
			words1.push_back(str1);
		}

		if(words1[0]=="RET") i++;

		code1+=lines[i];
		code1+="\n";
		words1.clear();
	}

	lines.clear();
	return code1;
}


void optimize_code(string code) {
    stringstream stream(code);
    vector<string> lines;
	vector<string> words1;
	vector<string> words2;
	string str;
	string str1;
	string str2;

    while(getline(stream, str, '\n')) {
        lines.push_back(str);
    }

    for(int i=0; i<lines.size(); i++) {
		stringstream stream1(lines[i]);
		stringstream stream2(lines[i+1]);
		
		while(getline(stream1, str1, ' ')) {
			words1.push_back(str1);
		}

		while(getline(stream2, str2, ' ')) {
			words2.push_back(str2);
		}

		optimized_codeFile<<lines[i]<<endl;

		if(words1[0]=="MOV" && words2[0]=="MOV" && (words1[2]+(string)",")==words2[1] && words1[1]==(words2[2]+(string)","))
			++i;

		words1.clear();
		words2.clear();
		
    }


    lines.clear();
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

			
			//**********Assembly Code***********//
			//..................................//

			if(error_count==0){
				string code = "";
                code += (string)".MODEL SMALL\n\n.STACK 100H\n\n.DATA\nLR EQU 0DH\nCF EQU 0AH\nR DW ?\nMSG1 DW LR, CF, \" $\"\n";

                for(int i=0; i<data_sgmt_varList.size(); i++) {
                    code += (string)data_sgmt_varList[i]+(string)"\n";
                }

                data_sgmt_varList.clear();

                code += (string)"\n.CODE\n\n";
                code += $1->getAsmCode();

				code+=(string)get_Asm_Print_func();

				code += (string)"\nEND MAIN";

                $$->setAsmCode(code);
				optimize_code(code);
                codeFile<<code<<endl;

			}
		}
	;

program : program unit
		{
			cout<<"Line "<<line_count<<": program : program unit"<<endl<<endl;
            cout<<(string)$1->getName()+(string)$2->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)$2->getName(), "nt");
		

			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode()+ $2->getAsmCode());

		}
		| unit
		{
			cout<<"Line "<<line_count<<": program : unit"<<endl<<endl;
            cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");

			
			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());
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


			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());
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
		
		
			//**********Assembly Code***********//
			//..................................//

            string code = "";
            
            if(($2->getName() == "main") && (isFuncDefinition == 1)) {
                code += (string)"MAIN PROC\nMOV AX, @DATA\nMOV DS ,AX\n\n";
                code += mainfuncBody($8->getAsmCode());
                code += (string)"\n\nMOV AH, 4CH\nINT 21H\nMAIN ENDP\n\n";
                isFuncDefinition = 0;
            } 
			else {
                if(isFuncDefinition == 1) {
					string t = newTemp();
					data_sgmt_varList.push_back(t+(string)" DW ?");

                    code += $2->getName()+(string)"_FUNC PROC\nPOP "+t+(string)"\n";

                    int l = recieved_func_arg.size()-1;

					for(int i=l; i>=0; i--) {
                        code += (string)"POP "+recieved_func_arg[i]+(string)"\n";
                    }

                    code += funcBody($8->getAsmCode(), t);
					if($1->getName()=="void")
                    	code += (string)"PUSH "+t+(string)"\nRET\n";
                    code += $2->getName()+(string)"_FUNC ENDP\n\n";
                }

                isFuncDefinition = 0;
            }

            $$->setAsmCode(code);
            recieved_func_arg.clear();


		}
		| type_specifier id emd LPAREN RPAREN emdOutDef compound_statement
		{
			cout<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
            cout<<(string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)")"+(string)$7->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)")"+(string)$7->getName()+(string)"\n", "nt");
		

			//**********Assembly Code***********//
			//..................................//

            string code = "";
            
            if(($2->getName() == "main") && (isFuncDefinition == 1)) {
                code += (string)"MAIN PROC\nMOV AX, @DATA\nMOV DS ,AX\n\n";
                code += mainfuncBody($7->getAsmCode());
                code += (string)"\n\nMOV AH, 4CH\nINT 21H\nMAIN ENDP\n\n";
                isFuncDefinition = 0;
            } 
			else {
                if(isFuncDefinition == 1) {
					string t = newTemp();
					data_sgmt_varList.push_back(t+(string)" DW ?");

                    code += $2->getName()+(string)"_FUNC PROC\nPOP "+t+(string)"\n";

					int l = recieved_func_arg.size()-1;

                    for(int i=l; i>=0; i--) {
                        code += (string)"POP "+recieved_func_arg[i]+(string)"\n";
                    }

                    code += funcBody($7->getAsmCode(), t);
					if($1->getName()=="void")
                    	code += (string)"PUSH "+t+(string)"\nRET\n";
                    code += $2->getName()+(string)"_FUNC ENDP\n\n";
                }

                isFuncDefinition = 0;
            }

            $$->setAsmCode(code);
            recieved_func_arg.clear();


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

				//**********Assembly Code***********//
				//..................................//
				si->setAsmCodeSymbol(tempParF.first);

				symbolTable->Insert(si);
            }
    	}
    ;		

emdOutDef: 
		{
            SymbolInfo* lu = symbolTable->currentScopeLookup(tempParF.first);

            if(lu == NULL) {

				//**********Assembly Code***********//
				//..................................//

				isFuncDefinition = 1;


				SymbolInfo* si = new SymbolInfo(tempParF.first, "ID");
				si->setReturnType(tempParF.second);
				si->setCategory(2);
				for(int i=0; i<parameterList.size(); i++){
					si->insertParameter(parameterList[i].first, parameterList[i].second);
				}

				//**********Assembly Code***********//
				//..................................//
				si->setAsmCodeSymbol(tempParF.first);

				symbolTable->Insert(si);
			} 
			else if(lu->getCategory() != 1) setError((string)"Multiple declaration of "+tempParF.first);
			else {
                if(lu->getReturnType() != tempParF.second) 
					setError((string)"Return type mismatch with function declaration in function "+ (string)lu->getName());
				else if(lu->getParameterCount()==1 && parameterList.size()==0 && lu->getParameter(0).second=="void") {
					lu->setCategory(2); 

					//**********Assembly Code***********//
					//..................................//
					
					isFuncDefinition = 1;
				}
				else if(lu->getParameterCount()==0 && parameterList.size()==1 && parameterList[0].second=="void") {
					lu->setCategory(2);
				
					//**********Assembly Code***********//
					//..................................//
					
					isFuncDefinition = 1;
				}
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
                    if(isOk){
						lu->setCategory(2);

						//**********Assembly Code***********//
						//..................................//
						
						isFuncDefinition = 1;
					}
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
			
			
			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($3->getAsmCode());
		
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
			scope_count++;
            if(!(parameterList.size()==1 && parameterList[0].second=="void")) {
                for(int i=0; i<parameterList.size(); i++) {
					SymbolInfo* si = new SymbolInfo(parameterList[i].first, "ID");
					si->setCategory(0);
					si->setReturnType(parameterList[i].second);
					symbolTable->Insert(si);


					//**********Assembly Code***********//
					//..................................//
		
					string name = (string)parameterList[i].first+(string)get_number_to_string(scope_count);
					si->setAsmCodeSymbol(name);
					data_sgmt_varList.push_back(name+(string)" DW ?");
					recieved_func_arg.push_back(name);

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


						//**********Assembly Code***********//
						//..................................//
			
						string name = (string)variableList[i].first+(string)get_number_to_string(scope_count);
						data_sgmt_varList.push_back(name+(string)" DW ?");
						si->setAsmCodeSymbol(name);

					}
					else{
						si->setCategory(3);
						si->setArraySize(variableList[i].second);

						
						//**********Assembly Code***********//
						//..................................//

						string name = (string)variableList[i].first+(string)get_number_to_string(scope_count);
						si->setAsmCodeSymbol(name);
						name+=(string)" DW "+(string)get_number_to_string(variableList[i].second)+(string)" DUP (?)";
						data_sgmt_varList.push_back(name);

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

			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());

		}
		| statements statement
		{
			cout<<"Line "<<line_count<<": statements : statements statement"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)$2->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)$2->getName(), "nt");
		
			
			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode((string)$1->getAsmCode()+(string)$2->getAsmCode());
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


			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());
		}
		| compound_statement
		{
			cout<<"Line "<<line_count<<": statement : compound_statement"<<endl<<endl;	
            cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"\n", "nt");


			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());

		}
		| FOR LPAREN expression_statement dummyExpression dummyVoid expression_statement dummyExpression dummyVoid expression dummyExpression dummyVoid RPAREN statement
		{
			cout<<"Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl<<endl;	
			cout<<(string)"for ("+(string)$3->getName()+(string)$6->getName()+(string)$9->getName()+(string)")"+(string)$13->getName()<<endl<<endl;
            $$ = new SymbolInfo((string)"for ("+(string)$3->getName()+(string)$6->getName()+(string)$9->getName()+(string)")"+(string)$13->getName()+(string)"\n", "nt");
		

			//**********Assembly Code***********//
			//..................................//

			if(($3->getAsmCodeSymbol() != ";") && ($6->getAsmCodeSymbol() != ";")) {
               string l1 = "LABEL";
				string n = get_number_to_string(current_label++);
				l1+=n;
				string l2 = "LABEL";
				n = get_number_to_string(current_label++);
				l2+=n;

                $$->setAsmCode($3->getAsmCode()+(string)""+l1+(string)":\n"+$6->getAsmCode()+(string)"MOV AX, "
								+$6->getAsmCodeSymbol()+(string)"\nCMP AX, 0\nJE "+l2+(string)"\n"
               					+$13->getAsmCode()+$9->getAsmCode()+(string)"JMP "+l1+(string)"\n"+l2+(string)":\n");
            }

		}
		| IF LPAREN expression dummyExpression RPAREN dummyVoid statement %prec LOWER_THAN_ELSE
		{
			cout<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement"<<endl<<endl;	
			cout<<(string)"if ("+(string)$3->getName()+(string)")"+(string)$7->getName()<<endl<<endl;
            $$ = new SymbolInfo((string)"if ("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)"\n", "nt");
		

			//**********Assembly Code***********//
			//..................................//

            string l1 = "LABEL";
			string n = get_number_to_string(current_label++);
			l1+=n;

			$$->setAsmCode($3->getAsmCode()+(string)"MOV AX, "+$3->getAsmCodeSymbol()+(string)"\nCMP AX, 0\nJE "+l1+(string)"\n"+$7->getAsmCode()+(string)""+l1+(string)":\n");

		}
		| IF LPAREN expression dummyExpression RPAREN dummyVoid statement ELSE statement
		{
			cout<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl<<endl;	
			cout<<(string)"if ("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)" else "+(string)$9->getName()<<endl<<endl;
            $$ = new SymbolInfo((string)"if ("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)" else "+(string)$9->getName()+(string)"\n", "nt");
		
		
			//**********Assembly Code***********//
			//..................................//

            string l1 = "LABEL";
			string n = get_number_to_string(current_label++);
			l1+=n;
            string l2 = "LABEL";
			n = get_number_to_string(current_label++);
			l2+=n;

			$$->setAsmCode($3->getAsmCode()+(string)"MOV AX, "+$3->getAsmCodeSymbol()+(string)"\nCMP AX, 0\nJE "
							+l1+(string)"\n"+$7->getAsmCode()+(string)"JMP "+l2+(string)"\n"
            				+(string)""+l1+(string)":\n"+$9->getAsmCode()+(string)""+l2+(string)":\n");


		}
		| WHILE LPAREN expression dummyExpression RPAREN dummyVoid statement
		{
			cout<<"Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement"<<endl<<endl;	
			cout<<(string)"while ("+(string)$3->getName()+(string)")"+(string)$7->getName()<<endl<<endl;
            $$ = new SymbolInfo((string)"while ("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)"\n", "nt");
		
			
			//**********Assembly Code***********//
			//..................................//

            string l1 = "LABEL";
			string n = get_number_to_string(current_label++);
			l1+=n;
            string l2 = "LABEL";
			n = get_number_to_string(current_label++);
			l2+=n;

            $$->setAsmCode((string)""+l1+(string)":\n"+$3->getAsmCode()+(string)"MOV AX, "
							+$3->getAsmCodeSymbol()+(string)"\nCMP AX, 0\nJE "+l2+(string)"\n"
            				+$7->getAsmCode()+(string)"JMP "+l1+(string)"\n"+l2+(string)":\n");


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



			//**********Assembly Code***********//
			//..................................//

			string in = si->getAsmCodeSymbol();
			$$->setAsmCode((string)"MOV AX, "+in+(string)"\nMOV R, AX\nCALL PRINTS\n");
            
		}
		| RETURN expression SEMICOLON
		{
			cout<<"Line "<<line_count<<": statement : RETURN expression SEMICOLON"<<endl<<endl;	
			cout<<(string)"return "+(string)$2->getName()+(string)";"<<endl<<endl;
			$$ = new SymbolInfo((string)"return "+(string)$2->getName()+(string)";\n", "nt");

			if($2->getReturnType()=="void") setError("Void function used in expression");
		
			
			//**********Assembly Code***********//
			//..................................//
			
		    $$->setAsmCode($2->getAsmCode()+(string)"PUSH "+$2->getAsmCodeSymbol()+(string)"\n\RET\n");

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

			//**********Assembly Code***********//
			//..................................//
			
			$$->setAsmCodeSymbol(";");

		}			
		| expression SEMICOLON 
		{
			cout<<"Line "<<line_count<<": expression_statement : expression SEMICOLON"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)";"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)";\n", "nt");
			$$->setReturnType((string)$1->getReturnType());
			tempPar.second = $1->getReturnType();

			//**********Assembly Code***********//
			//..................................//
			
			$$->setAsmCode($1->getAsmCode());
			$$->setAsmCodeSymbol($1->getAsmCodeSymbol());

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
                if(si->getReturnType()!="void") {
					$$->setReturnType(si->getReturnType());
					$$->setAsmCodeSymbol(si->getAsmCodeSymbol());
				}
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
                if(si->getReturnType()!="void") {
					$$->setReturnType(si->getReturnType());
					$$->setCategory(si->getCategory());
					$$->setAsmCodeSymbol(si->getAsmCodeSymbol());
				}
                else $$->setReturnType("float");
				if(si->getCategory()!=3){
					setError((string)$1->getName()+(string)" not an array");
					argMisMatch = false;
				}

			}

			string rt3 = (string)$3->getReturnType();
            if(rt3!="int") setError("Expression inside third brackets not an integer");     
            if(rt3=="void") setError("Void function called within expression");
		

			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($3->getAsmCode()+(string)"MOV BX, "+$3->getAsmCodeSymbol()+(string)"\n"+(string)"ADD BX, BX"+(string)"\n");

		}
	;
	 
 expression : logic_expression
		{
			cout<<"Line "<<line_count<<": expression : logic expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType((string)$1->getReturnType());
			tempPar.second = (string)$1->getReturnType();


			//**********Assembly Code***********//
			//..................................//
			
			$$->setAsmCode($1->getAsmCode());
			$$->setAsmCodeSymbol($1->getAsmCodeSymbol());

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



			//**********Assembly Code***********//
			//..................................//

			string str = (string)";Line no: "+get_number_to_string(line_count)+(string)" -> "+$$->getName()+(string)"\n";

			if($1->getCategory()==0){
				$$->setAsmCode(str+$1->getAsmCode()+$3->getAsmCode()+(string)"MOV AX, "+$3->getAsmCodeSymbol()+(string)"\nMOV "+$1->getAsmCodeSymbol()+(string)", AX\n");
                $$->setAsmCodeSymbol($1->getAsmCodeSymbol());
			}
			else if($1->getCategory()==3) {
                string t = "TEMP";
				string n = get_number_to_string(current_temp++);
				t+=n;
				data_sgmt_varList.push_back(t+(string)" DW ?");

                $$->setAsmCode(str+$3->getAsmCode()+$1->getAsmCode()+(string)"MOV AX, "+$3->getAsmCodeSymbol()+(string)"\n"
                				+(string)"MOV "+$1->getAsmCodeSymbol()+(string)"[BX], AX\nMOV "+t+(string)", AX\n");
                $$->setAsmCodeSymbol(t);
            }

		} 	
	;
			
logic_expression : rel_expression 
		{
			cout<<"Line "<<line_count<<": logic_expression : rel_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType($1->getReturnType());


			//**********Assembly Code***********//
			//..................................//
			
			$$->setAsmCode($1->getAsmCode());
			$$->setAsmCodeSymbol($1->getAsmCodeSymbol());

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


			//**********Assembly Code***********//
			//..................................//

			string l1 = newLabel();
            string l2 = newLabel();
			string l3 = newLabel();
			string t = newTemp();
            data_sgmt_varList.push_back(t+(string)" DW ?");

            $$->setAsmCode($1->getAsmCode()+$3->getAsmCode());
            
            if($2->getName() == "&&") {
				string code = (string)"MOV BX, "+$1->getAsmCodeSymbol()+(string)"\nCMP BX, 0\nJE "+l1+(string)"\n"
							+ (string)"MOV BX, "+$3->getAsmCodeSymbol()+(string)"\nCMP BX, 0\nJE "+l1+(string)"\n"
							+ (string)"MOV BX, 1\nMOV "+t+(string)", BX\nJMP "+l2+(string)"\n"
							+ l1+(string)":\nMOV BX, 0\nMOV "+t+(string)", BX\n"+l2+(string)":\n";

                $$->setAsmCode($$->getAsmCode()+code);

            } else {
				string code = (string)"MOV BX, "+$1->getAsmCodeSymbol()+(string)"\nCMP BX, 0\nJNE "+l1+(string)"\n"
							+ (string)"MOV BX, "+$3->getAsmCodeSymbol()+(string)"\nCMP BX, 0\nJNE "+l1+(string)"\n"
							+ (string)"MOV BX, 0\nMOV "+t+(string)", BX\nJMP "+l2+(string)"\n"
							+ l1+(string)":\nMOV BX, 1\nMOV "+t+(string)", BX\n"+l2+(string)":\n";

                $$->setAsmCode($$->getAsmCode()+code);

            }
            
            $$->setAsmCodeSymbol(t);
		} 	
	;
			
rel_expression	: simple_expression
		{
			cout<<"Line "<<line_count<<": rel_expression : simple_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType($1->getReturnType());


			//**********Assembly Code***********//
			//..................................//
			
			$$->setAsmCode($1->getAsmCode());
			$$->setAsmCodeSymbol($1->getAsmCodeSymbol());

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


			
			//**********Assembly Code***********//
			//..................................//

			string l1 = newLabel();
            string l2 = newLabel();
			string t = newTemp();
            data_sgmt_varList.push_back(t+(string)" DW ?");

			string str = (string)";Line no: "+get_number_to_string(line_count)+(string)" -> "+$$->getName()+(string)"\n";

            $$->setAsmCode(str+$1->getAsmCode()+$3->getAsmCode()+(string)"MOV BX, "+$1->getAsmCodeSymbol()+(string)"\nCMP BX, "+$3->getAsmCodeSymbol()+(string)"\n");

            if($2->getName() == "<") {
                $$->setAsmCode($$->getAsmCode()+(string)"JL "+l1+(string)"\nMOV BX, 0\nMOV "+t+(string)", BX\nJMP "+l2+(string)"\n"
                				+(string)""+l1+(string)":\nMOV BX, 1\nMOV "+t+(string)", BX\n"+l2+(string)":\n");
            } else if($2->getName() == "<=") {
                $$->setAsmCode($$->getAsmCode()+(string)"JLE "+l1+(string)"\nMOV BX, 0\nMOV "+t+(string)", BX\nJMP "+l2+(string)"\n"
                				+(string)""+l1+(string)":\nMOV BX, 1\nMOV "+t+(string)", BX\n"+l2+(string)":\n");
            } else if($2->getName() == ">") {
                $$->setAsmCode($$->getAsmCode()+(string)"JG "+l1+(string)"\nMOV BX, 0\nMOV "+t+(string)", BX\nJMP "+l2+(string)"\n"
                				+(string)""+l1+(string)":\nMOV BX, 1\nMOV "+t+(string)", BX\n"+l2+(string)":\n");
            } else if($2->getName() == ">=") {
                $$->setAsmCode($$->getAsmCode()+(string)"JGE "+l1+(string)"\nMOV BX, 0\nMOV "+t+(string)", BX\nJMP "+l2+(string)"\n"
                				+(string)""+l1+(string)":\nMOV BX, 1\nMOV "+t+(string)", BX\n"+l2+(string)":\n");
            } else if($2->getName() == "==") {
                $$->setAsmCode($$->getAsmCode()+(string)"JE "+l1+(string)"\nMOV BX, 0\nMOV "+t+(string)", BX\nJMP "+l2+(string)"\n"
                				+(string)""+l1+(string)":\nMOV BX, 1\nMOV "+t+(string)", BX\n"+l2+(string)":\n");
            } else {
                $$->setAsmCode($$->getAsmCode()+(string)"JNE "+l1+(string)"\nMOV BX, 0\nMOV "+t+(string)", BX\nJMP "+l2+(string)"\n"
                				+(string)""+l1+(string)":\nMOV BX, 1\nMOV "+t+(string)", BX\n"+l2+(string)":\n");
            }

            $$->setAsmCodeSymbol(t);

		}
	;
				
simple_expression : term 
		{
			cout<<"Line "<<line_count<<": simple_expression : term"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType((string)$1->getReturnType());

			//**********Assembly Code***********//
			//..................................//
			
			$$->setAsmCode($1->getAsmCode());
			$$->setAsmCodeSymbol($1->getAsmCodeSymbol());
			
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


			//**********Assembly Code***********//
			//..................................//

			string t = "TEMP";
			string n = get_number_to_string(current_temp++);
			t+=n;
            data_sgmt_varList.push_back(t+(string)" DW ?");

			string str = (string)";Line no: "+get_number_to_string(line_count)+(string)" -> "+$$->getName()+(string)"\n";

            if($2->getName() == "+") {
                $$->setAsmCode(str+$1->getAsmCode()+$3->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"\nADD AX, "
							+$3->getAsmCodeSymbol()+(string)"\nMOV "+t+(string)", AX\n");
                $$->setAsmCodeSymbol(t);
            } 
			else {
                $$->setAsmCode(str+$1->getAsmCode()+$3->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"\nSUB AX, "
							+$3->getAsmCodeSymbol()+(string)"\nMOV "+t+(string)", AX\n");
                $$->setAsmCodeSymbol(t);
            }

		} 
	;
					
term :	unary_expression
		{
			cout<<"Line "<<line_count<<": term : unary_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType($1->getReturnType());


			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());
			$$->setAsmCodeSymbol($1->getAsmCodeSymbol());

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



			//**********Assembly Code***********//
			//..................................//

			string t = newTemp();
            data_sgmt_varList.push_back(t+(string)" DW ?");

			string str = (string)";Line no: "+get_number_to_string(line_count)+(string)" -> "+$$->getName()+(string)"\n";

            if($2->getName() == "*") {
                $$->setAsmCode(str+$1->getAsmCode()+$3->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"\nMOV BX, "
							+$3->getAsmCodeSymbol()+(string)"\nIMUL BX\nMOV "+t+(string)", AX\n");
                $$->setAsmCodeSymbol(t);

            }
			else {
                $$->setAsmCode(str+$1->getAsmCode()+$3->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"\nCWD\n"
                			+(string)"MOV BX, "+$3->getAsmCodeSymbol()+(string)"\nIDIV BX\n");
                
                if($2->getName() == "/") {
                    $$->setAsmCode($$->getAsmCode()+(string)"MOV "+t+(string)", AX\n");
                } else {
                    $$->setAsmCode($$->getAsmCode()+(string)"MOV "+t+(string)", DX\n");
                }
                
                $$->setAsmCodeSymbol(t);
            }
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


			//**********Assembly Code***********//
			//..................................//

			if($1->getName() == "+") {
				$$->setAsmCodeSymbol($2->getAsmCodeSymbol());
                $$->setAsmCode($2->getAsmCode());
			}
			else {
                string t = "TEMP";
				string n = get_number_to_string(current_temp++);
				t+=n;
				data_sgmt_varList.push_back(t+(string)" DW ?");
                $$->setAsmCode($2->getAsmCode()+(string)"MOV AX, "+$2->getAsmCodeSymbol()+(string)"\nMOV "+t+(string)", AX\nNEG "+t+(string)"\n");
                $$->setAsmCodeSymbol(t);
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


			//**********Assembly Code***********//
			//..................................//

			string l1 = newLabel();
            string l2 = newLabel();
			string t = newTemp();
            data_sgmt_varList.push_back(t+(string)" DW ?");

            $$->setAsmCode($2->getAsmCode()+(string)"MOV AX, "+$2->getAsmCodeSymbol()+(string)"\nCMP AX, 0\nJE "+l1
							+(string)"\nMOV AX, 0\nMOV "+t+(string)", AX\nJMP "+l2+(string)"\n"
            				+(string)""+l1+(string)": \nMOV AX, 1\nMOV "+t+(string)", AX\n"+l2+(string)":\n");

            $$->setAsmCodeSymbol(t);
		}
		| factor 
		{
			cout<<"Line "<<line_count<<": unary_expression : factor"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType((string)$1->getReturnType());
			

			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());
			$$->setAsmCodeSymbol($1->getAsmCodeSymbol());
		}
	;
	
factor	: variable 
		{
			cout<<"Line "<<line_count<<": factor : variable"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), $1->getType());
			$$->setReturnType((string)$1->getReturnType());
			$$->setCategory($1->getCategory());
			
			
			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());
			$$->setAsmCodeSymbol($1->getAsmCodeSymbol());

			if($$->getCategory()==3) {
                string t = "TEMP";
				string n = get_number_to_string(current_temp++);
				t+=n;
                data_sgmt_varList.push_back(t+(string)" DW ?");

                $$->setAsmCode($$->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"[BX]\nMOV "+t+(string)", AX\n");
                $$->setAsmCodeSymbol(t);
            }
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


			//**********Assembly Code***********//
			//..................................//

			//make a temporary variable for function return value
			string t = "TEMP";
			string n = get_number_to_string(current_temp++);
			t+=n;

			//for declaring in data segment
			data_sgmt_varList.push_back(t+(string)" DW ?");
			
			//push func all argument of function before calling function
			$$->setAsmCode($3->getAsmCode()+(string)"PUSH AX\nPUSH BX\n");

			for(int i=0; i<sent_func_arg.size(); i++) {
				$$->setAsmCode($$->getAsmCode()+(string)"PUSH "+sent_func_arg[i]+(string)"\n");
			}

			//call procedure
			$$->setAsmCode($$->getAsmCode()+(string)"CALL "+si->getAsmCodeSymbol()+(string)"_FUNC\n");

			//pop return value if function return a value
			if(si->getReturnType() != "void") {
				$$->setAsmCode($$->getAsmCode()+(string)"POP "+t+(string)"\n");
			}

			//pop all variable which are pushed before procedure calling
			$$->setAsmCode($$->getAsmCode()+(string)"POP BX\nPOP AX\n");
			$$->setAsmCodeSymbol(t);

			argumentList.clear();
			sent_func_arg.clear();
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


			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($2->getAsmCode());
			$$->setAsmCodeSymbol($2->getAsmCodeSymbol());

		}
		| CONST_INT
		{
			cout<<"Line "<<line_count<<": factor : CONST_INT"<<endl<<endl;	
			cout<<(string)$1->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName(), "int");
			$$->setReturnType("int");

			
			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCodeSymbol($1->getName());
		} 
		| CONST_FLOAT
		{
			cout<<"Line "<<line_count<<": factor : CONST_FLOAT"<<endl<<endl;	
			cout<<(string)$1->getName()<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName(), "float");
			$$->setReturnType("float");
			
			
			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCodeSymbol($1->getName());
		}
		| variable INCOP 
		{
			cout<<"Line "<<line_count<<": factor : variable INCOP"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)"++"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"++", "nt");
			$$->setReturnType($1->getReturnType());


			//**********Assembly Code***********//
			//..................................//

			if($1->getCategory()==0){
				string t = "TEMP";
				string n = get_number_to_string(current_temp++);
				t+=n;
				data_sgmt_varList.push_back(t+(string)" DW ?");
                $$->setAsmCode($1->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"\nMOV "+t+(string)", AX\n"
								+(string)"INC "+$1->getAsmCodeSymbol()+(string)"\n");
                $$->setAsmCodeSymbol(t);
			}
			else if($1->getCategory()==3){
				string t = "TEMP";
				string n = get_number_to_string(current_temp++);
				t+=n;
				data_sgmt_varList.push_back(t+(string)" DW ?");
                $$->setAsmCode($1->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"[BX]\nMOV "+t+(string)", AX\n"
								+(string)"INC "+$1->getAsmCodeSymbol()+(string)"[BX]\n");
                $$->setAsmCodeSymbol(t);
			}
		}
		| variable DECOP
		{
			cout<<"Line "<<line_count<<": factor : variable DECOP"<<endl<<endl;	
			cout<<(string)$1->getName()+(string)"--"<<endl<<endl;
			$$ = new SymbolInfo((string)$1->getName()+(string)"--", "nt");
			$$->setReturnType($1->getReturnType());


			//**********Assembly Code***********//
			//..................................//

			if($1->getCategory()==0){
				string t = "TEMP";
				string n = get_number_to_string(current_temp++);
				t+=n;
				data_sgmt_varList.push_back(t+(string)" DW ?");
                $$->setAsmCode($1->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"\nMOV "+t+(string)", AX\n"
								+(string)"DEC "+$1->getAsmCodeSymbol()+(string)"\n");
                $$->setAsmCodeSymbol(t);
			}
			else if($1->getCategory()==3){
				string t = "TEMP";
				string n = get_number_to_string(current_temp++);
				t+=n;
				data_sgmt_varList.push_back(t+(string)" DW ?");
                $$->setAsmCode($1->getAsmCode()+(string)"MOV AX, "+$1->getAsmCodeSymbol()+(string)"[BX]\nMOV "+t+(string)", AX\n"
								+(string)"DEC "+$1->getAsmCodeSymbol()+(string)"[BX]\n");
                $$->setAsmCodeSymbol(t);
			}
			
		}
	;
	
argument_list : arguments
		{
			cout<<"Line "<<line_count<<": argument_list : arguments"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
			
			
			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());
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
			
			
			//**********Assembly Code***********//
			//..................................//
			
			$$->setAsmCode((string)$1->getAsmCode()+(string)$3->getAsmCode());

			if((string)$3->getReturnType()=="void") {
                setError("Void function called within argument of function "+(string)$3->getName());
                $3->setReturnType("float");
            }
			argumentList.push_back($3->getReturnType());
			sent_func_arg.push_back($3->getAsmCodeSymbol());
		}
	    | logic_expression
		{
			cout<<"Line "<<line_count<<": arguments : logic_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), "nt");
			
			
			//**********Assembly Code***********//
			//..................................//

			$$->setAsmCode($1->getAsmCode());

			if((string)$1->getReturnType()=="void") {
                setError("Void function called within argument of function "+(string)$1->getName());
                $1->setReturnType("float");
            }
			argumentList.push_back($1->getReturnType());
			sent_func_arg.push_back($1->getAsmCodeSymbol());
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

	freopen("1705017_log.txt","w",stdout);

	yyin = input;
	yyparse();

	symbolTable->printAllScope();

	cout<<"Total lines: "<<line_count<<endl;
	cout<<"Total errors: "<<error_count<<endl;

	fclose(yyin);
	errFile.close();

	return 0;
}

