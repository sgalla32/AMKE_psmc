#!/bin/bash
#SBATCH -J AMKE_PSMC
#SBATCH -o log.o%j 
#SBATCH -p bsudfq
#SBATCH -N 1
#SBATCH -n 14
#SBATCH -t 14-00:00:00
#SBATCH --mail-type=END
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=stephaniegalla@boisestate.edu

#Ensure the temporary directory is in your scratch, so that big files don't take up too much space.

export TMPDIR=~/scratch

# Align short reads to genome. reference=AMKE.fa
~/anaconda3/bin/bwa index ~/scratch/AMKE/Ne/Genome/Assembled_Genome/AMKE.fa
~/anaconda3/bin/bwa mem -t 64 ~/scratch/AMKE/Ne/Genome/Assembled_Genome/AMKE.fa ~/scratch/AMKE/Ne/Genome/AMKE-WG_S1_L002_R2_001.fastq ~/scratch/AMKE/Ne/Genome/AMKE-WG_S1_L002_R1_001.fastq > ~/scratch/AMKE/Ne/Genome/AMKE_aln.sam
~/anaconda3/bin/samtools view -@ 63 -b -h -o ~/scratch/AMKE/Ne/Genome/AMKE_aln.bam ~/scratch/AMKE/Ne/Genome/AMKE_aln.sam 

# Make SNPable mask file. Download Heng Li's seqbility tools for this. Search "Heng Li SNPable" for more info.
# Note, you can compile splitfa.c into an executable by running: $ make
~/seqbility-20091110/splitfa ~/scratch/AMKE/Ne/Genome/Assembled_Genome/AMKE.fa 150 > ~/scratch/AMKE/Ne/Genome/Assembled_Genome/xxaa.fa
# Stephanie added this line:
~/anaconda3/bin/bwa aln ~/scratch/AMKE/Ne/Genome/Assembled_Genome/AMKE.fa ~/scratch/AMKE/Ne/Genome/Assembled_Genome/xxaa.fa > ~/scratch/AMKE/Ne/Genome/Assembled_Genome/xxaa.sai
~/anaconda3/bin/bwa samse ~/scratch/AMKE/Ne/Genome/Assembled_Genome/AMKE.fa ~/scratch/AMKE/Ne/Genome/Assembled_Genome/xxaa.sai ~/scratch/AMKE/Ne/Genome/Assembled_Genome/xxaa.fa | ~/anaconda3/bin/samtools view -@ 7 -b -h -o ~/scratch/AMKE/Ne/Genome/xxaa.bam
~/anaconda3/bin/samtools view -h -@ 62 ~/scratch/AMKE/Ne/Genome/xxaa.bam | ~/seqbility-20091110/gen_raw_mask.pl > ~/scratch/AMKE/Ne/Genome/rawMask_150.fa
~/seqbility-20091110/gen_mask -l 150 -r 0.5 ~/scratch/AMKE/Ne/Genome/rawMask_150.fa > ~/scratch/AMKE/Ne/Genome/mask_150.fa
