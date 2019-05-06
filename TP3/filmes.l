%{
#include <stdio.h>
#include "y.tab.h"

int init = -1;
%}

%option noyywrap

id       [a-zA-Z0-9]+
number   [0-9]+
string   [^\r\n]+
wspace   [ \r\n]*
newline  (\r\n|\n)

%x object_id attribute attributeValue connection

%%
(ator|estreia|filme)                    { init++; if (init == 0) { yyout = fopen("debug.flex", "w"); }
                            fprintf(yyout,"Início de Objeto\nTipo Objeto: %s\n", yytext); BEGIN object_id; yylval.str = strdup(yytext); return OBJECT_TYPE; }
{id}                                    { fprintf(yyout,"Início de Ligação\nID: %s\n", yytext); BEGIN connection; yylval.str = strdup(yytext); return OBJECT_ID; }

<object_id>[ ]                          { /* Eating the space between object type and its ID */ }
<object_id>{id}                         { fprintf(yyout,"ID: %s\n", yytext); yylval.str = strdup(yytext); return OBJECT_ID; }
<object_id>:{wspace}                    { BEGIN attribute; }

<attribute>{wspace}                     { ; } /* remove espaços atrás do atributo */
<attribute>{id}                         { fprintf(yyout,"Atributo: %s\n", yytext); yylval.str = strdup(yytext); return ATTRIBUTE; }
<attribute>\:{wspace}                   { BEGIN attributeValue; }

<attributeValue>{string}                { fprintf(yyout,"String: %s\n", yytext); yylval.str = strdup(yytext); return STRING; }
<attributeValue>[ ]*{newline}{2,}       { fprintf(yyout,"Fim de Objeto\n\n"); BEGIN INITIAL; }
<attributeValue>[ ]*{newline}           { fprintf(yyout,"Fim de String\n"); BEGIN attribute; }

<connection>{wspace}participou{wspace}  { fprintf(yyout,"participou\n"); return PARTICIPOU; }
<connection>{wspace}estreou{wspace}     { fprintf(yyout,"estreou\n"); return ESTREOU; }
<connection>{id}                        { fprintf(yyout,"ID: %s\n", yytext); yylval.str = strdup(yytext); return OBJECT_ID; }
<connection>[ ]*{newline}               { fprintf(yyout,"Fim de ligação\n\n"); BEGIN INITIAL; }

{newline}                               { fprintf(yyout,"Removendo \\n.\n"); yylineno++; }
.                                       { fprintf(yyout,"Erro.\n"); return ERR; }
%%