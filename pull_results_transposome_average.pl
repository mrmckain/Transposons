#!/usr/bin/env perl -w
use strict;

my @dir;
open my $file, "<", $ARGV[0];
while(<$file>){
	chomp;
	push (@dir, $_);
}
my %values;
my %types;
my %count_for_avg;
my %variance;
for my $dir_s (@dir){
	chdir($dir_s);
my @files = <*out/*log.txt>;
my $total_counts=0;
CHECK: for my $file (@files){
		$file =~ /(.*?)_transposome_(\d+)_out/;
		my $name = $1;
		my $counter=$2;
		my $name_short =$name;
		my %total_values;
		$name=$name."_".$counter;
		open my $tfile, "<", $file;
		while(<$tfile>){
			if($total_counts == 100){
				last CHECK;
			}
			chomp;
			if(/Results/){

                                if(/Repeat fraction from clusters:/){
                                        /Repeat fraction from clusters:\s+(.*?)$/;

                                        $values{$name}{Clusters}+=$1;

                                }
                                if(/Singleton repeat fraction:/){
                                        /Singleton repeat fraction:\s+(.*?)$/;
                                       my $per;
                                        if(!$1 || $1 eq ''){
                                                $per ="0.00";
                                        }
                                        else{
                                                $per = $1;
                                        }
                                        $values{$name}{Singleton}+=$per;

                                }

                                if(/Total repeat fraction:/){
                                        /Total repeat fraction:\s+(.*?)$/;

                                        $values{$name}{Total}+=$1;
                                }

                                if(/Total repeat fraction from annotations:/){
                                        /Total repeat fraction from annotations:\s+(.*?)$/;

                                        $values{$name}{Annotations}+=$1;
                                }
				$total_counts++;

                        }	
		}


}
chdir("../");
}
open my $out, ">", $ARGV[1] . "_TE_total_results_average.txt";
#open my $out2, ">", $ARGV[1] . "_TE_annotation_results_stdev.txt";
print $out "Species\tClustered_Repeats\tSingleton_Repeats\tTotal_Repeats\tAnnotated_Repeats\n";
for my $id (sort keys %values){
                if(!exists $values{$id}{Annotations}){
                        $values{$id}{Annotations} = "NA";
                }
		my $tcl = ($values{$id}{Clusters}/100);
		my $ts = ($values{$id}{Singleton}/100);
		my $tot = ($values{$id}{Total}/100);
		my $ann= ($values{$id}{Annotations}/100);
		print $out "$id\t$tcl\t$ts\t$tot\t$ann\n";
}
