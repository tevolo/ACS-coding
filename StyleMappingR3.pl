#!c:/strawberry/perl/bin/perl.exe 
  use HTML::TokeParser;
  use HTML::Element;
  use HTML::TreeBuilder;
  use warnings;
# my $filename = 'C:\acs\SA\content\acs\meetings\expositions\CNBP_028491';
 my $filename =	'C:\acs\SA\content\acs\careers\whatchemistsdo\profiles\CTP_004417';
# my $filename =	'C:\acs\SA\content\acs\careers\whatchemistsdo\profiles\CTP_004425';

$output = & get_h($filename);
$output = & get_h2($filename);
$output = & get_h3($filename);
$output = & get_h4($filename);
$output = & get_h5($filename);
$output = & get_h6($filename);
$output = & get_par($filename);
$output = & get_list($filename);
$output = & get_blockquote($filename);
$output = & get_spanclass($filename);


   sub get_h {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
	  	  my $heading = "";
		my @h1s = $tree->look_down(
		'_tag', 'h1'
		);
			warn "What, no h1s here?" unless @h1s;
			my $real_h1 = $h1s[-1];  # last or only element
			$heading = $real_h1->as_text;
			$tree->delete;     # clear memory
			return $heading;
  }
 
    sub get_h2 {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
	  my $heading2 = "";
		my @h2s = $tree->look_down(
		'_tag', 'h2'
		);
			warn "What, no h2s here?" unless @h2s;
			foreach (@h2s) {
			$real_h2 = $_;  # last or only element
			$heading2 = $real_h2->as_text;
			print " $heading2 \n";
			}
      $tree->delete;     # clear memory
      return $heading2;
  }
  
      sub get_h3 {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
      my $heading3 = "";
		my @h3s = $tree->look_down(
		'_tag', 'h3'
		);
			foreach (@h3s) {
			$real_h3 = $_;  # last or only element
			$heading3 = $real_h3->as_text;
			print " $heading3 \n";
			}
      $tree->delete;     # clear memory
      return $heading3;
  }
  
      sub get_h4 {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
      my $heading4 = "";
		my @h4s = $tree->look_down(
		'_tag', 'h4'
		);
			foreach (@h4s) {
			$real_h4 = $_;  # last or only element
			$heading4 = $real_h4->as_text;
			print " $heading4 \n";
			}
      $tree->delete;     # clear memory
      return $heading4;
  }
  
        sub get_h5 {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
      my $heading5 = "";
		my @h5s = $tree->look_down(
		'_tag', 'h5'
		);
			foreach (@h5s) {
			$real_h5 = $_;  # last or only element
			$heading5 = $real_h5->as_text;
			print " $heading5 \n";
			}
      $tree->delete;     # clear memory
      return $heading5;
  }
  
      sub get_h6 {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
      my $heading6 = "";
		my @h6s = $tree->look_down(
		'_tag', 'h6'
		);
			foreach (@h6s) {
			$real_h6 = $_;  # last or only element
			$heading6 = $real_h6->as_text;
			print " $heading6 \n";
			}
      $tree->delete;     # clear memory
      return $heading6;
  }
  
      sub get_par {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
      my $paragraph = "";
 		my @pars = $tree->look_down(
		'_tag', 'p'
		);
			foreach (@pars) {
			$real_par = $_;  # last or only element
			$paragraph = $real_par->as_HTML;
				if ($paragraph ne '<p>') {
					print " $paragraph \n";
				}
			}
      $tree->delete;     # clear memory
      return $paragraph;
  }
  
 sub get_list {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
      my $list = "";
 		my @ul = $tree->look_down(
		'_tag', 'ul'
		);
			foreach (@ul) {
			$real_ul = $_;  # last or only element
			$list = $real_ul->as_HTML;
			print " $list \n";
			}
      $tree->delete;     # clear memory
      return $list;
  }
  
 sub get_blockquote {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
      my $blockquote = "";
 		my @bq = $tree->look_down(
		'_tag', 'blockquote'
		);
			foreach (@bq) {
			$real_bq = $_;  # last or only element
			$blockquote = $real_bq->as_text;
			print " $blockquote \n";
			}
      $tree->delete;     # clear memory
      return $blockquote;
  }
  
   sub get_spanclass {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse_file($_[0]);
      my $spanclass = "";
 		my @sc = $tree->look_down('_tag', 'span', 'class', 'image-right');
			foreach (@sc) {
			$real_sc = $_;  # last or only element
			$openclass = $real_sc->as_HTML;
			print " $openclass \n";
			}
      $tree->delete;     # clear memory
      return $spanclass;
  }
  