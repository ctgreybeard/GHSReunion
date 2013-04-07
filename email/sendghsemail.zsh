#!/sw/bin/zsh -f

csvfile=
msgfile=

while [[ $csvfile == "" ]] do
	print
	print "CSV files available:"
	print
	ls *.csv

	print
	read csvfile\?'Which address file? '

	if [[ ! -r $csvfile ]] {
		print "Sorry, I can't find $csvfile"
		csvfile=""
	} else {
		print "OK, I'll use $csvfile"
	}
done

while [[ $msgfile == "" ]] do
	print
	print "MSG files available:"
	print
	ls *.msg

	print
	read msgfile\?'Which message file? '

	if [[ ! -r $msgfile ]] {
		print "Sorry, I can't find $msgfile"
		msgfile=
	} else {
		print "OK, I'll use $msgfile"
	}
done

logfile="sendghs"$(date "+%F-%T")".log"

print
print "Logging is sent to $logfile"

print
print "The Subject of the message is: "
grep -i '^subject: ' $msgfile

print

csvrecs=${(z)$(wc -l $csvfile)}

print "and the CSV file: $csvfile has $csvrecs[1] records."

print

read ok\?'OK? [Yn]'

if [[ $ok == "y" || $ok == "Y" || .$ok == "." ]] ; then

	perl ./outgoingemail.pl  --logfile "$logfile" --csvfile "$csvfile"  --message "$msgfile" --DEBUG

fi