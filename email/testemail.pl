#!/usr/bin/perl

use strict;
use warnings;

our $smtp_server;
our $smtp_port;
our $smtp_user;
our $smtp_passwd;
our $smtp_sasl;

use Mail::Sendmail qw(sendmail %mailcfg);
use Data::Dumper;
use smtpopts;

my $to      = "ctgreybeard+ghstest\@gmail.com";
my $from    = "karenwaggoner\@ghs64reunion.org";
my $bounce  = "admin\@ghs64reunion.org";
my $reply   = $from;
my $subject = "Test reunion email";
my $mesg    = <<MESG;
--089e01177461f4e59304d980c151
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

T
=E2=80=8Bhis is a test message

Can you read this?

Bill=E2=80=8B

--089e01177461f4e59304d980c151
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><font size=3D"4">T<div class=3D"gmail_default" style=3D"fo=
nt-family:garamond,serif;font-size:large;display:inline">=E2=80=8B<font siz=
e=3D"4">his is a test message<br><br></font></div><div class=3D"gmail_defau=
lt" style=3D"font-family:garamond,serif;font-size:large;display:inline">
<font>Can you read this?<br><br></font></div><div class=3D"gmail_default" s=
tyle=3D"font-family:garamond,serif;font-size:large;display:inline"><font><f=
ont>Bill</font></font>=E2=80=8B</div></font><br></div>

--089e01177461f4e59304d980c151--
MESG
my @Content_Type = (
    "Content-Type",
    "multipart/alternative; boundary=089e01177461f4e59304d980c151"
);

$mailcfg{'smtp'}  = [$smtp_server];
$mailcfg{'mime'}  = 0;
$mailcfg{'port'}  = $smtp_port;
$mailcfg{'debug'} = 1;

my %mail;
$mail{'To'}        = $to;
$mail{'From'}      = $from;
$mail{'Errors-to'} = $bounce;
$mail{'Reply-to'}  = $reply;
$mail{'Subject'}   = $subject;
$mail{'Message'}   = $mesg;
