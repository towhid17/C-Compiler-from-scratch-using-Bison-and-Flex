#ifndef SYMBOLTABLE
#define SYMBOLTABLE

#include<bits/stdc++.h>
using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo* next;
    string returnType;
    //category: 0=variable, 1=funcDec, 2=funcDef, 3=array
    int category; 
    int arraySize;
    bool isMisMatch = false;
    vector<pair<string, string>> parameterList;

    string asm_code;
    string asm_code_symbol;

public:

    SymbolInfo(string name, string type){
        this->name = name;
        this->type = type;
        this->next = nullptr;
        this->isMisMatch = false;
    }
    string getName(){
        return this->name;
    }
    string getType(){
        return this->type;
    }
    void setName(string name){
        this->name = name;
    }
    void setType(string type){
        this->type = type;
    }

    void setMisMatch(bool b){
        this->isMisMatch = b;
    }

    bool getMisMatch(){
        return this->isMisMatch;
    }

    void setNext(SymbolInfo* next){
        this->next = next;
    }

    SymbolInfo* getNext(){
        return this->next;
    }

    void setReturnType(string type){
        this->returnType = type;
    }

    string getReturnType(){
        return this->returnType;
    }

    void setCategory(int i){
        this->category = i;
    }

    int getCategory(){
        return this->category;
    }

    void setArraySize(int size){
        this->arraySize = size;
    }

    int getArraySize(){
        return this->arraySize;
    }

    void insertParameter(string name, string type){
        this->parameterList.push_back(make_pair(name, type));
    }

    pair<string, string> getParameter(int idx){
        if(idx>=this->parameterList.size()){
            return make_pair("null", "null");
        }
        return this->parameterList[idx];
    }

    int getParameterCount(){
        return this->parameterList.size();
    }

    string getAsmCode(){
        return this->asm_code;
    }

    string getAsmCodeSymbol(){
        return this->asm_code_symbol;
    }

    void setAsmCode(string code){
        this->asm_code = code;
    }

    void setAsmCodeSymbol(string symbol){
        this->asm_code_symbol = symbol;
    }

    ~SymbolInfo(){
        parameterList.clear();
    }

};

class ScopeTable
{
    vector<SymbolInfo*> hashTable;
    int total_buckets;
    string id;
    int child;
    ScopeTable* parentScope;

    int hashFunc(string name){
        int idx = 0;
        for(int i=0; i<name.length(); i++){
            idx+=name[i];
        }
        return idx%total_buckets;
    }

public:
    ScopeTable(int n, string id){
        total_buckets = n;
        hashTable.reserve(n);
        this->id = id;
        child = 0;
        for(int i=0; i<n; i++)
        {
            hashTable[i]=nullptr;
        }
    }

    ~ScopeTable(){
        for(SymbolInfo* s: hashTable){
            while(s->getNext()){
                SymbolInfo* prev = s;
                s = s->getNext();
                delete prev;
            }
            delete s;
        }
        hashTable.clear();
    }
    
    void setID(string id){
        this->id = id;
    }
    string getID(){
        return this->id;
    }
    void setChild(int n){
        child = n;
    }

    int getChild(){
        return child;
    }

    void setParent(ScopeTable* parentScope){
        this->parentScope = parentScope;
    }

    ScopeTable* getParent(){
        return this->parentScope;
    }
    
    bool Insert(string name, string type){
        SymbolInfo* sm = this->Lookup(name);
        if(sm!=nullptr){
        //cout<<name<<" already exists in current ScopeTable"<<endl<<endl;
            return false;
        }

        int idx = hashFunc(name);
        int pos = 0;
        SymbolInfo* SI = new SymbolInfo(name, type);
        if(hashTable[idx]!=nullptr){
        pos++;
        SymbolInfo* s = hashTable[idx];
        while(s->getNext()){
            s = s->getNext();
            pos++;
        }
        s->setNext(SI);
        }
        else hashTable[idx] = SI;
        return true;
    }

    bool Insert(SymbolInfo *si){
        SymbolInfo* sm = this->Lookup(si->getName());
        if(sm!=nullptr){
            //cout<<name<<" already exists in current ScopeTable"<<endl<<endl;
            return false;
        }

        int idx = hashFunc(si->getName());
        int pos = 0;
        if(hashTable[idx]!=nullptr){
        pos++;
        SymbolInfo* s = hashTable[idx];
        while(s->getNext()){
            s = s->getNext();
            pos++;
        }
        s->setNext(si);
        }
        else hashTable[idx] = si;
        return true;
    }


    SymbolInfo* Lookup(string name){
        int idx = hashFunc(name);
        if(hashTable[idx]==nullptr) return nullptr;
        SymbolInfo* s = hashTable[idx];

        if(s->getName()==name) {
        return s;
        }
        else{
            int sidx = 0;
            while(s->getNext()){
                s = s->getNext();
                sidx++;
                if(s->getName()==name) {
                    return s;
                }
            }
        }
        return nullptr;
    }

 

    bool Delete(string name){
        int idx = hashFunc(name);
        if(hashTable[idx]==nullptr) {
            return false;
        }
        SymbolInfo* s = hashTable[idx];
        int sidx = 0;
        if(s->getName()==name) {
            if(s->getNext()==nullptr) {
                delete s;
                hashTable[idx] = nullptr;
            }
            else{
                hashTable[idx] = s->getNext();
                delete s;
            }
            return true;
        }
        else{
            SymbolInfo* prev = s;
            while(s->getNext()){
                sidx++;
                prev = s;
                s = s->getNext();
                if(s->getName()==name){
                    prev->setNext(s->getNext());
                    delete s;
                    return true;
                }
            }
        }
        return false;
    }
        
    void print(){
        cout<<endl<<endl<<endl;
        cout<<"ScopeTable # "<<this->id<<endl;

        for(int i=0; i<total_buckets; i++){
            SymbolInfo* s = hashTable[i];
            SymbolInfo* ss = s;
            if(s!=nullptr) cout<<" "<<i<<" --> ";
            while(s!=nullptr){
                cout<<"< "<<s->getName()<<" , "<<s->getType()<<" > ";
                s = s->getNext();
            }
            if(ss!=nullptr) cout<<endl;
        }
        //cout<<endl;
    }

};


class SymbolTable{
    ScopeTable* current_ScopeTable;
    int total_buckets;
public:
    SymbolTable(int n){
        total_buckets = n;
        current_ScopeTable = new ScopeTable(n, "1");
    }
    ~SymbolTable(){
        delete current_ScopeTable;
    }
    
    void EnterScope(){
        if(current_ScopeTable!=nullptr){
            string id;
            int child = current_ScopeTable->getChild();
            child++;
            id = current_ScopeTable->getID();
            id = id + "."+ to_string(child);
            ScopeTable* scope = new ScopeTable(total_buckets, id);
            scope->setParent(current_ScopeTable);
            current_ScopeTable = scope;
            //cout<<"New ScopeTable with id "<<id<<" created"<<endl;
        }
        else{
            string id = "1";
            ScopeTable* scope = new ScopeTable(total_buckets, id);
            current_ScopeTable = scope;
            //cout<<"New ScopeTable with id "<<id<<" created"<<endl;
        }
    }

    void ExitScope(){
        string id = current_ScopeTable->getID();
        ScopeTable* scope = current_ScopeTable->getParent();
        delete current_ScopeTable;
        current_ScopeTable = scope;
        current_ScopeTable->setChild(current_ScopeTable->getChild()+1);
        //cout<<"ScopeTable with id "<<id<<" removed"<<endl;
    }

    bool Insert(string name, string type){
        if(current_ScopeTable==nullptr) return false;
        if(current_ScopeTable->Insert(name, type))
            return true;
        return false;
    }

    bool Insert(SymbolInfo *si){
        if(current_ScopeTable==nullptr) return false;
        if(current_ScopeTable->Insert(si))
            return true;
        return false;
    }

    bool Remove(string name){
        if(current_ScopeTable->Delete(name))
            return true;
        return false;
    }

    SymbolInfo* currentScopeLookup(string name){
        if(current_ScopeTable!=nullptr){
            return current_ScopeTable->Lookup(name);
        }
        else return nullptr;
    }

    SymbolInfo* Lookup(string name){
        ScopeTable* cs = current_ScopeTable;
        SymbolInfo* si;

        while(1){
            if(cs==nullptr){
                break;
            }
            si = cs->Lookup(name);
            if(si!=nullptr)
                break;
            else cs = cs->getParent();
        }
        return si;
    }

    void printCurrentScope(){
        current_ScopeTable->print();
        return;
    }

    void printAllScope(){
        ScopeTable* sc = current_ScopeTable;
        while(sc!=nullptr){
            sc->print();
            sc = sc->getParent();
        }
        cout<<endl<<endl;
        return;
    }

};


#endif

