#include<bits/stdc++.h>

using namespace std;


class SymbolInfo{
    string name;
    string type;
    SymbolInfo* next;

public:

    SymbolInfo(string name, string type){
        this->name = name;
        this->type = type;
        this->next = nullptr;
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

    void setNext(SymbolInfo* next){
        this->next = next;
    }

    SymbolInfo* getNext(){
        return this->next;
    }

    ~SymbolInfo(){

    }

};

class ScopeTable{
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
        child = 0;
        this->id = id;
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

    bool Insert(string name, string type);
    SymbolInfo* Lookup(string name);
    bool Delete(string name);
    void print();
};

bool ScopeTable::Insert(string name, string type){
    SymbolInfo* sm = this->Lookup(name);
    if(sm!=nullptr) return false;

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

    ofstream out("out.txt", ios_base::app);
    out<<"Inserted into ScopeTable# "<<this->id<<" at position "
        <<idx<<", "<<pos<<endl<<endl;

    out.close();

    return true;
}

SymbolInfo* ScopeTable::Lookup(string name){
    int idx = hashFunc(name);
    if(hashTable[idx]==nullptr) return nullptr;
    SymbolInfo* s = hashTable[idx];

    ofstream out("out.txt", ios_base::app);

    if(s->getName()==name) {
        out<<"Found in ScopeTable# "<<this->id<<" at position "<<idx<<", 0"<<endl<<endl;
        out.close();
        return s;
    }
    else{
        int sidx = 0;
        while(s->getNext()){
            s = s->getNext();
            sidx++;
            if(s->getName()==name) {
                out<<"Found in ScopeTable# "<<this->id<<" at position "<<idx<<", "<<sidx<<endl<<endl;
                out.close();
                return s;
            }
        }
    }

    out.close();
    return nullptr;
}

bool ScopeTable::Delete(string name){
    int idx = hashFunc(name);

    ofstream out("out.txt", ios_base::app);

    if(hashTable[idx]==nullptr) {
        out<<"Not Found"<<endl<<endl;
        out<<name<<" not found"<<endl<<endl;
        out.close();
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
        out<<"Found in ScopeTable# "<<this->id<<" at position "<<idx<<", 0"<<endl<<endl;
        out<<"Deleted Entry "<<idx<<", 0 from current ScopeTable"<<endl<<endl;
        out.close();
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
                out<<"Found in ScopeTable# "<<this->id<<" at position "<<idx<<", "<<sidx<<endl<<endl;
                out<<"Deleted Entry "<<idx<<", "<<sidx<<" from current ScopeTable"<<endl<<endl;
                out.close();
                return true;
            }
        }
    }
    out<<"Not Found"<<endl<<endl;
    out<<name<<" not found"<<endl<<endl;
    out.close();
    return false;

}

void ScopeTable::print(){
    ofstream out("out.txt", ios_base::app);

    out<<"ScopeTable # "<<this->id<<endl;

    for(int i=0; i<total_buckets; i++){
        out<<i<<"--> ";
        SymbolInfo* s = hashTable[i];
        while(s!=nullptr){
            out<<" < "<<s->getName()<<" : "<<s->getType()<<">";
            s = s->getNext();
        }
        out<<endl;
    }
    out<<endl;
    out.close();
}

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
    void EnterScope();
    void ExitScope();
    bool Insert(string name, string type);
    bool Remove(string name);
    SymbolInfo* Lookup(string name);
    void printCurrentScope();
    void printAllScope();
};

void SymbolTable::EnterScope(){
    if(current_ScopeTable!=nullptr){
        string id;
        int child = current_ScopeTable->getChild();
        child++;
        id = current_ScopeTable->getID();
        id = id + "."+ to_string(child);
        ScopeTable* scope = new ScopeTable(total_buckets, id);
        scope->setParent(current_ScopeTable);
        current_ScopeTable = scope;
    }
    else{
        string id = "1";
        ScopeTable* scope = new ScopeTable(total_buckets, id);
        current_ScopeTable = scope;
    }

    ofstream out("out.txt", ios_base::app);

    out<<"New ScopeTable with id "<<current_ScopeTable->getID()<<" created"<<endl<<endl;

    out.close();

}

void SymbolTable::ExitScope(){
    string id = current_ScopeTable->getID();
    ScopeTable* scope = current_ScopeTable->getParent();
    delete current_ScopeTable;
    current_ScopeTable = scope;
    current_ScopeTable->setChild(current_ScopeTable->getChild()+1);

    ofstream out("out.txt", ios_base::app);

    out<<"ScopeTable with id "<<id<<" removed"<<endl<<endl;

    out.close();
}

bool SymbolTable::Insert(string name, string type){
    if(current_ScopeTable->Insert(name, type))
        return true;
    return false;
}

bool SymbolTable::Remove(string name){
    if(current_ScopeTable->Delete(name))
        return true;
    return false;
}

SymbolInfo* SymbolTable::Lookup(string name){
    ScopeTable* cs = current_ScopeTable;
    SymbolInfo* si;

    ofstream out("out.txt", ios_base::app);

    while(1){
        if(cs==nullptr){
            out<<"Not found"<<endl<<endl;
            break;
        }
        si = cs->Lookup(name);
        if(si!=nullptr)
            break;
        else cs = cs->getParent();
    }
    out.close();
    return si;
}

void SymbolTable::printCurrentScope(){
    current_ScopeTable->print();
    return;
}

void SymbolTable::printAllScope(){
    ScopeTable* sc = current_ScopeTable;
    while(sc!=nullptr){
        sc->print();
        sc = sc->getParent();
    }
    return;
}

int main()
{
    int n;
    ifstream input("input.txt");
    input>>n;
    SymbolTable st(n);
    string tmp;
    getline(input, tmp);
    ofstream output;
    output.open("out.txt");
    output.close();
    output.open("out.txt", ios_base::app);


    while(1){
        string str, tk;
        getline(input, str);
        output<<str<<endl<<endl;
        vector<string> tokens;
        stringstream strm(str);
        while(getline(strm, tk, ' ')){
            tokens.push_back(tk);
        }
        if(tokens[0]=="I"){
            st.Insert(tokens[1], tokens[2]);
        }
        else if(tokens[0]=="L"){
            st.Lookup(tokens[1]);
        }
        else if(tokens[0]=="D"){
            st.Remove(tokens[1]);
        }
        else if(tokens[0]=="P"){
            if(tokens[1]=="A"){
                st.printAllScope();
                output<<endl;
            }
            else if(tokens[1]=="C"){
                st.printCurrentScope();
            }
        }
        else if(tokens[0]=="S"){
            st.EnterScope();
        }
        else if(tokens[0]=="E"){
            st.ExitScope();
        }
        else if(tokens[0]=="Exit"){
            break;
        }
        else continue;
    }

    cout<<"Done"<<endl;
    output.close();
    return 0;
}
