
# Activate Conda env (from Olivier's HOME for now):
source /etc/profile.d/conda.sh && conda activate /home/olivier/.conda/envs/hap.py


set -euo pipefail

# MAIN:
if [ $# -lt 3 ]; then
    echo "ERROR: Script takes 3 mandatory args"
	echo "USAGE: bash run_happy_SAREK.sh /path/to/runID/MobiCorail HG002 Twist-exome.bed"
	echo ""
    exit 1
fi

prfx_tested=$1
SAMPLE=$2
usedBed=$3

# Get func that run hap.py on corriel sequenced with exomeTwist:
source /home/felix/MobiDL/tests/func_special.sh

set -x  # Activation of env is too verbose set 'DEBUG' from here


# Then run hap.py on 'merged' VCF + 'subunit' VCFs (HC + DV)
# Running hap.py takes ~ 15 min by sample

# 'DeepVariant' VCF:
# MEMO: DV vcf in Sarek is not 'refCall' filtered -> used '.norm.' one
#       They sould be kept by 'normAndMerge.wdl' (by default)
happy_exomeTwist \
    "$SAMPLE" \
    $(find "$prfx_tested"/variant_calling/deepvariant/* -type f -name "${SAMPLE}*.deepvariant.norm.vcf.gz") \
    "$usedBed" &

# 'HaplotypeCaller' VCF:
# MEMO: We use 'filtered' one bellow
happy_exomeTwist \
    "$SAMPLE" \
    $(find "$prfx_tested"/variant_calling/haplotypecaller/* -type f -name "${SAMPLE}*.haplotypecaller.norm.vcf.gz") \
    "$usedBed" &

# 'merged' VCF:
happy_exomeTwist \
   "$SAMPLE" \
   $(find "$prfx_tested"/variant_calling/merge/* -type f -name "${SAMPLE}*.vcf.gz") \
   "$usedBed" &


# Wait for 'srun' jobs ran in background to finish:
# Inspired from: https://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0
wait
