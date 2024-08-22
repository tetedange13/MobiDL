workflow DEBUGbwaSamtools {
	File FastqR1
	File FastqR2
	String RefFasta
	Boolean intermediateSAM = true

	if (intermediateSAM) {
		call bwaMemnosort {
			input:
				FastqR1 = FastqR1,
				FastqR2 = FastqR2,
				RefFasta = RefFasta,
				Cpu = 8,
				Memory = 1536
		}
		call samtoolsSort {
			input:
				BamFile = bwaMemnosort.outputFile,
				Cpu = 8,
				Memory = 1536
		}
	}

	if (!intermediateSAM) {
		call bwaSamtools {
			input:
				FastqR1 = FastqR1,
				FastqR2 = FastqR2,
				RefFasta = RefFasta,
				Cpu = 8,
				Memory = 1536
		}
	}
}


task bwaMemnosort {
	#global variables
	String SampleID = "FELIX"
	File FastqR1
	File FastqR2
	#task specific variables
	String BwaExe = "bwa"
	String Platform = "ILLUMINA"
	String RefFasta
	#runtime attributes
	Int Cpu
	Int Memory

	command {
		${BwaExe} mem -M -t ${Cpu} \
		-R "@RG\tID:${SampleID}\tSM:${SampleID}\tPL:${Platform}" \
		${RefFasta} \
		${FastqR1} \
		${FastqR2}
	}
	output {
		File outputFile = stdout()
	}
	runtime {
		cpu: "${Cpu}"
		requested_memory_mb_per_core: "${Memory}"
	}
}


task samtoolsSort {
	#global variables
	String SamtoolsExe = "samtools"
	String BamFile
	#runtime attributes
	Int Cpu
	Int Memory
	String SortedBam = "sorted.bam"
	String SortedBamIndex = "sorted.bam.bai"
	command {
		#Sort:
		${SamtoolsExe} sort -@ ${Cpu} -l 1 \
		-o "${SortedBam}" \
		"${BamFile}"
		#And index BAM:
		${SamtoolsExe} index "${SortedBam}"
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


task bwaSamtools {
	#global variables
	String SampleID = "FELIX"
	File FastqR1
	File FastqR2
	String SamtoolsExe = "samtools"
	#task specific variables
	String BwaExe = "bwa"
	String Platform = "ILLUMINA"
	String RefFasta
	Int Cpu
	Int Memory
	String SortedBam = "sorted.bam"
	String SortedBamIndex = "sorted.bam.bai"
	command {
		${BwaExe} mem -M -t ${Cpu} \
		-R "@RG\tID:${SampleID}\tSM:${SampleID}\tPL:${Platform}" \
		${RefFasta} \
		${FastqR1} \
		${FastqR2} \
		| ${SamtoolsExe} sort -@ ${Cpu} -l 1 \
		-o "${SortedBam}"

		${SamtoolsExe} index "${SortedBam}"
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
