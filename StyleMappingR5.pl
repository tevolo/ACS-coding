#!c:/strawberry/perl/bin/perl.exe 
  use HTML::TokeParser;
  use HTML::Element;
  use HTML::TreeBuilder;
  use warnings;
  use File::Copy;
  use File::Basename;
  use File::Find;
$ArtTitle = "";
my $dir = 'C:\acs\SA\content\acs';
# my $articlefile =   'C:\Temp3\temp files for coding\scripts\CTP_004425';
my $path = 'c:\temp\\';
$doccounter = 0;
$pdfcounter = 0;
$othercounter = 0;
find(\&isArticle, $dir);
sub isArticle
{
    if ($_ =~ m/.*_\d*/) {
    $articlefile = $_;
    $outputfilename = basename($articlefile);
    $articleList = 'c:\acs\articleMetaShort.txt';
    &Stripping($articlefile);
    ($ArtTitle,$URL,$Ext) = FindMeta($articleList,$outputfilename);
    $outputfile = $path . $URL;
		if ($Ext eq "doc" or $Ext eq "docx") {
		$doccounter++;
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



##########			Begin Stellent2CQ	##########
sub Stellent2CQ {
##### arrays #####
@MainPar = ();
@Final = ();
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
if ($spanhit eq "true") {
	if ($_ =~ m/<\/span>/) {
	$spanhit = "false" ;
	next;
	} else {
	next;
	}
}

 ###   print "$_ \n";
    
##########			check for header

if ($_ =~ m/<h[1-6]>(.*)<\/h[1-6]>/) {
	# print "\n $_ \n";
	$output = & get_h($filename);
	$i++; ##### iterate if we have found a head tag
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
	next;
}


##########			end header check

##########			check for paragraph

if ($_ =~ m/<p>/) {
	# print "\n $j   $_  \n";
	$output = & get_par($filename);
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
	$j++; ##### iterate if we have found a para tag
	$a++;
	next;
}

##########			end pragraph check

##########			check for lists  #######  need to add check for ol too!!!!!!

if ($_ =~ m/<ul>/) {
	#print "\n $_ \n";
	$output = & get_list($filename);
	$output =~  s/<br \/>//g;
	#print "\n" . 'text="' . $output  . '"' .  "\n";
	push(@MainPar,'list="' . $output . '"');
	$k++; ##### iterate if we have found a list tag
	$a++;
	next;
}

##########			end list check

##########			check for block quote

if ($_ =~ m/<blockquote>/) {
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
	$a++;
	next;
}

##########			end block quote

if ($_ =~ m/<span class="image-right">/) {
	#print "\n $_ \n";
	$output = & get_spanclassR($filename);
	$m++; ##### iterate if we have found a span image right
	$a++;
	$output =~  s/<br \/>//g;
	#print "\n" . 'iamge-right="' . $output . '"' . "\n";
	push(@MainPar,'image="' . $output . '"');
	$spanhit = "true";
	next;
}

##########			end span right

if ($_ =~ m/<span class="image-left">/) {
	#print "\n $_ \n";
	$output = & get_spanclassL($filename);
	$n++; ##### iterate if we have found a span image left
	$a++;
	$output =~  s/<br \/>//g;
	#print "\n" . 'image-left="' . $output . '"' . "\n";
	push(@MainPar,'image="' . $output . '"');
	$spanhit = "true";
	next;
}

##########			end span left

if ($_ =~ m/<span class="image-center">/) {
	#print "\n $_ \n";
	$output = & get_spanclassL($filename);
	$p++; ##### iterate if we have found a span image center
	$a++;
	$output =~  s/<br \/>//g;
	#print "\n" . 'image-left="' . $output . '"' . "\n";
	push(@MainPar,'image="' . $output . '"');
	$spanhit = "true";
	next;
}

##########			end span left

if ($_ =~ m/table>/) {
	#print "\n $_ \n";
	$output = & get_table($filename);
	$n++; ##### iterate if we have found a table
	$a++;
	$output =~  s/<br \/>//g;
	#print "\n" . 'table="' . $output . '"' . "\n";
	push(@MainPar,'image="' . $output . '"');
	next;
}

##########			end span left

# print " I did not match anything $_ \n ";

 } ######### 			end main while loop	##########
 
 
##########			loop thorugh arrays 	##########    
&CreateContentHeader;
&BuildIt();
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
 		 if ($parent and $parent->tag eq 'span') {
 		  $real_pars = $pars[$j++];
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
  open (INFILE, "$_[0]") or warn " cant open $_[0] \n";
  $outfile = "c:\\temp\\stripping";
  open (OUTFILE, ">$outfile");
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
  copy("$outfile","$_[0]");
  $/ = $Z;
}

sub BuildIt {

 foreach (@MainPar) {
 	 print MYOUTFILE $_ . "\n";
 }
 
 } # end build it
 
  sub CreateContentHeader {
  	    	 print MYOUTFILE '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
  	    	 print MYOUTFILE '<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0" xmlns:cq="http://www.day.com/jcr/cq/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0" xmlns:mix="http://www.jcp.org/jcr/mix/1.0" xmlns:nt="http://www.jcp.org/jcr/nt/1.0"' . "\n";
  	    	 print MYOUTFILE '    jcr:primaryType="cq:Page">' . "\n";
  	    	 print MYOUTFILE '    <jcr:content' . "\n";
			 print MYOUTFILE ' cq:designPath="/etc/designs/undergrad"'  . "\n";
			 print MYOUTFILE '         cq:lastModifiedBy="admin"' . "\n";
			 print MYOUTFILE '		cq:template="/apps/acs/template/undergrad"' . "\n";
			 print MYOUTFILE '		jcr:isCheckedOut="{Boolean}true"' . "\n";
			 print MYOUTFILE '		jcr:mixinTypes="[mix:versionable]"' . "\n";
			 print MYOUTFILE '		jcr:primaryType="cq:PageContent"' . "\n";
			 print MYOUTFILE '		jcr:title="' . $ArtTitle . '"' . "\n";
}
			 
sub FindMeta {
# print " $_[0] and $_[1] this is what was passed \n ";
my $list = $_[0];
	local $/; #Enable 'slurp' mode
	open my $fh, "<", "$list";
	$content = <$fh>;
	close $fh;
	@ArtData  = split('},', $content);
		for my $elem (@ArtData) {
	#   print $elem . "\n";
		$elem =~ m/([A-Za-z0-9]*_\d*?)":{ "Type":"Article","Title":"(.*)?","Web Extension":"([A-Za-z]*)?","WebSiteSection":"PublicWebSite:\d*/;
		
			if ($_[1] eq $1) {
			#print "match $1 $2 and lowly  $3 \n";
			$extension = $3;
			$title = $2;
			$url = $2;
			$title =~ s/:|\///g;
			# print " this is athens and a url $url \n";
			$url =~ s/\s+/_/g;
			$url2 = $url;
			$url2 =~ s/:|\///g;
			# print " this is sparta and a url $url \n";
			
			last;
			}
		}
		print " returning $_[1]  $title, $url2, $extension \n";
	return ($title, $url2, $extension);
	}

	print " doc  $doccounter pdf  $pdfcounter other  $othercounter \n" ;