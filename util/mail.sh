config_msmtp() {
    local mail_account=$1
    local mail_password=$2

    local config_file=~/.msmtprc
    if [ -s ${config_file} ]; then
        return 0
    fi

    sed -e "s/from/from ${mail_account}/; s/user/user ${mail_account}/; s/password/password ${mail_password}/" ${cur_dir}/msmtprc_template > ${config_file}
}
#
config_mutt() {
    local mail_account=$1
    local mail_realname=$2
    local msmtp_location=$(which msmtp)

    local config_file=~/.muttrc
    if [ -s ${config_file} ]; then
        return 0
    fi

    sed -e "s#set sendmail=#set sendmail=${msmtp_location}#; s/set from=/set from=\"${mail_account}\"/; s/set realname=/set realname=\"${mail_realname}\"/" ${cur_dir}/muttrc_template > ${config_file}
}
