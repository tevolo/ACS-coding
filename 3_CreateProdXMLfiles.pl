#!c:/Perl/perl/bin/perl.exe
use strict;
use warnings; 
use FileHandle; 
use File::Find qw(find);
use File::Basename;
use File::Copy;
use File::Find;
use Cwd;

##############################
# this file creates the .content.xml
# files needed for cq5 to add content
# using the packages component
# crx/packmgr/index.jsp
##############################

my $BaseDir = 'C:/acs/jcr_root/content/acs/';

  find( \&createContentxml, $BaseDir );
  
  sub createContentxml {
  	if (-d $File::Find::name) {
  		my $dir = $File::Find::name;
  		#  print $dir . ": \n";
  	 	&subdir($dir) ;
  	}
  }
  
  
  sub subdir {
   my $dir2 = getcwd;
  print $dir2 . "\n";
  my $dir = $_[0];
  chdir($dir) or warn " not able to cd into $dir \n";
  print "dir: $dir: \n";
  opendir DH, $dir or die "Failed to open $dir: $!";
  	while ($_ = readdir(DH)) {
  	next if $_ eq "." or $_ eq "..";
  	if (-d $_ ) {
  	print $_ . "\n";
  	  if (-f ".content.xml") {
  	  	open (MYFILE, '>>.content.xml');
  	  	print MYFILE $_ . "\n";
  	  	close (MYFILE); 
  	  } else {
  	    	 open (MYFILE, '>>.content.xml');
  	    	 print MYFILE '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
  	    	 print MYFILE '<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0" xmlns:cq="http://www.day.com/jcr/cq/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0" xmlns:mix="http://www.jcp.org/jcr/mix/1.0" xmlns:nt="http://www.jcp.org/jcr/nt/1.0"' . "\n";
  	    	 print MYFILE '    jcr:primaryType="cq:Page">' . "\n";
  	    	 print MYFILE '    <jcr:content' . "\n";
			 print MYFILE '         cq:lastModifiedBy="admin"' . "\n";
			 print MYFILE '		cq:template="/apps/geometrixx-outdoors/templates/page_home"' . "\n";
			 print MYFILE '		jcr:isCheckedOut="{Boolean}true"' . "\n";
			 print MYFILE '		jcr:mixinTypes="[mix:versionable]"' . "\n";
			 print MYFILE '		jcr:primaryType="cq:PageContent">' . "\n";
    		 print MYFILE  '</jcr:content>' . "\n";
	    	 print MYFILE $_ . "\n";
  	  	close (MYFILE); 
  	  }
  	  	
  	  } else {
  	  next;
  	  }
  	}
  	if (-f ".content.xml") {  	
    		open (MYFILE, '>>.content.xml');
    		print MYFILE  '</jcr:root>' . "\n";
  		close (MYFILE); 
		chdir($dir2);
	} else {
	    open (MYFILE, '>>.content.xml');
	  	print MYFILE '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
	  	print MYFILE '<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0" xmlns:cq="http://www.day.com/jcr/cq/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0" xmlns:mix="http://www.jcp.org/jcr/mix/1.0" xmlns:nt="http://www.jcp.org/jcr/nt/1.0"' . "\n";
	  	print MYFILE '    jcr:primaryType="cq:Page">' . "\n";
	  	print MYFILE '    <jcr:content' . "\n";
		print MYFILE '         cq:lastModifiedBy="admin"' . "\n";
		print MYFILE '		cq:template="/apps/geometrixx-outdoors/templates/page_home"' . "\n";
		print MYFILE '		jcr:isCheckedOut="{Boolean}true"' . "\n";
		print MYFILE '		jcr:mixinTypes="[mix:versionable]"' . "\n";
		print MYFILE '		jcr:primaryType="cq:PageContent">' . "\n";
	    print MYFILE  '</jcr:content>' . "\n";
    	print MYFILE  '</jcr:root>' . "\n";
	  	close (MYFILE); 
	  	chdir($dir2);	
	return 0; # Did not find any subdirectory in this directory
	}
  }
  
 use Archive::Zip;
 #my $zip = Archive::Zip->new();
 #$zip->addTree( 'C:/acs/jcr_root/', 'jcr_root' );
 # $zip->addTree( 'C:/acs/META-INF/', 'META-INF' );
 # $zip->writeToFileNamed('c:/acs/prodstruct.zip');
 
 
  
  
  
  