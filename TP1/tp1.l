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
%x CATEGORIA
%x LINKS
%x FORMULAS
%x SMALL
%x SUP
%x MATH
%x EXTRA
%x NOWIKI
%x U
%x BR

%%

"<"title>[^<]* { if (toRead != 0) {if(tit == toRead) {return 0;}} printf("\n\n\\section{%s} \n", yytext+7); x = 1; cat = 0; tit++; info = 0; int i = 7;
                            while(yytext[i]) { if (yytext[i] == ' ') { yytext[i] = '_'; } i++; } printf("\nLink do artigo: https://pt.wikipedia.org/wiki/%s\n", yytext+7);}
                            /* imprime título */

\{\{Info(\/[^\n\r]*)?[\n\r]/[|] { if (info == 0) {printf("Info: %s \n", yytext+7); BEGIN INFO;  info = 1; }} /* imprime cabeçalho da info e muda para o estado INFO */

<INFO>\}\}[\n\r]*/[A-Þ\'\=&] { yytext[yyleng-2] = '\0'; printf("\n"); BEGIN INITIAL;}

<INFO>\[\[[ ]*([A-Za-zÀ-ÖÙ-öù-ÿ ]*)?([ ][^ ]+)?[ ]*\|([ ]?[A-Za-zÀ-ÖÙ-öù-ÿ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
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

<RESUMO>\[\[[ ]*([A-Za-zÀ-ÖÙ-öù-ÿ ]*)?([ ][^ ]+)?[ ]*\|([ ]?[A-Za-zÀ-ÖÙ-öù-ÿ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                                        printf("%s", yytext+i+1);
                                        }
<RESUMO>&amp;nbsp;       {;}

<RESUMO>\{\{formatnum:[0-9]*\}\} { yytext[yyleng-2] = '\0'; printf("%s", yytext+12);}

<RESUMO>&quot; 			{;}

<RESUMO>&lt;[Rr]ef 		{ BEGIN LINKS; }
<LINKS>.|\n|\r {;}
<LINKS>&lt;\/ref&gt;    { BEGIN RESUMO; }

<RESUMO>&lt;sub 		{ BEGIN FORMULAS; }
<FORMULAS>.|\n|\r {;}
<FORMULAS>&lt;\/sub&gt; { BEGIN RESUMO; }

<RESUMO>&lt;small 	    { BEGIN SMALL; }
<SMALL>.|\n|\r {;}
<SMALL>&lt;\/small&gt;  { BEGIN RESUMO; }

<RESUMO>&lt;sup 	    { BEGIN SUP; }
<SUP>.|\n|\r {;}
<SUP>&lt;\/sup&gt; 		{ BEGIN RESUMO; }

<RESUMO>&lt;math 	    { BEGIN MATH; }
<MATH>.|\n|\r {;}
<MATH>&lt;\/math&gt; 	{ BEGIN RESUMO; }

<RESUMO>&lt;\!\-\- 	    { BEGIN EXTRA; } /* Nem sequer aparece no wiki */
<EXTRA>.|\n|\r {;}
<EXTRA>\-\-&gt; 		{ BEGIN RESUMO; }

<RESUMO>&lt;nowiki 	    	{ BEGIN NOWIKI; }
<NOWIKI>.|\n|\r {;}
<NOWIKI>[\nowiki]?[/]?&gt; 	{ BEGIN RESUMO; }

<RESUMO>&lt;u&gt; 	    { BEGIN U; }
<U>.|\n|\r				{ printf("%s", yytext); }
<U>&lt\;\/u&gt;			{ BEGIN RESUMO; }

<RESUMO>&lt;br 			{ BEGIN BR; }
<BR>.|\n|\r 			{ ;}
<BR>[ ]?[/]?&gt			{ BEGIN RESUMO; }

<RESUMO>\n|\r { BEGIN INITIAL;} /* QUANDO ENCONTRA MUDANÇA DE LINHA, muda o estado */

\[\[Categoria\:.*/\]\][\<|\n|\r] { BEGIN CATEGORIA; if (cat == 0) { printf("\n\nCategorias:"); } if (yytext[yyleng-2] == '|') { yytext[yyleng-2] = '\0'; }
                                                printf(" %s;", yytext+12); cat++;
                                                } /* sacar as categorias e tirar o | que vem às vezes */

<CATEGORIA><INFO>\[\[[ ]*([A-Za-zÀ-ÖÙ-öù-ÿ ]*)?([ ][^ ]+)?[ ]*\|([ ]?[A-Za-zÀ-ÖÙ-öù-ÿ ]*?)\]\] { yytext[yyleng-2] = '\0'; int i = 0; while (yytext[i] != '|') { i++;}
                        printf("%s", yytext+i+1);
                        } /* [[Tétis (nereida)|Tétis]] */

<CATEGORIA>.|\n|\r {BEGIN INITIAL;}

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

int yyparse (char const *file) {

  yyin = fopen (file, "r");

  if (!yyin) {

      perror ("fopen");
      exit (EXIT_FAILURE);
    }

  return 0;
}

int main(int argc, char **argv) {

    if (argc < 4) {

        printf("Não passou os argumentos suficientes à função\n");
        printf("USAGE: ./tp1 nrLinhas inputFile outputFile \n");
        return 0;
    }

    char* file = argv[2];
    char* fileOutput = argv[3];

    printf("Início de filtragem no ficheiro %s...\n", argv[2]);

    toRead = atoi(argv[1]);

    yyin = fopen (file, "r");

    remove(fileOutput);
    int fd = open(fileOutput, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);

    int stdout = dup(1);
    dup2(fd, 1);

    beginDocument();

    yylex();

    printf("\n\n");

    endDocument();

    close(fd);

    dup2(stdout,1);
    printf("Filtragem feita em %d artigos! Output escrito em %s!\n", tit, fileOutput);
    close(stdout);

    return 0;
}