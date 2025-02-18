task toolVersions {
	String SampleID
	String OutDir
	String WorkflowType
  String GenomeVersion
  String FastpExe
  String BwaExe
  String SamtoolsExe
  String SambambaExe
  String BedToolsExe
  String QualimapExe
  String BcfToolsExe
  String BgZipExe
  Boolean DoCrumble = false
  String CrumbleExe
  String TabixExe
  String MultiqcExe
  String GatkExe
  String SingularityExe
	String DvSimg
  String JavaExe
  String DvExe
  String VcfPolyXJar
	File Vcf
	#runtime attributes
	Int Cpu
	Int Memory
  String dollar = "$"
	# echo "FastQC: ${dollar}(${FastqcExe} -v | grep 'FastQC' | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
	command {
    date > "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "Sample ID: ${SampleID}" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "Workflow: MobiDL ${WorkflowType} v1.1 executed on ${dollar}(hostname)" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "Genome Version: ${GenomeVersion}" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
		echo "----- FastQ pre-processing -----" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
		echo "fastp: v${dollar}(${FastpExe} --version 2>&1 | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "----- Alignment -----" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "BWA: v${dollar}(${BwaExe} 2>&1 | grep 'Version' | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "Samtools: v${dollar}(${SamtoolsExe} --version | grep 'samtools' | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "Sambamba: v${dollar}(${SambambaExe} --version 2>&1 | grep 'sambamba 0' | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "GATK: ${dollar}(${GatkExe} -version | grep 'GATK' | cut -f6 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "----- Variant Calling -----" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "GATK Haplotype Caller: ${dollar}(${GatkExe} -version | grep 'GATK' | cut -f6 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "DeepVariant: v1.5" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    # not on 0.10 echo "DeepVariant: v${dollar}(${SingularityExe} run ${DvSimg} ${DvExe} --version | cut -f3 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "VcfPolyX: ${dollar}(${JavaExe} -jar ${VcfPolyXJar} --version)" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "Bcftools: v${dollar}(${BcfToolsExe} --version | grep bcftools | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "----- Compression -----" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    if [ ${DoCrumble} ];then
      echo "Crumble: v${dollar}(${CrumbleExe} -h 2>&1 | grep 'Crumble' | cut -f3 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    fi
    echo "Bgzip: v${dollar}(${BgZipExe} --version 2>&1 | grep 'bgzip' | cut -f3 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "Tabix: v${dollar}(${TabixExe} --version 2>&1 | grep 'tabix' | cut -f3 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "----- Quality -----" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "Qualimap: ${dollar}(${QualimapExe} -h | grep 'QualiMap' | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "GATK (Picard): ${dollar}(${GatkExe} -version | grep 'GATK' | cut -f6 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
    echo "MultiQC: v${dollar}(${MultiqcExe} --version | grep 'multiqc' | cut -f3 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
		if [ -f /softs/cromwell.jar ];then
			echo "----- Execution Engine -----" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
			echo "Cromwell: v${dollar}(${JavaExe} -jar /softs/cromwell.jar --version | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
		fi
		if command -v srun &> /dev/null ;then
			echo "----- Workload Manager -----" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
			echo "SLURM: v${dollar}(srun --version | cut -f2 -d ' ')" >> "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
		fi
	}
	output {
		File versionFile = "${OutDir}${SampleID}/${WorkflowType}/${SampleID}.versions.txt"
	}
	runtime {
		cpu: "${Cpu}"
		requested_memory_mb_per_core: "${Memory}"
	}
}
