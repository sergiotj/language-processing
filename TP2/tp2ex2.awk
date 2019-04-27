BEGIN {FS=";"; RS="\n"}

NR > 2 {

    split($6, date, "[-/.]")

    yearPlace = sprintf("%s, %s", date[1], $5)
    yearPlaces[yearPlace]++
}

END {

    PROCINFO["sorted_in"] = "@val_num_desc"
    for(yearPlace in yearPlaces) print yearPlace " -> " yearPlaces[yearPlace]

}