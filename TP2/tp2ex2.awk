BEGIN {FS=";+"; RS="\n"}

NR > 2 { split($5, data, "[-/.]"); b = sprintf("%s, %s", data[1], $4); conta[b]++;}

END { PROCINFO["sorted_in"] = "@val_num_desc"; for(ano in conta) print ano " -> " conta[ano]}