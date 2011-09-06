DRISEE: Duplicate Read Inferred Sequencing Error Estimation
===

Contributors: Kevin Keegan, William Trimble, Jared Wilkening, Andreas Wilke, Travis Harrison, & Mark D'souza

Requires at least: 
	a unix environment ( Unix / Linux / OSX / Darwin / Cygwin / etc. ) 
	install the ncbi BLAST package (ftp://ftp.ncbi.nih.gov/blast/), specifically formatdb and fastacmd. 
	install uclust 3.0  (http://www.drive5.com/)  


Description
==

DRISEE is a tool that allows for platform independent assessment of sequencing error
in metagenomic (or genomic) data.  DRISEE is designed to consider shotgun data.
It is not appropriate for amplicon data. 

Download DRISEE.tgz from ftp://ftp.metagenomics.anl.gov/DRISEE/

Unzip DRISEE:
tar -zxf /your_path/DRISEE.tgz
cd /your_path/DRISEE

Installation
==

Download DRISEE.tgz from ftp://ftp.metagenomics.anl.gov/DRISEE/

Unzip DRISEE:
tar -zxf /your_path/DRISEE.tgz
cd /your_path/DRISEE

Using DRISEE
==

To run
>DRISEE.sh <fasta_file> <fasta_dir> <prefix_length> <output_dir>

     fasta_file:    the name of the fasta file you want DRISEE'd
     fasta_dir:     the path for the fasta_file
     prefix_length: prefix length you want to use for DRISEE analysis

example
>DRISEE.sh my.FASTA /data/location/ 50

Will perform a DRISEE style analysis on /data/location/my.FASTA
using a prefix length of 50 bp

Output Description
==

A preliminary DRISEE output (the *STAT file)has the following format:

	A_err   T_err   C_err   G_err   N_err   X_err   bp_err  prefix_length = 50
	0.0929  0.0895  0.1117  0.0995  0.0000  0.1516  0.5451
	A       T       C       G       N       X       A       T       C       G       N       X
	5663    2274    3014    3808    0       0       0       0       0       0       0       0
	3414    2336    3379    5630    0       0       0       0       0       0       0       0
	5778    1899    3414    3668    0       0       0       0       0       0       0       0
	3440    3983    4430    2906    0       0       0       0       0       0       0       0
	4254    3317    2281    4907    0       0       0       0       0       0       0       0
	...

The first line     ("A_err   T_err ...") contains headers for the summary values
on the second line ("5663    2274 ...")
The first line also indicates the length of the prefix ("prefix_length") used for 
a given DRISEE analysis.  Here a 50 base-long prefix was used.

The second line values indicate the various error rates (described below)calculated
from the non-prefix portion of the reads that have undergone DRISEE analysis. 
A, T, C, &G_err indicate the A, T, C & G substituation rates respectively.
N_err	indicates the substition rate for ambiguous base calls - by default reads  
that contain ambiguous base calls are exceluded from DRISEE analysis (Keegan et. al. 2011);
reads with ambiguous bases can be included in analyses if non default parameters are used.
X_err indicates the combined insertion/deletion error rate rate
bp_err indicates the total error, the sum of A, T, C, G, N, & X _err.

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

The fourth line ("5663    2274 ...") indicates the integer counts for the match or
mismatches described in third line header, for the first position for all considered
bins of prefix identical reads.  The fifth line indicates the same information for
the second position in all considered bins of prefix identical reads etc.  This 
format extends to the end of the file. The example above includes the count data 
for the first 5 bases - as these are part of the 50 base long prefix region, they
are expected to be identical -- all displayed counts correspond to consensus matches.

STAT_file_example (ftp://ftp.metagenomics.anl.gov/DRISEE/STAT_file_example)
includes the complete STAT file for the example excerpted above.
Note that counts that correspond to mismatches are not observed until the first 
non-prefix base, base 51 (line 54 of the file): 
"2100	3196	4147	5247	0	15	10	19	7	5	0	13"
    

DRISEE also produces a detailed log of all processes performed (*LOG) 
and several intermediary files that contain sequence files in various 
stages of DRISEE processing (*length*, *filtered*, *fasta* & *seed) 
A detailed description of each file type is beyond the scope of this document.

Modifying DRISEE
==

DRISEE analyses can be modified/customized in a number of ways.
The easiest place to start is DRISEE.sh - in this 
shell script you can modify most of the default parameters 
that a typical DRISEE analysis will use.

The accessory scripts that DRISEE uses have additional 
variables that users may want to modify.

If you would like to have more detailed information, please contact
Kevin Keegan (kkeegan@anl.gov). 

Changelog
==

This is DRISEE version 8-19-11 (1.0)
