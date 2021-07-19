#
# Install tools via apt-get
#
install_tools() {
    if [ $# -eq 0 ]; then
        log error "Call install_tools() function without arguments!"
        return 1
    fi

    local tools="$@"
    local tool
    apt-get -y update
    for tool in ${tools[@]}; do
        # command -v ：print a description of COMMAND，similar to the 'type', all are builtin commands
        if [ ! $(command -v ${tool}) ]; then
            log info "Installing ${tool}."
            apt-get -y install ${tool}
            if [ $? -eq 0 ]; then
                log info "Installation of ${tool} completed."
            else
                log error "Installation of ${tool} failed."
                return 1
            fi
        fi
    done
}
