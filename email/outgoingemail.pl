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
my $logger;
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
    $logger->write( level => $lvl, comment => $msg )
      or die "Logging failed, cannot continue: " . $logger->get_error();
    die($msg) if ($lvl == $LOG_CRITICAL);
}

# CSV processing
use Text::CSV::Auto;
my $csv_file_name;
my $csv_file_handle;
my @headers;

# MIME message handling
use MIME::Parser;
use MIME::Entity;
my $mime_parser;
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
my $smtp_transport;
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
my $input_records = 0;
my $sent_messages = 0;

# Useful stuff
my $DEBUG;

# Command options
use Getopt::Long;
my %opts = (

    # logging
    'loglevel|loglvl=i' => \$loglevel,
    'logfile=s'         => \$logfile,

    # MIME message
    'message=s' => \$model_message_file,

    # CSV processing
    'csvfile=s' => \$csv_file_name,
    
    # Debugging
    'DEBUG!'    => \$DEBUG,
);

GetOptions(%opts) or die "Command options incorrect: $!\n";


# Subroutines

# Logging

sub init_log() {
	die("Logfile not specified\n") unless ($logfile);
	
	$logger = Log::Trivial->new(
	   log_file => $logfile) or die "Logging init failed: $!\n";

	# Process options

	$logger->set_log_level($loglevel) if ($loglevel);

	LOG($LOG_NORMAL, "init_log: done");
}

sub cleanup_log() {
	LOG($LOG_NORMAL, "cleanup_log: start");

	$logger = undef;
}

# MIME message

sub init_message() {
    LOG( $LOG_NORMAL, "init_message: start" );
    
    # Create the MIME message

	$mime_parser = MIME::Parser->new();
	$mime_parser->output_to_core(1);
	$mime_parser->tmp_to_core(0);
	$mime_parser->decode_bodies(1);
	
	### Ultra-tolerant mechanism:
    $mime_parser->ignore_errors(1);
    $model_message = eval { $mime_parser->parse_open($model_message_file) };
    my $error = ($@ || $mime_parser->last_error);

    if ($error) { ### Cleanup all files created by the parse:
		$mime_parser->filer->purge();
		LOG($LOG_CRITICAL, "init_message: message parse error: $error"); # Does not return
	}
    
    LOG( $LOG_NORMAL, "init_message: stop" );
}

sub cleanup_message() {
	LOG($LOG_NORMAL, "cleanup_message: start");

	$mime_parser->filer->purge();
	$mime_parser = undef;

	LOG($LOG_NORMAL, "cleanup_message: stop");
}

# CSV input

sub init_list() {
    LOG( $LOG_NORMAL, "init_list: start" );

    if ( !$csv_file_name ) {
        LOG( $LOG_CRITICAL, "CSV file name not specified" ); # Does not return
    }

    LOG( $LOG_DETAIL, "init_list: create csv reader" );
    $csv_reader = Text::CSV->new( { binary => 1, eol => $/ } );

    LOG( $LOG_DETAIL, "init_list: open $csv_file_name" );
    unless ( open $csv_file_handle, "<", $csv_file_name ) {
        my $emsg = $!;
        LOG( $LOG_CRITICAL, "CSV file open failed: $emsg" ); # Does not return
    }

    my $row;
    unless ( $row = $csv_reader->getline($csv_file_handle) ) {    # First line is headers
        LOG( $LOG_CRITICAL, "init_list: CSV file is empty" ); # Does not return
    }
    map { s/ +// } @$row;    # Remove spaces in labels, it's easier that way
    $csv_reader->column_names($row);

    LOG( $LOG_DEBUG, "init_list: header row: " . join( ',', @headerrow ) );

    LOG( $LOG_NORMAL, "init_list: stop" );
}

sub get_list_entry() {
	LOG($LOG_DETAIL, "get_list_entry: start");
	
	my $inrec;

	unless ($inrec = $csv_reader->getline_hr($csv_file_handle)) {
		LOG($LOG_CRITICAL, "get_list_entry: error in input: " . $csv_reader->error_input); # Does not return
	}
	$row_count++;
	
    map { s/ +$//, s/ +/ / } values %{$inrec};    # Clean up spaces

	LOG($LOG_DETAIL, "get_list_entry: done");
	return $inrec;
}

sub cleanup_list() {
	LOG($LOG_NORMAL, "cleanup_list: start");

	LOG($LOG_NORMAL, "cleanup_list: stop");
}

# Sending mail

sub init_sendmail() {
    LOG( $LOG_NORMAL, "init_sendmail: start" );
    
	if ($DEBUG) {
		$smtp_transport = Email::Sender::Transport::Test->new();
		LOG($LOG_DEBUG, "init_sendmail: Running TEST transport");
	} else {
		$smtp_transport = Email::Sender::Transport::SMTP::Persistent->new(
			{
				host          => $smtp_server,
				port          => $smtp_port,
				sasl_username => $smtp_user,
				sasl_password => $smtp_passwd,
				helo          => "ghs64reunion.org",
			}
		);
		LOG($LOG_DEBUG, "init_sendmail: Running SMTP transport");
	}
	
	LOG($LOG_CRITICAL, "init_sendmail: Cannot create Transport") unless ($smtp_transport);

    LOG( $LOG_NORMAL, "init_sendmail: stop" );
}

sub cleanup_sendmail() {
	LOG($LOG_NORMAL, "cleanup_sendmail: start");

	$smtp_transport->disconnect() if ($smtp_transport->can("disconnect"));
	$smtp_transport = undef;

	LOG($LOG_NORMAL, "cleanup_sendmail: stop");
}

# This does the main work

sub process_recipient($) {
    LOG( $LOG_NORMAL, "process_recipient: start" );
    
    
    
    LOG( $LOG_NORMAL, "process_recipient: stop" );
}

# Process email for GHS Class of '64 50th reunion

# Initialize the processing
# Any of these can die with errors ...

# Logging is first
init_log();

# Read in the model message template
init_message();

# Initialize the CSV headers and prep the input
init_list();

# Get the email sending prepped
init_sendmail();

# Main processing loop
# Loop reading the CSV input file and send email if a valid email is present

while ( my $inrec = get_list_entry() ) {
	$input_records++;
    process_recipient($inrec);
}

# Cleanup

cleanup_sendmail();
cleanup_list();
cleanup_message();

print "Input records: $input_records\nMessages sent: $sent_messages\n";
LOG($LOG_IMPORTANT, "Input records: $input_records");
LOG($LOG_IMPORTANT, "Messages sent: $sent_messages");

cleanup_log();
