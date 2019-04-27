BEGIN {FS=";"; RS="\n"}

NR > 2 { split($2, data, "[ ]"); nomes[data[1]]++; split($7, data, "[ ]"); nomes[data[1]]++; split($9, data, "[ ]"); nomes[data[1]]++; }

END { PROCINFO["sorted_in"] = "@val_num_desc"; for(ano in nomes) print ano " -> " nomes[ano]}