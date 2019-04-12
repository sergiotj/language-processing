BEGIN {FS=";+"; RS="\n"}

NR == 2    { print > "meta.txt" }
NR == 2    { for (i = 1; i < NF; i++) print i ": " $i >> "meta.txt" }

NR > 2 { split($2, data, "[ ]"); nomes[data[1]]++; split($6, data, "[ ]"); nomes[data[1]]++; split($7, data, "[ ]"); nomes[data[1]]++; }

END { PROCINFO["sorted_in"] = "@val_num_desc"; for(ano in nomes) print ano " -> " nomes[ano]}