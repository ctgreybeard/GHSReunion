#!/sw/bin/zsh -f

csvfile=
msgfile=
logfile=
prefix=()
suffix=()
special=()
debug=
help="Usage: $0 [-d | -t] [-a Addressfile] [-m Msgfile] [-l Logfile] [-p subjectPrefix] [-s subjectSuffix] [-e spEcialvalue]"

while getopts dtha:m:l:p:s:e: myarg; do
    # print -u2 "Option: $myarg, OPTIND=$OPTIND, OPTARG=$OPTARG"
    case $myarg in
    	'h' )
    		print -u2 $help
    		exit 1
    		;;
    	'd'|'t' )
    		print -u2 "DEBUG mode"
    		debug=--DEBUG
    		logfile=sendghstest.log
    		rm -f $logfile
    		;;
    	'a' )
    		csvfile=$OPTARG
    		if [[ ! -r $csvfile ]] {
    			print -u2 "Address file: $csvfile not found, ignoring ..."
    			csvfile=
    		}
    		;;
    	'm' )
    		msgfile=$OPTARG
    		if [[ ! -r $msgfile ]] {
    			print -u2 "Message file: $csvfile not found, ignoring ..."
    			msgfile=
    		}
    		;;
    	'l' )
    		logfile=$OPTARG
    		;;
    	'p' )
    		prefix=("--subject-prefix" "$OPTARG")
    		;;
    	's' )
    		suffix=("--subject-suffix" "$OPTARG")
		;;
    	'e' )
    		special=("--special" "$OPTARG")
    		;;
    	':'|'?' )
    		print -u2 "Quitting on option error";
    		exit 1;
    esac
done

if [[ $#@[$OPTIND,-1] -gt 0 ]] {
    print -u2 -f "Found extra options: \"%s\", aborting!\n" "${(pj: :)@[$OPTIND,$(( OPTIND + 1 ))]}"
    exit 1
}

while [[ $csvfile == "" || ! -r $csvfile ]] do
	print -u2
	print -u2 "Address files available:"
	print -u2
	ls -1 *.csv

	print -u2
	read csvfile\?'Which address file? '

	if [[ ! -r $csvfile ]] {
		print -u2 "Sorry, I can't find $csvfile"
		csvfile=""
	}
done

print -u2
print -u2 "OK, I'll use $csvfile"

while [[ $msgfile == "" || ! -r $msgfile ]] do
	print -u2
	print -u2 "MSG files available:"
	print -u2
	ls -1 *.msg

	print -u2
	read msgfile\?'Which message file? '

	if [[ ! -r $msgfile ]] {
		print -u2 "Sorry, I can't find $msgfile"
		msgfile=
	}
done

print -u2
print -u2 "OK, I'll use $msgfile"

if [[ $logfile == "" ]] {

	logfile="sendghs"$(date "+%F-%T")".log"

}

print -u2
print -u2 "Logging is sent to $logfile"

print -u2
print -u2 "The Subject of the message is: "
grep -i '^subject: ' $msgfile

print -u2

csvrecs=${(z)$(wc -l $csvfile)}

print -u2 "and the CSV file: $csvfile has $csvrecs[1] records."

print -u2

if [[ $debug != "" ]] {
	print -u2 "We are running in $debug MODE!"
	print -u2
}

if [[ $#prefix -ne 0 ]] {
	print -u2 "Subject prefix = $prefix[2]"
	print -u2
}

if [[ $#suffix -ne 0 ]] {
	print -u2 "Subject suffix = $suffix[2]"
	print -u2
}

if [[ $#special -ne 0 ]] {
	print -u2 "Sending only to Special = $special[2]"
	print -u2
}

read ok\?'OK? [Yn]'

if [[ ( $ok == "y" ) || ( $ok == "Y" ) || ( $ok == "" ) ]]; then

	print perl ./outgoingemail.pl  --logfile "$logfile" --csvfile "$csvfile"  --message "$msgfile" "$prefix[@]" "$suffix[@]" "$special[@]" $debug
	perl ./outgoingemail.pl  --logfile "$logfile" --csvfile "$csvfile"  --message "$msgfile" "$prefix[@]" "$suffix[@]" "$special[@]" $debug

fi
