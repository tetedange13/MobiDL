workflow DEBUGbwaSamtools {
	File FastqR1
	File FastqR2
	String RefFasta

	call bwaSamtools {
		input:
			FastqR1 = FastqR1,
			FastqR2 = FastqR2,
			RefFasta = RefFasta,
			Cpu = 16,
			Memory = 2400
	}

}

task bwaSamtools {
	#global variables
	String SampleID = "FELIX"
	String OutDirSampleID = ""
 	String OutDir = "./"
	String WorkflowType = ""
	File FastqR1
	File FastqR2
	String SamtoolsExe = "samtools"
	#task specific variables
	String BwaExe = "bwa"
	String Platform = "ILLUMINA"
	String RefFasta
	#File RefFai
	#RefFai useles for bwa
	#index files for bwa
	File? RefAmb
	File? RefAnn
	File? RefBwt
	File? RefPac
	File? RefSa
	#runtime attributes
	Int Cpu
	Int Memory

	String SortedBam = "${OutDir}/${SampleID}.bam"
	String SortedBamIndex = "${OutDir}/${SampleID}.bam.bai"

	command {
		${BwaExe} mem -M -t ${Cpu} \
		-R "@RG\tID:${SampleID}\tSM:${SampleID}\tPL:${Platform}" \
		${RefFasta} \
		${FastqR1} \
		${FastqR2} \
		| ${SamtoolsExe} sort -@ ${Cpu} -l 1 \
		-o "${SortedBam}"

		#Index BAM:
		${SamtoolsExe} index "${SortedBam}"

		#Run 'flagstats' on it:
		${SamtoolsExe} flagstat "${SortedBam}" > "${SortedBam}".flagstats
	}
	output {
		File sortedBam = SortedBam
		File sortedBamIndex = SortedBamIndex
	}
	runtime {
		cpu: "${Cpu}"
		requested_memory_mb_per_core: "${Memory}"
	}
}
