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
my @Begin = ();
my @Images = ();
my @ListArray = ();
my @TextArray = ();
my @MainPar = ();
my @TextImageArray = ();
my @ImageArray = ();
my @FullArray = ();
my @MultiPar = (); # array of paragraphs
my $i = "0";
my $text0 = "false";
$outfile = 'c:\acs\SA\.content.xml';
my $imagearray = "false";
my $listarray = "false";
my $paraSpan= "false";
 &CreateContentHeader;
 open (MYARTICLE, 'C:\acs\SA\content\acs\meetings\expositions\CNBP_028491');
 while (<MYARTICLE>) {
 	chomp;
  if ($_ =~ m/<p>(.*)<\/p>/) {
	if($1=~/^\s*$/){
	next;
	}
	}
 	my $block = &CheckBlock($_); # used to check for images and lists for now
 	
 	if ($block eq "BEGINIMAGE" ) {
 		$imagearray = "true";
 		next;
 	}
 	if ($block eq "imagefinish" ) {
 		$imagearray = "false";
		push(@{$MultiPar[$i]}, @TextImageArray);
		push(@{$MultiPar[$i]}, '"' . "\n");
		push(@{$MultiPar[$i]}, 'textisRich="true">'  . "\n");
		push(@{$MultiPar[$i]}, @ImageArray);
		push(@{$MultiPar[$i]}, "ENDIMAGE");
 		next;
 	}	
 	if ($block eq "liststart" ) {
 		$listarray = "true";
 		next;
 	}
 	if ($block eq "listfinish" ) {
 		$listarray = "false";
		push(@TextArray,@ListArray);
		$i++;
		push(@{$MultiPar[$i]}, "BEGINLIST");
		push(@{$MultiPar[$i]}, @ListArray);
		push(@{$MultiPar[$i]}, "ENDLIST");
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
                push(@ImageArray,'    alt="ALT"');
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
		 if ($paraSpan eq "PARASPANTRUE") {
		 	  $paraSpan = &CheckPar($_);
			  next;
		}
		 CheckHeadings($_);
		$paraSpan = &CheckPar($_);

 }
 close (MYARTICLE);

 ######  loops   ######	

 open (MYFILE, ">$outfile");
 print MYFILE  '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
 print MYFILE  '<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0" xmlns:cq="http://www.day.com/jcr/cq/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0" xmlns:mix="http://www.jcp.org/jcr/mix/1.0" xmlns:nt="http://www.jcp.org/jcr/nt/1.0"' . "\n";
  print MYFILE  'jcr:primaryType="cq:Page">' . "\n";
 $k = 0;
for $j (0 .. $#MultiPar ) {
	#print " $j and $k  in beginnning \n";
	
	if ( $MultiPar[$j][$k] eq "BEGINTITLE") {
				push(@Begin, '<jcr:content');
			 push(@Begin, '         cq:lastModifiedBy="admin"');
			 push(@Begin, '		cq:template="/apps/acs/template/undergrad"');
			# push(@Begin, '		cq:template="/apps/acs/templates/acsArticle"');
			 push(@Begin, '		jcr:isCheckedOut="{Boolean}true"');
			 push(@Begin, '		jcr:mixinTypes="[mix:versionable]"');
			 push(@Begin, '		jcr:primaryType="cq:PageContent"');
				for $k ( 1 .. $#{$MultiPar[$j]} ) {
				if ( $MultiPar[$j][$k] eq "ENDTITLE" ) {
				} else {
				push(@Begin, " $MultiPar[$j][$k]")
				}
			}
	} elsif ( $MultiPar[$j][$k] eq "BEGINTEXT") {
			$textcounter = 'text_' . "$j";
			push(@MainPar,  '<' . $textcounter  . "\n");
			push(@MainPar,    'jcr:primaryType="nt:unstructured"'  . "\n");
			push(@MainPar,    'sling:resourceType="acs/components/general/text"'  . "\n");
            push(@MainPar,    'border="Normal"' . "\n");
            push(@MainPar,    'round="Normal"' . "\n");
            push(@MainPar,    'style="Normal"' . "\n");
			push(@MainPar,    'text="');
			for $k ( 1 .. $#{$MultiPar[$j]} ) {
				if ( $MultiPar[$j][$k] eq "ENDTEXT" ) {
				push(@MainPar, 'textIsRich="true">' . "\n");
				push(@MainPar, '</' . $textcounter . '>' . "\n");
				} else {
				# print "$j $k   here here    $MultiPar[$j][$k] \n";
				push(@MainPar, " $MultiPar[$j][$k]" . '"' . "\n")
				}
			}
	} elsif ($MultiPar[$j][$k] eq "BEGINLIST") {
			$textcounter = 'text_' . "$j";
			push(@MainPar,  '<' . $textcounter  . "\n");
			push(@MainPar,    'jcr:primaryType="nt:unstructured"'  . "\n");
			push(@MainPar,    'sling:resourceType="acs/components/general/text"'  . "\n");
            push(@MainPar,    'border="Normal"' . "\n");
            push(@MainPar,    'round="Normal"' . "\n");
            push(@MainPar,    'style="Normal"' . "\n");
			push(@MainPar,    'text="');
			for $k ( 1 .. $#{$MultiPar[$j]} ) {
				if ($MultiPar[$j][$k] eq "ENDLIST" ) {
				# print "hit end text \n";
				push(@MainPar, '"' . "\n");
				push(@MainPar, 'textIsRich="true">' . "\n");
				push(@MainPar, '</' . $textcounter . '>' . "\n");
				} else {
				# print "$j $k   here here    $MultiPar[$j][$k] \n";
				push(@MainPar, " $MultiPar[$j][$k]" . "\n")
				}
			}	
	}	elsif ($MultiPar[$j][$k] eq "BEGINIMAGE") {
            push(@Images,    '<rightPar' . "\n");
			push(@Images,    ' jcr:primaryType="nt:unstructured"' . "\n");
			push(@Images,    ' sling:resourceType="foundation/components/parsys">'  . "\n");		
			for $k ( 1 .. $#{$MultiPar[$j]} ) {
				if ($MultiPar[$j][$k] eq "ENDIMAGE" ) {
				push(@Images, '</textimage>' . "\n");
				push(@Images, '</rightPar>' . "\n");
				} else {
				push(@Images, " $MultiPar[$j][$k]" . "\n")
				}
			}	
	}
}


#####  below for diagnostics
for $j (0 .. $#MultiPar ) {
			for $k ( 1 .. $#{$MultiPar[$j]} ) {

			   print "$j $k     $MultiPar[$j][$k] \n";
				}
			}

####  begin the build of the file
foreach (@Begin) {
 # print "$_\n";
   print MYFILE $_ . "\n";
} # begin body
 #  print MYFILE '<articleContent' . "\n";  
   print MYFILE '<mainPar' . "\n";  
   print MYFILE 'jcr:primaryType="nt:unstructured"' . "\n";
   print MYFILE 'sling:resourceType="foundation/components/parsys">' . "\n";
 foreach (@MainPar) {
 # print "$_\n";
   print MYFILE $_ ;
} # end text paragraphs in main body
   # print MYFILE '</articleContent>' . "\n";
	  print MYFILE '</mainPar>' . "\n";
	# this is always assuming right paragraph  will need to break out into right and other
 foreach (@Images) {
 # print "$_\n";
   print MYFILE $_ ;
}
####  end it 
 print MYFILE '</jcr:content>' . "\n";
 #print MYFILE "image.jpg \n";
print MYFILE '</jcr:root>' . "\n";
close (MYFILE);
#############  end  ################	
 sub CheckHeadings {
   $headings = $_[0];
 	if ($headings =~ m/<h1>(.*)<\/h1>/) {
			$i++;
	push(@{$MultiPar[$i]}, "BEGINTITLE");
 	$new = 'jcr:title="' . $1 . '"' . "\n"; #set H1 to title
	push(@{$MultiPar[$i]}, $new);
	# push(@{$MultiPar[$i]}, 'sling:resourceType="acs/components/pages/acsArticle">');
	push(@{$MultiPar[$i]}, 'sling:resourceType="acs/components/pages/undergrad">');
	push(@{$MultiPar[$i]}, "ENDTITLE");
	$i++;
	} elsif ($headings =~ m/<h2>(.*)<\/h2>/) {
			$text = '&lt;h2>' . "$1" . '&lt;/h2>';
			$i++;
			push(@{$MultiPar[$i]}, "BEGINTEXT");			
			push(@{$MultiPar[$i]}, $text);
			push(@{$MultiPar[$i]}, "ENDTEXT");
	} elsif ($headings =~ m/<h3>(.*)<\/h3>/) {
			$text = '&lt;h3>' . "$1" . '&lt;/h3>';
			$i++;
			push(@{$MultiPar[$i]}, "BEGINTEXT");	
			push(@{$MultiPar[$i]}, $text);
			push(@{$MultiPar[$i]}, "ENDTEXT");
	} elsif ($headings =~ m/<h4>(.*)<\/h4>/) {
			$text = '&lt;h4>' . "$1" . '&lt;/h4>';
			$i++;
			push(@{$MultiPar[$i]}, "BEGINTEXT");	
			push(@{$MultiPar[$i]}, $text);
			push(@{$MultiPar[$i]}, "ENDTEXT");
	} elsif ($headings =~ m/<h5>(.*)<\/h5>/) {
			$text = '&lt;h5>' . "$1" . '&lt;/h5>';
			$i++;
			push(@{$MultiPar[$i]}, "BEGINTEXT");	
			push(@{$MultiPar[$i]}, $text);
			push(@{$MultiPar[$i]}, "ENDTEXT");
	} elsif ($headings =~ m/<h6>(.*)<\/h6>/) {
			$text = '&lt;h6>' . "$1" . '&lt;/h6>';
			$i++;
			push(@{$MultiPar[$i]}, "BEGINTEXT");	
			push(@{$MultiPar[$i]}, $text);
			push(@{$MultiPar[$i]}, "ENDTEXT");
	} 	
 }
 
  sub CheckPar {
    $paragraph = $_[0];
	if ($paragraph =~ m/<p>/) {
		if ($paragraph =~ m/<p>(.*)<\/p>/) {
			if($1=~/^\s*$/){
			} else {
			$i++;
			$middle = $1;
			$middle =~ s/</&lt;/g;       
			$middle =~ s/br \/>//g;   
			$text = '&lt;p>' . "$middle" . '&lt;/p>' . "\n";
			push(@{$MultiPar[$i]}, "BEGINTEXT");
			push(@{$MultiPar[$i]}, $text);
			push(@{$MultiPar[$i]}, "ENDTEXT");
			return "PARASPANFALSE";
			}
		} else {
		$i++;
		$paragraph = m/<p>(.*)/ ;
		$middle = $1;
		$middle =~ s/</&lt;/g;       
		$middle =~ s/br \/>//g; 
		push(@{$MultiPar[$i]}, "BEGINTEXT");
				push(@{$MultiPar[$i]}, $middle);	
		return "PARASPANTRUE";
			}
	} elsif ($paragraph =~ m/(.*)<\/p>/) {
		$middle = $1;
		$middle =~ s/</&lt;/g;       
		$middle =~ s/br \/>//g; 
		push(@{$MultiPar[$i]}, $middle);
		push(@{$MultiPar[$i]}, "ENDTEXT");
		$i++;
		return "PARASPANFALSE";
	} else {
		$paragraph =~ s/</&lt;/g;       
		$paragraph =~ s/br \/>//g; 
		push(@{$MultiPar[$i]}, $paragraph);	
		return "PARASPANTRUE";
	}
 }
 ####

 ####
   sub CheckBlock {
     $span = $_[0];
   	if ($span =~ m/<span class=\"(.*)\">/) {
		if ($1 =~ m/image-right/) {
	    $i++	;
		$span =~ s/</&lt;/g;       
		$span =~ s/br \/>//g;   
		$text = '<textimage';
		push(@{$MultiPar[$i]}, "BEGINIMAGE");
		push(@{$MultiPar[$i]}, $text);
		$cssclass = 'cq:cssClass="image_left"';
		push(@{$MultiPar[$i]}, $cssclass);
		push(@{$MultiPar[$i]}, 'jcr:primaryType="nt:unstructured"');
		push(@{$MultiPar[$i]}, 'sling:resourceType="acs/components/general/textimage"');
		push(@{$MultiPar[$i]},'style="Normal"');
		push(@{$MultiPar[$i]}, 'text="');
		} else {
		# would have an image left??????
		}
		return "BEGINIMAGE";
  	} 	elsif ($span =~ m/<\/span>/) {
			return "imagefinish"; 
		}
  	elsif   ($span =~ m/<ul>/) {
			if ($span =~ m/<ul>(.*)<\/ul>/) {
			
			$span = $1;
			$span =~ s/</&lt;/g;        
			$span =~ s/br \/>//g;   
			print "\n $span  here I am steve \n";
			push(@ListArray,$1);
			return "listfinish"; 
			}
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
 

 
 sub CreateContentHeader {
  	    	 push(@{$MultiPar[$i]}, '<?xml version="1.0" encoding="UTF-8"?>' . "\n");
					 
}