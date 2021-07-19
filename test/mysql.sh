source $(pwd)/../config.sh
source $(pwd)/../utils/log.sh
source $(pwd)/../utils/mysql.sh

mysql_dump ${mysql_config_arr[@]}
