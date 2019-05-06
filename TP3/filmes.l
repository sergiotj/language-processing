%{
#include <stdio.h>
#include "y.tab.h"

int init = -1;
%}

%option noyywrap

id       [a-zA-Z0-9]+
number   [0-9]+
string   [^"\r\n]+
wspace   [ \r\n]*
newline  (\r\n|\n)

%x object_id attribute attributeValue connection

%%
(ator|filme|estreia)                    { init++; if (init == 0) { yyout = fopen("debug.flex", "w"); }
                            fprintf(yyout,"Object type: %s\n", yytext); BEGIN object_id; yylval.str = strdup(yytext); return OBJECT_TYPE; }
{id}                                    { fprintf(yyout,"Link ID: %s\n", yytext); BEGIN connection; yylval.str = strdup(yytext); return OBJECT_ID; }

<object_id>[ ]                          { /* Eating the space between object type and its ID */ }
<object_id>{id}                         { fprintf(yyout,"Object ID: %s\n", yytext); yylval.str = strdup(yytext); return OBJECT_ID; }
<object_id>:{wspace}                    { BEGIN attribute; }

<attribute>{id}                         { fprintf(yyout,"attribute ID: %s\n", yytext); yylval.str = strdup(yytext); return ATTRIBUTE; }
<attribute>\:{wspace}\"                 { BEGIN attributeValue; }

<attributeValue>{string}                { fprintf(yyout,"String: %s\n", yytext); yylval.str = strdup(yytext); return STRING; }
<attributeValue>\"[ ]*{newline}{2,}     { fprintf(yyout,"Two newlines after attribute value\n"); BEGIN INITIAL; }
<attributeValue>\"{wspace}              { fprintf(yyout,"End of string (not two newlines)\n"); BEGIN attribute; }

<connection>{wspace}participou{wspace}  { fprintf(yyout,"participou\n"); return PARTICIPOU; }
<connection>{wspace}estreou{wspace}     { fprintf(yyout,"estreou\n"); return ESTREOU; }
<connection>{id}                        { fprintf(yyout,"Link ID string: %s\n", yytext); yylval.str = strdup(yytext); return OBJECT_ID; }
<connection>[ ]*{newline}               { fprintf(yyout,"End of connection\n"); BEGIN INITIAL; }

{newline}                               { fprintf(yyout,"Eating newline.\n"); yylineno++; }
.                                       { fprintf(yyout,"Unexpected character (return ERR).\n"); return ERR; }
%%