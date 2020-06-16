#!/usr/bin/perl -w
use strict;
use File::Basename;
#################################################################################################################
#Objective: Filter the Consolidated TPM file clustered based on experimental condition. Satisfying		#
#1) if the TPM is present in 50% in ALL experimental condition							#
#2) if the TPM is present in 50% in any one of the experimental condition					#
#3) if the TPM is present in 10 Samples in ALL experimental condition						#
#4) if the TPM is present in 10 Samples in any one of the experimental condition				#
#################################################################################################################

my $INPUT=$ARGV[0]; ### Consolidated TPM Files
my $Minimum_TPM=1;
my $Minimum_PC=50;
my $Minimum_Count=10;

my($name,$path,$suffix) = fileparse($INPUT);
my $FilterCount_PC=0; my $FilterCount_MC=0;

#my $OUT="$path/Filter_TPM_$name";
my $OUT="Filter_TPM_$name";
system("mkdir -p $OUT");


####### Writing Out put Files 

open (HNS,">$OUT/$name\_Filter_MimimumTPM_$Minimum_TPM\_$Minimum_PC\_PC_AnyVisit.txt") || die "Cannot create file File1!!\n\n"; 	# Objective:2
open (HNS2,">$OUT/$name\_Filter_MimimumTPM_$Minimum_TPM\_$Minimum_Count\_Samples_AnyVisit.txt") || die "Cannot create File2 !!\n\n";    # Objective:4
open (HNS3,">$OUT/$name\_Filter_MimimumTPM_$Minimum_TPM\_$Minimum_Count\_Samples_ALLVisit.txt")|| die "Cannot create File3 !!\n\n";     # Objective:3
open (HNS4,">$OUT/$name\_Filter_MimimumTPM_$Minimum_TPM\_$Minimum_PC\_PC_ALLVisit.txt") || die "Cannot create file File4!!\n\n";	# Objective:1




my($Filtered,$Filtered2,$FilteredC,$FilteredC2)=(0,0,0,0);

open (STAT,">$OUT/$name\_STAT.txt") || die "Cannot create STAT file\n\n"; ### Writing Stats  
print STAT "ARG:perl $0 $INPUT\nInfile:$INPUT\n\nMimimum_TPM:$Minimum_TPM\n%Samples To be percentage:$Minimum_PC\nFilter2: minimum number of samples:$Minimum_Count\n\n";
print STAT "\nAny: Criteria set had fullfiled in either V1/V2/V3/V4 \nAll: Criteria set had fullfiled in all V1/V2/V3/V4 \n\n";
my $SI=0;
sleep(10);

open HN,"<$INPUT";
while(<HN>)
{
	chomp;
	my $Flag_Count=0;
	my $Count=0;
	if($SI>0)
	{
		my ($ID,$locus,@info)=(split "\t",$_);

		my @V1=splice(@info,0,64);
                my @V2=splice(@info,0,29);
                my @V3=splice(@info,0,94);
                my @V4=splice(@info,0,99);

		my $V1Count=scalar(@V1);                my $V2Count=scalar(@V2);                my $V3Count=scalar(@V3);                my $V4Count=scalar(@V4);

                my($V1F,$V2F,$V3F,$V4F)=(0,0,0,0);
                foreach my $In(@V1){$V1F++ if($In>=$Minimum_TPM)}
                foreach my $In(@V2){$V2F++ if($In>=$Minimum_TPM)}
                foreach my $In(@V3){$V3F++ if($In>=$Minimum_TPM)}
                foreach my $In(@V4){$V4F++ if($In>=$Minimum_TPM)}

		if((($V1F/$V1Count*100>=$Minimum_PC))||(($V2F/$V2Count*100>=$Minimum_PC))||(($V3F/$V3Count*100>=$Minimum_PC))||(($V4F/$V4Count*100>=$Minimum_PC)))
                {
                        print HNS"$_\n";
                        $Filtered++;
                }
		
		if((($V1F/$V1Count*100>=$Minimum_PC))&&(($V2F/$V2Count*100>=$Minimum_PC))&&(($V3F/$V3Count*100>=$Minimum_PC))&&(($V4F/$V4Count*100>=$Minimum_PC)))
                {
                        print HNS4"$_\n";
                        $Filtered2++;
                }

                if((($V1F>=$Minimum_Count))||(($V2F>=$Minimum_Count))||(($V3F>=$Minimum_Count))||(($V4F>=$Minimum_Count)))
                {
                        print HNS2"$_\n";
                        $FilteredC++;
                }

                if((($V1F>=$Minimum_Count))&&(($V2F>=$Minimum_Count))&&(($V3F>=$Minimum_Count))&&(($V4F>=$Minimum_Count)))
                {
                        print HNS3 "$_\n";
                        $FilteredC2++;
                }
		


	}
	else
	{
		print HNS"$_\n";
		print HNS2"$_\n";
		print HNS3"$_\n";
		print HNS4"$_\n";
	}
	$SI++;
}

close HN;
close HNS;
close HNS2;
close HNS3;

print STAT"Number of Genes:".($SI-1)."\nNumber of Genes Cleared Filter(% $Minimum_PC Samples Any Visit) :$Filtered\n";
print STAT"Number of Genes Cleared Filter(% $Minimum_PC Samples ALL Visit) :$Filtered2\n";
print STAT"\nNumber of Genes Cleared Filter($Minimum_Count Samples in any Visit):$FilteredC\n";
print STAT"\nNumber of Genes Cleared Filter($Minimum_Count Samples in all Visit):$FilteredC2\n";
close STAT;


