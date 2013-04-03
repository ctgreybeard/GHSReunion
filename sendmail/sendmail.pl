#!/usr/bin/perl 

# Program to read the reunion CSV file and send emails through smtp.com

use strict;
use warnings;

use Getopt::Long;
use Mail::Sendmail;
use Text::Template;
use Text::CSV::Auto;

my $DEBUG = 1;

if ($DEBUG) { print "Starting...\n"};



if ($DEBUG) { print "Stopping...\n" };
