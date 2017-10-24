#!/usr/bin/perl

use strict;
use warnings;

## set to the directory or maybe I should allow for a config setting, CLI for now
my $directory = $ARGV[0];
my $test= $ARGV[1];

if(!$directory) {
	die "Usage: perl extraction_code.pl <directory> <test>";
}elsif(!(-d $directory)){
	die "$directory is not a directory. Kindly provide a valid directory to be monitored";
}


# Good use of the argument to not actively run the real code but to test all the directory mappings
if(!$test) {
     $test=0;
}else{
     $test=1;
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