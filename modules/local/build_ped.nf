// Import generic module functions
include { saveFiles; getSoftwareName} from './functions'

params.options = [:]
params.singularity_pull_docker_container = true
// params {    singularity_pull_docker_container = true
// }


process BUILDPED {
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:[:], publish_by_meta:[]) }
    conda (params.enable_conda ? "conda-forge::pandas=1.3.4" : null)
    //TODO singularity container for pandas does not exist
    container "quay.io/biocontainers/pandas:1.1.5"


    input:
    path(valid_csv)

    output:
    path("*.ped"), emit: ped


    script: // This script is bundled with the pipeline, in nf-core/raredisease/bin/
    """
    buildped_from_samplesheet.py \\
        ${valid_csv} \\
        samplesheet.valid.ped
    """
}
