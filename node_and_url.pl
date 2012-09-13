#!c:/Perl/perl/bin/perl.exe 
###########################
### not being used anymore
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

# for checking url exists
my $ua = LWP::UserAgent->new;
$ua->timeout(15);
$ua->env_proxy;
$ua->max_redirect(0);
#  end of checks

# directory and file variables
 
my $xml = new XML::Simple (KeyAttr=>[]);
# my $url2 = "https://wcmsconsumpdev.acs.org/stellent/idcplg?IdcService=SS_GET_SITE_PUBLISH_REPORT&siteId=PublicWebSite";
# my $xml_file = getstore($url, "C:\\apache\\apache2.2\\scripts\\project.xml");
my $baseURL = "http://www.acs.org";
my $HomeIndex = "/index.htm";
my $HomePage = $baseURL . $HomeIndex;
# my $xmlPage = get($url);
my @Assets = ();
my @URLs =();
my $img = "";
my $parser = $xml->XMLin("c:\\acs\\productionNodes.xml");
my $link = "";

# $xmlPage = get($url);
@URLs =();
$parser = $xml->XMLin("c:\\acs\\productionNodes.xml");
@URLs = @{$parser->{PublishInfo}->{nodeUrl}};

foreach my $e (@Assets)
{
	chomp($e);

	print $baseURL . $e->{url} . " this is the base url \n";
	my $link = $baseURL .$e->{url};
#	print FH $link . "\n";
}

open (MYFILE, '>>HierarchyProd.txt');


foreach my $e (@URLs)
{
	chomp($e);
	my $link =  $e->{url};
#	my $link = $baseURL ."/" . $e->{url};
	my $node = $baseURL ."/" . $e->{nodeId};
			print "this is the stub " . $e->{url} . " " . $e->{nodeId} . "  and node \n";
			# print MYFILE "node_id=" . $e->{nodeId} . " http:\/\/www\.acs\.org\/$e->{url}" . "\n";
			print MYFILE $e->{url} . "\n";
}
close (MYFILE);
# $baseURL . 