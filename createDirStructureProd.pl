#!c:/Perl/perl/bin/perl.exe
use warnings; 
use FileHandle; 
use File::Find qw(find);
use File::Basename;
use File::Copy;
###########################
# This file is used to build a directory structure
# by going through a flat file of URL's one line at a time
# and making a directory for each url
# this file must be run before createProdXMLfiles.pl
###########################

$StructFile = 'c:/acs/ProdStructure.txt';
$BaseDir = 'C:/acs/jcr_root/content/acs/';



  
 # &mkdir_recursive($FullDir);
  
  
  open (MYFILE, $StructFile);
  while (<MYFILE>) {
  	chomp;

  $NewDir = "$_";
  $FullDir = $BaseDir . $NewDir; 
    print $FullDir . "\n";
  #  &mkdir_recursive($FullDir);
  }
  close (MYFILE); 
  
  
  
  
  
  sub mkdir_recursive {     
  my $path = shift;  
  print $path;
  mkdir_recursive(dirname($path)) if not -d dirname($path); 
  mkdir $path or die "Could not make dir $path: $!" if not -d $path; 
  return;
  }  