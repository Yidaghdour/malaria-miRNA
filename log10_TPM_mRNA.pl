#!/usr/bin/perl -w
use strict;

my $IN=$ARGV[0];
my $OUT="$IN\_log10.txt";

my $SI=0;
open HN,"<$IN";
open HNS,">$OUT";
while(<HN>)
{
	chomp;
	if($SI>0)
	{
		my($id,$locus,@arr)=(split "\t",$_);
		print HNS"$id\t$locus";
		foreach my $in(@arr)
		{
			$in=log($in+1)/log(10);
			print HNS"\t$in";
		}
		print HNS"\n";

	}
	else
	{
		print HNS"$_\n";
	}
	$SI++;
}
close HN;
close HNS;
