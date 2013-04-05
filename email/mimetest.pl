#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper::Perltidy;

use MIME::Parser;
use MIME::Head;
use Email::Sender::Simple qw/sendmail/;
use Email::Sender::Transport::SMTP::Persistent;
use Email::Sender::Transport::Test;

my $DEBUG = 0;

# Setup for SMTP
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

my $parser = MIME::Parser->new();
$parser->output_to_core(1);
$parser->tmp_to_core(0);
$parser->decode_bodies(0);

my $entity = $parser->parse_open("mimetest.msg")
  or die "Parse failure!\n";

$entity->dump_skeleton if ($DEBUG);

my $head = $entity->head();

if ($DEBUG) {
    print "\nHeader:\n";
    $head->print( \*STDOUT );
}

my $newhead = MIME::Head->new();

$newhead->replace( "To",       '"Bill Waggoner, Jr" <ctgreybeard+mimetest@gmail.com>' );
$newhead->replace( "From",     $smtp_from );
$newhead->replace( "Reply-To", $smtp_from );

my $subject = $head->get("Subject")
  or die "Subject not found in email!\n";
chomp $subject;
$newhead->replace( "Subject", $subject );

my $contenttype = $head->get("Content-Type")
  or die "Content-type not found in email!\n";
chomp $contenttype;
$newhead->replace( "Content-Type", $contenttype );

print "\nNew header:\n";
$newhead->print( \*STDOUT );

$entity->head($newhead);

if ($DEBUG) {
    print "\nNew entity\n";

    $entity->dump_skeleton;

    open OUT, ">", "mimetest.out";
    $entity->print( \*OUT );
    close OUT;
}

my $transport;
if ($DEBUG) {
    $transport = Email::Sender::Transport::Test->new();
    print "Running TEST transport\n";
} else {
    $transport = Email::Sender::Transport::SMTP::Persistent->new(
        {
            host          => $smtp_server,
            port          => $smtp_port,
            sasl_username => $smtp_user,
            sasl_password => $smtp_passwd,
            helo          => "ghs64reunion.org",
        }
    );
    print "Running SMTP transport\n";
}

sendmail( $entity, { transport => $transport, from => $smtp_bounce } )
  or die "Sending mail failed!\n";

$transport->disconnect() if $transport->can("disconnect");

if ($DEBUG) {
    print Dumper $transport->deliveries
      if $transport->isa("Email::Sender::Transport::Test");
}

print "\nAll done...\n";
