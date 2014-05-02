DRISEE: Duplicate Read Inferred Sequencing Error Estimation
===

Contributors: Kevin Keegan, William Trimble, Jared Wilkening, Jared Bischof, Travis Harrison, Andreas Wilke, Mark D'souza, & Folker Meyer


DESCRIPTION
===

DRISEE is a tool that utilizes artifactual duplicate reads (ADRs) to provide a platform independent assessment 
of sequencing error in metagenomic (or genomic) sequencing data.  DRISEE is designed to consider shotgun data.
Currently, it is not appropriate for amplicon data. 


REQUIREMENTS
===

System:
---
A Unix environment ( Unix / Linux / OSX / Darwin / Cygwin / etc. ) 
DRISEE was developed to run on multicore Unix systems, but can be run on a desktop or laptop. DRISEE has been run on several OSX based systems.

Software:
---
- perl 5.12.1 or later (http://www.perl.org/get.html) *1
- python 2.6 or later (http://python.org/getit/)
		with biopython (http://biopython.org/wiki/Biopython) *1
- QIIME and the supporting uclust packages  (http://qiime.org/install/virtual_box.html) *1
- cdbfasta & cdbyank (http://sourceforge.net/projects/cdbfasta/) *1

*1 Please note that users are responsible for making sure that their use of required software
   products is compliant with existing licenses and/or user agreements. A full installation
   procedure for all requirements is provided below.  

FULL INSTALLATION
===

Note: This installation procedure has be tested on multiple ubuntu releases. It has not been rigorously tested on other platforms
---


CHANGE TEMP DIRECTORY TO SOMEPLACE WITH MORE SPACE (May not be necessary for your configuration, 10Gb free for DRISEE to use)

	# first remove the existing temp directory
	sudo rm -rf /tmp
	# create a directory that has more space
	sudo mkdir /mnt/my_temp_dir
	# then create symbolic link to the newly created directory  
	sudo ln -s /mnt/my_temp_dir /tmp
	# open permissions
	sudo chmod -R 777 /mnt/


INSTALL QIIME

	# install pip
	sudo apt-get install python-pip
	# use pip to install numpy 
	sudo pip install numpy==1.7.1
	# use pip to install qiime
	sudo pip install qiime

---

INSTALL DRISEE (CLONE THE DRISEE REPOSITORY)

	# move to home directory
	cd ~
	# clone the DRISEE repository
	git clone https://github.com/MG-RAST/DRISEE.git

---

Add qiime and DRISEE to the PATH of the envrionment

	# source the activation script; among other things, this will add everything that qiime has installed to your PATH variable
	source ~/qiime_software/activate.sh
	# add the DRISEE directory to the PATH variable
	export PATH=$PATH:~/DRISEE
	# NOTE: you can add the path info for DRISEE and Qiime to your .profile and/or .bashrc so it will load every time you log into your machine

---

DESCRIPTION OF MAIN DRISEE SCRIPTS
===
       drisee.py           		(the main driving script - a main script file)
       seq_length_stats.py 		(an accessory script - generates sequence related stats)
       run_find_steiner.pl 		(an accessory script - performs iterative consensus sequence construction)
       qiime-uclust				(an accessory script - runs qiime-integrated uclust)
       
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

	-p PROCESSES, --processes=PROCESSES			[default '8']
		Number of processes to use. With this option you can select the number of processers 
		to use on a multiprocessor system. When more than 1 processor is selected, processing 
		of bins of duplicate reads is split among the specified number of processors. Default
		is 8 -- this reflects the number of CPUs on a typical Magellan VM (http://www.alcf.anl.gov/magellan).

	-t SEQ_TYPE, --seq_type=SEQ_TYPE			[default 'fasta']
		Sequence type: fasta, fastq 
		Specify the type of sequence file; fasta and fastq are the only accepted options

	-f, --filter_seq  					[default True]    
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
		from further analysis.

	-r REP_FILE, --replicate_file=REP_FILE[default to calculate replicates]
		List file with sorted indices for replicate bins.  The file has one row for each read: 
		two columns indicating the bin and sequence id for the read 
	
	-d TMPDIR, --tmp_dir=TMPDIR				[default '/tmp']
		DIR for intermediate files (must be full path). Specified directory must already exist. 
		Files are automatically deleted at analysis completion.

	-l LOGFILE, --log_file=LOGFILE				[default '/dev/null']
		A detailed log of processing related statistics
 
	--percent						[default True]         
		Produce second output profile with values presented 			
		as percent per position. Additional output file is				
		named "output_stat_file_pattern".per

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
		
	-j, --check_contam    					[default off]
		Produce separate results for seqs with adapter contamination.
                        
  	-o MINOVERLAP, --minoverlap==MINOVERLAP			[default 10]
                (Requires -j) Minimum overlap paramter for identifying adapter contamination 
                
  	-e MINALIGNID, --fractionid=MINALIGNID			[default 0.9]
                (Requires -j) Minimum alignment id for identifying adapter contamination 
                        
  	-g DATABASE, --database=DATABASE			[default adapterDB.fna]
                (Requires -j) Database fasta of adapter sequences 
                      
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
The summary header and summary values are identical to those from the raw counts file.

Lines 4 on are produced from the the values used to generate the raw output. These are modified
as follows: each row presents counts as the percent of total counts for that row
(i.e. for the indicated seqeunce-indexed postion).
In the example above, the row indexed as "1" has a value of 100 under the first "C" column, indicating
that 100% of considered reads match a consensus "C" at postion 1.  A value of "0" in the second "C"
column indicates that no reads possess a "C" at this postion that does not match their respective 
consensus sequence. These values are calculated from the corresponding counts in the raw counts output:
a value of "24" for the first "C" column (percent = 24/24*100), and "0" for the second "C" column
(percent = 0/24).  Where 24 is the number of total counts (in this example it is also the number of 
"C" counts that match their consensus at postion 1).
. 

See Keegan 2012 (email kkeegan AT anl.gov :: manuscript is currently under review) for more details. 


PLOTTING DRISEE OUTPUTS
===
Two scripts allow you to produce linear graphs from *.DRISEE (raw DRISEE abundance output) and *.DRISEE.per
(percentage scaled DRISEE output) outputs.  One is an independent R script (plot_DRISEE.11-19-12.r), the 
second is a shell script (plot_DRISEE_shell.sh) -- the shell script is a shell wrapper for the R script.
Usage information for each plotting script is provided in the script/ script usage.

CHANGELOG
===
This is DRISEE version 1.2 (April 2012)
- Debugged 11-13-12
- Added plotting scripts 11-19-12

CITATION
==
          Keegan KP, Trimble WL, Wilkening J, Wilke A, Harrison T, et al. (2012)
          A Platform-Independent Method for Detecting Errors in Metagenomic Sequencing Data: DRISEE. 
          PLoS Comput Biol 8(6): e1002541. doi:10.1371/journal.pcbi.1002541

OTHER INFORMATION
===
DRISEE was designed to run on a Unix platform, preferably with access to multiple processors.  
A typical DRISEE analysis using the default parameters specified above takes on the order 
of 10's of minutes to a few hours to complete.  Processing time will vary considerably based 
on the size of the input data file.  DRISEE has been run on OSX machines with a single CPU; 
processing times are generally longer, based largely on the limited capability of such 
machines to perform parallel computation on multiple CPUs.

License
===

Copyright (c) 2010-2012, University of Chicago
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
