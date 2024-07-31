import "modules/preparePanelCaptureTmpDirs.wdl" as runPreparePanelCaptureTmpDirs
# import "modules/fastqc.wdl" as runFastqc
import "modules/fastp.wdl" as runFastp
import "modules/bwaSamtools.wdl" as runBwaSamtools
import "modules/sambambaIndex.wdl" as runSambambaIndex
import "modules/sambambaMarkDup.wdl" as runSambambaMarkDup
import "modules/bedToGatkIntervalList.wdl" as runBedToGatkIntervalList
import "modules/gatkSplitIntervals.wdl" as runGatkSplitIntervals
import "modules/gatkBaseRecalibrator.wdl" as runGatkBaseRecalibrator
import "modules/gatkGatherBQSRReports.wdl" as runGatkGatherBQSRReports
import "modules/gatkApplyBQSR.wdl" as runGatkApplyBQSR
import "modules/gatkLeftAlignIndels.wdl" as runGatkLeftAlignIndels
import "modules/gatkGatherBamFiles.wdl" as runGatkGatherBamFiles
import "modules/samtoolsSort.wdl" as runSamtoolsSort
import "modules/samtoolsCramConvert.wdl" as runSamtoolsCramConvert
import "modules/samtoolsCramIndex.wdl" as runSamtoolsCramIndex
import "modules/sambambaFlagStat.wdl" as runSambambaFlagStat
import "modules/gatkCollectMultipleMetrics.wdl" as runGatkCollectMultipleMetrics
import "modules/gatkCollectInsertSizeMetrics.wdl" as runGatkCollectInsertSizeMetrics
import "modules/gatkBedToPicardIntervalList.wdl" as runGatkBedToPicardIntervalList
import "modules/computePoorCoverage.wdl" as runComputePoorCoverage
import "modules/samtoolsBedCov.wdl" as runSamtoolsBedCov
import "modules/computeCoverage.wdl" as runComputeCoverage
import "modules/computeCoverageClamms.wdl" as runComputeCoverageClamms
import "modules/gatkCollectHsMetrics.wdl" as runGatkCollectHsMetrics
import "modules/gatkHaplotypeCaller.wdl" as runGatkHaplotypeCaller
import "modules/gatkGatherVcfs.wdl" as runGatkGatherVcfs
import "modules/qualimapBamQc.wdl" as runQualimapBamQc
import "modules/jvarkitVcfPolyX.wdl" as runJvarkitVcfPolyX
import "modules/gatkSplitVcfs.wdl" as runGatkSplitVcfs
import "modules/gatkVariantFiltrationSnp.wdl" as runGatkVariantFiltrationSnp
import "modules/gatkVariantFiltrationIndel.wdl" as runGatkVariantFiltrationIndel
import "modules/gatkMergeVcfs.wdl" as runGatkMergeVcfs
import "modules/gatkSortVcf.wdl" as runGatkSortVcf
import "modules/bcftoolsNorm.wdl" as runBcftoolsNorm
import "modules/compressIndexVcf.wdl" as runCompressIndexVcf
import "modules/deepVariant.wdl" as runDeepVariant
import "modules/refcallFiltration.wdl" as runRefCallFiltration
import "modules/gatkHardFilteringVcf.wdl" as runGatkHardFilteringVcf
import "modules/bcftoolsStats.wdl" as runBcftoolsStats
# import "modules/gatkVariantEval.wdl" as runGatkVariantEval
# import "modules/gatkCombineVariants.wdl" as runGatkCombineVariants
# import "modules/rtgMergeVcfs.wdl" as runRtgMerge
# import "modules/fixVcfHeaders.wdl" as runFixVcfHeaders
import "modules/crumble.wdl" as runCrumble
import "modules/anacoreUtilsMergeVCFCallers.wdl" as runAnacoreUtilsMergeVCFCallers
import "modules/gatkUpdateVCFSequenceDictionary.wdl" as runGatkUpdateVCFSequenceDictionary
import "modules/cleanUpPanelCaptureTmpDirs.wdl" as runCleanUpPanelCaptureTmpDirs
import "modules/multiqc.wdl" as runMultiqc
import "modules/toolVersions.wdl" as runToolVersions

# Import panelCapture as a subworkflow:
import "panelCapture.wdl" as panelCapture

workflow MetaPanelCapture {
	meta {
		author: "Felix VANDERMEEREN"
		email: "felix.vandermeeren(at)chu-montpellier.fr"
	}
	## Global
    String inRun
	Array[String] samplesList
	Array[File] intervalBedFileList
	Array[String] intervalBaitBedList = []
	String metaOutDir

    ### Sample-level inputs (for panelCapture)
	# variables declarations
	## Resources
	Int cpuHigh
	Int cpuLow
	Int memoryLow
	Int memoryHigh
	# memoryLow = scattered tasks =~ mem_per_cpu in HPC or not
	# memoryHigh = one cpu tasks => high mem ex 10Gb
	String genomeVersion
	File refFasta
	File refFai
	File refDict
	String workflowType
	Boolean debug = false
	## Bioinfo execs
	# String fastqcExe
	String fastpExe
	String bwaExe
	String samtoolsExe
	String sambambaExe
	String bedToolsExe
	String qualimapExe
	String bcfToolsExe
	String bgZipExe
	String tabixExe
	String multiqcExe
	## Standard execs
	String awkExe
	String sedExe
	String sortExe
	String gatkExe
	String javaExe
	## fastp
	String noFiltering = ""
	## bwaSamtools
	String platform
	File refAmb
	File refAnn
	File refBwt
	File refPac
	File refSa
	## sambambaIndex
	## gatk splitintervals
	String subdivisionMode
	## gatk Base recal
	File knownSites1
	File knownSites1Index
	File knownSites2
	File knownSites2Index
	File knownSites3
	File knownSites3Index
	## cram conversion
	File refFastaGz
	File refFaiGz
	File refFaiGzi
	## gatk-picard
	String variantEvalEV = "MetricsCollection"
	## computePoorCoverage
	Int bedtoolsLowCoverage
	Int bedToolsSmallInterval
	## computeCoverage
	Int minCovBamQual
	## haplotypeCaller
	String swMode
	String emitRefConfidence = "NONE"
	## jvarkit
	String vcfPolyXJar
	## ConvertCramtoCrumble
	Boolean doCrumble = true 
	String crumbleExe
	String ldLibraryPath
	## DeepVariant
	String modelType
	String data
	String refData
	String outputMnt
	String dvExe
	String singularityExe
	String dvSimg
	## RefCallFiltration
	String vcftoolsExe
	## VcSuffix
	String dvSuffix = ".dv"
	String hcSuffix = ".hc"
	## Anacore-Utils mcustom mergeVCF script
	File mergeVCFMobiDL

    call prepareInputs {
        input:
        inRun = inRun,
        samplesList = samplesList,
        intervalBedFileList = intervalBedFileList
    }

    scatter (sample in samplesList) {
        call getIndex {
            input :
            CI = CI,
            Parents = Parents
        }
        call panelCapture {
            input:
            suffix1 = prepareInputs.suffix1
            suffix2 = prepareInputs.suffix2,
            fastqR1 = prepareInputs.fastqR1,
            fastqR2 = prepareInputs.fastqR1,
            intervalBedFile = intervalBedFileList[getIndex.out]
        }
    }
}