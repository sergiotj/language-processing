BEGIN {FS=";"; RS="\n"}

NR > 2 {

    par = sprintf("%s|%s", $7, $9)

    if (par in desc) {

        desc[par] = sprintf("%s|%s", desc[par], $2)
    }

    else desc[par] = $2

    if ($11) {

        spouse[$2] = $11
    }
}

END {

    print ("digraph{rankdir=LR")

    for(data in desc) {

        split(data, parents, "[|]")
        split(desc[data], children, "[|]")

        for(child in children) {

            if (children[child] in spouse) {

                print ("\""parents[1]"\" -> \""children[child]"\"; \""parents[2]"\" -> \""children[child]"\"; \""children[child]"\" -> \""spouse[children[child]]"\" [penwidth=3,dir=both]")
            }

            else {

                print ("\""parents[1]"\" -> \""children[child]"\"; \""parents[2]"\" -> \""children[child]"\"")
            }
        }

    }

    print ("}")

}