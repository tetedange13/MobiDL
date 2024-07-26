task samtoolsSort {
	#global variables
	String SampleID
	String OutDirSampleID = ""
 	String OutDir
	String WorkflowType
	String SamtoolsExe
	String BamFile
	#runtime attributes
	Int Cpu
	Int Memory
	String OutputDirSampleID = if OutDirSampleID == "" then SampleID else OutDirSampleID
	command {
		#Sort:
		${SamtoolsExe} sort -@ ${Cpu} -l 6 \
		-o "${OutDir}${OutputDirSampleID}/${WorkflowType}/${SampleID}.sorted.bam" \
		"${BamFile}"
		#And index BAM:
		${SamtoolsExe} index "${OutDir}${OutputDirSampleID}/${WorkflowType}/${SampleID}.sorted.bam"
	}
	output {
		File sortedBam = "${OutDir}${OutputDirSampleID}/${WorkflowType}/${SampleID}.sorted.bam"
		File sortedBamIndex = "${OutDir}${OutputDirSampleID}/${WorkflowType}/${SampleID}.sorted.bam.bai"
	}
	runtime {
		cpu: "${Cpu}"
		requested_memory_mb_per_core: "${Memory}"
	}
}
