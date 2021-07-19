#
# Record a message to STDOUT and log_file
# Usage: log [error/info/debug] "message"
# Options:
#   - Set log_level option in config.sh
# Chain of Responsibility Pattern
#
_red_bg_white_fg="\033[41;37m"
_white_bg_black_fg="\033[47;30m"
_blue_bg_white_fg="\033[44;33m"
_plain="\033[0m"
# log_level corresponding number
_log_level=""
#
log() {
    if [ $# -ne 2 ]; then
        echo -e "${_red_bg_white_fg}""$(date '+%Y-%m-%d %H:%M:%S')" "[error]" "Call log() function with wrong number of parameters""${_plain}" | tee -a ${log_file}
        return 1
    fi
    # congfig log_level
    _log_level=$(echo "${log_level}" | sed -e 's/error/1/; s/info/2/; s/debug/3/')
    # param level
    local _level=$(echo "$1" | sed -e 's/error/1/; s/info/2/; s/debug/3/')
    _log_error "${_level}" "$2"
}
_log_error(){
    local _level=1
    if [ ${_level} -le ${_log_level} ]; then
        if [ ${_level} -eq $1 ]; then
            echo -e "${_red_bg_white_fg}""$(date '+%Y-%m-%d %H:%M:%S')" "[error]" "$2""${_plain}" | tee -a ${log_file}
        fi
    fi
    _log_info "$1" "$2"
}
_log_info(){
    local _level=2
    if [ ${_level} -le ${_log_level} ]; then
        if [ ${_level} -eq $1 ]; then
            echo -e "${_white_bg_black_fg}""$(date '+%Y-%m-%d %H:%M:%S')" "[info ]" "$2""${_plain}" | tee -a ${log_file}
        fi
    fi
    _log_debug "$1" "$2"
}
_log_debug(){
    local _level=3
    if [ ${_level} -le ${_log_level} ]; then
        if [ ${_level} -eq $1 ]; then
            echo -e "${_blue_bg_white_fg}""$(date '+%Y-%m-%d %H:%M:%S')" "[debug]" "$2""${_plain}" | tee -a ${log_file}
        fi
    fi
}
