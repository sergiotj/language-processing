%{
#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>

int x = -1;
int cat = 0;
int toRead;
int tit = 0;
int info = 0;
%}

%x INFO
%x RESUMO
%x LINKS

%%

"<"title>[^<]* { if (toRead != 0) {if(tit == toRead) {return 0;}} printf("\n\n\\section{%s} \n", yytext+7); x = 1; cat = 0; tit++; info = 0;} /* imprime título */

\{\{Info(\/[^\n\r]*)?[\n\r]/[|] { if (info == 0) {printf("Info: %s \n", yytext+7); BEGIN INFO;  info = 1; }} /* imprime cabeçalho da info e muda para o estado INFO */

<INFO>\}\}[\n\r]*/[A-Þ\'\=&] { yytext[yyleng-2] = '\0'; printf("\n"); BEGIN INITIAL;}

<INFO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<INFO>[ ]\=/[^ ] {printf(" = ");} /* na info, meter espaços onde não tem */
<INFO>[ ]*\|[ ]*/[ a-ÿA-z0-9A-Þ_ã-]+[ ]*\= {;}

<INFO>\[|\] {;}
<INFO>\&lt\;ref { ; }
<INFO>\' {;} /* tirar os ' */
<INFO>&lt;br&gt; {;}
<INFO>\{\{[A-z]*\}\}[ ] {;}
<INFO>\(.*?\) {;} /* tirar tudo o que é parentesis */
<INFO>&amp;nbsp; {;}
<INFO>&lt;(.*)&gt\; {;}
<INFO>&quot; {;}

<INFO>\_ {printf("-");} /*LATEX*/

<INITIAL>^[A-Z\'] { if (x == 1) { if (isupper(yytext[0])) { printf("\nResumo: %s", yytext); } else { printf("\nResumo: ");} BEGIN RESUMO; x = -1; } }

<RESUMO>(\[|\])|\' {;}

<RESUMO>\[\[Imagem:.*[.]\]\][\n|\r] {;}

<RESUMO>\(\{\{[^\n]+\}\}\) {;}

<RESUMO>&quot; {;}

<RESUMO>&lt;ref { BEGIN LINKS; }
<LINKS>.|\n|\r {;}
<LINKS>&lt;\/ref&gt; {BEGIN RESUMO;}

<RESUMO>\[\[[ ]*[^ ]+([ ][^ ]+)?[ ]*\|([^ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<RESUMO>\n|\r { BEGIN INITIAL;} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda o estado */

\[\[Categoria\:.*/\]\][\<|\n|\r] { if (cat == 0) { printf("\nCategorias:"); } if (yytext[yyleng-2] == '|') { yytext[yyleng-2] = '\0';  }
                                                printf(" %s;", yytext+12); cat++;
                                                } /* sacar as categorias e tirar o | que vem às vezes */


.|\n {;}
%%

// LATEX ----------
void beginDocument(){
	printf("\\documentclass[a4paper]{article}\n");
	printf("\\usepackage[portuguese]{babel}\n");
	printf("\\usepackage[utf8x]{inputenc}\n");
	printf("\\begin{document}\n");
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

    remove("tp1.tex");

    int fd = open("tp1.tex", O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);

    int stdout = dup(1);
    dup2(fd, 1);

    beginDocument();

    yylex();

    printf("\n\n");

    endDocument();

    close(fd);

    dup2(stdout,1);
    printf("filtragem realizada com sucesso!\n");
    close(stdout);

    return 0;
}