#!c:/strawberry/perl/bin/perl.exe 
###########################
# parses cms project to get 
# landing pages and also 
# region content
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
use FileHandle; 
use File::Find qw(find);
use File::Basename;
use File::Copy;

my $StartingDir = 'c:/acs/';
my $ZipDir = $StartingDir . 'SA/';
my $BaseDir = $ZipDir . 'content/acs/';

# my $url2 = "https://wcmsconsumpdev.acs.org/stellent/idcplg?IdcService=SS_GET_SITE_PUBLISH_REPORT&siteId=PublicWebSite";
# my $xml_file = getstore($url, "C:\\apache\\apache2.2\\scripts\\project.xml");
 open (MYJSON, 'C:\acs\articleJson.txt');
 while (<MYJSON>) {
 	chomp;

	if ($_ =~ m/\"([A-Za-z]+_[0-9]+)\"/) {
	# $line = $_;
	$ContentID = $1;
	}
	if ($_ =~ m/Web Extension/) {
			if ($_ =~ m/(doc|pdf|docx)/) {
			$extension = $1 ;
			}
	}
	if ($_ =~ m/WebSiteSection/) {
		if ($_ =~ m/PublicWebSite:(.*)\"/) {
		$node = $1 ;
		# $node = 'node_id="' . $node . '"';
		# print $ContentID . " " . $extension . " " . $node . "\n";
		&FindFolder($node,$ContentID,$extension);
		}
	}
 }
 close (MYJSON); 

 
 
 sub FindFolder {
  $node2match = $_[0];
  $contentid = $_[1];
  $ext = $_[2];
    $root = 'C:\acs\SA\content\acs\\';
  open (MYNODE, 'C:\acs\nodesProd.xml');
	while (<MYNODE>) {
 	chomp;
		if ( $_ =~ m/\"$node2match\"/ ) {
		$_ =~ m/url=\"(.*\/)index.htm/;
		$tempstub = $1;
		print " we have a match $node2match at $tempstub\n";
		$newpath = $root . $tempstub;
		chdir($newpath);
			if ( $ext ne "pdf" ) {
			my $wgetURL = 'https://wcmscontrib.acs.org/dc/' . $_[1]; 
			system("wget -q --no-check-certificate -t 3 -T 30 -O $contentid $wgetURL") ;
			} else
			{
			my $WgetURLpdf = 'https://wcmscontrib.acs.org/PublicWebSite/' . $tempstub . $_[1];
			system("wget -q --no-check-certificate -t 3 -T 30 -O $contentid $WgetURLpdf") ;
			}
		}
	
	}
	close (MYNODE); 
 }
 