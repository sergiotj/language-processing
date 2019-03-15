%{
#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>

int x = -1;
int cat = 0;
int toRead;
int tit = 0;
%}

%x INFO
%x RESUMO
%x LINKS

%%

"<"title>[^<]* { if (toRead != 0) {if(tit == toRead) {return 1;}} printf("\n\nARTIGO\nTit: %s \n", yytext+7); x = 1; cat = 0; tit++;} /* imprime título */

\{\{(Info[^"|"]*) { printf("Info: %s \n", yytext+7); BEGIN INFO;} /* imprime cabeçalho da info */

<INFO>[ |]?[ ]?([a-ÿA-z0-9A-Þ _ã]*)[ ]?\= { if (yytext[0] == '|') printf("%s", yytext+1); else printf("%s", yytext);}  /* imprime a parte da esquerda da info */

<INFO>[\n\r][\| ] { printf("\r");} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda de linha e muda o estado */

<INFO>[\n\r][^\|\&] { yytext[yyleng-2] = '\0'; printf("\n"); BEGIN INITIAL; }

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

<INITIAL>^[A-Z\'] { if (x == 1) { if (isupper(yytext[0])) { printf("\nResumo: %s", yytext); } else { printf("\nResumo: ");} BEGIN RESUMO; x = -1; } }

<RESUMO>(\[|\])|\' {;}

<RESUMO>\[\[Imagem:.*[.]\]\][\n|\r] {;}

<RESUMO>\(\{\{[^ ]*\}\}\) { printf("("); yytext[yyleng-3] = '\0'; int i = 0; while (yytext[i] != '|') { i++;} i++; while (yytext[i] != '|') { i++;}
                            printf("%s", yytext+i+1); printf(")");
                        }

<RESUMO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */


<RESUMO>[\n\r]+ { BEGIN INITIAL;} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda de linha e muda o estado */

\[\[Categoria\:.*\]\][\<|\n|\r] { if (cat == 0) {printf("\nCategorias: ");} yytext[yyleng-3] = ';'; yytext[yyleng-2] = ' '; yytext[yyleng-1] = '\0';
                                                printf("%s", yytext+12); cat++;}

.|\n {;}
%%

// LATEX ----------
void beginDocument(){
	printf("\\documentclass[a4paper]{article}\n\n");
	printf("\\usepackage[portuguese]{babel}\n\n");
	printf("\\usepackage[utf8]{inputenc}\n");
	printf("\\begin{document}\n\n");
}

void endDocument(){
	printf("\\end{document}\n");
}

int yywrap() {

    return 1;
}

int main(int argc, char **argv) {

    printf("filtragem a começar\n");

    if (argc < 2) {

        printf("Não passou os argumentos suficientes à função\n");
        return 0;
    }

    toRead = atoi(argv[1]);

    int fd = open("tp1.tex", O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);

    dup2(fd, 1);

    beginDocument();
    yylex();
    endDocument();

    close(fd);

    return 0;
}