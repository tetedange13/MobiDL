version 1.0

task deepVariant {
	meta {
		author: "David BAUX"
		email: "d-baux(at)chu-montpellier.fr"
		version: "0.0.1"
		date: "2023-09-04"
	}
	input {
		# env variables	
		String CondaBin
		String SingularityEnv
		# global variables
		String SampleID
		String OutDir
		String WorkflowType
		String ReferenceFasta
		String SingularityExe
		String DvSimg
		String DvExe
		String GatkExe
		Boolean Version = false
		# task specific variables
		File BamFile
		File BamIndex
		String BedFile
		String ModelType
		String Data
		String RefData
		String DvOut
		String Output
		String VcSuffix
		# runtime attributes
		String Queue
		Int Cpu
		Int Memory
	}
	command <<<
		source ~{CondaBin}activate ~{SingularityEnv}
		~{SingularityExe} run \
		--bind ~{Output} \
		--bind ~{RefData} \
		--bind ~{Data} \
		~{DvSimg} ~{DvExe} \
		--model_type=~{ModelType} \
		--ref=~{ReferenceFasta} \
		--reads="~{DvOut}/~{SampleID}/~{WorkflowType}/~{SampleID}.bam" \
		--regions=~{BedFile} \
		--num_shards=~{Cpu} \
		--output_vcf="~{DvOut}/~{SampleID}/~{WorkflowType}/~{SampleID}.unsorted.vcf"
		if [ ~{Version} = true ];then
			# fill-in tools version file			
			echo "DeepVariant: v$(~{SingularityExe} run ~{DvSimg} ~{DvExe} --version 2>/dev/null | grep 'DeepVariant' | cut -f3 -d ' ')" >> "~{OutDir}~{SampleID}/~{WorkflowType}/~{SampleID}.versions.txt"
		fi
		source ~{CondaBin}deactivate
		~{GatkExe} SortVcf \
		-I "~{OutDir}~{SampleID}/~{WorkflowType}/~{SampleID}.unsorted.vcf" \
		-O "~{OutDir}~{SampleID}/~{WorkflowType}/~{SampleID}.dv.vcf"
		rm "~{OutDir}~{SampleID}/~{WorkflowType}/~{SampleID}.unsorted.vcf" "~{OutDir}~{SampleID}/~{WorkflowType}/~{SampleID}.dv.vcf.idx"
		mv "~{OutDir}~{SampleID}/~{WorkflowType}/~{SampleID}.unsorted.visual_report.html" "~{OutDir}~{SampleID}/~{WorkflowType}/~{SampleID}.unsorted.dv.html"
	>>>
	runtime {
		queue: "~{Queue}"
		cpu: "~{Cpu}"
		requested_memory_mb_per_core: "~{Memory}"
	}
	output{
		 File DeepVcf = "~{OutDir}~{SampleID}/~{WorkflowType}/~{SampleID}~{VcSuffix}.vcf"
	}
}
