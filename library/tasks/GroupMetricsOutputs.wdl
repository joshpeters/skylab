task GroupQCOutputs {
  Array[File] picard_row_outputs
  Array[File] picard_table_outputs
  File hisat2_stats
  File hisat2_trans_stats
  File rsem_stats
  String output_name
  # Runtime
  String docker = "quay.io/humancellatlas/secondary-analysis-sctools:v0.3.0"
  Int mem = 2
  Int cpu = 1
  Int disk_space = 20
  Int preemptible = 5
  Int max_retries = 0
  
  meta {
    description: "This task will group the Picard metrics"
  }
  parameter_meta {
    picard_row_outputs: "array of files generated by Picard"
    picard_table_outputs: "array of files which contains table metrics generated by Picard."
    hisat2_stats: "statistics output of hisat2 alignment"
    hisat2_trans_stats:"statistics output of hisat2 transcriptome alignment"
    rsem_stats: "statistics output of rsem "
    output_name: "name output files"
    docker: "(optional) the docker image containing the runtime environment for this task"
    mem: "(optional) the amount of memory (MB) to provision for this task"
    cpu: "(optional) the number of cpus to provision for this task"
    disk_space: "(optional) the amount of disk space (GB) to provision for this task"
    preemptible: "(optional) if non-zero, request a pre-emptible instance and allow for this number of preemptions before running the task on a non preemptible machine"
    max_retries: "(optional) retry this number of times if task fails -- use with caution, see skylab README for details"
  }
 command {
    set -e
    GroupQCs -f ${sep=' ' picard_row_outputs}  -t Picard -o Picard_group
    GroupQCs -f ${hisat2_stats} -t HISAT2 -o hisat2
    GroupQCs -f ${hisat2_trans_stats} -t HISAT2 -o hisat2_trans
    GroupQCs -f ${rsem_stats} -t RSEM -o rsem
    GroupQCs -f Picard_group.csv hisat2.csv hisat2_trans.csv rsem.csv -t Core -o "${output_name}_QCs"
    GroupQCs -f ${sep=' ' picard_table_outputs} -t PicardTable -o "${output_name}"
    
}
  output{
    Array[File] group_files = glob("${output_name}_*.csv")
  }
  runtime {
    docker: docker
    memory: "${mem} GB"
    disks: "local-disk ${disk_space} HDD"
    cpu: cpu
    preemptible: preemptible
    maxRetries: max_retries
  }
}
