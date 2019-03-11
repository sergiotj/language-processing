%{
#include <stdio.h>
%}

%x INFO
%x RESUMO

%%

"<"title>[^<]* { printf("\nARTIGO\nTit: %s \n", yytext+7);} /* imprime título */

(Info[^"|"]*) { printf("Info: %s \n", yytext+5); } /* imprime cabeçalho da info */

\|([A-z ]*)\= { printf("%s", yytext+1); BEGIN INFO; }  /* imprime a parte da esquerda da info */

<INFO>\n|\r { printf("\n"); BEGIN INITIAL;} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda de linha e muda o estado */

<INFO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<INFO>\[|\] {;}
<INFO>\'\'\' {;} /* tirat os ''' */
<INFO>&lt;br&gt; {;}
<INFO>\{\{[A-z]*\}\}[ ] {;}
<INFO>\(.*?\) {;} /* tirar tudo o que é parentesis */

\'\'\'[.]*? { printf("\nResumo: "); BEGIN RESUMO;}

<RESUMO>\[|\]|(''') {;}

<RESUMO>\(\{\{(.*)\}\}\) { printf("("); yytext[yyleng-3] = '\0'; int i = 0; while (yytext[i] != '|') { i++;} i++; while (yytext[i] != '|') { i++;}
                            printf("%s", yytext+i+1); printf(")");
                        } /* [[Tétis (nereida)|Tétis|Tétis]] */

<RESUMO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<RESUMO>&lt;(.*)&gt; {;} /* tirar cenas < > */

<RESUMO>\{\{(.*?)\}\} {;} /* tirar o que está dentro de parentesis */

<RESUMO>\{\{Citar[ ]livro[\n\r][^\,]*?\}\} /* tirar livro */

<RESUMO>\n|\r { printf("\n"); BEGIN INITIAL;} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda de linha e muda o estado */

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