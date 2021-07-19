#
# Dump MySQL databases
#
mysql_dump() {
    local mysql_args=($(echo "$@"))
    log debug "mysql_args: ${mysql_args[*]}"

    local mysql_host=${mysql_args[0]}
    log debug "mysql_host: ${mysql_host}"
    local mysql_port=${mysql_args[1]}
    log debug "mysql_port: ${mysql_port}"
    local mysql_root_password=${mysql_args[2]}
    log debug "mysql_root_password: ${mysql_root_password}"
    local mysql_dump_folder=${mysql_args[3]}
    log debug "mysql_dump_folder: ${mysql_dump_folder}"

    unset mysql_args[0]; unset mysql_args[1]; unset mysql_args[2]; unset mysql_args[3];
    # after unset, there still index in array
    # local files_to_backup=${tar_args}
    local mysql_database_name=($(echo "${mysql_args[@]}"))
    log debug "mysql_database_name: ${mysql_database_name[*]}"
    log debug "length of mysql_database_name: ${#mysql_database_name[@]}"

    mkdir -p ${mysql_dump_folder}

    log info "MySQL dump start."
    mysql -h${mysql_host} -P${mysql_port} -uroot -p"${mysql_root_password}" 2>/dev/null <<EOF
exit
EOF
    if [ $? -ne 0 ]; then
        log error "MySQL root password is incorrect. Please check it and try again."
        return 1
    fi

    if [ ${#mysql_database_name[@]} -eq 0 ]; then
        mysqldump -h${mysql_host} -P${mysql_port} -uroot -p"${mysql_root_password}" --all-databases > "${mysql_dump_folder}/all-databases.sql"
        if [ $? -ne 0 ]; then
            log error "MySQL all databases dump failed."
            return 1
        else
            log info "MySQL all databases dump completed. Dump File name: ${mysql_dump_folder}/all-databases.sql."
        fi
    else
        local db
        for db in ${mysql_database_name[@]}; do
            mysqldump -h${mysql_host} -P${mysql_port} -uroot -p"${mysql_root_password}" ${db} > "${mysql_dump_folder}/${db}.sql"
            if [ $? -ne 0 ]; then
                log error "MySQL database: [${db}] dump failed, please check database name."
                return 1
            else
                log info "MySQL database: [${db}] dump completed. Dump File name: ${mysql_dump_folder}/${db}.sql."
            fi
        done
    fi
    log info "MySQL dump completed."
}
