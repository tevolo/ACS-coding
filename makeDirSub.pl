#!c:/strawberry/perl/bin/perl.exe 
  use HTML::TokeParser;
  use HTML::Element;
  use HTML::TreeBuilder;
  use warnings;
  use File::Copy;
  use File::Basename;
  use File::Find;
  use File::Path qw(mkpath);
  use Cwd;
  use LWP::Simple; # for downloading urls 
  use LWP 5.64;
$cq5Dir = 'C:\acs\bundles\prodstruct2\jcr_root\content\acs_steve'; # directory to palce files prior to being zipped

 find(\&isXML, $cq5Dir);
 find(\&delXML, $cq5Dir);

sub isXML
{
# print $_ . "\n";
    if ($_ =~ m/\.content.xml$/ ) {
	$pwd = cwd();
	$file = $pwd . '/' . $_;
		@ARRAYFILE = ();	
opendir(DIR, $pwd) or warn(" couldnt open $pwd \n");
		while (my $directory = readdir(DIR)) {
		next if ($directory =~ m/^\./);
		next unless (-d "$pwd/$directory");
		push (@ARRAYFILE, $directory);
		}

			rename $file, "$file.orig";
			open ORIG, "<",  "$file.orig";
			 open FILE, ">", $file;
					foreach $line (<ORIG>) {
						if ($line =~ m/<\/jcr:content>/) {
						#print " match  at $line \n";
						print FILE $line;
							foreach (@ARRAYFILE) {
								print FILE "$_ \n";
								}
								print FILE '</jcr:root>';
								last;		
						}  else {
						print FILE $line;
						}
						
					}
			
			
	} # end if			

}

sub delXML
{
# print $_ . "\n";
    if ($_ =~ m/\.content\.xml.orig$/ ) {
	$delfile = $_;
	unlink($delfile) ;
	}
	
}