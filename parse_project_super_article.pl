#!c:/strawberry/perl/bin/perl.exe 
###########################
# parses cms project to get 
# landing pages that are super articles and also writes a list of sueprarticles to SuperArticles.txt
# this will also downlaod the stellent contentID file as html and gets the images from it while rewriting the urls
# to do:::  do not save it as index.htm save it as the stellent contentID look in style mapping for code for that
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

my $StartingDir = 'c:/temp/';
my $ZipDir = $StartingDir . 'SA/';
my $BaseDir = $ZipDir . 'content/acs/';

# my $url2 = "https://wcmsconsumpdev.acs.org/stellent/idcplg?IdcService=SS_GET_SITE_PUBLISH_REPORT&siteId=PublicWebSite";
# my $xml_file = getstore($url, "C:\\apache\\apache2.2\\scripts\\project.xml");
 open (MYFILE, 'C:\temp\ss_project_acs.xml');
 while (<MYFILE>) {
 	chomp;
 	# print "$_\n";
	#sleep(2);
	if ($_ =~ m/primaryUrl=\"PP_SUPERARTICLE/) {
	if ($_ =~ m/(nodeId="\d+")/) {
	$line = $_;
	$nodeID = $1;
	$nodeID =~ s/"//g;
	$nodeID =~ s/nodeId/node_id/g;
	# need to match node to url here then make the directory
	&ParseXml($nodeID);
		if ($line =~ m/region1=([A-Za-z0-9]+_\d+)/) {
			$region1 = $1;  # this is the stellent content ID
		}
		if ($line =~ m/urlDirName="([A-Za-z]+)\"/) {
			$region2 = $1;
			# print " region1  $region1  reegion2 $region2 \n";
			&Write2FileSA($nodeID,$region1,$region2);
			my $dir = getcwd;
			&mkdir_SA($dir,$region1);
		}
	} else {
	next;
	}
	} else {
		if ($_ =~ m/(nodeId="\d+")/) {
	$line = $_;
	$nodeID = $1;
	$nodeID =~ s/"//g;
	$nodeID =~ s/nodeId/node_id/g;
	# need to match node to url here then make the directory
	&ParseXml($nodeID);
		if ($line =~ m/urlDirName="([A-Za-z]+)\"/) {
			$region2 = $1;
			$region1 = "placeholder";
			my $dir = getcwd;
			&mkdir_SA($dir,$region1);
		}
		} else {
		next;
		}
	}
 }
 close (MYFILE); 
 sub Write2File {
tie @lines, 'Tie::File', 'c:\temp\SuperArticles.txt' or die;
        for (@lines) {
          if (/$_[0]\s/) {
            $_ .= "\r\n  $_[1] ";
            last;
          }
        }
		 untie @lines;
}

sub Write2FileSA {
	open (FILE, '>>c:\temp\SuperArticles.txt') or warn( "didnt open");
	print FILE $_[0] . " " . $_[1] . " " . $_[2] . "\n";
	close(FILE);
}

sub ImageLocal {   # called from mkdir_SA  should probably merge into content.xml for images 
 $file = $_[0];
 open (IMFILE, "$file");
 open (OUT, '>>index.htm') or warn( "didnt open");
	while (<IMFILE>) {
		chomp;
		$_ =~ s/PublicWebSite/acs\/SA\/content\/acs/g;
		if ($_ =~ m/<img src=\"\/.*\/([A-Za-z0-9]+-\d+.jpg|gif)?\"/) {
			$savedimage = $1;
			$image = '"' . $savedimage;
			$line = $_;
			$line =~ m/img src=\"(.*jpg|gif)/ ; 
			$imagePath = $1;
			$imageURL = 'https://wcmscontrib.acs.org' . "$imagePath";
			print "$image url is $imageURL \n";
			system("wget -q --no-check-certificate -t3 -T30 -O $savedimage $imageURL") ;
			# print " \n This is line before replace \n $_ \n \n ";
			$_ =~ s/\"\/.*jpg|gif?/$image/g;
			# print "\n \n this should be a whole line \n \n $_ \n \n ";
		}
		print OUT $_ . "\n";
		
	}
	close(IMFILE);
	close(OUT);
	copy("index.htm","$file");
}

sub mkdir_SA {     # this gets [assed the current directory and the stellent content ID
	my $path = $_[0];  
	# print $path;
	mkdir $path or die "Could not make dir $path: $!" if not -d $path; 
	chdir($path) or warn " not able to cd into $path \n";
	my $fileName = $_[1] ;
	my $wgetURL = 'https://wcmscontrib.acs.org/dc/' . $_[1];  # get the dynamic converted stellent content ID as html
	if ($fileName ne "placeholder") {   # dont bother connecting if it is a dummy placeholder
	system("wget -q --no-check-certificate -t 3 -T 30 -O $fileName $wgetURL") ;
	&ImageLocal($fileName);  # content ID
	}
	return;
}  

sub ParseXml {
 my $NodeMatch = $_[0];  
 open (MYNODES, 'C:\acs\nodesProd.xml');
 while (<MYNODES>) {
 	chomp;
		$node = " ";
		if ($_ =~ m/(nodeId="\d+")/) {
		$node = $1;
		$node =~ s/"//g;
		$node =~ s/nodeId/node_id/g;
		}
		if ($NodeMatch eq $node) {
				if ($_ =~ m/url="(.+)index.htm"/) {
				$stub = $1;
				$stub =~ s/[^!-~\s]/n/g; 
				$FullDir = $BaseDir . $stub; 
				print $FullDir . "\n";
				&mkdir_recursive($FullDir);
				 chdir($FullDir) or warn " not able to chdir \n";

				}
			return ;
		}
 }
 close (MYNODES); 
}
####  does this need to be here any more??????
sub mkdir_recursive {     
	$path = shift;  
	 print $path;
	mkdir_recursive(dirname($path)) if not -d dirname($path); 
	mkdir $path or die "Could not make dir $path: $!" if not -d $path; 
	return;
}  

print time - $^T;