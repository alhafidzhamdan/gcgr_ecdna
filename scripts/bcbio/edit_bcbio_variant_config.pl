#!/usr/bin/perl -w

=head1 NAME

edit_bcbio_variant_config.pl

=head1 AUTHOR

Alison Meynert (alison.meynert@igmm.ed.ac.uk)

=head1 DESCRIPTION

Fixes a couple of minor things in the bcbio config file for variant calling.

=cut

use strict;

# Perl
use IO::File;
use Getopt::Long;

my $usage = qq{USAGE:
$0 [--help]
  --upload  Upload dir
  --fc_date Date to use for fc_date, yyyymmdd
  --fc_name Name for fc_name
};

my $help = 0;
my $upload_dir;
my $fc_date;
my $fc_name;

GetOptions(
    'help'      => \$help,
    'upload=s'  => \$upload_dir,
    'fc_date=s' => \$fc_date,
    'fc_name=s' => \$fc_name
) or die $usage;

if ($help || !$fc_date || !$fc_name || !$upload_dir)
{
    print $usage;
    exit(0);
}

while (my $line = <>)
{
    if ($line =~ /fc_name/)
    {
	print "fc_name: $fc_name\n";
	print "fc_date: \'$fc_date\'\n";
    }
    elsif ($line =~ /dir.+final/)
    {
	print "  dir: $upload_dir\n";
    }
    else
    {
	print $line;
    }
}
