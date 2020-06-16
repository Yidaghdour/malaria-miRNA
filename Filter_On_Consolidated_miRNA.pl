#!/usr/bin/perl
use strict;
use File::Basename;
################################################################################################################################
#Objective: Filter the miRNA based on the minimum count 10 Read count and least 50% of the samples per experimental condition  #
###############################################################################################################################

my $Consolidated_Count=$ARGV[0]; ## Consolidated Count File with samples clustered to each experimental condition

my $Minimum=10;  ## Minimum_Read;
my $FilterC=50;  ### Minimum % of Samples;

my $Filtered=0;		my $FilteredC=0;	my $FilteredC2=0;


open HNS,">Present_$Minimum\_CountIn_$FilterC\_PercentageSample.txt";

open STAT,">Filter_Statistics.txt";
print STAT "Input:$Consolidated_Count\nMinimum_Read:$Minimum\nMinimum %samples in any visit:$FilterC\\n";

open HN,"<$Consolidated_Count";
my $SI=0;
while(<HN>)
{
	chomp;
	next if(/^\s*$/);
	if($SI>0)
	{
		my($GeneID,@info)=(split "\t",$_);
                my @V1=splice(@info,0,19); ## Samples Belonging To V1. Change numbers as per Visit
                my @V2=splice(@info,0,16); ## Samples Belonging To V2. Change numbers as per Visit
                my @V3=splice(@info,0,19); ## Samples Belonging To V3. Change numbers as per Visit
                my @V4=splice(@info,0,18); ## Samples Belonging To V4. Change numbers as per Visit
		
		my $V1Count=scalar(@V1);		my $V2Count=scalar(@V2);		my $V3Count=scalar(@V3);		my $V4Count=scalar(@V4);

		my($V1F,$V2F,$V3F,$V4F)=(0,0,0,0);
		my($V1FC,$V2FC,$V3FC,$V4FC)=(0,0,0,0);
		foreach my $In(@V1){$V1F++ if($In>=$Minimum);$V1FC+=$In;}
		foreach my $In(@V2){$V2F++ if($In>=$Minimum);$V2FC+=$In;}
		foreach my $In(@V3){$V3F++ if($In>=$Minimum);$V3FC+=$In;}
		foreach my $In(@V4){$V4F++ if($In>=$Minimum);$V4FC+=$In;}

		if((($V1F/$V1Count*100>=$FilterC))||(($V2F/$V2Count*100>=$FilterC))||(($V3F/$V3Count*100>=$FilterC))||(($V4F/$V4Count*100>=$FilterC)))
		{
			print HNS"$_\n";
			$Filtered++;
		}
		
	
	}
	else
	{
		print HNS "$_\n";
	}
	$SI++;

}
close HN;
close HNS;

print STAT "Total Genes:$SI\nFiltered Genes (in $FilterC(%)):$Filtered\n\n";
close STAT;

