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
my $dir = 'C:\acs\SA\content\acs\policy';  ## change per env ##
my $path = 'c:\temp\\';
$doccounter = 0;
$pdfcounter = 0;
$othercounter = 0;
$paramatch = 0;
$imagerighthit = "false" ;
$imagelefthit = "false";
$imagecenterhit = "false";
find(\&isArticle, $dir);


sub isArticle
{
    if ($_ =~ m/.*_\d*$/) {
    $articlefile = $_;
    $outputfilename = basename($articlefile);
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
$articletitlePDF = $_[2]; # title from metadata
$filenamePDF = $_[3]; # filename of new pdf
$finalPDF = $outfilePDF . '/' . $filenamePDF . '.pdf';
copy("$filenameStellent","$finalPDF") or warn "Copy failed: $!";
# need to create pdf template for cq 
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
# print "\n \n $outfile \n \n";
$spanhit = "false";
 $a = 0;
 $i = 0;
 $j = 0;
 $k = 0;
 $l = 0;
 $m = 0;
 $n = 0;
 $o = 0;
 $p = 0;
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
	{ $paramatch++;
	# print " match this $paramatch \n";
	}
	next;
	}
}

 ###   print "$_ \n";
    
##########			check for header
#### from below <\/h[1-6]>
if ($_ =~ m/<h[1-6]>(.*)/) {
 print "\n $_ \n";
	$output = & get_h($filename);	
	$a++;
	$textcounter = 'text_' . "$a";
			$output =~ s/</&lt;/g;
			$output =~  s/>/&gt;/g;
			$output =~    s/'/&pos;/g;
			$output =~ s/"/&quot;/g;
	push(@MainPar,  '<' . $textcounter );
	push(@MainPar,    'jcr:primaryType="nt:unstructured"' );
	push(@MainPar,    'sling:resourceType="acs/components/general/text"' );
        push(@MainPar,    'border="Normal"');
        push(@MainPar,    'round="Normal"' );
        push(@MainPar,    'style="Normal"' ); 
	push(@MainPar,'text="' . $output . '"');
	push(@MainPar,'textIsRich="true">' ); 
	push(@MainPar,  '</' . $textcounter  . '>' );
	$i++; ##### iterate if we have found a head tag
	next;
}


##########			end header check

##########			check for paragraph

if ($_ =~ m/<p>/) {
	
	$a++;
	# print "\n $j   $_  \n";
	$output = & get_par($filename);
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
	$output = & get_list($filename);
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
	push(@MainPar,'list="' . $output . '"');
	push(@MainPar,'textIsRich="true">' ); 
	push(@MainPar,  '</' . $listcounter  . '>' );
	$k++; ##### iterate if we have found a list tag

	next;
}

if ($_ =~ m/<ol>/) {
	$a++;
	#print "\n $_ \n";
	$output = & get_list($filename);
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
	push(@MainPar,'list="' . $output . '"');
	push(@MainPar,'textIsRich="true">' ); 
	push(@MainPar,  '</' . $listcounter  . '>' );
	$k++; ##### iterate if we have found a list tag

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
	if ($imagerighthit eq "false") {
		push(@RightPar,'<rightPar');
		push(@RightPar,'jcr:primaryType="nt:unstructured"');
		push(@RightPar,'sling:resourceType="foundation/components/parsys">');
		}
	$imagerighthit = "true";
	#print "\n $_ \n";
	$output = & get_spanclassR($filename);
	$m++; ##### iterate if we have found a span image right
	$a++;
		push(@RightPar,'<textimage' . "_$a");
		push(@RightPar,'cq:cssClass="image_right"');
		push(@RightPar,'jcr:primaryType="nt:unstructured"');
		push(@RightPar,'sling:resourceType="acs/components/general/textimage"');
		push(@RightPar,' style="Normal">');
				$Title = "No Title";
			if ($output =~ m/div class="image-caption"\>(.*)<\/div>/) {
				push(@RightPar,'text="');
				push(@RightPar,"$1" . '"');
				push(@RightPar,'textisRich="true">');
				$Title = $1;
			}
			
		push(@RightPar,'<image' . "_$a");
		push(@RightPar,'jcr:primaryType="nt:unstructured"');
		push(@RightPar,'jcr:title="' . "$Title" . '"');
		push(@RightPar,'sling:resourceType="acs/components/general/image"');
		push(@RightPar,'alt="' . "$Title" . '"');
		
		if ($output =~ m/img border="([0-9]+)?"/) {
			push(@RightPar,'border="' . $1 . '"');
		}
		
		if ($output =~ m/height="([0-9]+)"?/) {
			push(@RightPar,'height="' . $1 . '"');
		}
		if ($output =~ m/width="([0-9]+)"?/) {
		push(@RightPar,'width="' . $1 . '"');
		}
		##### additional variables ########
		 push(@RightPar,'round="rounded"');
         push(@RightPar,'ruleHorizontal="border-bottom"');
        push(@RightPar,'style="box-callout"');
		###################################
		$spanhit = "true";
		$imagefile="blankimage.jpg";
		if ($output =~ m /src="(.*?)"/) {
		$imagefile = basename($1);		
		#   this is where we need to grab the image 
		# push(@RightPar,'image="' . $imagefile . '"');   #### moved lower
	
		my $pwd = cwd();
		my $CMSserver = 'https://wcmscontrib.acs.org';
		my $url2get = $CMSserver . $1; 
		my $image2save =  $pwd . '/'  . $imagefile . '/'  . $imagefile;
		#### my $browser = LWP::UserAgent->new;
		#### my $response = $browser->get( $url2get );
		#### warn "Can't get $url -- ", $response->status_line
		#### unless $response->is_success;
		getstore($url2get, $image2save) or warn 'Unable to get page'; #######################################################################
		$image2save =~ s/C:\/acs\/SA\/content\/acs/\/content\/acs_steve/;
		push(@RightPar,'fileReference="' . $image2save . '"/>');
		push(@RightPar,'</textimage' . "_$a" . '>');
		print "\n  this is url $url2get  $image2save hopefuly it is all I need from image right \n ";	
		}
		next;
}	
##########			end span right

if ($_ =~ m/<span class="image-left">/) {
	if ($imagelefthit eq "false") {
		push(@LeftPar,'<leftPar');
		push(@LeftPar,'jcr:primaryType="nt:unstructured"');
		push(@LeftPar,'sling:resourceType="foundation/components/parsys">');
		}
	$imagelefthit = "true";
	#print "\n $_ \n";
	$output = & get_spanclassL($filename);
	$n++; ##### iterate if we have found a span image left
	$a++;
	
		push(@LeftPar,'<textimage' . "_$a");
		push(@LeftPar,'cq:cssClass="image_left"');
		push(@LeftPar,'jcr:primaryType="nt:unstructured"');
		push(@LeftPar,'sling:resourceType="acs/components/general/textimage"');
		push(@LeftPar,' style="Normal"');
				$Title = "No Title";
			if ($output =~ m/div class="image-caption"\>(.*)<\/div>/) {
				push(@LeftPar,'text="');
				push(@LeftPar,"$1" . '"');
				push(@LeftPar,'textisRich="true">');
				$Title = $1;
			}
			
		push(@LeftPar,'<image' . "_$a");
		push(@LeftPar,'jcr:primaryType="nt:unstructured"');
		push(@LeftPar,'jcr:title="' . "$Title" . '"');
		push(@LeftPar,'sling:resourceType="foundation/components/image"');
		push(@LeftPar,'alt="' . "$Title" . '"');
		
		if ($output =~ m/img border="([0-9]+)?"/) {
			push(@LeftPar,'border="' . $1 . '"');
		}
		
		if ($output =~ m/height="([0-9]+)"?/) {
			push(@LeftPar,'height="' . $1 . '"');
		}
		if ($output =~ m/width="([0-9]+)"?/) {
		push(@LeftPar,'width="' . $1 . '"');
		}

		##### additional variables ########
		 push(@LeftPar,'round="rounded"');
         push(@LeftPar,'ruleHorizontal="border-bottom"');
        push(@LeftPar,'style="box-callout"');
		###################################		
		$spanhit = "true";
		$imagefile="blankimage.jpg";
		if ($output =~ m /src="(.*?)"/) {
		$imagefile = basename($1);		
		#   this is where we need to grab the image 
		# push(@RightPar,'image="' . $imagefile . '"');   #### moved lower
	
		my $pwd = cwd();
		my $CMSserver = 'https://wcmscontrib.acs.org';
		my $url2get = $CMSserver . $1; 
		my $image2save =  $pwd . '/'  . $imagefile . '/'  . $imagefile;
		#### my $browser = LWP::UserAgent->new;
		#### my $response = $browser->get( $url2get );
		#### warn "Can't get $url -- ", $response->status_line
		#### unless $response->is_success;
		getstore($url2get, $image2save) or warn 'Unable to get page'; #######################################################################
		$image2save =~ s/C:\/acs\/SA\/content\/acs/\/content\/acs_steve/;
		push(@LeftPar,'fileReference="' . $image2save . '"/>');
		push(@LeftPar,'</textimage' . "_$a" . '>');
		print "\n  this is url $url2get  $image2save hopefuly it is all I need from image left \n ";	
		}
		next;
}

##########			end span left

if ($_ =~ m/<span class="image-center">/) {
	if ($imagecenterhit eq "false") {
		push(@CenterPar,'<centerPar');
		push(@CenterPar,'jcr:primaryType="nt:unstructured"');
		push(@CenterPar,'sling:resourceType="foundation/components/parsys">');
		}
	$imagecenterhit = "true";
	#print "\n $_ \n";
	$output = & get_spanclassC($filename);
	print " output is $output \n ";
	$o++; ##### iterate if we have found a span image center
	$a++;	
		push(@CenterPar,'<textimage' . "_$a");
		push(@CenterPar,'cq:cssClass="image_center"');
		push(@CenterPar,'jcr:primaryType="nt:unstructured"');
		push(@CenterPar,'sling:resourceType="acs/components/general/textimage"');
		push(@CenterPar,' style="Normal"');
				$Title = "No Title";
			if ($output =~ m/div class="image-caption"\>(.*)<\/div>/) {
				push(@CenterPar,'text="');
				push(@CenterPar,"$1" . '"');
				push(@CenterPar,'textisRich="true">');
				$Title = $1;
			}
			
		push(@CenterPar,'<image' . "_$a");
		push(@CenterPar,'jcr:primaryType="nt:unstructured"');
		push(@CenterPar,'jcr:title="' . "$Title" . '"');
		push(@CenterPar,'sling:resourceType="foundation/components/image"');
		push(@CenterPar,'alt="' . "$Title" . '"');
		
		if ($output =~ m/img border="([0-9]+)?"/) {
			push(@CenterPar,'border="' . $1 . '"');
		}
		
		if ($output =~ m/height="([0-9]+)"?/) {
			push(@CenterPar,'height="' . $1 . '"');
		}
		if ($output =~ m/width="([0-9]+)"?/) {
		push(@CenterPar,'width="' . $1 . '"');
		}
		##### additional variables ########
		 push(@CenterPar,'round="rounded"');
         push(@CenterPar,'ruleHorizontal="border-bottom"');
        push(@CenterPar,'style="box-callout"');
		###################################	
		$spanhit = "true";
		$imagefile="blankimage.jpg";
		if ($output =~ m /src="(.*?)"/) {
		$imagefile = basename($1);		
		#   this is where we need to grab the image 
		# push(@RightPar,'image="' . $imagefile . '"');   #### moved lower
	
		my $pwd = cwd();
		my $CMSserver = 'https://wcmscontrib.acs.org';
		my $url2get = $CMSserver . $1; 
		my $image2save =  $pwd . '/'  . $imagefile . '/'  . $imagefile;
		#### my $browser = LWP::UserAgent->new;
		#### my $response = $browser->get( $url2get );
		#### warn "Can't get $url -- ", $response->status_line
		#### unless $response->is_success;
		getstore($url2get, $image2save) or warn 'Unable to get page'; #######################################################################
		$image2save =~ s/C:\/acs\/SA\/content\/acs/\/content\/acs_steve/;
		push(@CenterPar,'fileReference="' . $image2save . '"/>');
		push(@CenterPar,'</textimage' . "_$a" . '>');
		print "\n  this is url $url2get  $image2save hopefuly it is all I need  \n ";	
		}
		next;
}

##########			end span center

if ($_ =~ m/table>/) {
	#print "\n $_ \n";
	$output = & get_table($filename);
	$n++; ##### iterate if we have found a table
	$a++;
	#print "\n" . 'table="' . $output . '"' . "\n";
	# push(@MainPar,'image="' . $output . '"');
	next;
}

##########			end span left

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
		print " this is the header tag" . $headings. "\n";
      $tree->delete;     # clear memory
      return $headings;
  } # end of header sub
  
        sub get_par {
        my $tree = HTML::TreeBuilder->new;
        $tree->parse_file($_[0]);
        my $paragraph = "";
   		my @pars = $tree->look_down(
  		'_tag', 'p'
  		);
 		 $real_pars = $pars[$j];
 		 my $parent = $real_pars->parent;
		   # print " before $j is j \n";
 		 if ($parent and $parent->tag eq 'span') {
 		  # $real_pars = $pars[$j++];
		  $j = $j + $paramatch;
		  $real_pars = $pars[$j];
		   print " now $j is j and $paramatch is para\n";
 		 }
 		 $real_pars = $pars[$j];
 		 # $paragraph = $real_pars->as_text;  # might be blank
 		 $paragraph = $real_pars->as_HTML;
        $tree->delete;     # clear memory
        return $paragraph;
  } # end of paragraph sub
  
   sub get_list {
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
   		 $real_spans = $sc[$m];
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
          my $spanclass = "";
			my @sc = $tree->look_down('_tag', 'span', 'class', 'image-right');
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
my $xmloutfile = $xmldir . '/' . '.content.xml' ;
print " \n directory $pwd and  $xmloutfile \n \n"; #
  open (XMLFILE, ">$xmloutfile") or warn "something wrong here \n";;
	&CloseTags();
	&CreateContentHeader;
 	foreach (@MainPar) {
			$_ =~ s/&ndash/&#8211;/g; # <!-- en dash, U+2013 ISOpub -->' . "\n";
			$_ =~ s/&mdash/&#8212;/g; #  <!-- em dash, U+2014 ISOpub -->' . "\n";
			$_ =~ s/&lsquo/&#8216;/g; # <!-- left single quotation mark, U+2018 ISOnum -->' . "\n";
			$_ =~ s/&rsquo/&#8217;/g; # <!-- right single quotation mark, U+2019 ISOnum -->' . "\n";
			$_ =~ s/&sbquo/&#8218;/g; # <!-- single low-9 quotation mark,  U+201A NEW -->' . "\n";
			$_ =~ s/&ldquo/&#8220;/g; # <!-- left double quotation mark, U+201C ISOnum -->' . "\n";
			$_ =~ s/&rdquo/&#8221;/g; #<!-- right double quotation mark, U+201D ISOnum -->' . "\n";
			$_ =~ s/&copy/&#169;/g; #<!-- copyright -->' . "\n";
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
			 
sub FindMeta {
			my $extension = "";
			my $title = "";
			my $url = "";
print " $_[0] and $_[1] this is what was passed to findmeta\n ";
my $list = $_[0];
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
			print "match content id $1 title $2 and  ext  $3 \n";
			 $extension = $3;
			 $title = $2;
			 $url = $2;
			$title =~ s/:|\///g;
			print " this is original url  $url \n";
			$url =~ s/\s+/_/g;
			$url2 = $url;
			$url2 =~ s/,|:|\///g; # this is the replacement for titles should probably add all non safe URL encoding characters
			$url3 = $url2;
			 print " this is processed url3 $url3 \n";
			$match = "true";
			last;
			}  
		}
		##### make sure it doesnt exist first and also check extensions for making dir
		if ($extension eq "doc" || $extension eq "docx" || $extension eq "pdf") {
				if(!-e "$url3" && $match eq "true" ) {
				mkpath($url3);
				}
		}
		my $cwd = cwd();
		
		if ($match eq "true") {
		print " returning $_[1]  $title, $url3, $extension  and cwd $cwd\n"; #  can probably do work from here
		return ($title, $url3, $extension, $cwd);
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
}



	print " doc  $doccounter pdf  $pdfcounter other  $othercounter \n" ;