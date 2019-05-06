%{
#include <stdio.h>
#include <glib.h>
#include <string.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>

extern int yylineno;

GArray* node_data;
GArray* edge_data;
%}

%token OBJECT_TYPE STRING OBJECT_ID ATTRIBUTE PARTICIPOU ESTREOU ERR

%union{
  char* str;
}

%type <str> STRING OBJECT_TYPE OBJECT_ID ATTRIBUTE

%start Objects

%%
Objects: Objects Object
        | Objects Connection
        |
;

Object: OBJECT_TYPE OBJECT_ID Fields        { char* one = strdup($1); char* two = strdup($2); g_array_append_val(node_data, one); g_array_append_val(node_data,                                                 two); }
;

Fields: Fields Field
       | Field
;

Field: ATTRIBUTE STRING     { char* one = strdup($1); char* two = strdup($2); g_array_append_val(node_data, one); g_array_append_val(node_data, two); }
;

Connection: OBJECT_ID PARTICIPOU OBJECT_ID         { char* one = strdup($1); char* three = strdup($3); char* f = "participou"; g_array_append_val(edge_data, one);                                                          g_array_append_val(edge_data, three); g_array_append_val(edge_data, f); }
           | OBJECT_ID ESTREOU OBJECT_ID  { char* one = strdup($1); char* three = strdup($3); char* p = "estreou"; g_array_append_val(edge_data, one);                                                  g_array_append_val(edge_data, three); g_array_append_val(edge_data, p); }
;
%%

#include "lex.yy.c"

int yylex();

int yyerror(char *s) {

    printf("%s\n", s);
}

int main(int argc, char **argv) {

    if (argc != 2) {

        printf("Erro. USAGE: ./filmes inFile\n");
        return 1;
    }

    FILE *myfile = fopen(argv[1], "r");

    yyin = myfile;

    node_data = g_array_new(FALSE, TRUE, sizeof(char*));
    edge_data = g_array_new(FALSE, TRUE, sizeof(char*));
    yyparse();

    printf("----- Creating graph... -----\n");

    remove("graph.dot");
    int fd = open("graph.dot", O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);

    int stdout = dup(1);
    dup2(fd, 1);

    // Graph header
    printf("digraph D {\n  node [shape=Mrecord fontname=\"Arial\"];\n  edge [fontname=\"Arial\"];\n");
    // Print every node
    // (unsigned int because node_data->len is a guint)
    unsigned int lastUsed = 0;

    for (unsigned int i = 0; i < node_data->len; i++) {

        if (strcmp(g_array_index(node_data, char*, i), "ator") == 0 ||
            strcmp(g_array_index(node_data, char*, i), "filme") == 0 ||
            strcmp(g_array_index(node_data, char*, i), "estreia") == 0) {

            printf("%s [label=\"{", g_array_index(node_data, char*, i+1));

            char* label;
            char* string;
            int startedWriting = 0;

            for (; lastUsed < i; lastUsed++) {

                label = g_array_index(node_data, char*, lastUsed);
                label[0] = toupper(label[0]); // Uppercase first char of label
                lastUsed++; // Go to next node_data token
                string = g_array_index(node_data, char*, lastUsed);
                if (strcmp(label, "Url") == 0) {
                    break;
                }
                if (startedWriting) {
                    printf(" | ");
                } else {
                    startedWriting = 1;
                }

                printf("%s: %s", label, string);
            }

            if (strcmp(label, "Url") == 0) {
                printf("}\", URL=\"%s\"];\n", string);
                lastUsed += 3; // Move lastUsed 3 steps forward because we stopped at url
            } else {
                printf("}\"];\n");
                lastUsed += 2; // Move lastUsed 2 steps forward
            }
        }
    }

    // Print every edge
    for (unsigned int j = 0; j < edge_data->len; j++) {

        char* doer = g_array_index(edge_data, char*, j);
        j++;
        char* done = g_array_index(edge_data, char*, j);
        j++;
        char* action = g_array_index(edge_data, char*, j);

        printf("%s -> %s[label=\"%s\"]\n", doer, done, action);
    }

    // Close graph
    printf("}\n");

    close(fd);
    dup2(stdout,1);
    close(stdout);

    int status = system("dot -Tsvg graph.dot -o graph.svg");
    if (status == 0) {
        printf("Graph created at graph.svg!\n");
        return 0;
    }

    printf("Error at graph creation!\n");
    return 1;

}