source $(pwd)/../config.sh
source $(pwd)/../utils/log.sh
source $(pwd)/../utils/archive.sh

archive_tar ${tar_file}
archive_tar ${tar_file}  ${files_to_backup[@]}
