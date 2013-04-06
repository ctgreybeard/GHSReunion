#!/usr/bin/perl

use warnings;
use strict;

use Text::CSV::Auto;
use Data::Dumper::Perltidy;

# Set DEBUG for testing
my $DEBUG = 0;

sub DEBUG($$) {
    my ( $debug_lvl, $msg ) = @_;
    if ( $DEBUG >= $debug_lvl ) {
        print STDERR $msg, "\n";
    }
}

# Common parameters
my $test_mode    = 1;
my $input_csv    = "test.csv";
my $deceased_hdr = "Deceased";
my $email_hdr    = "Email";
my $bounce_hdr   = "EmailBounce";
my $gname_hdr    = "GivenName";
my $fname_hdr    = "Addr1";

my $csv = Text::CSV->new( { binary => 1, eol => $/ } );

open my $io, "<", $input_csv or die "$input_csv: $!";

my $row = $csv->getline($io);    # First line is headers
map { s/ +// } @$row;            # Remove spaces in labels, it's easier that way
my @headerrow = @$row;
my $colnum    = 0;
DEBUG( 1, "Found " . scalar(@headerrow) . " columns" );
DEBUG( 1, Data::Dumper->Dump( [ \@headerrow ], [qw/headerrow/] ) );
my %inrec;
my $rows = 0;

while ( my $row = $csv->getline($io) ) {
    $rows++;
    %inrec = ();                  # Clear the record ...
    @inrec{@headerrow} = @$row;
    map { s/ +$//, s/ +/ / } values %inrec;    # Clean up spaces
    DEBUG( 1, Data::Dumper->Dump( [ \%inrec ], [qw/InputRec/] ) );
    if (
          !$inrec{$deceased_hdr}
        && $inrec{$email_hdr}
        && (   $inrec{$bounce_hdr} =~ m/v/i
            || $inrec{$bounce_hdr} eq '' )
      )
    {
        printf "Sending mail to \"%s\" at \"%s\" <%s>\n", $inrec{$gname_hdr},
          $inrec{$fname_hdr}, $inrec{$email_hdr};
    } else {
        printf "NOT sending email to \"%s\"\n", $inrec{$fname_hdr};
    }
}

printf STDERR "%d rows processed.\n", $rows;
