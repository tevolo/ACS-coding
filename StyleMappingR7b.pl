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
$ArtTitle = "";
my $dir = 'C:\acs\SA\content\acs\careers\salaries';  ## change per env ##
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
		$pdfcounter++
		# print " we hae a pdf \n";
		} else {
		print " we have $Ext \n";
		$othercounter++;
		}
    }
	}
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
$filename = $_[0];
$outfile = $_[1];
$articletitle = $_[2];
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

#####  dont double count spans #####
#####  keep track of paragrapgs here   work zone #######################################################
if ($spanhit eq "true") {
	if ($_ =~ m/<\/span>/) {
	$spanhit = "false" ;
	next;
	} else {
	if ($_ =~ m/<p>/)
	{ $paramatch++;
	print " match this $paramatch \n";
	}
	next;
	}
}

 ###   print "$_ \n";
    
##########			check for header

if ($_ =~ m/<h[1-6]>(.*)<\/h[1-6]>/) {
	# print "\n $_ \n";
	$output = & get_h($filename);	
	$a++;
	$output =~  s/<br \/>//g;
	$output =~ s/</&lt;/g;
	$textcounter = 'text_' . "$a";
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
	$output =~  s/<br \/>//g;
	$output =~ s/</&lt;/g;
	$output =~  s/>/&gt;/g;
 #  s/&/&amp;/sig;
	$output =~    s/'/&pos;/g;
	$output =~ s/"/&quot;/g;	
	$textcounter = 'text_' . "$a";
	push(@MainPar,  '<' . $textcounter );
	push(@MainPar,    'jcr:primaryType="nt:unstructured"' );
	push(@MainPar,    'sling:resourceType="acs/components/general/text"' );
        push(@MainPar,    'border="Normal"');
        push(@MainPar,    'round="Normal"' );
        push(@MainPar,    'style="Normal"' ); 
	push(@MainPar,'text="' . $output . '"');
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
	$output =~  s/<br \/>//g;
	$output =~ s/</&lt;/g;
	$output =~  s/>/&gt;/g;
 #  s/&/&amp;/sig;
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
	$output =~  s/<br \/>//g;
	$output =~ s/</&lt;/g;
	$output =~  s/>/&gt;/g;
 #  s/&/&amp;/sig;
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

	$output =~  s/<br \/>//g;
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
	$output =~  s/<br \/>//g;
	
		push(@RightPar,'<textimage' . "_$a");
		push(@RightPar,'cq:cssClass="image_right"');
		push(@RightPar,'jcr:primaryType="nt:unstructured"');
		push(@RightPar,'sling:resourceType="acs/components/general/textimage"');
		push(@RightPar,' style="Normal"');
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
		push(@RightPar,'sling:resourceType="foundation/components/image"');
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
		$imagefile="blankimage.jpg";
		$output =~ m /src="(.*?)"/;
		$imagefile = basename($1);
		mkpath("$imagefile");
		#   this is where we need to grab the image 
		push(@RightPar,'image="' . $imagefile . '"');
		$spanhit = "true";
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
	$output = & get_spanclassR($filename);
	$n++; ##### iterate if we have found a span image left
	$a++;
	$output =~  s/<br \/>//g;
	
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
		$imagefile="blankimage.jpg";
		$output =~ m /src="(.*?)"/;
		$imagefile = basename($1);
		mkpath("$imagefile");
		push(@LeftPar,'image="' . $imagefile . '"');
		$spanhit = "true";
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
	$output = & get_spanclassR($filename);
	$o++; ##### iterate if we have found a span image center
	$a++;
	$output =~  s/<br \/>//g;
	
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

		$imagefile="blankimage.jpg";
		$output =~ m /src="(.*?)"/;
		$imagefile = basename($1);
		mkpath("$imagefile");
		push(@CenterPar,'image="' . $imagefile . '"');
		$spanhit = "true";
		next;
}

##########			end span center

if ($_ =~ m/table>/) {
	#print "\n $_ \n";
	$output = & get_table($filename);
	$n++; ##### iterate if we have found a table
	$a++;
	$output =~  s/<br \/>//g;
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
		# print " this is the header tag" . $headings. "\n";
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
		   print " before $j is j \n";
 		 if ($parent and $parent->tag eq 'span') {
 		  # $real_pars = $pars[$j++];
		  $j = $j + $paramatch;
		  $real_pars = $pars[$j];
		  print " now $j is j and $paramatch is para\n";
 		 }
 		 $real_pars = $pars[$j];
 		 $paragraph = $real_pars->as_text;
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
 	 	print XMLFILE $_ . "\n";
 	}
  	foreach (@RightPar) {
  	# print " right is $_ \n";
  	 	print XMLFILE $_ . "\n";
 	}
  	foreach (@LeftPar) {
  	 	print XMLFILE $_ . "\n";
 	}
  	foreach (@CenterPar) {
  	 	print XMLFILE $_ . "\n";
 	}
	&Footer();
	chdir($pwd);
   print " \n directory $pwd and next  $outfile \n \n"; #  good location for fiding things out
   close (XMLFILE);
 } # end build it
 
  sub CreateContentHeader {
  	    	 print XMLFILE '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
  	    	 print XMLFILE '<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0" xmlns:cq="http://www.day.com/jcr/cq/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0" xmlns:mix="http://www.jcp.org/jcr/mix/1.0" xmlns:nt="http://www.jcp.org/jcr/nt/1.0"' . "\n";
  	    	 # print XMLFILE '    jcr:primaryType="cq:Page"' . "\n";
			 print XMLFILE '    jcr:primaryType="cq:Page">' . "\n";
  	    	 print XMLFILE '    <jcr:content' . "\n";
			 print XMLFILE ' 		cq:template="/apps/acs/templates/acsArticle"'  . "\n";
			 print XMLFILE '      cq:lastModifiedBy="admin"' . "\n";
			 # print XMLFILE '		cq:template="/apps/acs/template/undergrad"' . "\n";
			 print XMLFILE '		jcr:isCheckedOut="{Boolean}true"' . "\n";
			 print XMLFILE '		jcr:mixinTypes="[mix:versionable]"' . "\n";
			 print XMLFILE '		jcr:primaryType="cq:PageContent"' . "\n";
			 print XMLFILE '		jcr:title="' . $ArtTitle . '"' . "\n";
			#  print XMLFILE '		sling:resourceType="acs/components/pages/acsArticle"' ."\n";
			 print XMLFILE '		sling:resourceType="acs/components/pages/acsArticle">' ."\n";
			 print XMLFILE '		<mainPar' ."\n";
			 print XMLFILE '		jcr:primaryType="nt:unstructured"' ."\n";
			 print XMLFILE '		sling:resourceType="foundation/components/parsys">' ."\n";
}
			 
sub FindMeta {
 # print " $_[0] and $_[1] this is what was passed \n ";
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
			# print "match $1 $2 and lowly  $3 \n";
			$extension = $3;
			$title = $2;
			$url = $2;
			$title =~ s/:|\///g;
			# print " this is athens and a url $url \n";
			$url =~ s/\s+/_/g;
			$url2 = $url;
			$url2 =~ s/:|\///g;
			#  print " this is sparta and a url $url \n";
			$match = "true";
			last;
			}  
		}
		mkpath($url2);
		my $cwd = cwd();
		print " returning $_[1]  $title, $url2, $extension  and cwd $cwd\n"; #  can probably do work from here
		if ($match eq "true") {
	return ($title, $url2, $extension, $cwd);
	}
	else {
	return ("miss", "miss", "miss", "miss");
	}
}
sub CloseTags {
	push(@MainPar,'</mainPar>' . "\n");
	
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