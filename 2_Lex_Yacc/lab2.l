%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *symbolTableOutput;
FILE *pifOutput;

int linie = 1;
int coloana = 0;

typedef struct {
    char symbol[101];
    int index;
} SymbolEntry;

typedef struct {
    char token[101];
    int linie;
    int coloana;
} PIFEntry;

SymbolEntry symbolTable[1000];
int symbolCount = 0;

PIFEntry pif[1000];
int pifCount = 0;

int addSymbol(char *symbol) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].symbol, symbol) == 0) {
            return i;
        }
    }
    strcpy(symbolTable[symbolCount].symbol, symbol);
    symbolTable[symbolCount].index = symbolCount;
    return symbolCount++;
}


void addPIFEntry(char *token, int linie, int coloana) {
    strcpy(pif[pifCount].token, token);
    pif[pifCount].linie = linie;
    pif[pifCount].coloana = coloana;
    pifCount++;
}

void outputSymbolTable() {
    symbolTableOutput = fopen("symbol_table.txt", "w");
    for (int i = 0; i < symbolCount; i++) {
        fprintf(symbolTableOutput, "Symbol: %s, Index: %d\n", symbolTable[i].symbol, symbolTable[i].index);
    }
    fclose(symbolTableOutput);
}

void outputPIF() {
    pifOutput = fopen("pif.txt", "w");
    for (int i = 0; i < pifCount; i++) {
        fprintf(pifOutput, "Token: %s, linie: %d, coloana: %d\n", pif[i].token, pif[i].linie, pif[i].coloana);
    }
    fclose(pifOutput);
}
%}

%option noyywrap

/* Token Patterns */
DIGIT   [0-9]
LETTER  [a-z]
ID      ({LETTER}|[.])({LETTER}|{DIGIT}|[.])*
NUMBER  {DIGIT}+

%%


"if"                    { addPIFEntry("IF", linie, coloana); coloana += yyleng; }
"else"                  { addPIFEntry("ELSE", linie, coloana); coloana += yyleng; }


"+"                     { addPIFEntry("PLUS", linie, coloana); coloana += yyleng; }
"-"                     { addPIFEntry("MINUS", linie, coloana); coloana += yyleng; }
"*"                     { addPIFEntry("MULTIPLY", linie, coloana); coloana += yyleng; }
"/"                     { addPIFEntry("DIVIDE", linie, coloana); coloana += yyleng; }
"="                     { addPIFEntry("ASSIGN", linie, coloana); coloana += yyleng; }


"("                     { addPIFEntry("LEFT_PAREN", linie, coloana); coloana += yyleng; }
")"                     { addPIFEntry("RIGHT_PAREN", linie, coloana); coloana += yyleng; }
"{"                     { addPIFEntry("LEFT_BRACE", linie, coloana); coloana += yyleng; }
"}"                     { addPIFEntry("RIGHT_BRACE", linie, coloana); coloana += yyleng; }
";"                     { addPIFEntry("SEMICOLON", linie, coloana); coloana += yyleng; }


{NUMBER}                { 
                            int pos = addSymbol(yytext); 
                            addPIFEntry("NUMBER", linie, coloana);   
                            coloana += yyleng; 
                        }


{ID}                    {
                            int pos = addSymbol(yytext);
                            addPIFEntry("ID", linie, coloana);
                            coloana += yyleng;
                        }

\n                      { linie++; coloana = 0; }

[ \t]                   { coloana += yyleng; } 

.                       { fprintf(stderr, "Lexical error at linie %d, coloana %d: Unknown '%s'\n", linie, coloana, yytext); coloana += yyleng; }

%%

int main(int argc, char **argv) {
    

    yyin = input;
    yylex();

    outputSymbolTable();
    outputPIF();

    fclose(input);
    return 0;
}
