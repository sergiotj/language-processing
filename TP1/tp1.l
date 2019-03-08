%{
#include <stdio.h>
%}

%x ACORDA

%%

"<"title>[^<]* { printf("Tit: %s \n", yytext+7);}

(Info[^"|"]*) { printf("Info: %s \n", yytext+5); }

\|([A-z ]*)\= { printf("%s", yytext+1); BEGIN ACORDA; }

<ACORDA>[^\[\]]* { printf("%s", yytext);}

<ACORDA>\[\[(.*)\]\] { printf("%s \n", yytext);}

[A-z]*"." { printf("Resumo: %s", yytext); }

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