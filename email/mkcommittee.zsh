#!/sw/bin/zsh -f

infile=$1
outfile=GHSCommittee.csv

if [[ $infile == "" ]] {
    print -u2 "I need an input list!"
    exit 1
}

egrep '^Surname,|^Ramsey,|^Annicelli,|^Cravens,|^Hall,|^Baird,|^Particelli,|^Pucci,|^Sherman,' $infile >$outfile

print "Should be nine records"
wc -l $outfile
