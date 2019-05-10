%{

#include <stdio.h>
#include <glib.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>

GArray* objectsData;
GArray* connectionsData;

int lookup(char* objectID) {

    for (unsigned int i = 0; i < objectsData->len; i++) {

        // Se encontra um objeto no array que é igual
        if (strcmp(g_array_index(objectsData, char*, i), objectID) == 0) {

                return 1;
            }

    }

    return -1;
}

%}

%token OBJECT_TYPE STRING OBJECT_ID ATTRIBUTE PARTICIPOU ESTREOU ERR

%union {

  char* str;
}

%type <str> STRING OBJECT_TYPE OBJECT_ID ATTRIBUTE

%start Objects

%%
Objects: Objects Object
        | Objects Connection
        |
;

Object: OBJECT_TYPE OBJECT_ID Fields        {   char* type = strdup($1); char* id = strdup($2);
                                                if (lookup(id) == -1) {
                                                    g_array_append_val(objectsData, type);
                                                    g_array_append_val(objectsData, id);
                                                }
                                                else {
                                                    yyerror("ID já declarado!");
                                                    exit(1);
                                                }
                                            }
;

Fields: Fields Field
       | Field
;

Field: ATTRIBUTE STRING     {   char* oneF = strdup($1); char* twoF = strdup($2);
                                g_array_append_val(objectsData, oneF);
                                g_array_append_val(objectsData, twoF); }
;

Connection: OBJECT_ID PARTICIPOU OBJECT_ID          {   char* oneO = strdup($1); char* threeO = strdup($3); char* part = "participou";
                                                        g_array_append_val(connectionsData, oneO);
                                                        g_array_append_val(connectionsData, threeO);
                                                        g_array_append_val(connectionsData, part); }

           | OBJECT_ID ESTREOU OBJECT_ID            {   char* oneO = strdup($1); char* threeO = strdup($3); char* estr = "estreou";
                                                        g_array_append_val(connectionsData, oneO);
                                                        g_array_append_val(connectionsData, threeO);
                                                        g_array_append_val(connectionsData, estr); }
;
%%

#include "lex.yy.c"

int yylex();

int yyerror(char *s) {

    printf("Erro: %s\n", s);
}

void getData() {

    // Cabeçalho do grafo
    printf("digraph D {\n  node [shape=Mrecord fontname=\"Helvetica\" fontsize = 9];\n  edge [fontname=\"Helvetica\" fontsize = 11];\n");

    // unsigned int pq objectsData-> é um "guint"
    unsigned int lastUsed = 0;

    for (unsigned int i = 0; i < objectsData->len; i++) {

        // Se encontra um objeto no array que é ator, filme ou estreia...
        if (strcmp(g_array_index(objectsData, char*, i), "ator") == 0 ||
            strcmp(g_array_index(objectsData, char*, i), "filme") == 0 ||
            strcmp(g_array_index(objectsData, char*, i), "estreia") == 0) {

            // ENCONTROU UM OBJECTO
            printf("%s [label=\"{", g_array_index(objectsData, char*, i+1));

            char* attributeY;
            char* attributeValueY;
            int startedWriting = 0;

            for (; lastUsed < i; lastUsed++) {

                // obtém o atributo: pode ser Nome, Género, Idioma etc...
                attributeY = g_array_index(objectsData, char*, lastUsed);

                // passa o atributo para maiúscula
                attributeY[0] = toupper(attributeY[0]);

                // anda um para a frente
                lastUsed++;;

                // obtém o valor do atributo (já se andou um para a frente)
                attributeValueY = g_array_index(objectsData, char*, lastUsed);

                if (strcmp(attributeY, "Url") == 0) {
                    break;
                }
                if (startedWriting) {
                    printf(" | ");
                } else {
                    startedWriting = 1;
                }

                printf("%s: %s", attributeY, attributeValueY);
            }

            if (strcmp(attributeY, "Url") == 0) {
                printf("}\", URL=\"%s\"];\n", attributeValueY);
                lastUsed += 3; // Move lastUsed 3 steps forward because we stopped at url
            } else {
                printf("}\"];\n");
                lastUsed += 2; // Move lastUsed 2 steps forward
            }
        }
    }

    // Queremos imprimir: bale -> prestige[label="participou"]
    unsigned int j = 0;
    while (j < connectionsData->len) {

        // obtém o objeto do lado esquerdo
        char* fstCon = g_array_index(connectionsData, char*, j);
        j++;

        // obtém o objeto do lado direito
        char* sndCon = g_array_index(connectionsData, char*, j);
        j++;

        // obtém a ação
        char* con = g_array_index(connectionsData, char*, j);

        printf("%s -> %s[label=\"%s\"]\n", fstCon, sndCon, con);

        j++;

    }

    // Fecha o grafo
    printf("}\n");

}

int main(int argc, char **argv) {

    if (argc != 2) {

        printf("Erro. USAGE: ./filmes inFile\n");
        return 1;
    }

    FILE *myfile = fopen(argv[1], "r");

    yyin = myfile;

    objectsData = g_array_new(FALSE, TRUE, sizeof(char*));
    connectionsData = g_array_new(FALSE, TRUE, sizeof(char*));
    yyparse();

    printf("----- Creating graph... -----\n");

    remove("graph.dot");
    int fd = open("graph.dot", O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);

    int stdout = dup(1);
    dup2(fd, 1);

    // obter dados para o grafo
    getData();

    close(fd);
    dup2(stdout,1);
    close(stdout);

    int status = system("dot -Tsvg graph.dot -o graph.svg");
    if (status != 0) {
        printf("Error at graph creation!\n");
        return 1;
    }

    printf("Graph created at graph.svg!\n");
    return 0;

}