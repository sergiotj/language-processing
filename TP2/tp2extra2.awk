BEGIN {FS=";"; RS="\n"}

NR > 2 {
    name = sprintf("%s", $2);
    id = sprintf("%s", $1);
    list[name] = id;
}

END {

    PROCINFO["sorted_in"] = "@val_num_asc";
    for(name in list)
    	print list[name];

}