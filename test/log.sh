# source $(pwd)/../config.sh

log_level=debug
log_file="./backup.log"

source $(pwd)/../utils/log.sh

log
log "这是一条信息"
log info info "这是一条信息"

log info "这是一条信息"
log error "这是一条错误"
log debug "这是一条调试"
