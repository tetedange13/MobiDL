## Global func to check 'special' files


checksum_vcf() {
	printf $(basename "$1")'\t'
	bcftools view --no-header "$1" | md5sum
}
export -f checksum_vcf


checksum_bam() {
	printf $(basename "$1")'\t'
	samtools view "$1" | md5sum
}
export -f checksum_bam


excel_to_tsv() {
	local in_xlsx=$1
	local sheet_name=$2
	/mnt/Bioinfo/Softs/bin/csvtk xlsx2csv --out-tabs --sheet-name "$sheet_name" "$in_xlsx"
}
export -f excel_to_tsv


run_wdl_MobiDL() {
	# Function to run a WDL on an inputs.json, both given as arg
	# A different config file can also be specified as an (optional) 3rd arg

	local main_wdl=$1
	local input_json=$2
	local main_conf=/mnt/Bioinfo/Softs/src/cromwell/conf/Cluster_noDB.conf
	if [ $# -eq 3 ]; then
		main_conf=$3
	fi
	# Activate Conda env:
	source /etc/profile.d/conda.sh && conda activate /home/felix/micromamba/envs/panelCapture
	local cwl_jar=$(find $CONDA_PREFIX -name "cromwell.jar")  # Use cromwell from env

	# Actually run pipeline:
	/mnt/Bioinfo/Softs/src/MobiDL/cww.sh \
		--exec "$cwl_jar" \
		--wdl "$main_wdl" \
		--input "$input_json" \
		--option /mnt/Bioinfo/Softs/src/cromwell/conf/cromwell_option_cluster.json \
		--conf "$main_conf"
}
export -f run_wdl_MobiDL


happy_exomeTwist() {
	# Function to run hap.py on a corriel VCF sequenced on exomeTwist
	# Chromosomes are expected to have 'chr' prefix (such as for 'Exome.wdl' pipeline)
	if [ $# -lt 2 ] ; then
		echo "Problem"
		return 1
	fi
	local SAMPLE=$1  # Used to find paths of bench files (eg: 'HG002')
	local to_tested_VCF=$2  # Path to VCF produced by pipeline

	local tgt_BED=/mnt/chu-ngs/refData/intervals/RefSeqHG19_CDSplus20.bed
	if [ $# -eq 3 ] ; then
		tgt_BED=$3
	fi
	local ref_fa=/mnt/chu-ngs/refData/genome/hg19/hg19.fa
	local prfx_truth=/mnt/chu-ngs/refData/VCFs_ref_for_validation
	local out_happy=out-test && mkdir --parents "$out_happy"

	source /etc/profile.d/conda.sh && conda activate /home/olivier/.conda/envs/hap.py

	# Intersect targetExome.bed with noinconsistend_bench.bed:
	# WARN: noinconsistent.bed have chr_name WITHOUT 'chr' prefix -> It is added on-the-fly
	bedtools intersect \
		-a "$tgt_BED" \
		-b <(sed 's/^/chr/' "$prfx_truth"/"$SAMPLE"_GRCh37_1_22_v4.2.1_benchmark_noinconsistent.bed) \
		> "$out_happy"/"$SAMPLE"_exomeTwist_vs_benchmark.bed

	# Run hap.py:
	srun --partition="test" hap.py \
		"$prfx_truth"/"$SAMPLE"_GRCh37_1_22_v4.2.1_benchmark.chr.vcf.gz \
		"$to_tested_VCF" \
		--target-regions "$out_happy"/"$SAMPLE"_exomeTwist_vs_benchmark.bed \
		--reference "$ref_fa" \
		--report-prefix "$out_happy"/"$(basename "$to_tested_VCF" .vcf)"
}
