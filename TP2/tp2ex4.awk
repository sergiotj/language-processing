BEGIN {FS=";+"; RS="\n"}

NR > 2 { b = sprintf("%s|%s", $6, $7);

    if (desc[b] != NULL) desc[b] = sprintf("%s|%s", desc[b], $2)
    else desc[b] = $2
}

END {

    print ("digraph{rankdir=LR")

    for(data in desc) {

        split(data, pais, "[|]");

        split(desc[data], filhos, "[|]");

        for(filho in filhos) {

            print ("\""pais[1]"\"-> \""filhos[filho]"\"; \""pais[2]"\" -> \""filhos[filho]"\"")
        }

    }

    print ("}")

}