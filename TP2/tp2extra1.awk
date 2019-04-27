BEGIN {FS=";+"; RS="\n"}

NR > 2 { 
	if ( sprintf("%s", $8) != null) {
		c++;
	}
}			

END { print "Número de pessoas casadas: " c; }