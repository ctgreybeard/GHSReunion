#!/usr/bin/perl

use warnings;
use strict;

# Set DEBUG for testing
my $DEBUG_CSV      = 0b00000001;
my $DEBUG_TEMPLATE = 0b00000010;
my $DEBUG_SMTP     = 0b00000100;
my $DEBUG_MIME     = 0b00001000;
my $DEBUG_ALL      = 0b11111111;	# Everything
# Set debug level
my $DEBUG          = $DEBUG_ALL;

sub DEBUG($$) {
    my ( $debug_lvl, $msg ) = @_;
    if ( $DEBUG & $debug_lvl ) {
        print STDERR $msg, "\n";
        logger->write(level => $debug_log, comment => $msg);
    }
}

# Logging interface
use Log::Trivial;
my $logger = Log::Trivial->new() or die "Logging init failed: $!\n";
my $loglevel = 0;
my $logfile  = "outgoingemail.log";
$logger->set_log_mode('single');
$logger->set_write_mode('s'); # This is the default

# CSV processing
use Text::CSV::Auto;
my $csv_file_name;
my $csv_file_handle;

# MIME message handling
use MIME::Parser;
use MIME::Entity;
my $model_message;

# Template processing
use Template;
my $template;

# Sendmail processing
use Email::Sender::Simple;
use Email::Sender::Transport::SMTP::Persistent;
use Email::Sender::Transport::Test;
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
  
# Various statistics
my $input_records;
my $sent_messages;

# Command options
use Getopt::Long;
%opts = (
# logging
	'loglevel|loglvl=i' => \$loglevel,
	'logfile=s'         => \$logfile,
	# debug
	'debug=i'           => \$DEBUG,
	# CSV processing
	'csvfile=s'         => \$csv_file_name,
	)
	
GetOptions(%opts) or die "Command options incorrect: $!\n";

# Process options
$logger->set_log_file($logfile);
$logger->set_log_level($loglevel);


# Process email for GHS Class of '64 50th reunion

# Initialize the processing
# Any of these can die with errors ...

# Read in the model message template
init_message();

# Initialize the CSV headers and prep the input
init_list();

# Get the email sending prepped
init_sendmail();

# Main processing loop
# Loop reading the CSV input file and send email if a valid email is present

while (my $inrec = get_list_entry()) {
	process_recipient($inrec);
}