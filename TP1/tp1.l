%{
#include <stdio.h>
%}

%x ACORDA

%%

"<"title>[^<]* { printf("\nARTIGO\nTit: %s \n", yytext+7);} /* imprime título */

(Info[^"|"]*) { printf("Info: %s \n", yytext+5); } /* imprime Info */

\|([A-z ]*)\= { printf("%s", yytext+1); BEGIN ACORDA; }  /* imprime a parte da esquerda da info */

<ACORDA>\s[A-z 0-9\(\)\.]* { printf("%s", yytext);} /* texto normal */

<ACORDA>\n|\r { printf("\n"); BEGIN INITIAL;} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda de linha e muda o estado */

<ACORDA>\[\[(.*?)\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<ACORDA>\[\[[A-z]*?\]\] { yytext[yyleng-2] = '\0'; printf("%s", yytext+2);} /* [[Peleu]] */
<ACORDA>\[\[([\S]*)\]\], { yytext[yyleng-2] = '\0'; printf("%s", yytext+2);} /* [[Peleu]], */

\}\}[\n\r]*\'\'\'.*\n|\r { yytext[yyleng-2] = '\0'; printf("Resumo: ");}

.|\n|\] {;}
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