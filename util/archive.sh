#
# Archive folders and files using tar
#
archive_tar(){
    local tar_args=($(echo "$@"))
    log debug "tar_args: ${tar_args[*]}"

    local tar_file=${tar_args}
    log debug "tar_file: ${tar_file}"

    unset tar_args[0]
    # after unset, there still index in array
    # local files_to_backup=${tar_args}
    local files_to_backup=($(echo "${tar_args[@]}"))
    log debug "files_to_backup: ${files_to_backup[*]}"
    log debug "length of files_to_backup：${#files_to_backup[@]}"

    if [ ${#files_to_backup[@]} -eq 0 ]; then
        log error "Call tar_file() function without arguments! There is nothing to backup!"
        return 1
    fi

    log info "Tar file start."
    # tar command always warning: Removing leading '/' from member names, but the exit code still be 0
    log info "The complete tar command: tar -czf ${tar_file} ${files_to_backup[*]}"
    tar -czf ${tar_file} ${files_to_backup[@]}
    if [ $? -ne 0 ]; then
        log error "Tar backup files failed!"
        return 1
    else
        log info "Tar backup files completed."
        return 0
    fi
}
