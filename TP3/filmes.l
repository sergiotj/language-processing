%{
#include <stdio.h>
#include "y.tab.h"

int init = -1;
%}

%option noyywrap

id       [a-ÿA-z0-9A-Þ_ã-]+
number   [0-9]+
string   [^\r\n]+
wspace   [ \r\n]*
newline  (\r\n|\n)

%x objectID attribute attributeValue connection

%%
([Aa]tor|[Ee]streia|[Ff]ilme)                    { init++; if (init == 0) { yyout = fopen("flex.txt", "w"); }
                            fprintf(yyout,"Início de Objeto\nTipo Objeto: %s\n", yytext); BEGIN objectID; yylval.str = strdup(yytext); return TYPE; }
{id}                                    { fprintf(yyout,"Início de Ligação\nID: %s\n", yytext); BEGIN connection; yylval.str = strdup(yytext); return ID; }

<objectID>{wspace}                      { /* tirar espaços */ }
<objectID>[Ii][Dd]{wspace}"->"          { /* tirar "ID" */ }
<objectID>{id}                          { fprintf(yyout,"ID: %s\n", yytext); yylval.str = strdup(yytext); BEGIN attribute; return ID; }

<attribute>{wspace}                     { ; } /* remove espaços atrás do atributo */
<attribute>{id}                         { fprintf(yyout,"Atributo: %s\n", yytext); yylval.str = strdup(yytext); return ATTRIBUTE; }
<attribute>\:{wspace}                   { BEGIN attributeValue; }

<attributeValue>{string}                { fprintf(yyout,"String: %s\n", yytext); yylval.str = strdup(yytext); return ATTRIBUTEVAL; }
<attributeValue>[ ]*{newline}{2,}       { fprintf(yyout,"Fim de Objeto\n\n"); BEGIN INITIAL; }
<attributeValue>[ ]*{newline}           { fprintf(yyout,"Fim de String\n"); BEGIN attribute; }

<connection>{wspace}participou{wspace}  { fprintf(yyout,"Ligação: participou\n"); return APPEARED; }
<connection>{wspace}estreou{wspace}     { fprintf(yyout,"Ligação: estreou\n"); return OPENED; }
<connection>{id}                        { fprintf(yyout,"ID: %s\n", yytext); yylval.str = strdup(yytext); return ID; }
<connection>[ ]*{newline}               { fprintf(yyout,"Fim de ligação\n\n"); BEGIN INITIAL; }

{newline}                               { fprintf(yyout,"Removendo \\n.\n"); }
.                                       { fprintf(yyout,"Erro.\n"); return ERROR; }
%%