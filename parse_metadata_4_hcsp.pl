#!c:/strawberry/perl/bin/perl.exe 
###########################

require LWP::UserAgent;
use HTTP::Headers;
use List::Util;
use LWP::Simple; 
use XML::Simple;
use Data::Dumper; 
use Net::SMTP;
use Tie::File;
use warnings;
use Cwd;



my @Assets = ();
my @URLs =();
my $img = "";

 open (MYFILE, 'C:\acs\metadataXML.txt');
 while (<MYFILE>) {
 	chomp;
 	# print "$_\n";
	#sleep(2);

		if ($_ =~ m/<idc:resultset name="([A-Za-z0-9]+)"/) {
		#$region1 = $1;
		$region1 = '"' . $1 . '"' . ":" . '"<!--$' . 'SearchResults.' . $1 . ' -->",' . "\n";
		 &Write2File($region1);
		}
		if ($_ =~ m/<idc:optionlist name="([A-Za-z0-9]+)\./) {
		# $region3 = $1;
				$region3 = '"' . $1 . '"' . ":" . '"<!--$' . 'SearchResults.' . $1 . ' -->",' . "\n";
				&Write2File($region3);
		}
 }
 close (MYFILE); 
 sub Write2File {
open (FILE, '>>c:\acs\metadata4query.txt');
print FILE $_[0] ;
# close(FILE);
}

