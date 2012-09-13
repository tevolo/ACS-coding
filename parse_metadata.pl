#!c:/strawberry/perl/bin/perl.exe 
###########################
# used to parce a metadata file from any piece of content 
# to represent the user choices in a text file
# IsJava=1 is used in CMS
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
		$region1 = "MetaData is $1 \n";
		 &Write2File($region1);
		}
		if ($_ =~ m/<idc:row [A-Za-z0-9]+="([A-Za-z0-9]+)"/) {
		#$region2 = $1;
				$region2 = "\t value is $1 \n";
				&Write2File($region2);
		}
		if ($_ =~ m/<idc:optionlist name="([A-Za-z0-9]+)\./) {
		# $region3 = $1;
				$region3 =  "MetaData is $1 \n";
				&Write2File($region3);
		}
		if ($_ =~ m/<idc:option>([A-Za-z0-9]+)</) {
		# $region4 = $1;
				$region4 =  " \t value is $1 \n";
				&Write2File($region4);
		}
	

 }
 close (MYFILE); 
 sub Write2File {
open (FILE, '>>c:\acs\parsedmetadata.txt');
print FILE $_[0] ;
# close(FILE);
}

