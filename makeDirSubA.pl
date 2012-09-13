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
$cq5Dir = 'C:\acs\bundles\prodstruct2\jcr_root\content\acs_steve\global\international'; # directory to palce files prior to being zipped

 find(\&isXML, $cq5Dir);
 find(\&delXML, $cq5Dir);

sub isXML
{
$hit = "false";
# print $_ . "\n";
    if ($_ =~ m/\.content.xml$/ ) {
	$pwd = cwd();
	$file = $pwd . '/' . $_;
		@ARRAYFILE = ();	
opendir(DIR, $pwd) or warn(" couldnt open $pwd \n");
	while (my $directory = readdir(DIR)) {
	next if ($directory =~ m/^\./);
	next unless (-d "$pwd/$directory");
			# print "$directory  \n";
			rename $file, "$file.orig";
			open ORIG, "<",  "$file.orig";
			open FILE, ">", $file;
				$hit = "false";
				foreach $line (<ORIG>) {
				chomp($line);
				if ($line =~ m/^$directory/) {
				$hit = "true";
				print FILE "$line \n";
				next;
				} elsif ($line =~ m/<\/jcr:root>/) {
				next;
				}
				else {
				print FILE "$line \n";
				}
				}

			
					if ($hit eq "false") {
					push (@ARRAYFILE, $directory);
					}
					$hit = "true"
		}  ###   end of first dir loop
		$a = 0;
				if (@ARRAYFILE) {
						foreach (@ARRAYFILE) { 
						print  FILE "$_ \n";
						print " $_ \n";
						}
				print FILE '</jcr:root>' . "\n";
				@ARRAYFILE = ();
				} else {
				$a++;
				 print " line now $line\n";
				print FILE '</jcr:root>' . "$a\n";
				 }
			#$a=0;	 
		}			

}

sub delXML
{
# print $_ . "\n";
    if ($_ =~ m/\.content\.xml.orig$/ ) {
	$delfile = $_;
	unlink($delfile) ;
	}
	
}