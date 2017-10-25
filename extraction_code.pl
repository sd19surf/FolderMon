#!/usr/bin/perl

use strict;
use warnings;

## set to the directory or maybe I should allow for a config setting, CLI for now
my $directory = $ARGV[0];
my $landingDirectory= $ARGV[1];

## checks to see if argument is a directory or not
if(!$directory) {
	die "Usage: perl extraction_code.pl <source directory> <destination directory>";
}elsif(!(-d $directory)){
	die "$directory is not a directory. Kindly provide a valid directory to be monitored";
}

if(!$landingDirectory) {
	die "Usage: perl extraction_code.pl <source directory> <destination directory>";
}elsif(!(-d $landingDirectory)){
	die "$landingDirectory is not a directory. Kindly provide a valid directory to drop the files into";
}

my $first_run = 'true';
my @prev_files_list = ();
my %prev_files_hash = ();
my %current_files_hash = ();

## Keep track of the files to ensure we extract them all 
sub updateMaps {
  my @files = @_;
	foreach(@files) {
	  if($prev_files_hash{$_}){
	     delete $prev_files_hash{$_};
	  }elsif(!$prev_files_hash{$_}){
	     next if($_ eq '.' || $_ eq '..');
	     print "File: $_ has been added now\n";
	  }
	  $current_files_hash{$_} = 1;
	}
  @prev_files_list = @files;
	foreach my $file (keys %prev_files_hash) {
	   print "File: $file is deleted\n";
	   delete $prev_files_hash{$file};
	}
	%prev_files_hash = ();
	%prev_files_hash = %current_files_hash; 
  }

sub untarFiles {

   my @files = @_;
   my $count = scalar(@files);

# return the amount of files untarred for logging
return $count;
}

sub moveFiles {

  my @files = @_;
  my $count = scalar(@files);


# return the number of files moved for logging
return $count;
}

# checks 12 iterations should change to allow to run for life

foreach (1..12) {
   print "Count: $_\n";
   opendir(DIR, $directory);
   my @files = readdir(DIR);
       if($first_run eq 'true'){
         @prev_files_list = @files;
           foreach (@files) {
             $prev_files_hash{$_} = 1;
           }
         $first_run = 'false';
         sleep(10);
         next;
       }else{
##Compare prev_files and new_files
         if(scalar(@files) > scalar(@prev_files_list)){
           print "Files has been added\n";
           updateMaps(@files);

         }elsif(scalar(@files) < scalar(@prev_files_list)) {
           print "Files have been deleted\n";
           updateMaps(@files);
         }else {
           print "Either the file is changed, or same number of file deleted and added, or nothing changes at all\n";
           %current_files_hash = ();
           updateMaps(@files);
         }
       }
        sleep(10);
}