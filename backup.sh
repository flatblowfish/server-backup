#!/bin/bash
#
# Copyright (C) flatblowfish
# Github:   https://github.com/flatblowfish
# Website:  https://blog.maplesugar.top
#
# Description: Auto backup shell script
#
# Backup folders,files,MySQL databases
# Number based rolling backup, keep the number of backup files you designated both local and Dropbox
# Auto transfer to Dropbox
# Encrypt file with zip format
# GMail notice
#
############################################################
#
# Working directory.
#
cur_dir=$(cd -P "$(dirname "$0")" && pwd)
cd ${cur_dir}
#
include(){
    local include=${1}
    if [ -s ${cur_dir}/${include} ]; then
        source ${cur_dir}/${include}
    else
        echo "[fatal error]" "${cur_dir}/${include}" "can not be found!"
        exit 1
    fi
}
#
include config.sh
include util/log.sh
include util/install.sh
include util/archive.sh
include util/tool.sh
include util/mysql.sh
include util/dropbox.sh
include util/mail.sh
#
send_mail() {
    local subject
    if [ $1 = "succeed" ]; then
        subject="backup succeed"
    elif [ $1 = "failed" ]; then
        subject="backup failed"
    fi

    if [ -n "${mail_password}" ]; then
        local mail_body=$(sed -n "${log_start_line},\$p" "${log_file}" | sed -e 's!.\[41;37m!<p style="color:#E67E22">!; s!.\[47;30m!<p style="color:#9B59B6;">!; s!.\[44;33m!<p style="color:#1ABC9C;">!; s!.\[0m!</p>!' | gawk 'BEGIN {FS="\n"; RS=""; print "<html><body><h2 style=\"color:#34495E;\">Here is the backup log</h2>"} {print $0} END {print "<h4>Make by <a href=\"https://blog.maplesugar.top/\">maplesugar</a>, view project on <a href=\"https://github.com/flatblowfish/server-backup/\">Github</a>.</h4></body></html>"}')
        mutt ${mail_account} -s "${subject}" -e 'set content_type="text/html"'  <<EOF
            ${mail_body}
EOF
        if [ $? -ne 0 ]; then
            log error "Send mail failed!"
        else
            log info "Mail has been send."
        fi
    fi

    if [ $1 = "succeed" ]; then
        exit 0
    fi
    if [ $1 = "failed" ]; then
        exit 1
    fi
}
#
############################################################
# Main
############################################################
#
# Run as root
#
root_required
#
# Calculate start line
#
log_start_line=$[$(cat "${log_file}" | wc -l) + 1]
#
log info "Backup start!"
#
# STDERR redirects to log_file
#
exec 2>>${log_file}
#
#
start_time=$(date +%s)
#
# Config mail
#
if [ -n "${mail_password}" ]; then
    install_tools mutt msmtp
    config_msmtp "${mail_account}" "${mail_password}"
    config_mutt "${mail_account}" "${mail_realname}"
    log info "Mail config success."
fi
#
# Check if the folders exist
#
[ ! -d "${backup_dir}" ] && mkdir -p "${backup_dir}"
[ ! -d "${temp_dir}" ] && mkdir -p "${temp_dir}"
[ ! -d "${mysql_dump_folder}" ] && mkdir -p "${mysql_dump_folder}"
#
# Backup MySQL databases
#
if [ -z "${mysql_root_password}" ]; then
    log info "MySQL root password is not configured, MySQL backup skipped!"
else
    if [ ! "$(command -v "mysql")" ]; then
        install_tools mysql-client
    fi
    mysql_dump ${mysql_config_arr[@]} || send_mail failed
fi
#
# Tar Files_To_Backup list
#
archive_tar "${tar_file}"  "${mysql_dump_folder}" "${files_to_backup[*]}"
[ -d "${mysql_dump_folder}" ] && rm -rf "${mysql_dump_folder}"
#
#
# Encrypt archived backup file
#
if [ -n "${encrypt_password}" ]; then
    if [ ! "$(command -v "zip")" ]; then
        install_tools zip
    fi
    zip_encrypt "${tar_file}" "${encrypt_file}" "${encrypt_password}"
    [ -f "${tar_file}" ] && rm -rf "${tar_file}"
    tar_file="${encrypt_file}"
fi
#
# Dropbox upload file
#
install_tools curl expect
install_dropbox_uploader "${temp_dir}"
config_dropbox_uploader ${dropbox_oauth_app_key} ${dropbox_oauth_app_secret} ${dropbox_oauth_access_code}
make_dropbox_folder "${dropbox_folder}"
dropbox_upload "${dropbox_folder}" "${tar_file}" || send_mail failed
#
# Clean up old files, both delete local and cloud
#
if [ $(count_files "${backup_dir}") -gt ${number_to_keep} ]; then
    oldest_file "${backup_dir}" outdated_file
    dropbox_delete "${dropbox_folder}" "${outdated_file}" || send_mail failed
    rm "${backup_dir}"/"${outdated_file}"
fi
#
# Backup files size
#
log info "+-------------------------------------------------------------------"
log info "| Backup files size                                                 "
cd ${backup_dir}
backup_files=($(ls -t *))
for (( i=0; i < ${#backup_files[@]}; i++ )); do
    log info "| ${backup_files[i]} $(calculate_size ${backup_files[i]})"
done
cd ${cur_dir}
log info "+-------------------------------------------------------------------"
#
end_time=$(date +%s)
duration=$((end_time - start_time))
log info "Backup and transfer completed in ${duration} seconds."
#
# Send mail
#
send_mail succeed
