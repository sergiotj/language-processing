BEGIN {FS=";"; RS="\n"}

NR > 2 {

    list[$2] = $1;
}

END {

    PROCINFO["sorted_in"] = "@val_num_asc";
    for(name in list)
    	print list[name] ":" name;

}