#!/usr/bin/perl

use warnings;
use strict;

# predefine all functions

sub LOG($$);
sub init_log();
sub cleanup_log();
sub init_message();
sub apply_template($);
sub build_message($);
sub cleanup_message();
sub init_list();
sub get_list_entry();
sub cleanup_list();
sub init_sendmail();
sub send_message($);
sub cleanup_sendmail();
sub init_template();
sub apply_template($);
sub cleanup_template();
sub process_recipient();

# Define all processing variables up here

# CSV input

my $csv_reader;
my @headerrow;
my $row_count    = 0;
my $deceased_hdr = "Deceased";
my $email_hdr    = "Email";
my $bounce_hdr   = "EmailBounce";
my $exclude_hdr  = "Exclude";
my $gname_hdr    = "GivenName";
my $fname_hdr    = "Addr1";
my $special_hdr  = "Special";

# Logging interface
use Log::Trivial;
my $logger;
my $loglevel = 4;
my $logfile;

# Define the logging levels
use constant {
    LOG_CRITICAL  => 0,
    LOG_URGENT    => 1,
    LOG_PRIORITY  => 2,
    LOG_IMPORTANT => 3,
    LOG_NORMAL    => 4,
    LOG_DETAIL    => 5,
    LOG_DEBUG     => 6,
};

sub LOG($$) {
    my ( $lvl, $msg ) = @_;

    $logger->write( level => $lvl, comment => "($lvl) $msg" );

    die(
        "Logging failed, cannot continue: attempted to log ($lvl)\"$msg\", error="
          . $logger->get_error()
          . "\n" )
      if $logger->get_error();

    die("FATAL: $msg\n") if ( $lvl == LOG_CRITICAL );
}

# Testing
use Data::Dumper::Perltidy;
use Try::Tiny::SmartCatch;

# CSV processing
use Text::CSV::Auto;
my $csv_file_name;
my $csv_file_handle;
my @headers;
my $input_record;

# MIME message handling
use MIME::Parser;
use MIME::Entity;
use MIME::Head;
my $model_message_file;
my $model_message;
my $mime_parser;

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
my $send_errors   = 0;

# Useful stuff
my $DEBUG;

# Message modification
my $subjectprefix = "";
my $subjectsuffix = "";
my $do_special;    # Process "special" column with these values

# Command options
use Getopt::Long;
my %opts = (

    # logging
    'loglevel|loglvl=i' => \$loglevel,
    'logfile=s'         => \$logfile,

    # MIME message
    'message=s' => \$model_message_file,

    # CSV processing
    'csvfile=s'   => \$csv_file_name,
    "Deceased"    => \$deceased_hdr,
    "Email"       => \$email_hdr,
    "EmailBounce" => \$bounce_hdr,
    "Exclude"     => \$exclude_hdr,
    "GivenName"   => \$gname_hdr,
    "Addr1"       => \$fname_hdr,
    "SpecialHdr"  => \$special_hdr,

    # message modification
    "Subject-Prefix=s" => \$subjectprefix,
    "Subject-Suffix=s" => \$subjectsuffix,
    "Special=s"        => \$do_special,

    # Debugging
    'DEBUG!' => sub {
        $DEBUG++;
        $loglevel = LOG_DEBUG;
    },
);

GetOptions(%opts) or die "Command options incorrect: $!\n";

# Subroutines

# Logging

sub init_log() {
    die("Logfile not specified\n") unless ($logfile);

    $logger = Log::Trivial->new( log_file => $logfile )
      or die "Logging init failed: $!\n";

    $logger->set_log_mode('single');
    $logger->set_write_mode('s');    # This is the default

    # Process options

    $logger->set_log_level($loglevel) if ($loglevel);

    LOG( LOG_IMPORTANT, "Address file  =$csv_file_name" );
    LOG( LOG_IMPORTANT, "Message file  =$model_message_file" );
    LOG( LOG_IMPORTANT, "Subject prefix=$subjectprefix" );
    LOG( LOG_IMPORTANT, "Subject suffix=$subjectsuffix" );
    LOG( LOG_IMPORTANT, "Special       =" . ( $do_special || "" ) ); # Prevent warning
    LOG( LOG_IMPORTANT, "DEBUG         =" . ( $DEBUG || "" ) ); # Prevent warning

    LOG( LOG_DETAIL, "init_log: done" );
}

sub cleanup_log() {
    LOG( LOG_DETAIL, "cleanup_log: start" );

    $logger = undef;
}

# MIME message

sub init_message() {
    LOG( LOG_DETAIL, "init_message: start" );

    LOG( LOG_CRITICAL, "init_message: message file not specified" )
      unless ($model_message_file);

    # Create the MIME message

    $mime_parser = MIME::Parser->new();
    $mime_parser->output_to_core(1);
    $mime_parser->tmp_to_core(0);
    $mime_parser->decode_bodies(1);

    ### Ultra-tolerant mechanism:
    $mime_parser->ignore_errors(1);
    $model_message = eval { $mime_parser->parse_open($model_message_file) };
    my $error = ( $@ || $mime_parser->last_error );

    if ($error) {    ### Cleanup all files created by the parse:
        $mime_parser->filer->purge();
        LOG( LOG_CRITICAL, "init_message: message parse error: $error" )
          ;          # Does not return
    }

    LOG( LOG_CRITICAL, "init_message: Model message has no Subject" )
      unless ( $model_message->head->get("Subject") );

    LOG( LOG_CRITICAL, "init_message: Model message has no Content-type" )
      unless ( $model_message->head->get("Content-Type") );

    LOG( LOG_DETAIL, "init_message: stop" );
}

sub build_message($) {
    LOG( LOG_DETAIL, "build_message: start" );

    sub do_part($);

    sub do_part($)
    {    # This processes each part and applies the template if necessary
        my $this_part = shift(@_);
        LOG( LOG_DEBUG, "do_part found: " . $this_part->effective_type() );
        if ( $this_part->parts()
          )    # If it has parts then process those recursively
        {
            map( do_part($_), $this_part->parts() );
        } else {
            if ( $this_part->effective_type =~ m/^text\/(?:plain|html)$/ ) {
                apply_template($this_part);
            }
        }
    }
    my ( $inrec, $newhead, $subject, $contenttype, $newmessage, $newparts );

    $inrec = shift(@_);

    # Build new message header

    $newhead = MIME::Head->new();

    $newhead->replace(
        "To",
        sprintf "\"%s\" <%s>",
        ${$inrec}{$fname_hdr},
        ${$inrec}{$email_hdr}
    );
    $newhead->replace( "From",     $smtp_from );
    $newhead->replace( "Reply-To", $smtp_from );

    $subject = $model_message->head->get("Subject");
    chomp $subject;
    $subject = $subjectprefix . $subject . $subjectsuffix;
    $newhead->replace( "Subject", $subject );

    $contenttype = $model_message->head->get("Content-Type");
    chomp $contenttype;
    $newhead->replace( "Content-Type", $contenttype );

    $newmessage = $model_message->dup();    # Make a full copy

    $newmessage->head($newhead);

    do_part($newmessage);

    send_message($newmessage);

    LOG( LOG_DETAIL, "build_message: stop" );
}

sub cleanup_message() {
    LOG( LOG_DETAIL, "cleanup_message: start" );

    $mime_parser->filer->purge();
    $mime_parser = undef;

    LOG( LOG_DETAIL, "cleanup_message: stop" );
}

# Template processing

sub init_template() {
    LOG( LOG_DETAIL, "init_template: start" );

    $template = Template->new()
      or LOG( LOG_CRITICAL, "init_template: $Template::ERROR" )
      ;    # Does not return

    LOG( LOG_DETAIL, "init_template: stop" );
}

sub apply_template($) {
    LOG( LOG_DETAIL, "apply_template: start" );

    # Apply the template to the MIME::Entity

    my ( $entity, $oldbodytext, $newbodytext, $newbody, $IO );

    $entity = shift(@_);

    $oldbodytext = $entity->bodyhandle->as_string();

    $template->process( \$oldbodytext, $input_record, \$newbodytext )
      or LOG( LOG_CRITICAL,
        "apply_template: Template process error: $template->error()" );

    $newbody = MIME::Body::InCore->new();

    $IO = $newbody->open("w");
    $IO->print($newbodytext);
    close $IO;

    $entity->bodyhandle($newbody);

    LOG( LOG_DETAIL, "apply_template: stop" );
}

sub cleanup_template() {
    LOG( LOG_DETAIL, "cleanup_template: start" );

    $template = undef;

    LOG( LOG_DETAIL, "cleanup_template: stop" );
}

# CSV input

sub init_list() {
    LOG( LOG_DETAIL, "init_list: start" );

    LOG( LOG_CRITICAL, "CSV file name not specified" )
      unless ($csv_file_name);    # Does not return

    LOG( LOG_DETAIL, "init_list: create csv reader" );
    $csv_reader = Text::CSV->new( { binary => 1, eol => $/ } );
    LOG( LOG_CRITICAL, "Cannot create CSV reader" )
      unless ($csv_reader);       # Does not return

    LOG( LOG_DETAIL, "init_list: open $csv_file_name" );
    unless ( open $csv_file_handle, "<", $csv_file_name ) {
        my $emsg = $!;
        LOG( LOG_CRITICAL, "CSV file open failed: $emsg" );    # Does not return
    }

    my $row;
    unless ( $row = $csv_reader->getline($csv_file_handle) )
    {    # First line is headers
        LOG( LOG_CRITICAL, "init_list: CSV file is empty" );   # Does not return
    }
    map { s/ +// } @$row;    # Remove spaces in labels, it's easier that way
    $csv_reader->column_names($row);

    LOG( LOG_DEBUG, "init_list: header row: " . join( ',', @headerrow ) );

    LOG( LOG_DETAIL, "init_list: stop" );
}

sub get_list_entry() {
    LOG( LOG_DETAIL, "get_list_entry: start" );

    my $return_val;

    $input_record = $csv_reader->getline_hr($csv_file_handle);

    if ($input_record) {
        $row_count++;

        map { s/ +$//, s/ +/ / } values %{$input_record};    # Clean up spaces

        $return_val = 1;
    } else {
        if ( $csv_reader->eof ) {
            LOG( LOG_DEBUG, "get_list_entry: end-of-file" );
            $return_val = undef;
        } else {
            LOG( LOG_CRITICAL,
                "get_list_entry: error in input: " . $csv_reader->error_input )
              ;                                              # Does not return
        }
    }

    LOG( LOG_DETAIL, "get_list_entry: done" );

  return $return_val;
}

sub cleanup_list() {
    LOG( LOG_DETAIL, "cleanup_list: start" );

    $csv_reader = undef;

    close $csv_file_handle;

    LOG( LOG_DETAIL, "cleanup_list: stop" );
}

# Sending mail

sub init_sendmail() {
    LOG( LOG_DETAIL, "init_sendmail: start" );

    if ($DEBUG) {
        $smtp_transport = Email::Sender::Transport::Test->new();
        LOG( LOG_PRIORITY, "init_sendmail: Running TEST transport" );
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
        LOG( LOG_PRIORITY, "init_sendmail: Running SMTP transport" );
    }

    LOG( LOG_CRITICAL, "init_sendmail: Cannot create Transport" )
      unless ($smtp_transport);

    LOG( LOG_PRIORITY, "init_sendmail: Send Special to \"$do_special\"" )
      if $do_special;

    LOG( LOG_DETAIL, "init_sendmail: stop" );
}

sub send_message($) {
    LOG( LOG_DETAIL, "send_message: start" );

    my ( $message, $sender_args );

    $message = shift(@_);

    $sender_args = { transport => $smtp_transport };

    $$sender_args{from} = $smtp_bounce;

    try sub {
        Email::Sender::Simple->send( $message, $sender_args );
      }, catch_when 'Email::Sender::Failure' => sub {
        my $sentto = $message->get("To");
        chomp $sentto;
        LOG( LOG_URGENT,
            "send_message: email to $sentto failed, Error=" . $_->message );
        $send_errors++;
      },
      then sub {
        $sent_messages++;
      };

    LOG( LOG_DETAIL, "send_message: stop" );
}

sub cleanup_sendmail() {
    LOG( LOG_DETAIL, "cleanup_sendmail: start" );

    my ( $delivery, $delivered );

    if ($DEBUG) {    # Dump test results
        $Data::Dumper::Indent   = 1;    # Simplify the output
        $Data::Dumper::Maxdepth = 5;    # Don't go too deep!
        $delivered = $smtp_transport->delivery_count();
        LOG( LOG_DEBUG, "cleanup_sendmail: Delivery count: $delivered" );
        foreach $delivery ( $smtp_transport->deliveries ) {
            LOG( LOG_DEBUG,
                "cleanup_sendmail: Delivery: " . Dumper($delivery) );
        }
    }

    $smtp_transport->disconnect() if ( $smtp_transport->can("disconnect") );
    $smtp_transport = undef;

    LOG( LOG_DETAIL, "cleanup_sendmail: stop" );
}

# This does the main work

sub process_recipient() {
    LOG( LOG_DETAIL, "process_recipient: start" );

    my $reason = 0;

    if ( ${$input_record}{$email_hdr} =~ m/^\s*$/ ) {
        $reason = "No email address";
    } elsif ( ${$input_record}{$bounce_hdr} !~ m/^(?:v|\s*)$/i ) {
        $reason = "Email not valid or bounced";
    } elsif ( $do_special
        && ${$input_record}{$special_hdr} =~ m/^$do_special$/i )
    {    # Special email processing ...
        $reason = 0;    # Mark for sending this time
    } elsif ( ${$input_record}{$exclude_hdr} !~ m/^\s*$/ ) {
        $reason = "Requested to be excluded";
    } elsif ( ${$input_record}{$deceased_hdr} !~ m/^\s*$/ ) {
        $reason = "Marked as Deceased";
    }

    unless ($reason) {
        LOG(
            LOG_NORMAL,
            sprintf(
                "Sending mail to \"%s\" at \"%s\" <%s>",
                ${$input_record}{$gname_hdr}, ${$input_record}{$fname_hdr},
                ${$input_record}{$email_hdr}
            )
        );

        my $msgout;

        send_message($msgout) if ( $msgout = build_message($input_record) );

    } else {
        LOG(
            LOG_NORMAL,
            sprintf(
                "NOT sending email to \"%s\", %s",
                ${$input_record}{$fname_hdr}, $reason
            )
        );
    }

    LOG( LOG_DETAIL, "process_recipient: stop" );
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

# Initialize template processing
init_template();

# Main processing loop
# Loop reading the CSV input file and send email if a valid email is present

while ( get_list_entry() ) {
    $input_records++;
    process_recipient();
}

# Cleanup

cleanup_template();
cleanup_sendmail();
cleanup_list();
cleanup_message();

print "Input records: $input_records\n", "Messages sent: $sent_messages\n",
  "**Send errors: $send_errors\n";
LOG( LOG_IMPORTANT, "Input records: $input_records" );
LOG( LOG_IMPORTANT, "Messages sent: $sent_messages" );
LOG( LOG_IMPORTANT, "**Send errors: $send_errors" );

cleanup_log();
