%{
#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>

int flag = -1;
int cat = 0;
int toRead;
int tit = 0;
int info = 0;

%}

%x INFO
%x RESUMO
%x LINKS
%x FORMULAS
%x SMALL
%x SUP
%x MATH
%x EXTRA
%x NOWIKI
%x U
%x BR
%x FMTNRES
%x FMTNINFO
%x TOOLTIP
%x IMAGEM

%%

\<title>[^<]* { if (toRead != 0) {
                    if(tit == toRead) {
                        return 0;
                    }
                }
                printf("\n\n\\section{%s} \n", yytext+7);
                flag = 1; cat = 0; tit++; info = 0; int i = 7;
                while(yytext[i]) {
                    if (yytext[i] == ' ') {
                        yytext[i] = '_';
                    }
                    i++;
                }
                printf("\nLink do artigo: \\url{https://pt.wikipedia.org/wiki/%s}\\newline\n", yytext+7);
            }

\{\{Info(\/)?.*\n/[ ]?\|            { if (info == 0) {
                                        yytext[yyleng-1] = '\0';
                                        int i = 0;
                                        while(yytext[i]) {
                                            if (yytext[i] == '/') {
                                                yytext[i] = '-';
                                            }
                                            i++;
                                        }
                                        printf("Info: %s \\newline\n", yytext+7);
                                        BEGIN INFO;  info = 1;
                                        }
                                    }

<INFO>\}\}[\n\r][\n\r]?/[A-Z\'\=&\[]        { BEGIN INITIAL; }
<INFO>^\}\}                                 { BEGIN INITIAL; }

<INFO>[ ]\=/[^ ]                           { printf(" = "); }
<INFO>[ ]*\|[ ]*/[ a-ÿA-z0-9A-Þ_ã-]+[ ]*\= { ; }
<INFO>\&lt\;ref                            { ; }
<INFO>\'                                   { ; }
<INFO>&lt;br&gt;                           { ; }
<INFO>&lt;(.*)&gt\;                        { ; }
<INFO>\|                                   { printf(" "); }

<INFO>\{\{fmtn\|([0-9]*)\}\}                                    { yytext[yyleng-2]='\0'; printf("%s", yytext+7); }
<INFO>\[\[[ ]*([A-Za-zÀ-ÖÙ-öù-ÿ ]*)?([ ][^ ]+)?[ ]*\|\*\]\]     { ; }
<INFO>\{\{small[ ]?\|[ ]?\(([A-Za-zÀ-ÖÙ-öù-ÿ ]*)?\)[ ]?\}\}     { int i = 1; while(yytext[i] != '|') i++;
                                                                  yytext[yyleng-2]='\0'; printf("%s", yytext+i+1);
                                                                }

<INFO>\_                                                { printf("-"); } /*LATEX*/
<INFO>\n|\r                                             { printf(" \\newline\n"); } /*LATEX*/

<INFO>\{\{[Tt]ooltip\|                                  { BEGIN TOOLTIP; }
<INFO>\{\{[Tt]ooltip[ ]num[ ]?\|                        { BEGIN TOOLTIP; }
<TOOLTIP>.                                              { ; }
<TOOLTIP>\{\{fmtn\|[0-9]*[.][0-9]*\|\[\[bilhões\]\]\}\} { ; }
<TOOLTIP>\{\{sfn\|FMI\|[0-9]*\}\}                       { ; }
<TOOLTIP>\|[$]?([0-9]*[ ]?[,]?[.]?)*\}                  { yytext[yyleng-1]='\0'; printf("%s",yytext+1); }
<TOOLTIP>\n|\r                                          { BEGIN INFO; }
<TOOLTIP>\}\}                                           { BEGIN INFO; }

<INFO>\{\{[Ff]mtn[\|]?[ ]?[\|]?                         { BEGIN FMTNINFO; }
<FMTNINFO>\|\[\[([A-Za-zÀ-ÖÙ-öù-ÿ ]*)?\|([A-Za-zÀ-ÖÙ-öù-ÿ²./ ]*)?\]\] { int i = 1;
                                                                        while(yytext[i] != '|') i++;
                                                                        yytext[yyleng-2]='\0';
                                                                        printf("%s", yytext+i+1);
                                                                    }
<FMTNINFO>[0-9]*                                        { printf("%s", yytext); }
<FMTNINFO>\|([A-Za-zÀ-ÖÙ-öù-ÿ²./$ ]*)?\}\}              { yytext[yyleng-2]='\0'; printf("%s", yytext+1); BEGIN INFO; }
<FMTNINFO>\}\}                                          { BEGIN INFO; }

<INFO>\[\[Imagem\:                                      { BEGIN IMAGEM; }
<IMAGEM>.                                               { ; }
<IMAGEM>\n|\r                                           { BEGIN INFO; }
<IMAGEM>\]\]                                            { BEGIN INFO; }

<INITIAL>^[A-Z\'] { if (flag == 1) {
                        if (isupper(yytext[0])) {
                            printf("\nResumo: %s", yytext);
                        } else {
                            printf("\nResumo: ");
                        }
                        BEGIN RESUMO; flag = -1;
                    }
                }

<INITIAL>\[\[Imagem:.*[.]\]\][\n|\r]         { ; }

<RESUMO>&lt;[Rr][Ee][Ff]                     { BEGIN LINKS; }
<LINKS>.                                     { ; }
<LINKS>\n|\r                                 { BEGIN RESUMO; }
<LINKS>&lt;\/[Rr][Ee][Ff]&gt;                { BEGIN RESUMO; }

<RESUMO>&lt;sub                              { BEGIN FORMULAS; }
<FORMULAS>.|\n|\r                            { ; }
<FORMULAS>&lt;\/sub&gt;                      { BEGIN RESUMO; }

<RESUMO>&lt;small                            { BEGIN SMALL; }
<SMALL>.|\n|\r                               { ; }
<SMALL>&lt;\/small&gt;                       { BEGIN RESUMO; }

<RESUMO>&lt;sup                              { BEGIN SUP; }
<SUP>.|\n|\r                                 { ; }
<SUP>&lt;\/sup&gt;                           { BEGIN RESUMO; }

<RESUMO>&lt;math                             { BEGIN MATH; }
<MATH>.|\n|\r                                { ; }
<MATH>&lt;\/math&gt;                         { BEGIN RESUMO; }

<RESUMO>&lt;\!\-\-                           { BEGIN EXTRA; }
<EXTRA>.|\n|\r                               { ; }
<EXTRA>\-\-&gt;                              { BEGIN RESUMO; }

<RESUMO>&lt;nowiki                           { BEGIN NOWIKI; }
<NOWIKI>.|\n|\r                              { ; }
<NOWIKI>[\nowiki]?[/]?&gt;                   { BEGIN RESUMO; }

<RESUMO>&lt;u&gt;                            { BEGIN U; }
<U>.|\n|\r                                   { printf("%s", yytext); }
<U>&lt\;\/u&gt;                              { BEGIN RESUMO; }

<RESUMO>&lt;br                               { BEGIN BR; }
<BR>.|\n|\r                                  { ; }
<BR>[ ]?[/]?&gt                              { BEGIN RESUMO; }

<RESUMO>\{\{[Ff]mtn[\|]?[ ]?[\|]?            { BEGIN FMTNRES; }
<FMTNRES>\|\[\[([A-Za-zÀ-ÖÙ-öù-ÿ ]*)?\|([A-Za-zÀ-ÖÙ-öù-ÿ²./ ]*)?\]\] { int i = 1; while(yytext[i] != '|') i++;
                                                                    yytext[yyleng-2]='\0'; printf("%s", yytext+i+1); }
<FMTNRES>[0-9]*                              { printf("%s", yytext); }
<FMTNRES>\|\[\[km\]\]                        { yytext[yyleng-2]='\0'; printf("%s", yytext+3); }
<FMTNRES>\|\[\[quilômetro\]\]                { yytext[yyleng-2]='\0'; printf("%s", yytext+3); }
<FMTNRES>\|([A-Za-zÀ-ÖÙ-öù-ÿ²./ ]*)?\}\}     { yytext[yyleng-2]='\0'; printf("%s", yytext+1); BEGIN RESUMO; }
<FMTNRES>\}\}                                { BEGIN RESUMO; }

<RESUMO>(\[|\])|\'                           { ; }

<RESUMO>\n|\r                                { BEGIN INITIAL; }

<RESUMO>\[\[Imagem:.*[.]\]\][\n|\r]          { ; }
<RESUMO,INFO>\{\{[Ll]ang[^\}]*\}\};?              { ; }
<RESUMO,INFO>&amp;nbsp;                           { ; }
<RESUMO,INFO>&quot;                               { ; }
<RESUMO,INFO>\[|\]                                { ; }
<RESUMO,INFO>\{|\}                                { ; }
<RESUMO,INFO>\{\{[Nn]owrap                        { ; }
<RESUMO,INFO>\{\{[Dd]ni                           { ; }
<RESUMO,INFO>\{\{[Dd]tlink                        { ; }
<RESUMO,INFO>lang\=[pb][tr]                       { ; }
<RESUMO,INFO>\|si\}\}                             { ; }
<RESUMO,INFO>\|                                   { printf(" "); }
<RESUMO,INFO>\{\{formatnum:[0-9]*\}\}                                  { yytext[yyleng-2] = '\0'; printf("%s", yytext+12); }

<RESUMO,INFO>\$                                   { ; } /* LATEX */

<RESUMO,INFO>\[\[([A-Za-zÀ-ÖÙ-öù-ÿ -.º]*)\|([A-Za-zÀ-ÖÙ-öù-ÿ -.º]*)\]\] { yytext[yyleng-2] = '\0';
                                                                                        int i = 0;
                                                                                        while (yytext[i] != '|') { i++;}
                                                                                        printf("%s", yytext+i+1);
                                                                                    }

\[\[Categoria\:([A-Za-zÀ-ÖÙ-öù-ÿ -.º|]*)\]\] {  if (cat == 0) { printf("\n\nCategorias:"); }
                                                                int i = 0;
                                                                while (yytext[i]!='|' && yytext[i]!=']') {
                                                                  i++;
                                                                }

                                                                if(yytext[i]=='|') {
                                                                  yytext[i] = '\0';
                                                                  printf(" %s;", yytext+12);
                                                                  cat++;
                                                                } else {
                                                                  yytext[yyleng-2] = '\0';
                                                                  printf(" %s;", yytext+12);
                                                                  cat++;
                                                                }
                                                              }
.|\n { ; }
%%

// LATEX ----------
void beginDocument() {
    printf("\\documentclass[a4paper]{article}\n");
    printf("\\usepackage[portuguese]{babel}\n");
    printf("\\usepackage[T1]{fontenc} \n");
    printf("\\usepackage[utf8]{inputenc}\n");
    printf("\\usepackage[unicode]{hyperref}\n");
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