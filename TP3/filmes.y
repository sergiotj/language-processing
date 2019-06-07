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

GHashTable* actors;
GHashTable* movies;
GHashTable* events;

int lookup(char* objectID) {

    if (g_hash_table_contains(actors, objectID)) return 1;

    if (g_hash_table_contains(movies, objectID)) return 1;

    if (g_hash_table_contains(events, objectID)) return 1;

    return -1;
}

void hashInsert(char* type, char* id) {

    if (strcmp(type, "ator") == 0 || strcmp(type, "Ator") == 0) g_hash_table_insert(actors, id, id);

    if (strcmp(type, "filme") == 0 || strcmp(type, "Filme") == 0) g_hash_table_insert(movies, id, id);

    if (strcmp(type, "estreia") == 0 || strcmp(type, "Estreia") == 0) g_hash_table_insert(events, id, id);
}

%}

%token TYPE ID ATTRIBUTE ATTRIBUTEVAL APPEARED OPENED ERROR

%union {

  char* str;
}

%type <str> TYPE ID ATTRIBUTE ATTRIBUTEVAL

%start Objects

%%
Objects: Objects Object
        | Objects Connection
        |
;

Object: TYPE ID Fields        {   char* type = strdup($1); char* id = strdup($2);
                                                if (lookup(id) == -1) {

                                                    g_array_append_val(objectsData, type);
                                                    g_array_append_val(objectsData, id);

                                                    hashInsert(type, id);

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

Field: ATTRIBUTE ATTRIBUTEVAL     {   char* oneF = strdup($1); char* twoF = strdup($2);
                                        g_array_append_val(objectsData, oneF);
                                        g_array_append_val(objectsData, twoF); }
;

Connection: ID APPEARED ID          {   char* fstID = strdup($1); char* sndID = strdup($3); char* part = "participou";

                                                        if (g_hash_table_contains(actors, fstID) && g_hash_table_contains(movies, sndID)) {

                                                            g_array_append_val(connectionsData, fstID);
                                                            g_array_append_val(connectionsData, sndID);
                                                            g_array_append_val(connectionsData, part);

                                                        } else {
                                                            yyerror("Conexão inválida!");
                                                            exit(1);
                                                        }
                                                    }

           | ID OPENED ID            {   char* fstID = strdup($1); char* sndID = strdup($3); char* estr = "estreou";

                                                        if (g_hash_table_contains(movies, fstID) && g_hash_table_contains(events, sndID)) {

                                                            g_array_append_val(connectionsData, fstID);
                                                            g_array_append_val(connectionsData, sndID);
                                                            g_array_append_val(connectionsData, estr);

                                                        } else {
                                                            yyerror("Conexão inválida!");
                                                            exit(1);
                                                        }
                                                    }
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

        char* objectFound = g_array_index(objectsData, char*, i);

        // passa o tipo do objeto para maiúscula
        objectFound[0] = toupper(objectFound[0]);

        // Se encontra um objeto no array que é ator, filme ou estreia...
        if (strcmp(objectFound, "ator") == 0 || strcmp(objectFound, "Ator") == 0 ||
            strcmp(objectFound, "filme") == 0 || strcmp(objectFound, "Filme") == 0 ||
            strcmp(objectFound, "estreia") == 0 || strcmp(objectFound, "Estreia") == 0) {

            // ENCONTROU UM OBJECTO

            printf("%s [label=\"{%s | ", g_array_index(objectsData, char*, i+1), objectFound);

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

                // mover 3 passos para a frente pq paramos no URL
                lastUsed += 3;
            } else {
                printf("}\"];\n");

                // mover 2 passos para a frente
                lastUsed += 2;
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

    actors = g_hash_table_new(g_str_hash,g_str_equal);
    movies = g_hash_table_new(g_str_hash,g_str_equal);
    events = g_hash_table_new(g_str_hash,g_str_equal);
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