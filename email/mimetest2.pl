#!/usr/bin/perl -w

use strict;

use Data::Dumper::Perltidy;

use MIME::Parser;
use MIME::Entity;

use Template;

# Variables
my $DEBUG = 1;
MIME::Tools->debugging($DEBUG);
MIME::Tools->quiet( !$DEBUG );

sub do_template($);
sub apply_template($);

sub apply_template($) {
}

sub do_template($)
{    # This processes each part and applies the template if necessary
    my $this_part = shift(@_);
    print "do_template found: ", $this_part->effective_type(), "\n";
    if ( $this_part->parts() )  # If it has parts then process those recursively
    {
        return map( do_template($_), $this_part->parts() );
    } else {
        if ( $this_part->effective_type =~ m/^text\/(?:plain|html)$/ ) {
            $this_part = apply_template($this_part);
        }
        return $this_part;
    }
}

# Create the MIME message

my $parser = MIME::Parser->new();
$parser->output_to_core(1);
$parser->tmp_to_core(0);
$parser->decode_bodies(0);

my $entity = $parser->parse_open("mimetest.msg")
  or die "Unable to parse mimetest.msg\n";

print "Original entity...\n";
$entity->dump_skeleton if ($DEBUG);

my @parts = $entity->parts();

$Data::Dumper::Maxdepth = 4;

#print Dumper( \@parts );

my @newparts = map( do_template($_), @parts );

#print Dumper( \@newparts );

$entity->parts( \@newparts );
print "New entity...\n";
$entity->dump_skeleton if ($DEBUG);
