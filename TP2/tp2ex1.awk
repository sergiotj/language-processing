BEGIN {FS=";"; RS="\n"}

NR > 2 {

    place = sprintf("%s, %s", $4, $5)
    places[place]++

}

END {

    PROCINFO["sorted_in"] = "@val_num_desc";
    for(place in places) print place " -> " places[place]

}