%{
#include <stdio.h>

int x = 0;
%}

%x INFO
%x RESUMO
%x LINKS

%%

"<"title>[^<]* { x = 1; printf("\n\nARTIGO\nTit: %s \n", yytext+7);} /* imprime título */

\{\{(Info[^"|"]*) { printf("Info: %s \n", yytext+7); BEGIN INFO; } /* imprime cabeçalho da info */

<INFO>[ |]?[ ]?([a-ÿA-z0-9A-Þ _ã]*)[ ]?\= { if (yytext[0] == '|') printf("%s", yytext+1); else printf("%s", yytext);}  /* imprime a parte da esquerda da info */

<INFO>[\n\r][\| ] { printf("\r");} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda de linha e muda o estado */

<INFO>[\n\r][^\|\&]*[^| &] { yytext[yyleng-2] = '\0'; printf("\n"); BEGIN INITIAL;}

<INFO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<INFO>\[|\] {;}
<INFO>\&lt\;ref { ; }
<INFO>\'\'\' {;} /* tirar os ''' */
<INFO>&lt;br&gt; {;}
<INFO>\{\{[A-z]*\}\}[ ] {;}
<INFO>\(.*?\) {;} /* tirar tudo o que é parentesis */
<INFO>&amp;nbsp; {;}
<INFO>&lt;(.*)&gt\; {;}

<INITIAL>\{\{[\n\r]*[A-Z\']* { if (x == 1) { printf("\nResumo: %s", yytext); BEGIN RESUMO; x = 2; } }

<RESUMO>\[|\]|(''') {;}

<RESUMO>\(\{\{(.*)\}\}\) { printf("("); yytext[yyleng-3] = '\0'; int i = 0; while (yytext[i] != '|') { i++;} i++; while (yytext[i] != '|') { i++;}
                            printf("%s", yytext+i+1); printf(")");
                        } /* [[Tétis (nereida)|Tétis|Tétis]] */

<RESUMO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */


<RESUMO>[\n\r][\n\r] { printf("\n"); BEGIN INITIAL;} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda de linha e muda o estado */

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