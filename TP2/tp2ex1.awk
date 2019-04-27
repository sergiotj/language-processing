BEGIN {FS=";"; RS="\n"}

NR > 2 {

    b = sprintf("%s, %s", $4, $5)
    conta[b]++

}

END {

    PROCINFO["sorted_in"] = "@val_num_desc";
    for(ano in conta) print ano " -> " conta[ano]

}