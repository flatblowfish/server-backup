#
# Install dropbox_uploader
#
install_dropbox_uploader() {
    local temp_dir=$1
    mkdir -p ${temp_dir}
    if [ ! $(command -v "dropbox_uploader") ]; then
        log info "Installing dropbox_uploader."
        curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o "${temp_dir}/dropbox_uploader.sh"
        mv ${temp_dir}/dropbox_uploader.sh /usr/bin/dropbox_uploader
        chmod +x /usr/bin/dropbox_uploader
        log info "Installation of dropbox_uploader completed."
    fi
}
#
# Deprecated!
# Config Dropbox access token
# Fist time run dropbox_uploader will need to set access token.
# After access tocken is configured, Run dropbox_uploader will just show help message.
# So, expect needs "eof" branch.
#
config_dropbox_uploader_v1_deprecated() {
    local dropbox_access_tocken=$1
    /usr/bin/expect <<EOF
    set time 30
    spawn dropbox_uploader
    expect {
        eof {send_tty "Already configured.\r";exit}
        "*App key*" { send "${dropbox_access_tocken}\r"; exp_continue }
        "*Looks ok*" { send "y\r" }
    }
    expect eof
EOF
}
#
# Config Dropbox access privileges
# Fist time run dropbox_uploader will need to set App key、App secret、Access code. To get Access code, you can read README.
# After all key is configured, Run dropbox_uploader will just show help message. So, expect needs "eof" branch.
#
config_dropbox_uploader() {
    local cur_dir=${cur_dir}
    local oauth_app_key=$1
    local oauth_app_secret=$2
    local oauth_access_code=$3
    log debug "oauth_app_key: ${oauth_app_key}"
    log debug "oauth_app_secret: ${oauth_app_secret}"
    log debug "oauth_access_code: ${oauth_access_code}"

    local config_file=~/.dropbox_uploader
    if [ -s ${config_file} ]; then
        return 0
    fi

    /usr/bin/expect <<EOF
    set time 30
    spawn dropbox_uploader
    expect {
        -re {[^>].App key*} { send "${oauth_app_key}\r"; exp_continue }
        -re {[^>].App secret*} { send "${oauth_app_secret}\r"; exp_continue }
        "*access code*" { send "${oauth_access_code}\r"; exp_continue }
        "*Looks ok*" { send "y\r" }
    }
    expect eof
EOF
    log info "Dropbox config success."
}
#
# Check if Dropbox backup folder exists
#
check_dropbox_folder() {
    local dropbox_folder=$1
    # If list file, dropbox_uploader will throws an error
    dropbox_uploader list ${dropbox_folder}  &> /dev/null
    if [ $? -ne 0 ]; then
        return 1
    else
        return 0
    fi
}
#
# Check if Dropbox backup folder exists, otherwise make it
#
make_dropbox_folder() {
    local dropbox_folder=$1
    dropbox_uploader list ${dropbox_folder}  &> /dev/null
    if [ $? -ne 0 ]; then
        dropbox_uploader mkdir ${dropbox_folder}
    fi
}
#
# Dropbox upload file
#
dropbox_upload() {
    if [ $# -ne 2 ]; then
        log error "Call dropbox_upload() function with wrong number of parameters"
        return 1
    fi
    local dropbox_folder=$1
    local upload_file=$2

    check_dropbox_folder ${dropbox_folder}
    if [ $? -ne 0 ]; then
        log error "Attention! There is no dropbox_folder you designated!"
        return 1
    fi

    if [ -z "${upload_file}" ] || [ $(echo "${upload_file}" | sed 's/[[:space:]]//g' | wc -L) -eq 0 ]; then
        log error "Attention! Your upload_file parameter is empty!"
        return 1
    fi

    log info "Dropbox upload start."
    dropbox_uploader upload ${upload_file} ${dropbox_folder}/
    if [ $? -ne 0 ]; then
        log error "Tranferring file: ${upload_file} to Dropbox folder: ${dropbox_folder} failed!"
        return 1
    else
        log info "Tranferring file: ${upload_file} to Dropbox folder: ${dropbox_folder} completed."
        return 0
    fi
}
#
# Dropbox delete file
#
dropbox_delete() {
    if [ $# -ne 2 ]; then
        log error "Call dropbox_delete() function with wrong number of parameters"
        return 1
    fi
    local dropbox_folder=$1
    local delete_file=$2

    check_dropbox_folder ${dropbox_folder}
    if [ $? -ne 0 ]; then
        log error "Attention! There is no dropbox_folder you designated!"
        return 1
    fi

    # Empty parameter test, avoid deleting all the files! It is Danger!
    if [ -z "$1" ] || [ $(echo "${delete_file}" | sed 's/[[:space:]]//g' | wc -L) -eq 0 ]; then
        log error "Attention! Your delete_file parameter is empty!"
        return 1
    fi

    log info "Dropbox delete start."
    dropbox_uploader delete ${dropbox_folder}/${delete_file}
    if [ $? -ne 0 ]; then
        log error "Delete Dropbox file: ${delete_file} failed!"
        return 1
    else
        log info "Delete Dropbox file: ${delete_file} completed."
        return 0
    fi
}
