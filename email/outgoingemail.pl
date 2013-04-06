#!/usr/bin/perl

use warnings;
use strict;

# Define all processing variables up here

# CSV input

my $csv_reader;
my @headerrow;
my $row_count = 0;

# Logging interface
use Log::Trivial;
my $logger   = Log::Trivial->new() or die "Logging init failed: $!\n";
my $loglevel = 0;
my $logfile  = "outgoingemail.log";
$logger->set_log_mode('single');
$logger->set_write_mode('s');    # This is the default

# Define the logging levels
my $LOG_CRITICAL  = 0;
my $LOG_URGENT    = 1;
my $LOG_PRIORITY  = 2;
my $LOG_IMPORTANT = 3;
my $LOG_NORMAL    = 4;
my $LOG_DETAIL    = 5;
my $LOG_DEBUG     = 6;

sub LOG($$) {
    my ( $lvl, $msg ) = @_;
    logger->write( level => $lvl, comment => $msg )
      or die "Logging failed, cannot continue: $!";
}

# CSV processing
use Text::CSV::Auto;
my $csv_file_name;
my $csv_file_handle;

# MIME message handling
use MIME::Parser;
use MIME::Entity;
my $model_message_file;
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

    # MIME message
    'message=s' => \$model_message_file,

    # CSV processing
    'csvfile=s' => \$csv_file_name,
);

GetOptions(%opts) or die "Command options incorrect: $!\n";

# Process options
$logger->set_log_file($logfile);
$logger->set_log_level($loglevel);

# Subroutines

# MIME message

sub init_message() {
    LOG( $LOG_NORMAL, "init_message: start" );
    LOG( $LOG_NORMAL, "init_message: stop" );
}

# CSV input

sub init_list() {
    LOG( $LOG_NORMAL, "init_list: start" );
    LOG( $LOG_DETAIL, "init_list: create csv reader" );
    $csv_reader = Text::CSV->new( { binary => 1, eol => $/ } );

    if ( !$csv_file_name ) {
        LOG( $LOG_CRITICAL, "CSV file name not specified" );
        die("CSV file name not specified");
    }

    LOG( $LOG_DETAIL, "init_list: open $csv_file_name" );

    unless ( open my $io, "<", $csv_file_name ) {
        my $emsg = $!;
        LOG( $LOG_CRITICAL, "CSV file open failed: $emsg" );
        die "$csv_file_name: $emsg";
    }

    my $row;
    unless ( $row = $csv_reader->getline($io) ) {    # First line is headers
        LOG( $LOG_CRITICAL, "init_list: CSV file is empty" );
        die("init_list: CSV file is empty\n");
    }
    map { s/ +// } @$row;    # Remove spaces in labels, it's easier that way
    @headerrow = @$row;

    LOG( $LOG_DEBUG, "init_list: header row: " . join( ',', @headerrow ) );

    LOG( $LOG_NORMAL, "init_list: stop" );
}

# Sending mail

sub init_sendmail() {
    LOG( $LOG_NORMAL, "init_sendmail: start" );
    LOG( $LOG_NORMAL, "init_sendmail: stop" );
}

# This does the main work

sub process_recipient($) {
    LOG( $LOG_NORMAL, "process_recipient: start" );
    LOG( $LOG_NORMAL, "process_recipient: stop" );
}

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

while ( my $inrec = get_list_entry() ) {
    process_recipient($inrec);
}
