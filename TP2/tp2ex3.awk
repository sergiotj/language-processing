BEGIN {FS=";"; RS="\n"}

NR > 2 {

    split($2, name, "[ ]");
    names[name[1]]++;

    split($7, name, "[ ]");
    names[name[1]]++;

    split($9, name, "[ ]");
    names[name[1]]++;

}

END {

    PROCINFO["sorted_in"] = "@val_num_desc";
    for(iName in names) print iName " -> " names[iName]

}