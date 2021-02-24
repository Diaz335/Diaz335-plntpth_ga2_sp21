#2.1 make dir and intialize Git then mk README
mkdir ass2
cd mkdir ass2
git init
git status

echo "This is the repository for graded assignment 2 plntpth8300 spring 2021"> README1.md
git add README.md
git commit -m "Added README"
git status

#2.2 Copy the FASTQ files to directory
mkdir -p data/fastq 
cd data/fastq
cp  /fs/ess/PAS1855/data/week05/fastq/*.fastq .

#2.3
echo "*.fastq" >> .gitignore
git add .gitignore
git commit -m "ignore fastq files"

#2.4 Conda &cutadapt
module load python/3.6-conda5.2
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

conda create -n cutadaptenv cutadapt
conda activate cutadaptenv
cutadapt --version

#2.5 export environment to YAML
conda env export -n Cutadapt > Cutadapt.yml
source deactivate #getoutofCutadapt

##writing script

#2.6
nano cutadapt_single.sh #allows writing script 2.6-2.11 in script

#!/bin/bash
#SBATCH --account=PAS1855
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1

#2.7 include familiar set & load OSC conda
set -u -e -o pipefail

module load python/3.6-conda5.2
source activate cutadaptenv

#2.8 add 4 arguments to script
r1_fwd="$1"#path to forward fastq
r1_fwd=/fs/ess/PAS1855/users/diaz335/ass2/data/fastq/201-S4-V4-V5_S53_L001_R1_001.fastq

output_dir="$2" #output directory for trimmed fastq
output_dir=/fs/ess/PAS1855/users/diaz335/ass2/results/trim

fwdprimer="$3" #forward primer
fwdprimer="GAGTGYCAGCMGCCGCGGTAA"

revprimer="$4" #reverse primer
revprimer="TTACCGCGGCKGCTGRCACTC"

#2.9 reverse complement for each primer
primer_f_rc=$(echo "$fwdprimer" | tr ATCGYRKMBVDH TAGCRYMKVBHD | rev)
primer_r_rc=$(echo "$revprimer" | tr ATCGYRKMBVDH TAGCRYMKVBHD | rev)

#2.10 infer reverse fastq
r2_rev="$(dirname "$r1_fwd")/$(basename -s ".fastq" "$r1_fwd" | sed -e 's/_R1_/_R2_/').fastq"
echo "infered fastq $r2_rev"


#2.11 Assign output file paths

fwd_trim=$output_dir/$(basename -s ".fastq" $r1_fwd)_trimmed.fastq
rev_trim=$output_dir/$(basename -s ".fastq" $r2_rev )_trimmed.fastq
echo "forward trimmed fastq $fwd_trim"
echo "reverse trimmed fastq $rev_trim"




#2.12 output directory
mkdir -p results/trim
echo "Output directory $output_dir"

#2.13
cutadapt -a "$fwdprimer"..."$primer_r_rc" \
    -A "$revprimer"..."$primer_f_rc" \
    --discard-untrimmed --pair-filter=any \
    -o "$fwd_trim" -p "$rev_trim" "$r1_fwd" "$r2_rev"

#WRONG  sbatch cutadapt_single.sh "$R1_fw" "$output_dir"

sbatch cutadapt_single.sh "$R1_fw" "$output_dir" “$fwdprimer” “$revprimer”
git add --all
git add cutadapt_single.sh
git status
git commit -m "added all files"

git remote add origin https://github.com/Diaz335/plntpth_sp21_ga2
git branch -M main
git push -u origin main
git push 
git remote -v