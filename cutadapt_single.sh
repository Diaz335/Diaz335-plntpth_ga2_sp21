#!/bin/bash
#SBATCH --account=PAS1855
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1

set -e -u -o pipefail

module load python/3.6-conda5.2
source activate cutadaptenv

r1_fwd="$1"
r1_fwd=/fs/ess/PAS1855/users/diaz335/ass2/data/fastq/201-S4-V4-V5_S53_L001_R1_001.fastq

output_dir="$2"
mkdir -p results/trim
output_dir=/fs/ess/PAS1855/users/diaz335/ass2/results/trim

fwdprimer="$3"
fwdprimer="GAGTGYCAGCMGCCGCGGTAA"

revprimer="$4"
revprimer="TTACCGCGGCKGCTGRCACTC"


primer_f_rc=$(echo "$fwdprimer" | tr ATCGYRKMBVDH TAGCRYMKVBHD | rev)
primer_r_rc=$(echo "$revprimer" | tr ATCGYRKMBVDH TAGCRYMKVBHD | rev)

r2_rev="$(dirname "$r1_fwd")/$(basename -s ".fastq" "$r1_fwd" | sed -e 's/_R1_/_R2_/').fastq"
echo "infered fastq $r2_rev"


fwd_trim="$output_dir/$(basename -s ".fastq" $r1_fwd)_trimmed.fastq"
rev_trim="$output_dir/$(basename -s ".fastq" $r2_rev )_trimmed.fastq"

echo "Trimmed forward read $fwd_trim"
echo "Trimmed reverse read $rev_trim"

cutadapt -a "$fwdprimer"..."$primer_r_rc" \
    -A "$revprimer"..."$primer_f_rc" \
    --discard-untrimmed --pair-filter=any \
    -o "$fwd_trim" -p "$rev_trim" "$r1_fwd" "$r2_rev"
