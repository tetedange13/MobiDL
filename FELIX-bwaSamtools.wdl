workflow DEBUGbwaSamtools {
	File FastqR1
	File FastqR2
	String RefFasta

	call bwaMemnosort {
		input:
			FastqR1 = FastqR1,
			FastqR2 = FastqR2,
			RefFasta = RefFasta,
			Cpu = 16,
			Memory = 2400
	}
	call samtoolsSort {
		input:
			BamFile = bwaMemnosort.outputFile
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
		${SamtoolsExe} sort -@ ${Cpu} -l 6 \
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
