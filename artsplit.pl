#!c:/strawberry/perl/bin/perl.exe
use Data::Dumper; 
use warnings;  
  local $/; #Enable 'slurp' mode
  open my $fh, "<", 'C:\acs\articleMetaShort.txt';
  $content = <$fh>;
  close $fh;
@ArtData  = split('},', $content);

for my $elem (@ArtData) {
   #   print $elem . "\n";
	$elem =~ m/([A-Za-z0-9]*_\d*?)":{ "Type":"Article","Title":"(.*)?","Web Extension":"([A-Za-z]*)?","WebSiteSection":"PublicWebSite:\d*/;
	 print "$1 and $2 and $3 \n";
}