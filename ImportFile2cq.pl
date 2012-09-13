#!c:/strawberry/perl/bin/perl.exe 
###########################
use warnings;
use Cwd;
use File::Basename;
$StructFile = 'c:/acs/productionStructure.txt';
 open (MYFILE, $StructFile);
  while (<MYFILE>) {
  	chomp;
  $NewDir = "$_";
    &CreateStruct($NewDir);
  }
  close (MYFILE); 

sub CreateStruct {
# $WorkingDir='C:\acs\undergrad.acs.org';
# chdir("$WorkingDir") or  print " can not change into working directory no files will be processed $! \n";
 # @files = <*.test>;
#  foreach $file (@files) {
   my $filename = shift; 
   my $filebase = basename($filename);
   print $filebase . "\n";
   $nodeID = '/content/acs2/' . $filename;
   print $nodeID . "\n";
   $Template= '/apps/geometrixx/templates/contentpage';
   $cmd = 'curl -u admin:admin -F cmd="createPage" -F label="" -F ' . ' parentPath="' . $nodeID . '" -F  template="' . $Template . '" -F title="' . $filebase . '"' . " " . 'http://wit289.acs.org:4802/bin/wcmcommand';
 # system('curl -u admin:admin -F cmd="createPage" -F label="" -F parentPath="/content/geometrixx/en/company" -F template="/apps/geometrixx/templates/contentpage" -F title="steves test2" http://wit289:4802/bin/wcmcommand');
# system($cmd);
  print $cmd . "\n";
  } 
 
  # system('curl -u admin:admin -F cmd="createPage" -F label="" -F parentPath="/content/geometrixx/en/company" -F template="/apps/geometrixx/templates/contentpage" -F title="steves test2" http://wit289:4802/bin/wcmcommand');
