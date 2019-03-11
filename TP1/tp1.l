%{
#include <stdio.h>
%}

%x INFO
%x INSIDEINFO
%x RESUMO
%x LINKS

%%

"<"title>[^<]* { printf("\n\nARTIGO\nTit: %s \n", yytext+7);} /* imprime título */

\{\{(Info[^"|"]*) { printf("Info: %s \n", yytext+7); BEGIN INFO; } /* imprime cabeçalho da info */

<INFO>[ ]?\|([A-z ]*)\= { if (yytext[0] == '|') printf("%s", yytext+1); else printf("%s", yytext+2); BEGIN INSIDEINFO; }  /* imprime a parte da esquerda da info */

<INSIDEINFO>\n|\r { BEGIN INFO; } /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda de linha e muda o estado */

<INFO>^\}\} { yytext[yyleng-2] = '\0'; BEGIN INITIAL;}

<INSIDEINFO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<INSIDEINFO>\[|\] {;}
<INSIDEINFO>\'\'\' {;} /* tirar os ''' */
<INSIDEINFO>&lt;br&gt; {;}
<INSIDEINFO>\{\{[A-z]*\}\}[ ] {;}
<INSIDEINFO>\(.*?\) {;} /* tirar tudo o que é parentesis */

\'\'\'[.]*? { printf("\nResumo: "); BEGIN RESUMO;}

<RESUMO>\[|\]|(''') {;}

<RESUMO>\(\{\{(.*)\}\}\) { printf("("); yytext[yyleng-3] = '\0'; int i = 0; while (yytext[i] != '|') { i++;} i++; while (yytext[i] != '|') { i++;}
                            printf("%s", yytext+i+1); printf(")");
                        } /* [[Tétis (nereida)|Tétis|Tétis]] */

<RESUMO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<RESUMO>\&lt\;ref {BEGIN LINKS;} /* tira links/referencias */
<LINKS>.|\n {;}
<LINKS>&lt\;\/ref&gt\; {BEGIN RESUMO;}

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