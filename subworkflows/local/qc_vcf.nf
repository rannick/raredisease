//
// A quality check subworkflow for processed vcf.
//


params.buildped_options = [:]
params.peddy_options = [:]


include { BUILDPED } from '../../modules/local/build_ped'  addParams( options: params.buildped_options )
include { PEDDY } from '../../modules/nf-core/modules/peddy/main'  addParams( options: params.peddy_options )

workflow QC_VCF {

    take:
        valid_csv // file: /path/to/samplesheet.csv
        vcf
        vcf_tbi
    main:
        vcf_indexed = vcf.join(vcf_tbi)

        BUILDPED( valid_csv )
        PEDDY( vcf_indexed, BUILDPED.out.ped )

    emit:
        ped             = BUILDPED.out.ped
        peddy_version   = PEDDY.out.versions

}
