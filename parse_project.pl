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



my @Assets = ();
my @URLs =();
my $img = "";
# my $url2 = "https://wcmsconsumpdev.acs.org/stellent/idcplg?IdcService=SS_GET_SITE_PUBLISH_REPORT&siteId=PublicWebSite";
# my $xml_file = getstore($url, "C:\\apache\\apache2.2\\scripts\\project.xml");
 open (MYFILE, 'C:\acs\project.xml');
 while (<MYFILE>) {
 	chomp;
 	# print "$_\n";
	#sleep(2);
	if ($_ =~ m/(nodeId="\d+")/) {
	$nodeID = $1;
	$nodeID =~ s/"//g;
	$nodeID =~ s/nodeId/node_id/g;
		if ($_ =~ m/region1=([A-Za-z0-9]+_\d+)/) {
		$region1 = $1;
		print "$nodeID and $region1 \n";
		&Write2File($nodeID,$region1);
		}
		if ($_ =~ m/region2=([A-Za-z0-9]+_\d+)/) {
		$region2 = $1;
				&Write2File($nodeID,$region2);
		}
		if ($_ =~ m/region3=([A-Za-z0-9]+_\d+)/) {
		$region3 = $1;
				&Write2File($nodeID,$region3);
		}
		if ($_ =~ m/region4=([A-Za-z0-9]+_\d+)/) {
		$region4 = $1;
		print "$nodeID and $region4 \n";
				&Write2File($nodeID,$region4);
		}
		if ($_ =~ m/region5=([A-Za-z0-9]+_\d+)/) {
		$region5 = $1;
		print "$nodeID and $region5 5\n";
				&Write2File($nodeID,$region5);
		}
		if ($_ =~ m/region6=([A-Za-z0-9]+_\d+)/) {
		$region6 = $1;
		print "$nodeID and $region6 6\n";
				&Write2File($nodeID,$region6);
		}
		if ($_ =~ m/region7=([A-Za-z0-9]+_\d+)/) {
		$region7 = $1;
		print "$nodeID and $region7 7\n";
		&Write2File($nodeID,$region7);
		}
		if ($_ =~ m/region8=([A-Za-z0-9]+_\d+)/) {
		$region8 = $1;
		print "$nodeID and $region8 8\n";
		&Write2File($nodeID,$region8);
		}
		if ($_ =~ m/region9=([A-Za-z0-9]+_\d+)/) {
		$region9 = $1;
		print "$nodeID and $region9 9 \n";
		&Write2File($nodeID,$region9);
		}
		if ($_ =~ m/region10=([A-Za-z0-9]+_\d+)/) {
		$region10 = $1;
		print "$nodeID and $region10 10\n";
		&Write2File($nodeID,$region10);
		}
		if ($_ =~ m/region11=([A-Za-z0-9]+_\d+)/) {
		$region11 = $1;
		print "$nodeID and $region11 11\n";
		&Write2File($nodeID,$region11);
		}
		if ($_ =~ m/region12=([A-Za-z0-9]+_\d+)/) {
		$region12 = $1;
		print "$nodeID and $region12 12\n";
		&Write2File($nodeID,$region12);
		}
		if ($_ =~ m/region13=([A-Za-z0-9]+_\d+)/) {
		$region13 = $1;
		print "$nodeID and $region13 13\n";
		&Write2File($nodeID,$region13);
		}
	} else {
	#print " miss \n";
	#sleep(1);
	next;
	}
 }
 close (MYFILE); 
 sub Write2File {
tie @lines, 'Tie::File', 'c:\acs\dataFullACS.txt' or die;
        for (@lines) {
          if (/$_[0]\s/) {
            $_ .= "\r\n  $_[1] ";
            last;
          }
        }
		 untie @lines;
}

