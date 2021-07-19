############################################################
# log config
############################################################
#
# optional: debug/info/error
# For the first time, set it to debug to find errors.
#
log_level=debug
#
# Log file
#
log_file="${cur_dir}""/backup.log"
#
############################################################
# backup config
############################################################
#
# Backup folder, store backup fils
#
backup_dir="${cur_dir}""/backup-files"
#
# Temporary directory used during backup creation
#
temp_dir="${cur_dir}""/temp"
#
# Designated Folder or file to backup
#
files_to_backup[0]=
files_to_backup[1]=
files_to_backup[2]=
#
# Keep how many backup files
# When a new backup file completed, and the number of backup files exceeds number_to_keep, old backup files will be deleted
#
number_to_keep=3
#
# File date
#
file_date=$(date '+%Y%m%d-%H%M%S')
#
# Mark different server backups
# Also used in mail function to mark different backup notices
#
backup_prefix=""
#
tar_file="${backup_dir}/${backup_prefix}-${file_date}".tgz
#
############################################################
# MySQL config
############################################################
#
mysql_host=""
mysql_port=""
#
# Not dump MySQL databases by leaving it blank
#
mysql_root_password=""
#
# MySQL dump file name
#
mysql_dump_folder="${cur_dir}""/mysql-dump-${file_date}"
#
# A list of MySQL databases that will be backed up
# If you want backup ALL databases, leave it blank
#
mysql_database_name[0]=""
mysql_database_name[1]=""
#
# Put all parameters into an array
#
mysql_config_arr=(
${mysql_host}
${mysql_port}
${mysql_root_password}
${mysql_dump_folder}
${mysql_database_name[@]}
)
#
############################################################
# Dropbox config
############################################################
#
# Dropbox access keys
#
dropbox_oauth_app_key=
dropbox_oauth_app_secret=
dropbox_oauth_access_code=
#
# Dropbox folder to store backups
# For one Dropbox app, you can make many folders
#
dropbox_folder=""
#
############################################################
# Encrypt config
############################################################
#
# Encrypt password
# Not encrypt backup file by leaving it blank
#
encrypt_password=""
#
# Encrypt file name
#
encrypt_file="${tar_file}".zip
#
############################################################
# Mail config
############################################################
#
# Mail account
# Only support Gmail now
#
mail_account=""
#
# Mail password
# Not send mail by leaving it blank
#
mail_password=""
#
mail_realname=""
