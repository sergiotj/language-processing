BEGIN {FS=";"; RS="\n"}

NR > 2 {

    b = sprintf("%s|%s", $7, $9)

    if (b in desc) {

        desc[b] = sprintf("%s|%s", desc[b], $2)
    }

    else desc[b] = $2

    if ($11) {

        conj[$2] = $11
    }
}

END {

    print ("digraph{rankdir=LR")

    for(data in desc) {

        split(data, pais, "[|]");
        split(desc[data], filhos, "[|]");

        for(filho in filhos) {

            if (filhos[filho] in conj) {

                print ("\""pais[1]"\" -> \""filhos[filho]"\"; \""pais[2]"\" -> \""filhos[filho]"\"; \""filhos[filho]"\" -> \""conj[filhos[filho]]"\" [penwidth=3,dir=both]")
            }

            else {

                print ("\""pais[1]"\" -> \""filhos[filho]"\"; \""pais[2]"\" -> \""filhos[filho]"\"")
            }
        }

    }

    print ("}")

}