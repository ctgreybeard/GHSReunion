#!/usr/bin/perl -w

use strict;
use warnings;

# MIME message handling
use MIME::Parser;
use MIME::Entity;
use MIME::Head;
my $model_message_file = "Email5.msg";
my $model_message;
my $mime_parser;

# Template processing
use Template;
my $template;

my @headerrow;
my $row_count    = 0;
my $deceased_hdr = "Deceased";
my $email_hdr    = "Email";
my $bounce_hdr   = "EmailBounce";
my $gname_hdr    = "GivenName";
my $fname_hdr    = "Addr1";

my $input_record = {
    $email_hdr    => 'ctgreybeard+ghs64reunion@gmail.com',
    $bounce_hdr   => "",
    $gname_hdr    => "Bill",
    $fname_hdr    => "William Waggoner ",
    $deceased_hdr => "",
    Addr2			=> "51 Taylor Rd",
    Addr3			=> "Bethel, CT 06801",
    Addr4			=> "",
};

# Logging interface
use Log::Trivial;
my $logger;
my $loglevel = 6;
my $logfile  = "testtemplate.log";

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

    $logger->write( level => $lvl, comment => "($lvl) $msg" );

    die(
"Logging failed, cannot continue: attempted to log ($lvl)\"$msg\", error="
          . $logger->get_error()
          . "\n" )
      if $logger->get_error();

    die("FATAL: $msg\n") if ( $lvl == $LOG_CRITICAL );
}

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

# Testing
use Data::Dumper::Perltidy;

# Logging

sub init_log() {
    die("Logfile not specified\n") unless ($logfile);

    $logger = Log::Trivial->new( log_file => $logfile )
      or die "Logging init failed: $!\n";

    $logger->set_log_mode('single');
    $logger->set_write_mode('s');    # This is the default

    # Process options

    $logger->set_log_level($loglevel) if ($loglevel);

    LOG( $LOG_NORMAL, "init_log: done" );
}

sub cleanup_log() {
    LOG( $LOG_NORMAL, "cleanup_log: start" );

    $logger = undef;
}

# MIME message

sub init_message() {
    LOG( $LOG_NORMAL, "init_message: start" );

    LOG( $LOG_CRITICAL, "init_message: message file not specified" )
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
        LOG( $LOG_CRITICAL, "init_message: message parse error: $error" )
          ;          # Does not return
    }

    LOG( $LOG_CRITICAL, "init_message: Model message has no Subject" )
      unless ( $model_message->head->get("Subject") );

    LOG( $LOG_CRITICAL, "init_message: Model message has no Content-type" )
      unless ( $model_message->head->get("Content-Type") );

    LOG( $LOG_NORMAL, "init_message: stop" );
}

sub send_message($) {
	print Dumper(shift(@_));
}

sub build_message($) {
    LOG( $LOG_NORMAL, "build_message: start" );

    sub do_part($);

    sub do_part($)
    {    # This processes each part and applies the template if necessary
        my $this_part = shift(@_);
        LOG( $LOG_DEBUG, "do_part found: " . $this_part->effective_type() );
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
    $newhead->replace( "Subject", $subject );

    $contenttype = $model_message->head->get("Content-Type");
    chomp $contenttype;
    $newhead->replace( "Content-Type", $contenttype );

    $newmessage = $model_message->dup();    # Make a full copy

    $newmessage->head($newhead);

    do_part($newmessage);

    send_message($newmessage);

    LOG( $LOG_NORMAL, "build_message: stop" );
}

sub cleanup_message() {
    LOG( $LOG_NORMAL, "cleanup_message: start" );

    $mime_parser->filer->purge();
    $mime_parser = undef;

    LOG( $LOG_NORMAL, "cleanup_message: stop" );
}

# Template processing

sub init_template() {
    LOG( $LOG_NORMAL, "init_template: start" );

    $template = Template->new()
      or LOG( $LOG_CRITICAL, "init_template: $Template::ERROR" )
      ;    # Does not return

    LOG( $LOG_NORMAL, "init_template: stop" );
}

sub apply_template($) {
    LOG( $LOG_NORMAL, "apply_template: start" );

    # Apply the template to the MIME::Entity

    my ( $entity, $oldbodytext, $newbodytext, $newbody, $IO );

    $entity = shift(@_);

    $oldbodytext = $entity->bodyhandle->as_string();

    $template->process( \$oldbodytext, $input_record, \$newbodytext )
      or LOG( $LOG_CRITICAL,
        "apply_template: Template process error: $template->error()" );

    $newbody = MIME::Body::InCore->new();

    $IO = $newbody->open("w");
    $IO->print($newbodytext);
    close $IO;

    $entity->bodyhandle($newbody);

    LOG( $LOG_NORMAL, "apply_template: stop" );
}

sub cleanup_template() {
    LOG( $LOG_NORMAL, "cleanup_template: start" );

    $template = undef;

    LOG( $LOG_NORMAL, "cleanup_template: stop" );
}

init_log();

init_template();

init_message();

my $msgout;

$msgout = build_message($input_record);

cleanup_template();

cleanup_message();

