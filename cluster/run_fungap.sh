#!/bin/bash
#SBATCH -J fungap
#SBATCH -o fungap.o%j
#SBATCH -c 30
#SBATCH --mem=32G
#SBATCH -t 3-4:00:00

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=<your email>
set -e
set -u
set -o pipefail

#set local anaconda3 env located in project dir
set +eu
source ~/.bashrc

#set paths to prepare fungap correctly 
export PROJECT_DIR="/project/balan"
export FUNGAP_DIR="${PROJECT_DIR}/bin/FunGAP"
export SISTER_DIR="${PROJECT_DIR}/milky-white-mushoom/annotations/sister_orgs"

if [ $# -ne 4 ]
then
  echo "  Incorrect number of arguments  "
  echo "run_fungap.sh <a> <r1> <r2> <outdir>"
  echo "Arguments:"
  echo "  a: genome assembly in fasta format"
  echo "  r1: forward read of rna-seq data in fastq format"
  echo "  r2: reverse read of rna-seq data in fastq format"
  echo "  outdir: output directory"
  exit
fi


#get genome assembly and  rna reads
export assembly=$1; export r1=$2; export r2=$3;export out_dir=$4;

#prepare fungap
conda activate maker-env
export MAKER_DIR=$(dirname $(which maker))
conda activate fungap-env
cd $FUNGAP_DIR
./set_dependencies.py --pfam_db_path db/pfam/ --genemark_path external/gmes_linux_64/ --maker_path ${MAKER_DIR}


cd /project/balan/milky-white-mushoom/annotations/

#annotate with fungap
${FUNGAP_DIR}/fungap.py --output_dir ${out_dir}\
 --trans_read_1 ${r1} --trans_read_2 ${r2}\
 --genome_assembly ${assembly}\
 --augustus_species coprinus_cinereus\
 --sister_proteome ${SISTER_DIR}/prot_db.faa\
 --num_cores 30 --busco_dataset basidiomycota_odb10

#get out of fungap env
conda deactivate
#get out of maker env
conda deactivate
#get out of base env
conda deactivate
