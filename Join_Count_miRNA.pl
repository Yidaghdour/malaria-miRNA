#!/usr/bin/perl -w
use strict;
########################################################
#Objective: Read The folder containing oasis output and #
#           merge all the data based on Sample name.   #
#           Consider only Files with ending names    #
#           'allspeciesCounts.txt'                 #
###################################################


my $DIR= $ARGV[0];    ## OASIS OUTPUT FOLDER 
my $Consoildate_Output="$DIR/Consolidated.txt";


opendir DIR,"$DIR";
my @files =readdir(DIR);
closedir(DIR);


my $Sample_Count=0;
my %Info=(); my @ALL_Sam=();
foreach my $File(sort @files)
{
	next if($File!~/^\s*.*_allspeciesCounts.txt$/); # Consider only specific Files
	$Sample_Count++; my $Sam_Name=$1 if($File=~/^\s*(.*)_R1_allspeciesCounts.txt/);  ## Retrive sample name
	print "$File\t$Sam_Name\n";
	open HN,"<$DIR/$File";
	while(<HN>)
	{
		chomp;
		my($ID,$Count)=(split "\t",$_)[0,1];
		if(defined $Info{$ID}{$Sam_Name})
		{
			print "$ID already in $Sam_Name\n"; exit;
		}
		else
		{
			$Info{$ID}{$Sam_Name}=$Count;
		}
	}
	close HN;
	push(@ALL_Sam,$Sam_Name);
	#last;
}

print "\nTotal Sample Considered:$Sample_Count\n\n";

open HNS,">$Consoildate_Output";

print HNS"ID";
foreach my $Sample(sort @ALL_Sam)
{
		print HNS"\t$Sample";
}
print HNS"\n";

foreach my $ID(sort keys %Info)
{
	print HNS"$ID";
	foreach my $Sample(sort @ALL_Sam)
	{
		if(defined $Info{$ID}{$Sample})
		{
                	print HNS"\t$Info{$ID}{$Sample}";
		}
		else
		{
			print HNS"\t0";
		}
	}
	print HNS"\n";

}

close HNS;
