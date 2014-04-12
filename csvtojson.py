#!/usr/bin/python
# create html table from csv
# Author(s): Chris Trombley <ctroms@gmail.com>
# Version 2 - added css class to all columns except header

#!/usr/bin/python
# create html table from csv

# Modified for GHS '64 reunion needs - 2014 W C Waggoner

import sys
import csv
import json

cheaders = (
    "HS Name",
    "GivenName",
    "MarriedName",
    "Street Address",
    "City",
    "State",
    "ZIP",
    "Mail",
    "Phone",
    "Email",
    "Email Bounce",
    "Special",
    "Confirmed",
    "Deceased",
    "Exclude",
    "Addr1",
    "Addr2",
    "Addr3",
    "Addr4",
    )

string_fields = {
    "HS Name": "cm_hs_name",
    "GivenName": "cm_given_name",
    "MarriedName": "cm_married_name",
    "Street Address": "cm_street_address",
    "City": "cm_city",
    "State": "cm_state",
    "ZIP": "cm_zip",
    "Mail": "cm_mail_indicator",
    "Phone": "cm_phone_number",
    "Email": "cm_email",
    "Special": "cm_special",
    "Addr1": "cm_name",
    "Addr2": "_addr2",
    "Addr3": "_addr3",
    "Addr4": "_addr4",
    }

bool_fields = {
    "Email Bounce": "cm_email_bounce_indicator",
    "Confirmed": "cm_confirmed",
    "Deceased": "cm_deceased",
    "Exclude": "cm_exclude",
    }

key_fields = ('HS Name', 'GivenName', 'MarriedName')

static_fields = {"cm_class_year": 1964}

if len(sys.argv) < 3:
    print "Usage: csvtojson.py csv_file json_file"
    exit(1)

# Open the CSV file for reading
reader = csv.reader(open(sys.argv[1]))

# Create the HTML file for output
jsonfile = open(sys.argv[2],"w")

# initialize rownum variable
rownum = 0

# generate table contents
for row in reader: # Read a single row from the CSV file

    # Compute column indexes. assumes first row in csv contains headers
    if rownum == 0:
        json_out = []
        col = 0
        cvals = {}
        col = 0
        for column in row:
            cvals[column] = col
            col += 1

        print "Got the columns:", cvals
        rownum += 1

    #write all other rows   
    else:
        new = {}
        for (column, field) in string_fields.iteritems():
			new[field] = row[cvals[column]]

        for (column, field) in bool_fields.iteritems():
            new[field] = row[cvals[column]].strip() != ''
#            new[field] = 1 if row[cvals[column]].strip() != '' else 0

# Build the special fields
        new_cm_key = ''
        for key in key_fields:
            new_cm_key += row[cvals[key]].lower()

        new['cm_key'] = new_cm_key
        new.update(static_fields)

        json_out.append( new )
    
        #increment row count    
        rownum += 1

json.dump(json_out, jsonfile)
#json.dumps(json_out, indent = 2, separators = (',', ': '))

# print results to shell
print "Created " + str(rownum - 1) + " records."
exit(0)
