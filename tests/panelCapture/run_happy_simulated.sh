
# Activate Conda env (from Olivier's HOME for now):
source /etc/profile.d/conda.sh && conda activate /home/olivier/.conda/envs/hap.py


set -euo pipefail


# Common variables:
prfx_tested=$1
SAMPLE=$2
usedBed=$3

# Get func that run hap.py on corriel sequenced with exomeTwist:
source tests/func_special.sh

set -x  # Activation of env is too verbose set 'DEBUG' from here

if [ -z $(find "$prfx_tested"/"$SAMPLE" -type f -name "${SAMPLE}.vcf") ] ; then
	echo "ERROR: No VCF found with name '${SAMPLE}.vcf' in path '$prfx_tested/$SAMPLE'"
	exit 1
fi

# Then run hap.py on 'merged' VCF + 'subunit' VCFs (HC + DV)
# Running hap.py takes ~ 15 min by sample

# 'merged' VCF:
happy_simulated \
    "$SAMPLE" \
    $(find "$prfx_tested"/"$SAMPLE" -type f -name "${SAMPLE}.vcf") \
    "$usedBed" &

# 'DeepVariant' VCF:
happy_simulated \
    "$SAMPLE" \
    $(find "$prfx_tested"/"$SAMPLE" -type f -name "${SAMPLE}.dv.vcf") \
    "$usedBed" &

# 'HaplotypeCaller' VCF:
happy_simulated \
    "$SAMPLE" \
    $(find "$prfx_tested"/"$SAMPLE" -type f -name "${SAMPLE}.hc.vcf") \
    "$usedBed" &


# Wait for 'srun' jobs ran in background to finish:
# Inspired from: https://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0
wait
