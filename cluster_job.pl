#!/usr/local/bin/perl -w
#Created by Cedric Simillion on Wed Feb 19 12:33:16 CET 2003

=head1 Description

Reads from STDIN commands to be executed on the cluster (hagrid). This input in then
wrapped in a shell script and consequently submitted to the cluster. A name for the job
can optionally be given as argument at the command line. If ommited, a job name consisting
of the user ID and a timestamp will be created automatically.

=head1 !!!WARNING!!!

You must be logged onto mokele or hagrid if you want to launch a job with this script.

=cut

use strict;

#===============================================================================
# Initialisation
#===============================================================================
#($ENV{"HOSTNAME"} eq 'mokele') || die "You must be logged onto mokele to be able to start jobs on the cluster!!!\n";
my (@job)=<STDIN>;
my $temp_id;
($ARGV[0]) ? ($temp_id=$ARGV[0]) : ($temp_id="$ENV{'USER'}_job_".time.$$);

#===============================================================================
# Create the shell script...
#===============================================================================
open (CSH,">$temp_id.csh") || (die $!);
print CSH "#!/bin/tcsh\n";
#source /usr/local/share/skel/grid.cshrc\n";
print CSH @job;

#===============================================================================
# Submit the job
#===============================================================================
`chmod +x $temp_id.csh`;
print STDERR `qsub -cwd $temp_id.csh`;
