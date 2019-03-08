%{
#include <stdio.h>
%}

%%
"<"title>[^<]* { printf("Tit: %s \n", yytext+7);}
(Info[^"}}"]*) { printf("Info: %s \n", yytext+5);}
.|\n {;}
%%

int yywrap() {

    return 1;
}

int main() {

    printf("filtragem a começar\n");
    yylex();
    printf("\n");
    return 0;
}