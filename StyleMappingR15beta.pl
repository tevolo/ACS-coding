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
$ArtTitle = "";
my $dir = 'C:\acs\SA\content\acs\global\international';  ## change per env ##
my $path = 'c:\temp\\';
$doccounter = 0;
$pdfcounter = 0;
$othercounter = 0;
$relatedcontent = 0;
$cq5Dir = 'C:\acs\bundles\prodstruct2\jcr_root\content\acs_steve'; # directory to palce files prior to being zipped
$beginningDir = 'C:/acs/SA/content/acs';  ### where the real exported content is to be converted
find(\&isArticle, $dir);
find(\&isXML, $cq5Dir);
find(\&delXML, $cq5Dir);

sub isArticle
{
$paramatch = 0;
$imagerighthit = "false" ;
$imagelefthit = "false";
$imagecenterhit = "false";
 my %PDFhash = ();
 
	 #   if ($_ =~ m/.*_\d*$/ || $_ eq "index.htm") {
    if ($_ =~ m/.*_\d*$/ ) {
    $articlefile = $_;  # article file gets set to a content id and path but possibly not an article
    $outputfilename = basename($articlefile); # content ID
    $articleList = 'C:\acs\articleMetaShort.txt';## change per env ##
  #  &Stripping($articlefile);
    ($ArtTitle,$URL,$Ext,$cwd) = FindMeta($articleList,$outputfilename);
	if ($ArtTitle eq "miss") {
	# next ;
	} else {
    $outputfile = $cwd . '/' . $URL;
		if ($Ext eq "doc" or $Ext eq "docx") {
		$doccounter++;
		&Stripping($articlefile);
		&Stellent2CQ($articlefile,$outputfile,$ArtTitle);
		# print " we have a doc \n"
		} elsif ($Ext eq "pdf") {
		# extract pdf and do some pdf work ###################################################################
		&StellentPDF2CQ($articlefile,$outputfile,$ArtTitle,$URL); # create pdf file 
		$pdfcounter++
		# print " we hae a pdf \n";
		} else {
		# print " we have $Ext \n";
		$othercounter++;
		}
    }
	}
}
##########			Begin StellentPDF2CQ #########
sub StellentPDF2CQ {
$filenameStellent = $_[0]; # stellent filename
$outfilePDF = $_[1]; # this is the formed url directory
$outfilePDF =~ s/$beginningDir/$cq5Dir/;
$articletitlePDF = $_[2]; # title from metadata
$filenamePDF = $_[3]; # filename of new pdf
if (! -d $outfilePDF) {
my $dirs = eval {mkpath($outfilePDF) };
warn " failed to make $outfilePDF \n" unless $dirs;
}
$finalPDF = $outfilePDF . '/' . $filenamePDF . '.pdf';
copy("$filenameStellent","$finalPDF") or warn "Copy failed: $!";

$PDFhash{ $filenameStellent } = $finalPDF;
}
##########			Begin Stellent2CQ	##########
sub Stellent2CQ {
##### arrays #####
@MainPar = ();
@RightPar = ();
@LeftPar = ();
@CenterPar = ();
@Final = ();
@Add2End = ();
##################
$filename = $_[0]; # stellent filename
$outfile = $_[1]; # this is the formed url
$articletitle = $_[2];  # title from metadata
 print "\n filename $filename and outfile $outfile  \n";
$spanhit = "false";
 $a = 0; #master counter
 $i = 0; #h tags
 $j = 0; # par tag
 $k = 0; # unordered list
 $l = 0; # blockquote
 $m = 0; # image right
 $n = 0; # image left 
 $o = 0; # image center
 $p = 0; # table
 $q = 0; # ordered list
 $r = 0; # related content
  open (MYARTICLE, "$filename");
  open (MYOUTFILE, ">>$outfile");
 while (<MYARTICLE>) {
 ##########			 begin cleanup 	##########
 	if($_=~/^\s*$/){
 	next;
 	}
##########			 end cleanup 	##########

#####  dont double or tripple count spans #####
#####  keep track of paragraphs here  #
if ($spanhit eq "true") {
	if ($_ =~ m/<\/span>/) {
	$spanhit = "false" ;
	next;
	} else {
	if ($_ =~ m/<p>/)
	{ $j++;
	# print " match this $paramatch  and paramatch is $paramatch from beginning\n";
	} elsif ($_ =~ m/<ul>/) {
	$k++;
	}
	elsif ($_ =~ m/<ol>/) {
	$q++;
	}
	next;
	}
}

 ###   print "$_ \n";
    
##########			check for header
#### from below <\/h[1-6]>
if ($_ =~ m/<(h[1-6])>(.*)/) {
#  print " this is from h tag  $1 and $2 \n" ;
$HeadingNum = $1;
	$output = & get_h($filename);	
	$a++;
	$output =~ s/</&lt;/g;
	$output =~  s/>/&gt;/g;
	$output =~    s/'/&pos;/g;
	$output =~ s/"/&quot;/g;
	$output =~ s/&lt;h[1-6]&gt;//g;
	$output =~ s/&lt;\/h[1-6]&gt;//g;
if ($HeadingNum eq "h1") {
	$ArtTitle = $output;
	} else
	{
	$textcounter = 'headingtext_' . "$a";

	push(@MainPar,  '<' . $textcounter );
	push(@MainPar,    'jcr:primaryType="nt:unstructured"' );
	push(@MainPar,    'sling:resourceType="acs/components/general/headingtext"' );
        push(@MainPar,    'border="Normal"');
        push(@MainPar,    'round="Normal"' );
        push(@MainPar,    'style="Normal"' ); 
	push(@MainPar,'text="' . $output . '"');
	push(@MainPar,'textIsRich="true"' ); 
	push(@MainPar,'xheadingstyle="' . $HeadingNum . '">' ); 
	push(@MainPar,  '</' . $textcounter  . '>' );
	}
	$i++; ##### iterate if we have found a head tag
	next;
}
##########			end header check

##########			check for paragraph
if ($_ =~ m/<p>/) {
	
	$a++;
	# print "\n $j   $_  \n";
	$output = & get_par($filename);
	# print " \n output is $output and j is $j from para check \n";
			$output =~ s/</&lt;/g;
			$output =~  s/>/&gt;/g;
			$output =~    s/'/&pos;/g;
			$output =~ s/"/&quot;/g;	
	$textcounter = 'text_' . "$a";
	push(@MainPar,  '<' . $textcounter );
	push(@MainPar,    'jcr:primaryType="nt:unstructured"' );
	push(@MainPar,    'sling:resourceType="acs/components/general/text"' );
        push(@MainPar,    'border="Normal"');
        push(@MainPar,    'round="Normal"' );
        push(@MainPar,    'style="Normal"' ); 
	push(@MainPar,'text="' . $output . '&lt;/p&gt;"');
	push(@MainPar,'textIsRich="true">' ); 
	push(@MainPar,  '</' . $textcounter  . '>' );
	$j++; ##### iterate if we have found a para tag
	next;
}
##########			end pragraph check

##########			check for lists  #######  need to add check for ol too!!!!!!
if ($_ =~ m/<ul>/) {
	$a++;
	#print "\n $_ \n";
	$output = & get_list($filename,"unordered");
			$output =~ s/</&lt;/g;
			$output =~  s/>/&gt;/g;
			$output =~    s/'/&pos;/g;
			$output =~ s/"/&quot;/g;
	$listcounter = 'list_' . "$a";
	push(@MainPar,  '<' . $listcounter );
	push(@MainPar,    'jcr:primaryType="nt:unstructured"' );
	push(@MainPar,    'sling:resourceType="acs/components/general/text"' );
    push(@MainPar,    'border="Normal"');
    push(@MainPar,    'round="Normal"' );
    push(@MainPar,    'style="Normal"' ); 
	#print "\n" . 'text="' . $output  . '"' .  "\n";
	push(@MainPar,'text="' . $output . '"');
	push(@MainPar,'textIsRich="true">' ); 
	push(@MainPar,  '</' . $listcounter  . '>' );
	$k++; ##### iterate if we have found a list tag

	next;
}

if ($_ =~ m/<ol>/) {
	$a++;
	#print "\n $_ \n";
	$output = & get_list($filename,"ordered");
			$output =~ s/</&lt;/g;
			$output =~  s/>/&gt;/g;
			$output =~    s/'/&pos;/g;
			$output =~ s/"/&quot;/g;
	$listcounter = 'list_' . "$a";
	push(@MainPar,  '<' . $listcounter );
	push(@MainPar,    'jcr:primaryType="nt:unstructured"' );
	push(@MainPar,    'sling:resourceType="acs/components/general/text"' );
    push(@MainPar,    'border="Normal"');
    push(@MainPar,    'round="Normal"' );
    push(@MainPar,    'style="Normal"' ); 
	#print "\n" . 'text="' . $output  . '"' .  "\n";
	push(@MainPar,'text="' . $output . '"');
	push(@MainPar,'textIsRich="true">' ); 
	push(@MainPar,  '</' . $listcounter  . '>' );
	$q++; ##### iterate if we have found a list tag

	next;
}
##########			end list check

##########			check for block quote

if ($_ =~ m/<blockquote>/) {
	
	$a++;
	#print "\n $_ \n";
	$output = & get_blockquote($filename);
			$output =~ s/</&lt;/g;
			$output =~  s/>/&gt;/g;
			$output =~    s/'/&pos;/g;
			$output =~ s/"/&quot;/g;
	push(@MainPar,'<pullquotes' . "$a");
	push(@MainPar,'jcr:lastModifiedBy="admin"');
	push(@MainPar,'jcr:primaryType="nt:unstructured"');
	push(@MainPar,'sling:resourceType="acs/components/general/pullquotes"');
	push(@MainPar,'text="' . $output . '"');
	push(@MainPar,'<textIsRich="true"/>' . "\n");
	$l++; ##### iterate if we have found a blockquote tag
	next;
}

##########			end block quote

if ($_ =~ m/<span class="image-right">/) {
	if ($relatedcontent == 1) {
	$output = &get_spanclassR($filename,$m);
	$spanhit = "true";
	if ($output =~ m /src="(.*?)"/) {
	&GenericImage($1,"none",$output);
	 #  print "\n  this is filename $filename and output  $output  from image right \n ";	
		}
	$m++; ##### iterate if we have found a span image right
	} else {
	if ($imagerighthit eq "false") {
		push(@RightPar,'<rightPar');
		push(@RightPar,'jcr:primaryType="nt:unstructured"');
		push(@RightPar,'sling:resourceType="foundation/components/parsys">');
		}
		$a++;
	$imagerighthit = "true";
	#print "\n $_ \n";
	$output = &get_spanclassR($filename,$m);	
		push(@RightPar,'<textimage' . "_$a");
		push(@RightPar,'cq:cssClass="image_right"');
		push(@RightPar,'jcr:primaryType="nt:unstructured"');
		push(@RightPar,'sling:resourceType="acs/components/general/textimage"');
		push(@RightPar,' style="Normal">');
		$spanhit = "true";
		if ($output =~ m /src="(.*?)"/) {
		&GenericImage($1,"none",$output);
	 #  print "\n  this is filename $filename and output  $output  from image right \n ";	
		}
		push(@RightPar,'</textimage' . "_$a" . '>');
		$m++; ##### iterate if we have found a span image right
		next;
		}
}	# end of beginning if 
##########			end span right

if ($_ =~ m/<span class="image-left">/) {
	if ($relatedcontent == 1) {
	$output = &get_spanclassL($filename,$n);
	$spanhit = "true";
	if ($output =~ m /src="(.*?)"/) {
	&GenericImage($1,"none",$output);
	 #  print "\n  this is filename $filename and output  $output  from image right \n ";	
		}
	$n++; ##### iterate if we have found a span image right
	} else {
	if ($imagelefthit eq "false") {
		push(@LeftPar,'<leftPar');
		push(@LeftPar,'jcr:primaryType="nt:unstructured"');
		push(@LeftPar,'sling:resourceType="foundation/components/parsys">');
		}
	$imagelefthit = "true";
	#print "\n $_ \n";
	$output = &get_spanclassL($filename);
	$a++;	
		push(@LeftPar,'<textimage' . "_$a");
		push(@LeftPar,'cq:cssClass="image_left"');
		push(@LeftPar,'jcr:primaryType="nt:unstructured"');
		push(@LeftPar,'sling:resourceType="acs/components/general/textimage"');
		push(@LeftPar,' style="Normal">');
		$spanhit = "true";
		if ($output =~ m /src="(.*?)"/) {
		&GenericImage($1,"left",$output);
		#  print "\n  this is url $url2get  $image2save hopefuly it is all I need from image right \n ";	
		}	
		push(@LeftPar,'</textimage' . "_$a" . '>');
		$n++; ##### iterate if we have found a span image left
		next;
		} # end of else
}
##########			end span left
if ($_ =~ m/<span class="image-center">/) {
	if ($relatedcontent == 1) {
	$output = &get_spanclassC($filename,$o);
	$spanhit = "true";
	if ($output =~ m /src="(.*?)"/) {
	&GenericImage($1,"none",$output);
	 #  print "\n  this is filename $filename and output  $output  from image right \n ";	
		}
	$m++; ##### iterate if we have found a span image right
	} else {
	if ($imagecenterhit eq "false") {
		push(@CenterPar,'<centerPar');
		push(@CenterPar,'jcr:primaryType="nt:unstructured"');
		push(@CenterPar,'sling:resourceType="foundation/components/parsys">');
		}
	$imagecenterhit = "true";
	#print "\n $_ \n";
	$output = &get_spanclassC($filename);
	# print " output is $output \n ";	
	$a++;	
		push(@CenterPar,'<textimage' . "_$a");
		push(@CenterPar,'cq:cssClass="image_center"');
		push(@CenterPar,'jcr:primaryType="nt:unstructured"');
		push(@CenterPar,'sling:resourceType="acs/components/general/textimage"');
		push(@CenterPar,' style="Normal">');
		$spanhit = "true";
		$imagefile="blankimage.jpg";
		if ($output =~ m /src="(.*?)"/) {
		&GenericImage($1,"center",$output);
		}
		push(@CenterPar,'</textimage' . "_$a" . '>');
		$o++; ##### iterate if we have found a span image center
		next;
		} # end of else
}

##########			end span center

if ($_ =~ m/table>/) {
	#print "\n $_ \n";
	$output = & get_table($filename);
	$p++; ##### iterate if we have found a table
	$a++;
	#print "\n" . 'table="' . $output . '"' . "\n";
	# push(@MainPar,'image="' . $output . '"');
	next;
}

if ($_ =~ m/<div class="related-content">/) {
$relatedcontent = 1;
$a++;
	$containercounter = 'acscontainer_' . "$a";
	push(@MainPar,  '<' . $containercounter );
	push(@MainPar,    'jcr:primaryType="nt:unstructured"' );
	push(@MainPar,    'sling:resourceType="acs/components/general/acscontainer"' );
    push(@MainPar,    'border="bordered"');
	push(@MainPar,    'color="box-blue"' );
    push(@MainPar,    'round="rounded"' );
    push(@MainPar,    'style="rbc">' ); 
	#print "\n" . 'text="' . $output  . '"' .  "\n";
	$r++;
	$countainercounterPar = 'containerPar';
	push(@MainPar,  	'<' . $countainercounterPar );
	push(@MainPar,    'jcr:primaryType="nt:unstructured"' );
	push(@MainPar,    'sling:resourceType="foundation/components/parsys">' );
	
    

} # end of related content

if ($_ =~ m/^\s*<\/div>\s*$/ && $relatedcontent == 1) {	
	push(@MainPar,  	'</' . $countainercounterPar  . '>'  );
	push(@MainPar,  '</' . $containercounter  . '>' );	  
	$relatedcontent = 0;
}
                    

# print " I did not match anything $_ \n ";

 } ######### 			end main while loop	##########
 
 
##########			loop thorugh arrays 	##########    

&BuildIt();
&CloseTags();
close(MYOUTFILE);
close(MYARTICLE);
} # end Stellent2CQ    
##################################################################    
#######################    subs   ################################   
##################################################################
    
    sub get_h {
       my $tree = HTML::TreeBuilder->new;
       $tree->parse_file($_[0]);
 	  	  my $headings = "";
 		my @heads = $tree->find_by_tag_name(
 		'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
 		);
 		$real_heads = $heads[$i];
 		$headings = $real_heads->as_HTML;
		## print " this is the header tag" . $headings. "\n";
      $tree->delete;     # clear memory
      return $headings;
  } # end of header sub
  
        sub get_par {
		# print " \n now in get_par this was j $j_prime \n ";
        my $tree = HTML::TreeBuilder->new;
        $tree->parse_file($_[0]);
        my $paragraph = "";
   		my @pars = $tree->look_down(
  		'_tag', 'p'
  		);
 		 $real_pars = $pars[$j];
 		 my $parent = $real_pars->parent;
		 ##  print " before $j is j before paramatch is added in get_par\n";
 		 $real_pars = $pars[$j];
 		 # $paragraph = $real_pars->as_text;  # might be blank
 		 $paragraph = $real_pars->as_HTML;
        $tree->delete;     # clear memory
        return $paragraph;
  } # end of paragraph sub
  
   sub get_list {
   if ($_[1] eq "unordered") {
        my $tree = HTML::TreeBuilder->new;
        $tree->parse_file($_[0]);
        my $list = "";
   		my @ul = $tree->look_down(
  		'_tag', 'ul'
  		);
 		$real_lists = $ul[$k];
 		$list = $real_lists->as_HTML;
        $tree->delete;     # clear memory
        return $list;
	} else {
		my $tree = HTML::TreeBuilder->new;
        $tree->parse_file($_[0]);
        my $list = "";
   		my @ol = $tree->look_down(
  		'_tag', 'ol'
  		);
 		$real_lists = $ol[$q];
 		$list = $real_lists->as_HTML;
        $tree->delete;     # clear memory
        return $list;
		}
    } # end sub list
    
   sub get_blockquote {
        my $tree = HTML::TreeBuilder->new;
        $tree->parse_file($_[0]);
        my $blockquote = "";
   		my @bq = $tree->look_down(
  		'_tag', 'blockquote'
  		);
 		$real_blocks = $bq[$l];
 		$blockquote = $real_blocks->as_HTML;
        $tree->delete;     # clear memory
        return $blockquote;
    } # end sub block quote
    
     sub get_spanclassL {
        my $tree = HTML::TreeBuilder->new;
        $tree->parse_file($_[0]);
        my $spanclass = "";
   		my @sc = $tree->look_down('_tag', 'span', 'class', 'image-left');
   		 $real_spans = $sc[$n];
		#####  lets try and capture all the wonderful errors #######################################################
					use Scalar::MoreUtils qw(empty);
				if(not empty($real_spans)) {
				$spanclass = $real_spans->as_HTML;
				$tree->delete;     # clear memory
				return $spanclass;
				} else {
				print "we have an error $_[0] need to add it to some list \n";
				return $spanclass;
				}
  } # end class span
  
       sub get_spanclassR {
          my $tree = HTML::TreeBuilder->new;
          $tree->parse_file($_[0]);
		  my $n = $_[1];
          my $spanclass = "";
			my @sc = $tree->look_down('_tag', 'span', 'class', 'image-right');
			$real_spans = $sc[$m];
			# print " from getclassR real span is $real_spans and n is $n \n";
			#####  lets try and capture all the wonderful errors #######################################################
					use Scalar::MoreUtils qw(empty);
				if(not empty($real_spans)) {
				$spanclass = $real_spans->as_HTML;
				$tree->delete;     # clear memory
				return $spanclass;
				} else {
				print "we have an error $_[0] need to add it to some list \n";
				return $spanclass;
				}
			
  } # end class span
     sub get_spanclassC {
        my $tree = HTML::TreeBuilder->new;
        $tree->parse_file($_[0]);
        my $spanclass = "";
   		my @sc = $tree->look_down('_tag', 'span', 'class', 'image-center');
   		 $real_spans = $sc[$p];
		#####  lets try and capture all the wonderful errors #######################################################
					use Scalar::MoreUtils qw(empty);
				if(not empty($real_spans)) {
				$spanclass = $real_spans->as_HTML;
				$tree->delete;     # clear memory
				return $spanclass;
				} else {
				print "we have an error $_[0] need to add it to some list \n";
				return $spanclass;
				}
  } # end class span 
 
         sub get_table {
            my $tree = HTML::TreeBuilder->new;
            $tree->parse_file($_[0]);
            my $table = "";
       		my @tbl = $tree->look_down(
       		'_tag', 'table'
  		);
   		$real_tables = $tbl[$o];
   		$table = $real_tables->as_HTML;
            $tree->delete;     # clear memory
            return $table;
  } # end class table
  
  sub Stripping {
  $Z = $/;
  undef $/;
  print " infile $_[0] \n";
  open (INFILE, "$_[0]") or warn " cant open $_[0] \n";
  $stripfile = "c:\\temp\\stripping";
  open (OUTFILE, ">$stripfile");
  while (<INFILE>)
  {
  
  #take out the various site studio comments
  s/<!--SS_BEGIN_SNIPPET.*?-->//sig;
  s/<!-- SS_BEGIN_SNIPPET\(.*?-->//sig;
  s/<!--SS_END_SNIPPET.*?-->//sig;
  s/<!-- SS_END_SNIPPET.*?-->//sig;
  s/<!--SS_BEGIN_CLOSEREGIONMARKER.*?-->//sig;
  s/<!--SS_BEGIN_CLOSEREGIONMARKER\(.*?-->//sig;
  s/<!--SS_END_CLOSEREGIONMARKER.*?-->//sig;
  s/<!--SS_END_CLOSEREGIONMARKER\(.*?-->//sig;
  s/<!--SS_BEGIN_OPENREGIONMARKER.*?-->//sig;
  s/<!--SS_BEGIN_OPENREGIONMARKER\(.*?-->//sig;
  s/<!--SS_END_OPENREGIONMARKER.*?-->//sig;
  s/<!--SS_END_OPENREGIONMARKER\(.*?-->//sig;
  s/<!--SS_BEGIN_ELEMENT.*?-->//sig;
  s/<!--SS_END_ELEMENT.*?-->//sig;
  s/<COMMENT>//sig;
  s/<\/COMMENT>/""/sig;
  
  #trim white space
  #s/[\t]{1,}?//sig;
  #s/[ ]{2,}?//sig;
  # s/ \n//sig;
  #s/[\n]{3,}?//sig;
  #s/[ ]+</</sig;
  
  #strip out empty paragraphs
  s/<p> <\/p>//sig;
  
  # another palce I will try and replace xml characters
  			$_ =~ s/&ndash/&#821;/gi; # <!-- en dash, U+2013 ISOpub -->' . "\n";
			$_ =~ s/&mdash/&#8212/gi; #  <!-- em dash, U+2014 ISOpub -->' . "\n";
			$_ =~ s/&lsquo/&#8216/gi; # <!-- left single quotation mark, U+2018 ISOnum -->' . "\n";
			$_ =~ s/&rsquo/&#8217/gi; # <!-- right single quotation mark, U+2019 ISOnum -->' . "\n";
			$_ =~ s/&sbquo/&#8218/gi; # <!-- single low-9 quotation mark,  U+201A NEW -->' . "\n";
			$_ =~ s/&ldquo/&#8220/gi; # <!-- left double quotation mark, U+201C ISOnum -->' . "\n";
			$_ =~ s/&rdquo/&#8221/gi; #<!-- right double quotation mark, U+201D ISOnum -->' . "\n";
			$_ =~ s/&copy/&#169/gi; #<!-- copyright -->' . "\n";
			$_ =~ s/&oacute/&#243/gi; #<-- unknown -->
			$_ =~ s/&nbsp/&#160/gi; #<-- nonbreaking space -->
			$_ =~ s/&pound/&#163/gi; #<-- pound  -->
			$_ =~ s/&eacute/&#201/gi; #<-- latin e -->
			$_ =~ s/&iacute/&#205/gi; #<-- latin i -->
			$_ =~ s/&ntilde/&#209/gi; #<-- latin n -->
			
			
  # strip out breaks
  s/<br \/>//sig;
  

  
  $new = $_; #set variable $new to replaced string
  print OUTFILE $new; #print out replaced string
  }
   close (INFILE) or warn $!;
   close (OUTFILE) or die $!;
  copy("$new","$_[0]");
  $/ = $Z;  
}

sub BuildIt {
my $pwd = cwd();
my $xmldir = $outfile;
$xmldir =~ s/$beginningDir/$cq5Dir/;
my $xmloutfile = $xmldir . '/' . '.content.xml' ;
print " \n directory $pwd and  $xmloutfile \n \n"; #
  open (XMLFILE, ">$xmloutfile") or warn "something wrong here \n";;
	&CloseTags();
	&CreateContentHeader;
 	foreach (@MainPar) {
			$_ =~ s/&ndash/&#821;/gi; # <!-- en dash, U+2013 ISOpub -->' . "\n";
			$_ =~ s/&mdash/&#8212/gi; #  <!-- em dash, U+2014 ISOpub -->' . "\n";
			$_ =~ s/&lsquo/&#8216/gi; # <!-- left single quotation mark, U+2018 ISOnum -->' . "\n";
			$_ =~ s/&rsquo/&#8217/gi; # <!-- right single quotation mark, U+2019 ISOnum -->' . "\n";
			$_ =~ s/&sbquo/&#8218/gi; # <!-- single low-9 quotation mark,  U+201A NEW -->' . "\n";
			$_ =~ s/&ldquo/&#8220/gi; # <!-- left double quotation mark, U+201C ISOnum -->' . "\n";
			$_ =~ s/&rdquo/&#8221/gi; #<!-- right double quotation mark, U+201D ISOnum -->' . "\n";
			$_ =~ s/&copy/&#169/gi; #<!-- copyright -->' . "\n";
			$_ =~ s/&oacute/&#243/gi; #<-- unknown -->
			$_ =~ s/&nbsp/&#160/gi; #<-- nonbreaking space -->
			$_ =~ s/&pound/&#163/gi; #<-- pound  -->
			$_ =~ s/&eacute/&#201/gi; #<-- latin e -->
			$_ =~ s/&iacute/&#205/gi; #<-- latin i -->
			$_ =~ s/&aacute/&#193/gi; #<-- latin a -->
			$_ =~ s/&ntilde/&#209/gi; #<-- latin n -->
			$_ =~ s/&uacute/&#218/gi; #<-- latin u -->
			$_ =~  s/<br \/>//g;
							
 	 	print XMLFILE '				' . $_ . "\n";
 	}
  	foreach (@RightPar) {
  	# print " right is $_ \n";
  	 	print XMLFILE '					' . $_ . "\n";
 	}
  	foreach (@LeftPar) {
  	 	print XMLFILE  '				' .  $_ . "\n";
 	}
  	foreach (@CenterPar) {
  	 	print XMLFILE  '				' .  $_ . "\n";
 	}
	&Footer();
	chdir($pwd);
   print " \n directory $pwd and next  $outfile \n \n"; #  good location for fiding things out
   close (XMLFILE);
 } # end build it
 #############################################  start header #######################################################################
  sub CreateContentHeader {
  			$ArtTitle =~ s/&ndash/&#821;/gi; # <!-- en dash, U+2013 ISOpub -->' . "\n";
			$ArtTitle =~ s/&mdash/&#8212/gi; #  <!-- em dash, U+2014 ISOpub -->' . "\n";
			$ArtTitle =~ s/&lsquo/&#8216/gi; # <!-- left single quotation mark, U+2018 ISOnum -->' . "\n";
			$ArtTitle =~ s/&rsquo/&#8217/gi; # <!-- right single quotation mark, U+2019 ISOnum -->' . "\n";
			$ArtTitle =~ s/&sbquo/&#8218/gi; # <!-- single low-9 quotation mark,  U+201A NEW -->' . "\n";
			$ArtTitle =~ s/&ldquo/&#8220/gi; # <!-- left double quotation mark, U+201C ISOnum -->' . "\n";
			$ArtTitle =~ s/&rdquo/&#8221/gi; #<!-- right double quotation mark, U+201D ISOnum -->' . "\n";
			$ArtTitle =~ s/&copy/&#169/gi; #<!-- copyright -->' . "\n";
			$ArtTitle =~ s/&oacute/&#243/gi; #<-- unknown -->
			$ArtTitle =~ s/&nbsp/&#160/gi; #<-- nonbreaking space -->
			$ArtTitle =~ s/&pound/&#163/gi; #<-- pound  -->
			$ArtTitle =~ s/&eacute/&#201/gi; #<-- latin e -->
			$ArtTitle =~ s/&aacute/&#193/gi; #<-- latin a -->
			$ArtTitle =~ s/&iacute/&#205/gi; #<-- latin i -->
			$ArtTitle =~ s/&ntilde/&#209/gi; #<-- latin n -->
			$ArcTitle =~ s/&uacute/&#218/gi; #<-- latin u -->
			
  	    	 print XMLFILE '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
  	    	 print XMLFILE '<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0" xmlns:cq="http://www.day.com/jcr/cq/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0" xmlns:mix="http://www.jcp.org/jcr/mix/1.0" xmlns:nt="http://www.jcp.org/jcr/nt/1.0"' . "\n";
			 print XMLFILE '     jcr:primaryType="cq:Page">' . "\n";
  	    	 print XMLFILE '     <jcr:content' . "\n";
			 print XMLFILE ' 		cq:template="/apps/acs/templates/acsArticle"'  . "\n";
			 print XMLFILE '      	cq:lastModifiedBy="admin"' . "\n";
			 print XMLFILE '		jcr:isCheckedOut="{Boolean}true"' . "\n";
			 print XMLFILE '		jcr:mixinTypes="[mix:versionable]"' . "\n";
			 print XMLFILE '		jcr:primaryType="cq:PageContent"' . "\n";
			 print XMLFILE '		jcr:title="' . $ArtTitle . '"' . "\n";
			 print XMLFILE '		sling:resourceType="acs/components/pages/acsArticle">' ."\n";
			 print XMLFILE '		<articleContent' ."\n";
			 print XMLFILE '		jcr:primaryType="nt:unstructured"' ."\n";
			 print XMLFILE '		sling:resourceType="foundation/components/parsys">' ."\n";
			 


}
sub GenericImage {
	$imagefile="blankimage.jpg";
	$Title = "title";
	$imagelink = $_[0];
	$imagefile = basename($_[0]);
	$Placement = $_[1];
	my $output = $_[2];
	# print " from Generic Image filename is $_[0] and placement is $Placement \n";
		push(@Array,'<image' . "_$a");
		push(@Array,'jcr:primaryType="nt:unstructured"');
		push(@Array,'jcr:title="' . "$Title" . '"');
		push(@Array,'sling:resourceType="acs/components/general/image"');
		push(@Array,'alt="' . "$Title" . '"');
		
		if ($output =~ m/img border="([0-9]+)?"/) {
			push(@Array,'border="' . $1 . '"');
		}
		
		if ($output =~ m/height="([0-9]+)"?/) {
			push(@Array,'height="' . $1 . '"');
		}
		if ($output =~ m/width="([0-9]+)"?/) {
		push(@Array,'width="' . $1 . '"');
		}
		##### additional variables ########
		 push(@Array,'round="rounded"');
         push(@Array,'ruleHorizontal="border-bottom"');
        push(@Array,'style="box-callout"');		
		#   this is where we need to grab the image 
		# push(@Array,'image="' . $imagefile . '"');   #### moved lower
	
		my $pwd = cwd();
		my $CMSserver = 'https://wcmscontrib.acs.org';
		my $url2get = $CMSserver . $imagelink; 
		my $image2save =  $pwd . '/'  . $imagefile . '/'  . $imagefile;
		$image2save =~ s/$beginningDir/$cq5Dir/;  #### just added 8/16
		 my $browser = LWP::UserAgent->new;
		 my $response = $browser->get( $url2get );
		 warn "Can't get $url2get -- ", $response->status_line
		 unless $response->is_success;
		 print " this is the url to get from generic image $url2get and image save place $image2save\n";
		 $image_stub = dirname("$image2save");
		 
		 if (!-d $image_stub) {
		 mkpath("$image_stub");
		 }
		getstore($url2get, $image2save) or warn 'Unable to get page $image2store'; #######################################################################
		$image2save =~ s/C:\\acs\\bundles\\prodstruct2\\jcr_root//;
		$image2save =~ s/\\/\//g;
			if ($output =~ m/div class="image-caption"\>(.*)<\/div>/) {
				push(@Array,'fileReference="' . $image2save . '"');
				push(@Array,'text="' . $1 . '"');
				push(@Array,'textisRich="true">');
				$Title = $1;
			} else {
			push(@Array,'fileReference="' . $image2save . '"/>');
			}
			if ($Placement eq "right") {
			push(@RightPar,@Array);
			} elsif ($Placement eq "left") {
			push(@LeftPar,@Array);
			} 	elsif ($Placement eq "center") {
			push(@CenterPar,@Array);
			}	else {
			push(@MainPar,@Array);	
			}
			@Array = ();
}
			 
sub FindMeta {
			my $extension = "";
			my $title = "";
			my $url = "";
print " $_[0] and $_[1] this is what was passed to findmeta\n ";
my $list = $_[0]; # list of all metadata on one line
	local $/; #Enable 'slurp' mode
	open my $fh, "<", "$list";
	$content = <$fh>;
	close $fh;
	@ArtData  = split('},', $content);
		my $match = "false";
		for my $elem (@ArtData) {
	#   print $elem . "\n";
		$elem =~ m/([A-Za-z0-9]*_\d*?)":{ "Type":"Article","Title":"(.*)?","Web Extension":"([A-Za-z]*)?","WebSiteSection":"PublicWebSite:\d*/;
		
			if ($_[1] eq $1) {
			# print "match content id $1 title $2 and  ext  $3 \n";
			 $extension = $3;
			 $title = $2;
			 $url = $2;
			$title =~ s/:|\///g;
			# print " this is original url  $url from find meta \n";
			$url =~ s/\s+/_/g;
			$url2 = $url;
			$url2 =~ s/,|\?|&|:|\\|"|\///g; # this is the replacement for titles should probably add all non safe URL filesystem encoding characters
			$url3 = $url2;
			#  print " this is processed url3 $url3 from find meta \n";
			$match = "true";
			last;
			}  
		}
		##### make sure it doesnt exist first and also check extensions for making dir
		if ($extension eq "doc" || $extension eq "docx" || $extension eq "pdf") {
				$url4 = cwd() . '\\' . $url3;			
				$url4 =~ s/$beginningDir/$cq5Dir/;
				if(!-e "$url4" && $match eq "true" ) {
				mkpath($url4);
				}
				
				
		}
		my $cwd = cwd();
		
		if ($match eq "true") {
		print " returning $_[1]  $title, $url3, $extension  and cwd $cwd\n"; #  can probably do work from here
		return ($title, $url3, $extension, $cwd);
	}	elsif ($_[1] eq "index.htm") {
	return ($_[1], "index.html", "doc", $cwd);
	}
	else {
	print "miss here so nothing should get done in sub findmeta \n";
	return ("miss", "miss", "miss", "miss");
	}
}
sub CloseTags {
	push(@MainPar,'</articleContent>' . "\n");
	
	if ($imagerighthit eq "true") {
		push(@RightPar,'</rightPar>');
	}
	if ($imagelefthit eq "true") {
		push(@LeftPar,'</leftPar>');
	}
	if ($imagecenterhit eq "true") {
		push(@CenterPar,'</centerPar>');
	}

}


sub Footer {
  	    	 print XMLFILE '</jcr:content>' . "\n";
  	    	 	foreach $folder (@Add2End) {
  	    	 		 print XMLFILE '<' . "$folder" . '/>'  . "\n";
  	    	 	}
  	    	 	
		 print XMLFILE '</jcr:root>';
$imagerighthit = "false" ;
$imagelefthit = "false";
$imagecenterhit = "false";
$sum = $i + $j + $k + $l + $m + $n + $o + $p + $q;
print " \n total is $a and sum is $sum \n";

} # end footer

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



  for my $key ( keys %PDFhash ) {
        my $value = $PDFhash{$key};
         print "$key => $value\n";
    }


	print " doc  $doccounter pdf  $pdfcounter other  $othercounter \n" ;