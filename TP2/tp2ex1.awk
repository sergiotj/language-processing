BEGIN {FS=";+"; RS="\n"}

NR > 2 { b = sprintf("%s, %s", $3, $4); conta[b]++;}

END { PROCINFO["sorted_in"] = "@val_num_asc"; for(ano in conta) print ano " -> " conta[ano]}