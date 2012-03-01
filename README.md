DRISEE: Duplicate Read Inferred Sequencing Error Estimation
===

Contributors: Kevin Keegan, William Trimble, Jared Wilkening, Andreas Wilke, Travis Harrison, Mark D'souza, & Folker Meyer


DESCRIPTION
===

DRISEE is a tool that utilizes artifactual duplicate reads (ADRs) to provide a platform independent assessment 
of sequencing error in metagenomic (or genomic) sequencing data.  DRISEE is designed to consider shotgun data.
Currently, it is not appropriate for amplicon data. 


REQUIREMENTS
===

System:
---
A unix environment ( Unix / Linux / OSX / Darwin / Cygwin / etc. ) 
DRISEE was developed to run on multicore Unix systems, but can be run on a desktop or laptop. DRISEE has been run on several OSX based systems.

Software:
---
- perl 5.12.1 or later (http://www.perl.org/get.html)
- python 2.6 or later (http://python.org/getit/)
		with biopython (http://biopython.org/wiki/Biopython)
- uclust (http://www.drive5.com/uclust/downloads1_2_15.html)
- cdbfasta & cdbyank (http://sourceforge.net/projects/cdbfasta/)


INSTALLATION
===

Download and place the three main "script files" into your folder of choice (listed below).  
A location in your PATH makes the most sense; alternatively, add the location to your PATH. 

       drisee.py           		(the main driving script - a main script file)
       seq_length_stats.py 		(an accessory script - a main script file)
       run_find_steiner.pl 		(an accessory script - a main script file)
       
       DRISEE_requirements_check.sh 	(an accessory script - non-required tool to check for requrements)

You can run DRISEE_requirements_check.sh to perform a simple check that will determine if your 
system has the software requirements listed above.  From a command prompt in the folder containing 
the scripts type: "sh DRISEE_requirements_check.sh" (without the quotes) The script will check to 
see if you have the required software installed.  Note that this check is not version-aware; 
read the output to determine your software versions.  If you meet all 5 requirements, and the 
version numbers for perl and python meet or exceed those listed above, you should be all set to run DRISEE


RUNNING DRISEE
===
DRISEE utilizes three scripts to perform its analyses.  All options and input parameters are passed to 
the main script (drisee.py) which calls the other scripts as needed. Each of the options and input 
parameters are explained below.  Examples of a typical execution are provided further below:
____
USAGE:

	drisee.py [options] input_seq_file output_stat_file_pattern
____
Input/Output summary:

	Input:  fasta/fastq file     (input_seq_file)
	Output: error matrix file(s) (output_stat_file_pattern)
	STDOUT: Runtime summary stats
____
Options:

	--version		show the DRISEE version number

	-h, --help		show help/usage and exit

	-p PROCESSES, --processes=PROCESSES			[default '1']
		Number of processes to use. With this option you can select the number of processers 
		to use on a multiprocessor system. When more than 1 processor is selected, processing 
		of bins of duplicate reads is split among the specified number of processors.

	-t SEQ_TYPE, --seq_type=SEQ_TYPE			[default 'fasta']
		Sequence type: fasta, fastq 
		Specify the type of sequence file; fasta and fastq are the only accepted options

	-f, --no_filter_seq  					[default True]    
		Run sequence filtering, 
		Sequence filtering performs two filtering processes before data are processed. 
		(1) An average and standard deviation is determined for the lengths of all reads.  
		The standard deviation is multiplied by the standard deviation multiplier 
		(option -m STDEV_MULTI below).  The product of this multiplication is added or 
		subtracted to the average sequence length to determine upper and lower bounds for 
		sequence length.  All reads with a length greater than the upper bound, or less than 
		the lower bound, are excluded from analysis. (2) Each remaining read is screened for 
		ambiguous bases ("N"). Reads with that possess a number of ambiguous bases that matches 
		or exceeds the specified limit (see -a AMBIG_MAX below)with -a AMBIG_MAX are excluded 
		from further analysis. NOTE: that by default, no_filter is disabled.  In this state, 
		drisee __will__ perform filtering. Enabling this option will disable filtering 
		(hence the long-option name, "no_filter").

	-r REP_FILE, --replicate_file=REP_FILE[default to calculate replicates]
		List file with sorted indices for replicate bins.  The file has one row for each read: 
		two columns indicating the bin and sequence id for the read 
	
	-d TMPDIR, --tmp_dir=TMPDIR				[default '/tmp']
		Directory for intermediate files (must be full path), 			
		deleted at the end of analysis.

	-l LOGFILE, --log_file=LOGFILE				[default '/dev/null']
		A detailed log of processing related statistics
 
	--no_percent						[default True]         
		Produce second output profile with values presented 			
		as percent per position. Additional output file is				
		named "output_stat_file_pattern".per NOTE: that by default, no_percent is disabled.  In this state, 
		drisee __will__ produce a percent profile. Enabling this option will disable production of
		percent-based profiles (hence the long-option name, "no_pecent").

	--prefix_length=PREFIX					[default 50]
		Prefix length for the identification of bins of ADRs
        
	-s SEQ_MAX, --seq_max=SEQ_MAX				[default 10000000]
		Maximum number of reads to process.  The specified number of reads are randomly 
		selected from the input fasta/fastq.  The remaining reads are 
		excluded from analysis.  It is frequently possible to determine the DRISEE error 
		for a data set using less than the total number of reads.  However; to validate 
		your sample size, it is recommended that you perform DRISEE with a number of different 
		sample sizes.  Make sure that your sample size is large enough not to be affected 
		by stochastic sampling artifacts (i.e. that multiple iterations run at the selected 
		sample size produce the same result.
                        
	-a AMBIG_MAX, --ambig_bp_max=AMBIG_MAX		[default 0]
		Maximum number of ambiguous bases ("N") allowed per read before the read is rejected. 
		Note that inclusion of even a single ambiguous character can dramatically affect 
		multiple sequence alignments of bins of prefix-identical bins.  We recommend exclusion 
		of reads that contain any ambiguous bases.
                       
	-m STDEV_MULTI, --stdev_multiplier=STDEV_MULTI	[default 2.0]
		Multiplier by which the standard deviation in the length of the input reads is 
		multiplied to establish upper and lower bounds for length based read filtering 
		(see -f, --filter_seq) 
                        
	-n READ_MIN, --bin_read_min=READ_MIN			[default 20]
		Minimum number of reads a bin of prefix identical reads must possess for it to be 
		considered in the error calculations
 
	-x READ_MAX, --bin_read_max=READ_MAX			[default 1000]
		Maximum number of reads to process from each bin of prefix identical reads.  We have 
		found that values much smaller than 1000 can lead to stochastic artifacts.  Consideration 
		of more reads is possible, but in our testing, rarely leads to results that are appreciably 
		different from those determined from the default of 1000 reads.  This parameter also 
		always for informal control of bin weighting; no bin is allowed to contribute more than 
		1000 reads to the error calculation (i.e.) exceptionally large bins are not allowed to 
		dominate error calculations.  Reads are randomly selected. 
 
	-b NUM_MAX, --bin_num_max=NUM_MAX			[default 1000]
		Maximum number of prefix bins to process.  Bins of prefix identical reads are randomly 
		selected.  Analyses that consider smaller numbers of bins are more prone to stochastic 
		artifacts.  Those that consider larger numbers of bins rarely lead to results that differ 
		appreciably from those determined from a default selection of 1000 bins.                        

	-i ITER_MAX, --iter_max=ITER_MAX			[default 10]
		In the multiple alignment step (used to generate the consensus sequence for each bin of 
		prefix identical reads), specifies the maximum number of iterations to perform if convergence 
		(convergence = no change in cluster identity over at least CONV_MIN iterations, see below) 
		is not achieved.  In our analysis, bins that require more than 2-3 iterations are exceptionally 
		rare, and usually indicate the presence of ambiguous bases or highly inconsistent sequence content 
		in the non-prefix portion of the reads.
	
	-c CONV_MIN, --converge_min=CONV_MIN			[default 3]
		Minimum number of iterations to identify convergence.  Multiple alignments are iterated until 
		convergence is observed for CONV_MIN consecutive iterations, or when ITER_MAX (see above) has 
		been reached. 
                      
	-v, --verbose 						[default off]
		Write runtime summary stats to STDOUT



EXAMPLES
===

Example command line
---

	(1)> drisee.py my_fasta my_fasta.err # will use all default settings on input fasta file my_fasta
													# primary output (raw output) will be called my_fasta.err
	(2)> drisee.py -v -l log test_fasta2 test_fasta2.err 
													# use the verbose setting to get some basic stats
													# and the log setting to generate a detailed runtime log
	(3)> drisee.py -p 10 -l example_log -v example_fasta example_fasta.drisee_results > verbose_text &
													# run drisee with 10 cpus on the example_file (see below), 
													# printing a log and the stdout text


Example input/output files
---

unzip example_files.zip: This file cotains the following:
	
	example_fasta         		# an example input fasta file       (used for example command line 3 above)
	example_fasta_results 		# example of the raw counts format  (produced from example command line 3 above)
	example_fasta_results.per	# example of the percentage output  (produced from example command line 3 above)
	example_log					# example of the log                (produced from example command line 3 above)


OUTPUT DESCRIPTION
===

DRISEE can produce 2 profile formats, raw counts, and percent per consensus indexed base. 

---
The raw counts output has the following format:

	#       A_err   T_err   C_err   G_err   N_err   X_err   bp_err
	# Raw counts    0.096899        0.000000        0.000000        0.000000        0.000000        0.000000	0.096899
	#       A       T       C       G       N       X       A       T       C       G       N       X
	1       0       0       24      0       0       0       0       0       0       0       0       0
	2       0       0       0       24      0       0       0       0       0       0       0       0
	3       24      0       0       0       0       0       0       0       0       0       0       0
	4       0       24      0       0       0       0       0       0       0       0       0       0
	...
	
The first line     ("A\_err   T\_err ...") contains headers for the summary values. It also also 
indicates the length of the prefix ("prefix_length") used for a given DRISEE analysis.  
Here a 50 base-long prefix was used.

The second line values indicate the various error rates (described below)calculated from the non-prefix 
portion of the reads that have undergone DRISEE analysis. A, T, C, & G_err indicate the A, T, C & G 
substituation rates respectively. N_err indicates the substitution rate for ambiguous base calls - by default 
reads that contain ambiguous base calls are exceluded from DRISEE analysis (Keegan et. al. 2012);
reads with ambiguous bases can be included in analyses if non default parameters are used. 
X\_err indicates the combined insertion/deletion error rate rate bp\_err indicates the total error, 
the sum of A, T, C, G, N, & X _err.

The third line contains headers for the DRISEE raw counts.
The columns labeled as "A, T, C, G, C, X, A, T, C, G, C, X" represent (in order from left to right)
A: bases that match consensus
T: bases that match consensus
C: bases that match consensus
G: bases that match consensus
N: ambiguous bases that match consensus
X: insertion or deletions that match consensus
A: bases that do not match consensus	
T: bases that do not match consensus
C: bases that do not match consensus
G: bases that do not match consensus
N: ambiguous bases that do not match consensus
X: insertion or deletions that do not match consensus

The fourth line ("1       0       0       24      0 ...") indicates the integer counts 
for the match or mismatches described in third line header, for the first position for 
all consideredbins of prefix identical reads.  The fifth line indicates the same information 
for the second position in all considered bins of prefix identical reads etc.  This 
format extends to the end of the file. The example above includes the count data 
for the first 5 bases - as these are part of the 50 base long prefix region, they
are expected to be identical -- all displayed counts correspond to consensus matches.

---
The percentage output has the following format:

	#       A_err   T_err   C_err   G_err   N_err   X_err   bp_err
	# Percent counts        0.096899        0.000000        0.000000        0.000000        0.000000        0.000000        0.096899
	#       A       T       C       G       N       X       A       T       C       G       N       X
	1	0.000000	0.000000	100.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000
	2	0.000000	0.000000	0.000000	100.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000
	3	0.000000	0.000000	100.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000
	4	0.000000	0.000000	0.000000	100.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000
	...

This is similar to the format for the raw output.
The summary header and summary values are identical to those from the raw counts file

Lines 4 on are produced from the the values used to generate the raw output. These are modified
as follows: each row presents indicates counts as the percent of total counts for that row
(i.e. for the indicated seqeunce-indexed postion).
In the example above, the row indexed as "1" has a value of 100 under the first "C" column, indicating
that 100% of considered reads match a consensus "C" at postion 1.  This value is calculated from
the same indexed row (1) in the raw counts that exhibit a raw count of "24" for the same data point. 

See Keegan 2012 (email kkeegan AT anl.gov :: manuscript is currently under review) for more details. 


CHANGELOG
===
This is DRISEE version 1.1 (Feb 2012)


OTHER INFORMATION
===
DRISEE was designed to run on a Unix platform, preferably with access to multiple processors.  
A typical DRISEE analysis using the default parameters specified above takes on the order 
of 10's of minutes to a few hours to complete.  Processing time will vary considerably based 
on the size of the input data file.  DRISEE has been run on OSX machines with a single CPU; 
processing times are generally longer, based largely on the limited capability of such 
machines to perform parallel computation on multiple CPUs.