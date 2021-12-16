#!/usr/bin/env python

import os
import sys
import errno
import argparse
import pandas as pd


def parse_args(args=None):
    Description = "Build a ped file from input samplesheet."
    Epilog = "Example usage: python build_ped_from_samplesheet.py <FILE_IN> <FILE_OUT>"

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("FILE_IN", help="Input samplesheet file.")
    parser.add_argument("FILE_OUT", help="Output file.")
    return parser.parse_args(args)

# def print_error(error, context="Line", context_str=""):
#     error_str = "ERROR: Please check samplesheet -> {}".format(error)
#     if context != "" and context_str != "":
#         error_str = "ERROR: Please check samplesheet -> {}\n{}: '{}'".format(
#             error, context.strip(), context_str.strip()
#         )
#     print(error_str)
#     sys.exit(1)



def build_ped(file_in, file_out):
    """
    The samplesheet follows the structure:
    sample,single_end,lane,fastq_1,fastq_2,gender,phenotype,paternal_id,maternal_id,case_id
    The constructed ped/fam file needs to contain (https://www.cog-genomics.org/plink/1.9/formats#fam)

    case_id, sample, paternal_id, maternal_id, gender, phenotype

    For an example samplesheet see:
    https://raw.githubusercontent.com/Clinical-Genomics/raredisease/feature/bwamem2/assets/samplesheet.csv
    """

    samplesheet = pd.read_csv(file_in)
    samplesheet['sample'] = samplesheet['sample'].str.split('_').str[0]
    samplesheet = samplesheet[['case_id','sample','paternal_id','maternal_id','gender','phenotype']]
    samplesheet = samplesheet.drop_duplicates()
    samplesheet.to_csv(file_out,index=False,header=False, sep=' ')

def main(args=None):
    args = parse_args(args)
    build_ped(args.FILE_IN, args.FILE_OUT)


if __name__ == "__main__":
    sys.exit(main())
