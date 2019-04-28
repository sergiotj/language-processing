BEGIN {FS=";"; RS="\n"}

NR > 2 {

	if ($11 != null) {
		c++;
	}
}

END {

	print "Number of maried people: " c*2;

}