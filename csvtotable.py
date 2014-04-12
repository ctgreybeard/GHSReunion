#!/usr/bin/python
# create html table from csv
# Author(s): Chris Trombley <ctroms@gmail.com>
# Version 2 - added css class to all columns except header

#!/usr/bin/python
# create html table from csv

# Modified for GHS '64 reunion needs - 2014 W C Waggoner

import sys
import csv

theaders = (
	'Name',
	'Address',
	'City, State, ZIP',
	'Phone',
	'Email',
	'Conf',
	'Dec',
	)

torder = (
	'Addr1',
	'Addr2',
	'Addr3',
	'Phone',
	'Email',
	'Confirmed',
	'Deceased',
	)

cwidth = (
	200,
	150,
	150, 
	100, 
	80, 
	10, 
	10,
	)

calign = (
	'left',
	'left',
	'left', 
	'left', 
	'left', 
	'center', 
	'center',
	)

if len(sys.argv) < 3:
	print "Usage: csvToTable.py csv_file html_file"
	exit(1)

# Open the CSV file for reading
reader = csv.reader(open(sys.argv[1]))

# Create the HTML file for output
htmlfile = open(sys.argv[2],"w")

# initialize rownum variable
rownum = 0

# Write global styles
htmlfile.write('Conf=Confirmed, Dec=Deceased<br /><style type="text/css">table{border-collapse:collapse;}table,th,td{border:1px solid black;}</style>\n')

# write <table> tag
htmlfile.write('<table>\n')

# generate table contents
for row in reader: # Read a single row from the CSV file

	# write header row. assumes first row in csv contains header
	if rownum == 0:
		htmlfile.write('<tr>') # write <tr> tag
		col = 0
  		for column in theaders:
  			htmlfile.write('<th style="width:{:d}">'.format(cwidth[col]) + column + '</th>')
  			col += 1
  		htmlfile.write('</tr>\n')
  		cvals = {}
  		col = 0
  		for column in row:
  			cvals[column] = col
  			col += 1

  	#write all other rows	
  	else:
  		htmlfile.write('<tr>')	
		col = 0
  		for column in torder:
  			htmlfile.write('<td style=";text-align:{:s}">'.format(calign[col]) + row[cvals[column]] + '</td>')
			col += 1
  		htmlfile.write('</tr>\n')
	
	#increment row count	
	rownum += 1

# write </table> tag
htmlfile.write('</table>\n')

# print results to shell
print "Created " + str(rownum) + " row table."
exit(0)
