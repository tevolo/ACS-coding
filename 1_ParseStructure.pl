#!c:/strawberry/perl/bin/perl.exe 
###########################
#  used to parse xml file to get simple
# flat file of urls
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

my $img = "";
#####  url below is location of stellent structure  need login credentials to get
 ### my $url = "https://wcmscontrib.acs.org/stellent/idcplg?IdcService=SS_GET_SITE_PUBLISH_REPORT&siteId=PublicWebSite";
 ### my $xml_file = getstore($url, "C:\\acs\\nodes.xml");

 open (MYFILE, 'C:\acs\nodes.xml');
 while (<MYFILE>) {
 	chomp;
	# print "$_\n";
	# sleep(2);

		if ($_ =~ m/url="(.+)index.htm"/) {
			$region1 = $1;
			print $region1 . "\n";
			&Write2File($region1);
		}
 }
 close (MYFILE); 
 
sub Write2File {
	open (FILE, '>>c:\acs\ProdStructure.txt') or warn( "didnt open");
	print FILE $_[0] . "\n";
	close(FILE);
}

