//
// A variant caller workflow for deepvariant
//

include { BCFTOOLS_NORM as SPLIT_MULTIALLELICS_GL } from '../../modules/nf-core/modules/bcftools/norm/main'
include { BCFTOOLS_NORM as REMOVE_DUPLICATES_GL } from '../../modules/nf-core/modules/bcftools/norm/main'
include { DEEPVARIANT } from '../../modules/local/deepvariant/main'
include { GLNEXUS } from '../../modules/nf-core/modules/glnexus/main'
include { TABIX_TABIX as TABIX_GL } from '../../modules/nf-core/modules/tabix/tabix/main'

workflow CALL_SNV_DEEPVARIANT {
    take:
    bam          // channel: [ val(meta), path(bam), path(bai) ]
    fasta        // path(fasta)
    fai          // path(fai)
    ch_case_info // channel: [ case_id ]

    main:
        ch_versions = Channel.empty()

        DEEPVARIANT ( bam, fasta, fai )
        DEEPVARIANT.out.gvcf.collect{it[1]}
            .toList()
            .set { file_list }
        ch_versions = ch_versions.mix(DEEPVARIANT.out.versions)

        //Combine case meta with the list of gvcfs
        ch_case_info.combine(file_list)
            .set { ch_gvcfs }
        GLNEXUS ( ch_gvcfs )
        ch_versions = ch_versions.mix(GLNEXUS.out.versions)

        SPLIT_MULTIALLELICS_GL (GLNEXUS.out.bcf, fasta)
        REMOVE_DUPLICATES_GL (SPLIT_MULTIALLELICS_GL.out.vcf, fasta)
        ch_versions = ch_versions.mix(REMOVE_DUPLICATES_GL.out.versions)

        TABIX_GL (REMOVE_DUPLICATES_GL.out.vcf)
        ch_versions = ch_versions.mix(TABIX_GL.out.versions)

    emit:
        vcf         = REMOVE_DUPLICATES_GL.out.vcf
        tabix       = TABIX_GL.out.tbi

        versions    = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
