#!c:/strawberry/perl/bin/perl.exe
use utf8;
use Encode qw(encode_utf8);
use JSON;
use Data::Dumper; 
use warnings;  
  local $/; #Enable 'slurp' mode
  open my $fh, "<", 'C:\acs\articleJson.txt';
  $content = <$fh>;
  close $fh;
$content = encode_utf8( $content );

my $data = decode_json($content);
# Output to screen one of the values read

print Dumper $data;


for my $elem (@{$data->{Content_ID}}) {
    print "$elem->{Title}\n";
}