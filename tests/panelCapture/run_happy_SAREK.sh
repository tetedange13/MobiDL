
# Activate Conda env (from Olivier's HOME for now):
source /etc/profile.d/conda.sh && conda activate /home/olivier/.conda/envs/hap.py


set -euo pipefail


# Common variables:
prfx_tested=$1
SAMPLE=$2
usedBed=$3

# Get func that run hap.py on corriel sequenced with exomeTwist:
source /home/felix/MobiDL/tests/func_special.sh

set -x  # Activation of env is too verbose set 'DEBUG' from here


# Then run hap.py on 'merged' VCF + 'subunit' VCFs (HC + DV)
# Running hap.py takes ~ 15 min by sample

# 'DeepVariant' VCF:
happy_exomeTwist \
    "$SAMPLE" \
    $(find "$prfx_tested"/variant_calling/deepvariant/"$SAMPLE"* -type f -name "${SAMPLE}*.deepvariant.vcf.gz") \
    "$usedBed" &

# 'HaplotypeCaller' VCF:
# MEMO: We use 'filtered' one bellow
happy_exomeTwist \
    "$SAMPLE" \
    $(find "$prfx_tested"/variant_calling/haplotypecaller/"$SAMPLE"* -type f -name "${SAMPLE}*.filtered.vcf.gz") \
    "$usedBed" &

# 'merged' VCF:
happy_exomeTwist \
   "$SAMPLE" \
   $(find "$prfx_tested"/variant_calling/merge/"$SAMPLE"* -type f -name "${SAMPLE}*.vcf.gz") \
   "$usedBed" &


# Wait for 'srun' jobs ran in background to finish:
# Inspired from: https://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0
wait
