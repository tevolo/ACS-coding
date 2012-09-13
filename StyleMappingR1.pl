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
my @RightArray = ();
my @ListArray = ();
my @TextArray = ();
my @TextImageArray = ();
my @ImageArray = ();
my @FullArray = ();
my $text0 = "false";
$outfile = 'c:\acs\SA\.content.xml';
my $imagearray = "false";
my $listarray = "false";
 &CreateContentHeader;
open (OUTFILE, ">>$outfile");
 open (MYARTICLE, 'C:\acs\SA\content\acs\careers\whatchemistsdo\profiles\CTP_004425');
 while (<MYARTICLE>) {
 	chomp;
  if ($_ =~ m/<p>(.*)<\/p>/) {
	if($1=~/^\s*$/){
	next;
	}
	}
 	my $block = &CheckBlock($_); # used to check for images and lists for now
 	
 	if ($block eq "imagestart" ) {
 		$imagearray = "true";
 		next;
 	}
 	if ($block eq "imagefinish" ) {
 		$imagearray = "false";
		&ImageFooter();
 		next;
 	}	
 	if ($block eq "liststart" ) {
 		$listarray = "true";
 		next;
 	}
 	if ($block eq "listfinish" ) {
 		$listarray = "false";
		push(@TextArray,@ListArray);
			@ListArray = ();
 		next;
 	}
	if ($imagearray eq "true") {
	$_ =~ s/</&lt;/g;
	$_ =~ s/&lt;br \/>//g;
	$_ =~ s/&lt;div class=\"image-caption\">//g;
	$_ =~ s/&lt;\/div>//g;
			if ($_ =~ m/img src/) {
				$_ =~ m/img src=\"(.*)?\".*border=\"(.*)?\".*width=\"(.*)?\".*height=\"(.*)?\"/;
				push(@ImageArray,'<image');
                push(@ImageArray,'jcr:primaryType="nt:unstructured"');
                push(@ImageArray,' jcr:title="' . "TITLE" . '"' );
               push(@ImageArray,'sling:resourceType="foundation/components/image"');
                push(@ImageArray,'    alt="Student presenting his research at a national meeting sci-mix session"');
                push(@ImageArray,    'fileReference="' . '/content/dam/Undergrad.acs.org/placeholder.png'  . '"');
                push(@ImageArray,       'height="' . $4  . '"');
				push(@ImageArray,       'width="' .  $3  . '"');
				push(@ImageArray,    'imageRotate="0"');
                 push(@ImageArray,    '/>'  . "\n");
				} else {
				push(@TextImageArray,$_);
				}
				next;
		} elsif ($listarray eq "true") {
		$_ =~ s/</&lt;/g;
		push(@ListArray,$_);
		next ;
		 } 
		&CheckHeadings($_);
		&CheckPar($_);
		

 }
 close (MYARTICLE);

 
 		foreach (@TextArray) {
			if ($text0 eq "false") {
			print OUTFILE '<text_0' . "\n"; 
			print OUTFILE ' jcr:primaryType="nt:unstructured"' . "\n"; 
            print OUTFILE 'sling:resourceType="acs/components/general/text"' . "\n";
			print OUTFILE 'text="'; 
			$text0 = "true";
			}
			$new = $_ . "\n"; #set variable $new to replaced string
			print OUTFILE $new; #print out replaced string
		}

		print OUTFILE '"' . "\n";
		print OUTFILE 'textIsRich="true">' . "\n";
		print OUTFILE '</text_0>' . "\n";
		print OUTFILE '</mainPar>' . "\n";
		print OUTFILE '<rightPar' . "\n";
		print OUTFILE '    jcr:primaryType="nt:unstructured"' . "\n";
		print OUTFILE 'sling:resourceType="foundation/components/parsys">' . "\n";	
		foreach (@RightArray) {
			$new = $_ . "\n"; #set variable $new to replaced string
			print OUTFILE $new; #print out replaced string
		}
		print OUTFILE '</rightPar>' . "\n";
		print OUTFILE '</jcr:content>' . "\n";
		print OUTFILE '</jcr:root>';		

 close (OUTFILE) or die $!;
	


#############  end  ################	
 sub CheckHeadings {
   $headings = $_[0];
 	if ($headings =~ m/<h1>(.*)<\/h1>/) {
 	$new = 'jcr:title="' . $1 . '"' . "\n"; #set H1 to title
	print OUTFILE $new; #print out replaced string
	print OUTFILE 'sling:resourceType="acs/components/pages/undergrad">' . "\n";
	print OUTFILE '<mainPar' . "\n";
	print OUTFILE 'jcr:primaryType="nt:unstructured"' . "\n";
	print OUTFILE 'sling:resourceType="foundation/components/parsys">' . "\n";
	} elsif ($headings =~ m/<h2>(.*)<\/h2>/) {
	print OUTFILE '<pullquotes' . "\n";
	print OUTFILE 'jcr:lastModifiedBy="admin"' . "\n";
	print OUTFILE 'jcr:primaryType="nt:unstructured"' . "\n";
	print OUTFILE 'sling:resourceType="acs/components/general/pullquotes"' . "\n";
	print OUTFILE 'text="' . $1 . '"' . "\n";
	print OUTFILE 'textIsRich="true"/>' . "\n";
	} elsif ($headings =~ m/<h3>(.*)<\/h3>/) {
			$text = '&lt;h3>' . "$1" . '&lt;/h3>' . "\n";
			push(@TextArray,$text);
	} elsif ($headings =~ m/<h4>(.*)<\/h4>/) {
			$text = '&lt;h4>' . "$1" . '&lt;/h4>' . "\n";
			push(@TextArray,$text);
	} elsif ($headings =~ m/<h5>(.*)<\/h5>/) {
			$text = '&lt;h5>' . "$1" . '&lt;/h5>' . "\n";
			push(@TextArray,$text);
	} elsif ($headings =~ m/<h6>(.*)<\/h6>/) {
			$text = '&lt;h6>' . "$1" . '&lt;/h6>' . "\n";
			push(@TextArray,$text);
	} 	
 }
 
  sub CheckPar {
    $paragraph = $_[0];
  	if ($paragraph =~ m/<p>(.*)<\/p>/) {
		if($1=~/^\s*$/){
		} else {
			$text = '&lt;p>' . "$1" . '&lt;/p>' . "\n";
			push(@TextArray,$text);
		}
 	} 	
 }
 
   sub CheckBlock {
     $span = $_[0];
   	if ($span =~ m/<span class=\"(.*)\">/) {
		if ($1 =~ m/image-right/) {
		$span =~ s/</&lt;/g;        $span =~ s/br \/>//g;   
		$text = '<textimage';
		push(@RightArray,$text);
		$cssclass = 'cq:cssClass="image_left"';
		push(@RightArray,$cssclass);
		push(@RightArray,'jcr:primaryType="nt:unstructured"');
		push(@RightArray,'sling:resourceType="acs/components/general/textimage"');
		push(@RightArray,'style="Normal"');
		push(@TextImageArray, 'text="');  # only for text images
		} else {
		# would have an image left??????
		}
		return "imagestart";
  	} 	elsif ($span =~ m/<\/span>/) {
			return "imagefinish"; 
		}
  	elsif   ($span =~ m/<ul>/) {
		$span =~ s/</&lt;/g;        
		$span =~ s/br \/>//g;   
		push(@ListArray,$span);
		return "liststart";
  	} elsif ($span =~ m/<\/ul>/) {
		$span =~ s/</&lt;/g;       
		$span =~ s/br \/>//g;   
	    push(@ListArray,$span);
  	return "listfinish"; 
	} 
	 	elsif   ($span =~ m/<ol>/) {
		$span =~ s/</&lt;/g;        
		$span =~ s/br \/>//g;   
		push(@ListArray,$span);
		return "liststart";
  	} elsif ($span =~ m/<\/ol>/) {
		$span =~ s/</&lt;/g;       
		$span =~ s/br \/>//g;   
	    push(@ListArray,$span);
  	return "listfinish"; 
	}
	else {
	return "miss";
	}
 }
 
 sub ImageFooter {
 		push(@TextImageArray, '"');  
		push(@TextImageArray, 'textisRich="true">'); # close off text image array
		push(@RightArray,@TextImageArray);
		@TextImageArray = ();
		push(@RightArray,@ImageArray);
				@ImageArray = ();
		push(@RightArray,'</textimage>');
		}
 
 sub CreateContentHeader {
   	    	 open (MYFILE, ">$outfile");
  	    	 print MYFILE '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
  	    	 print MYFILE '<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0" xmlns:cq="http://www.day.com/jcr/cq/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0" xmlns:mix="http://www.jcp.org/jcr/mix/1.0" xmlns:nt="http://www.jcp.org/jcr/nt/1.0"' . "\n";
  	    	 print MYFILE '    jcr:primaryType="cq:Page">' . "\n";
  	    	 print MYFILE '    <jcr:content' . "\n";
			 print MYFILE ' cq:designPath="/etc/designs/undergrad"'  . "\n";
			 print MYFILE '         cq:lastModifiedBy="admin"' . "\n";
			 print MYFILE '		cq:template="/apps/acs/template/undergrad"' . "\n";
			 print MYFILE '		jcr:isCheckedOut="{Boolean}true"' . "\n";
			 print MYFILE '		jcr:mixinTypes="[mix:versionable]"' . "\n";
			 print MYFILE '		jcr:primaryType="cq:PageContent"' . "\n";
			close (MYFILE); 
}