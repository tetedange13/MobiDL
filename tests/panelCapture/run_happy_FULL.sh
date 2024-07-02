
# Activate Conda env (from Olivier's HOME for now):
source /etc/profile.d/conda.sh && conda activate /home/olivier/.conda/envs/hap.py


set -euo pipefail


# Common variables:
prfx_tested=$1
SAMPLE=$2

# Get func that run hap.py on corriel sequenced with exomeTwist:
source tests/func_special.sh

set -x  # Activation of env is too verbose set 'DEBUG' from here

if [ -z $(find "$prfx_tested"/"$SAMPLE" -type f -name "${SAMPLE}.vcf") ] ; then
	echo "ERROR: No VCF found with name '${SAMPLE}.vcf' in path '$prfx_tested/$SAMPLE'"
	exit 1
fi

# Then run hap.py
# WARN: Each family member must have been analyzed as a solo (even though this is a trio)
# Running hap.py takes ~ 15 min by sample

happy_exomeTwist \
    "$SAMPLE" \
    $(find "$prfx_tested"/"$SAMPLE" -type f -name "${SAMPLE}.vcf") \
    /mnt/chu-ngs/refData/intervals/RefSeqHG19_CDSplus20.bed &

# Wait for 'srun' jobs ran in background to finish:
# Inspired from: https://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0
wait
