#
# Must run with root privileges, otherwise will exit with 126 code
#
root_required(){
    [ ${EUID} -ne 0 ] && echo "Error: This script must be run as root!" && exit 126
}
#
# Calculate folder or file size
#
calculate_size() {
    local file_name=$1
    local file_size=$(du -h --max-depth=0 ${file_name} 2>/dev/null | awk '{print $1}')
    if [ -z "${file_size}" ]; then
        echo "unknown"
    else
        echo "${file_size}"
    fi
}
#
# Get the number of files in ${folder} with ${suffix}
#
count_files() {
    local folder=$1
    local cur_dir=$(pwd)
    cd ${folder}
    # -t sort by modification time, newest first, to check if the sort correct
    local files=($(ls -t *))
    cd ${cur_dir}
    echo ${#files[@]}
}
#
# Get the oldest file in the folder, based on the filename: ${backup_prefix}-${file_date}".tgz
# ${file_date} is the time of creation of the file, example: homeserver-20201225-173039.tgz
# If encrypt file, file name will be like: homeserver-20201225-173039.tgz.enc
#
oldest_file(){
    local folder=$1
    local cur_dir=$(pwd)
    cd ${folder}
    # -t sort by modification time, newest first, to check if the sort correct
    local files=($(ls -t *))
    cd ${cur_dir}
    log info "All filtered files: ${files[*]}"

    local file_age=()
    local file
    local length
    local file_date
    local file_time
    local i
    for (( i=0; i < ${#files[@]}; i++ )); do
        # ${f: -19} extract file name suffix：20200825-184636.tgz
        file=${files[i]}
        log debug "file: ${file}"
        # to be compatible with 20201225-173039.tgz.enc, even more suffix, example:20201225-173039.tgz.enc.abc.edf
        length=$[$(echo "${file}" | gawk -F- '{print $NF}' | wc -L) + 9]
        file_date=$(echo ${file: -${length}} | cut -d- -f1)
        log debug "file_date: ${file_date}"
        file_time=$(echo ${file: -${length}} | cut -d- -f2 |cut -c 1-6)
        log debug "file_time: ${file_time}"
        file_age[i]=${file_date}${file_time}
        log debug "file_age[${i}]: ${file_age[i]}"
    done

    local j
    local temp
    for (( i=0; i < ${#file_age[@]}; i++ )); do
        for((j=i+1; j<${#file_age[@]}; j++))
        do
            if [ ${file_age[i]} -gt ${file_age[j]} ]; then
                temp=${file_age[i]}
                file_age[i]=${file_age[j]}
                file_age[j]=${temp}

                temp=${files[i]}
                files[i]=${files[j]}
                files[j]=${temp}
            fi
        done
    done
    log debug "after sort files: ${files[*]}"
    log debug "after sort file_age: ${file_age[*]}"

    log info "Find the oldest file in ${folder}: ${files}"
    # echo "${files[0]}"
    eval $2="${files[0]}"
}
#
# Openssl encrypt/decrypt, cipher is aes-256-cbc
#
openssl_encrypt(){
    local infile=$1
    local outfile=$2
    local pass=$3

    log info "Openssl encrypt start."
    openssl enc -e -aes-256-cbc -in "${infile}" -out "${outfile}" -pass pass:"${pass}"
    if [ $? -ne 0 ]; then
        log error "Openssl encrypt failed!"
        return 1
    else
        log info "Openssl encrypt completed."
        return 0
    fi
}
openssl_decrypt(){
    local infile=$1
    local outfile=$2
    local pass=$3

    openssl enc -d -aes-256-cbc -in "${infile}" -out "${outfile}" -pass pass:"${pass}"
}
#
# Zip encrypt/decrypt
#
zip_encrypt(){
    local infile=$1
    local outfile=$2
    local pass=$3

    log info "Zip encrypt start."
    # Deal with password with blank space by "${param}"
    zip -r "${outfile}" "${infile}" -P "${pass}"
    if [ $? -ne 0 ]; then
        log error "Zip encrypt failed!"
        return 1
    else
        log info "Zip encrypt completed."
        return 0
    fi
}
