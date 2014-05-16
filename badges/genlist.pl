#!/usr/bin/perl 

# Program to read the reunion CSV file and send emails through smtp.com

use strict;
use warnings;

# Common routines
use Getopt::Long;
use Data::Dumper::Perltidy;

# Email building and sending
use MIME::Parser;
use MIME::Head;
use Email::Sender::Simple qw/sendmail/;
use Email::Sender::Transport::SMTP::Persistent;
use Email::Sender::Transport::Test;

# Template handling
use Text::Template;
use Text::CSV::Auto;

# Set DEBUG for testing
my $DEBUG = 1;

sub DEBUG($$) {
    my ($debug_lvl, $msg) = @_;
    if ($DEBUG >= $debug_lvl) {
	print STDERR $msg, "\n";
    }
};

# Common parameters
my $test_mode = 1;

# SMTP parameters
our $smtp_server;
our $smtp_port;
our $smtp_user;
our $smtp_passwd;
our $smtp_sasl;
our $smtp_from;
our $smtp_bounce;
require "smtpopts.pm";

(        $smtp_server
      && $smtp_port
      && $smtp_user
      && $smtp_passwd
      && $smtp_sasl
      && $smtp_from
      && $smtp_bounce )
  or die "SMTP options not set.\n";

# CSV parameters
my $email_subject;
my $input_csv;	# Filename is required
my $name_hdr;
my $email_hdr = "Email";
my $bounce_hdr = "Email Bounce";
my $gname_hdr = "GivenName";
my $name_col  = -1;
my $email_col = -1;
my $bounce_col = -1;
my $gname_col = -1;
my %hdrs      = (
    $name_hdr => $name_col,
    $email_hdr => $email_col,
    $bounce_col => $bounce_col,
    $gname_hdr  => $gname_col,
);

my %cmdopts = (
    "subject=s" => \$email_subject,
    "csv=s" 	=> \$input_csv,
    "test+"	=> \$test_mode,
    "server=s"	=> \$smtp_server,
    "port:i"	=> \$smtp_port,
    "user=s"	=> \$smtp_user,
    "passwd=s"	=> \$smtp_passwd,
    "sasl!"	=> \$smtp_sasl,
    "debug+"	=> \$DEBUG,
);

GetOptions(%cmdopts) 
    or die("Error in command line options...\n");

# Check for required options
my $errors = "";
if (!$email_subject) { $errors .= " --subject option required\n" }
if (!$input_csv) { $errors .= " --csv option required\n" }
if (!$smtp_server) { $errors .= " --server option required\n" }
if (!$smtp_user) { $errors .= " --user option required\n" }
if (!$smtp_passwd) { $errors .= " --passwd option required\n" }

if ($errors) {
    $errors = "The following command option errors occurred:\n" . $errors;
    print STDERR $errors;
    exit 1;
}

DEBUG(1, "Starting...");

if ($test_mode) {
    print STDERR "Running in TEST mode level ", $test_mode, "\n";
}

# Some variables used throughout
my $row;	# Row array reference
my $rows = 0;	# Number of rows processed
my @headerrow;	# Header array
my @mailqueue = ();

if ($DEBUG) { print STDERR "Preparing to read CSV file: $input_csv\n" };

my $sendlist = [];	# Empty starting array

my $csv = Text::CSV->new ({ binary => 1, eol => $/ });

open my $io, "<", $input_csv or die "$input_csv: $!";

$row = $csv->getline($io);	# First line is headers
@headerrow = @$row;
my $colnum  = 0;
DEBUG(1, scalar(@headerrow) . " columns");
while ($colnum < scalar(@headerrow)) {
    $hdrs{$headerrow[$colnum]} = $colnum;
    $colnum++;
}

$errors = "";
if ( ($name_col = $hdrs{$name_hdr}) < 0 ) {
    $errors .= "Name column not found\n"
}
if ( ($email_col = $hdrs{$email_hdr}) < 0 ) {
    $errors .= "Email column not found\n"
}
if ( ($bounce_col = $hdrs{$bounce_hdr}) < 0 ) {
    $errors .= "Bounce column not found\n"
}
if ( ($gname_col = $hdrs{$gname_hdr}) < 0 ) {
    $errors .= "Givenname column not found\n"
}

{
    my $dmesg = "Name column = $name_col\n";
    $dmesg .= "Email column = $email_col\n";
    $dmesg .= "Bounce column = $bounce_col\n";
    $dmesg .= "Givenname column = $gname_col";
    DEBUG(1, $dmesg);
}

while (my $row = $csv->getline($io)) {
    $rows++;
    my @fields = @$row;
    if ($fields[$email_col] && ( $fields[$bounce_col] eq 'v' || $fields[$bounce_col] eq 'V' || $fields[$bounce_col] eq '' ) ) {
	push @mailqueue, [ $fields[$name_col], $fields[$email_col], $fields[$gname_col] ];
    }
}

printf STDERR "%d rows processed.\n", $rows;

DEBUG(1, "Email recipients = " . scalar(@mailqueue) );
DEBUG(1, "Email Subject = \"" . $email_subject . "\"" );

if ($DEBUG) { print "Stopping...\n" };
