#!/usr/bin/perl;
use strict;
##################################################################
#Objective: Convert FPKM to TPM 				 #
#REFERENCE: https://pubmed.ncbi.nlm.nih.gov/22872506/		#
#################################################################

my $Input_Folder =$ARGV[0];  ## PATH/TO/FPKM/Files
my $File_Formate=".genes.fpkm_tracking"; ## Looking for Files ending

opendir DIR,"$Input_Folder";
my @Files=readdir(DIR);
closedir(DIR);

my $OUT_FOLDER=$Input_Folder."/TPM";
system("mkdir -p $OUT_FOLDER");

my @Samples=(); my %All_Info=();
my %SampleS_Visit=();

foreach my $IN(sort @Files)
{
	next if($IN!~/^\s*.*$File_Formate/);
	my $Sample=$1 if($IN=~/^\s*(\S+)$File_Formate/);
	print "$IN\t$Sample\n";
	if($Sample=~/^\s*(Sample\_PAG\S+)\_(V\d+).*/)
	{
		my ($SampleID,$Visit)=($1,$2);  #### Fetching Sample names and Experimental condition from the file
		if(defined $SampleS_Visit{$Visit})
		{
			$SampleS_Visit{$Visit}.="\t".$Sample;
		}
		else
		{
			 $SampleS_Visit{$Visit}=$Sample;
		}
	}
	my $Counter=0;
	my %Info=(); my $Total_FPKM=0;

	open HN,"<$Input_Folder/$IN";   ### Reading the  cufflink output
	while(<HN>)
	{
		chomp;
		next if(/^\s*tracking_id.*/);

		#print "$_\n";
		my($tracking_id,$class_code,$nearest_ref_id,$gene_id,$gene_short_name,$tss_id,$locus,$length,$coverage,$FPKM,$FPKM_conf_lo,$FPKM_conf_hi,$FPKM_status)=(split "\t",$_);
		
		if(defined $Info{"$tracking_id\t$locus"})
		{
			print "Error : $tracking_id already defined\nChange the key accordingly\n";exit;
		}
		else
		{
			$Info{"$tracking_id\t$locus"}="$nearest_ref_id\t$gene_id\t$gene_short_name\t$tss_id\t$locus\t$length\t$coverage\t$FPKM";
			#print "$FPKM\n";
		}
		$Total_FPKM+=$FPKM;

		$Counter++;
		#last if($Counter==20);
	
	}
	close HN;

	print "Total_FPKM:$Total_FPKM\n";
	
	### Converting FPKM to TPM and creating output file
	open HNS,">$OUT_FOLDER/$Sample\.tpm";
	print HNS"tracking_id\tlocus\tgene_id\tgene_short_name\tTPM\n";
	foreach my $Tracking_ID(keys  %Info)
	{

		my($nearest_ref_id,$gene_id,$gene_short_name,$tss_id,$locus,$length,$coverage,$FPKM)=(split "\t",$Info{$Tracking_ID});
		my $TPM=(($FPKM/$Total_FPKM)*(10**6));
		print HNS"$Tracking_ID\t$gene_id\t$gene_short_name\t$TPM\n";
		$All_Info{$Tracking_ID}{$Sample}=$TPM;

	}
	close HNS;
	##last;


}


#### Create Consolidate TPM clustered per experimental condition
foreach my $Visit(sort keys %SampleS_Visit)
{
	print "$Visit"; my $Visit_Count=0;
	my @Visit_Samples=(split "\t",$SampleS_Visit{$Visit});
	foreach my $Sample(@Visit_Samples)
	{
		push(@Samples,$Sample);
		$Visit_Count++;
	}
	print "\t$Visit_Count\n";

}

open TPM,">$OUT_FOLDER/Consolidated_TPM.txt";
print TPM "tracking_id\tlocus";
foreach my $Sam(@Samples)
{
	print TPM"\t$Sam";
}
print TPM"\n";


foreach my $IN(sort keys %All_Info)
{
	print TPM"$IN";
	foreach my $Sam(@Samples)
	{
		if(defined $All_Info{$IN}{$Sam})
		{
			print TPM"\t$All_Info{$IN}{$Sam}";
		}
		else
		{
			print TPM"\tNA";
		}
	}
	print TPM"\n";
}
